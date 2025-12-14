import ray
from ray import serve
import logging
import time
import os
from typing import Dict, Any, Optional, List
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import torch
from huggingface_hub import snapshot_download
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig

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
    max_length: Optional[int] = 1024 
    history: Optional[List[Dict[str, str]]] = []
    temperature: Optional[float] = 0.7

# --------------------------------------------------------------
# 2. RAY SERVE DEPLOYMENT (Qwen2.5 - 4bit)
# --------------------------------------------------------------
@serve.deployment(
    name="qwen2.5-7b",
    # Autoscaling config (Tùy chọn: Scale to Zero để tiết kiệm tiền)
    autoscaling_config={
        "min_replicas": 1,
        "max_replicas": 2,
        "target_num_ongoing_requests_per_replica": 5,
        "downscale_delay_s": 300,
        "upscale_delay_s": 10,
    },
    ray_actor_options={
        "num_gpus": 1.0,
        "num_cpus": 2
    },
    max_ongoing_requests=10,
)
@serve.ingress(app)
class QwenServeDeployment:
    def __init__(self):
        logger.info("🚀 Initializing Qwen2.5-7B-Instruct with Runtime Download...")
        self.fallback_mode = False
        
        try:
            # 1. Cấu hình đường dẫn và tên model
            self.model_id = "Qwen/Qwen2.5-7B-Instruct"
            # Thư mục này sẽ được mount từ PVC vào
            self.local_dir = "/data/models/Qwen2.5-7B-Instruct"

            # 2. Cấu hình 4-bit (QUAN TRỌNG: Để chạy nhẹ RAM)
            bnb_config = BitsAndBytesConfig(
                load_in_4bit=True,
                bnb_4bit_quant_type="nf4",
                bnb_4bit_use_double_quant=True,
                bnb_4bit_compute_dtype=torch.float16
            )

            # 3. Tải Model từ HuggingFace (Nếu chưa có trong PVC)
            if not os.path.exists(self.local_dir):
                logger.info(f"Downloading model to {self.local_dir}...")
            else:
                logger.info(f"Model found in cache: {self.local_dir}")

            snapshot_download(
                repo_id=self.model_id,
                local_dir=self.local_dir,
                local_dir_use_symlinks=False, # Quan trọng cho PVC
                # token=os.environ.get("HF_TOKEN") # Bỏ comment nếu dùng model Private
            )

            logger.info(" Model downloaded/checked. Loading into GPU...")

            # 4. Load Model từ thư mục Local
            self.tokenizer = AutoTokenizer.from_pretrained(
                self.local_dir, 
                trust_remote_code=True
            )
            
            self.model = AutoModelForCausalLM.from_pretrained(
                self.local_dir,
                quantization_config=bnb_config, # Đã sửa lại đúng cú pháp
                device_map="auto",
                trust_remote_code=True,
                low_cpu_mem_usage=True
            )

            logger.info("Qwen2.5-7B loaded successfully!!")

        except Exception as e:
            logger.error(f"Init failed: {e}")
            self.fallback_mode = True
            self.error_msg = str(e)

    @app.post("/chat")
    async def chat(self, request: ChatRequest) -> Dict[str, Any]:
        if self.fallback_mode:
             return {"response": f"System Error: {getattr(self, 'error_msg', 'Unknown')}", "status": "error"}

        try:
            messages = [
                {"role": "system", "content": "You are Qwen, a helpful assistant."}
            ]

            if request.history:
                messages.extend(request.history)
            
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
                temperature=request.temperature, # Lấy từ request (đã có default 0.7)
                do_sample=True
            )
            
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
            logger.error(f"Inference error: {e}")
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