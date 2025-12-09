import ray
from ray import serve
import logging
import time
from typing import Dict, Any, Optional, List
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import torch

# --------------------------------------------------------------
# 1. CẤU HÌNH FASTAPI
# --------------------------------------------------------------
app = FastAPI(title="Qwen2.5-7B Ray Serve API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ray.serve")

class ChatRequest(BaseModel):
    message: str
    max_length: Optional[int] = 1024 # Qwen hỗ trợ context rất dài
    history: Optional[List[Dict[str, str]]] = []

# --------------------------------------------------------------
# 2. RAY SERVE DEPLOYMENT (Qwen2.5 - 4bit)
# --------------------------------------------------------------
@serve.deployment(
    name="qwen2.5-7b",
    num_replicas=1,
    ray_actor_options={
        "num_gpus": 1.0,
        "num_cpus": 2
    },
    max_ongoing_requests=10,
)
@serve.ingress(app)
class QwenServeDeployment:
    def __init__(self):
        logger.info("🚀 Initializing Qwen2.5-7B-Instruct...")
        self.fallback_mode = False
        
        try:
            from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig

            self.model_name = "Qwen/Qwen2.5-7B-Instruct"
            
            # Cấu hình 4-bit để chạy siêu nhẹ (chỉ tốn ~6-7GB VRAM)
            bnb_config = BitsAndBytesConfig(
                load_in_4bit=True,
                bnb_4bit_quant_type="nf4",
                bnb_4bit_use_double_quant=True,
                bnb_4bit_compute_dtype=torch.float16
            )

            logger.info(f"🔄 Loading tokenizer for {self.model_name}...")
            self.tokenizer = AutoTokenizer.from_pretrained(
                self.model_name,
                trust_remote_code=True
            )

            logger.info(f"🔄 Loading model {self.model_name} (4-bit)...")
            self.model = AutoModelForCausalLM.from_pretrained(
                self.model_name,
                quantization_config=bnb_config,
                device_map="auto",
                trust_remote_code=True,
                low_cpu_mem_usage=True
            )

            logger.info("✅ Qwen2.5-7B model loaded successfully!")

        except Exception as e:
            logger.error(f"❌ Model loading failed: {e}")
            self.fallback_mode = True
            self.error_msg = str(e)

    @app.post("/chat")
    async def chat(self, request: ChatRequest) -> Dict[str, Any]:
        if self.fallback_mode:
             return {"response": f"Error: {getattr(self, 'error_msg', 'Unknown')}", "status": "error"}

        try:
            # 1. Bắt đầu với System Prompt
            messages = [
                {"role": "system", "content": "You are Qwen, a helpful assistant."}
            ]

            # 2. Nối lịch sử chat (History) vào
            if request.history:
                messages.extend(request.history)
            
            # 3. Cuối cùng mới là câu hỏi hiện tại của User
            messages.append({"role": "user", "content": request.message})
            
            text = self.tokenizer.apply_chat_template(
                messages,
                tokenize=False,
                add_generation_prompt=True
            )
            
            model_inputs = self.tokenizer([text], return_tensors="pt").to(self.model.device)

            generated_ids = self.model.generate(
                model_inputs.input_ids,
                max_new_tokens=request.max_length,
                temperature=request.temperature,
                do_sample=True
            )
            
            # Lấy input length để cắt phần prompt đi, chỉ giữ lại câu trả lời mới
            generated_ids = [
                output_ids[len(input_ids):] for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
            ]

            response = self.tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]
            
            return {
                "response": response,
                "model": "Qwen2.5-7B-Instruct",
                "status": "success"
            }

        except Exception as e:
            logger.error(f"❌ Inference error: {e}")
            return {"response": str(e), "status": "error"}

    @app.get("/health")
    async def health_check(self) -> Dict[str, str]:
        return {"status": "healthy" if not self.fallback_mode else "fallback"}

# --------------------------------------------------------------
# 3. ENTRY POINT
# --------------------------------------------------------------
qwen_app = QwenServeDeployment.bind()

if __name__ == "__main__":
    serve.start(http_options={"host": "0.0.0.0", "port": 8000})
    serve.run(qwen_app, name="qwen2.5-7b", route_prefix="/")
    
    import time
    try:
        while True: time.sleep(10)
    except KeyboardInterrupt:
        pass
# test