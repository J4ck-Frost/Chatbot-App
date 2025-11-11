import ray
from ray import serve
import logging
import time
from typing import Dict, Any
import asyncio

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@serve.deployment(
    name="phi3-model",
    num_replicas=1,
    ray_actor_options={
        "num_gpus": 1.0,
        "num_cpus": 2
    },
    max_concurrent_queries=5,
)
class Phi3ServeDeployment:
    def __init__(self):
        """Initialize Phi3-mini model on GPU worker via Ray Serve"""
        logger.info("🚀 Initializing Phi3-mini model via Ray Serve...")
        
        # Install required packages
        import subprocess
        import sys
        import site
        
        try:
            # Add user site-packages to path for Ray workers
            user_site_packages = site.getusersitepackages()
            if user_site_packages not in sys.path:
                sys.path.insert(0, user_site_packages)
                
            logger.info("📦 Installing PyTorch with CUDA support...")
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", "--no-cache-dir",
                "torch", "torchvision", "torchaudio", 
                "--index-url", "https://download.pytorch.org/whl/cu121"
            ])
            
            logger.info("📦 Installing transformers and dependencies...")
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", "--no-cache-dir",
                "transformers", "accelerate", "sentencepiece", "bitsandbytes"
            ])
            logger.info("✅ Package installation completed!")
            
        except Exception as e:
            logger.error(f"❌ Package installation failed: {e}")
            self.fallback_mode = True
            return
        
        # Initialize model
        try:
            import torch
            from transformers import AutoTokenizer, AutoModelForCausalLM
            
            self.model_name = "microsoft/Phi-3-mini-4k-instruct"
            
            logger.info(f"🔄 Loading tokenizer for {self.model_name}...")
            self.tokenizer = AutoTokenizer.from_pretrained(
                self.model_name,
                trust_remote_code=True,
                cache_dir="/tmp/model_cache"
            )
            
            logger.info(f"🔄 Loading model {self.model_name} on GPU...")
            self.model = AutoModelForCausalLM.from_pretrained(
                self.model_name,
                trust_remote_code=True,
                torch_dtype=torch.float16,
                device_map="auto",
                cache_dir="/tmp/model_cache",
                low_cpu_mem_usage=True
            )
            
            # Set pad token
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            logger.info("✅ Phi3-mini model loaded successfully via Ray Serve!")
            logger.info(f"🎯 Model device: {next(self.model.parameters()).device}")
            logger.info(f"💾 GPU memory allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB")
            
            self.fallback_mode = False
            
        except Exception as e:
            logger.error(f"❌ Model loading failed: {e}")
            self.fallback_mode = True

    async def __call__(self, request) -> Dict[str, Any]:
        """Handle inference requests"""
        # Handle both HTTP requests and direct dict inputs
        if hasattr(request, 'json'):
            # HTTP request from Ray Serve
            data = await request.json()
        else:
            # Direct dict input
            data = request
            
        message = data.get("message", "")
        max_length = data.get("max_length", 200)
        
        logger.info(f"💬 Processing chat request: {message[:50]}...")
        
        start_time = time.time()
        
        try:
            if self.fallback_mode:
                response = f"[Fallback] You asked: '{message}'. Model is not available, but Ray Serve is responding!"
            else:
                response = await self._generate_response(message, max_length)
                
            processing_time = time.time() - start_time
            logger.info(f"✅ Chat response generated in {processing_time:.3f}s")
            
            return {
                "response": response,
                "processing_time": processing_time,
                "model_status": "fallback" if self.fallback_mode else "ready",
                "served_by": "ray-serve"
            }
            
        except Exception as e:
            logger.error(f"❌ Error during inference: {e}")
            return {
                "response": f"Error: {str(e)}",
                "processing_time": time.time() - start_time,
                "model_status": "error",
                "served_by": "ray-serve"
            }

    async def _generate_response(self, message: str, max_length: int = 200) -> str:
        """Generate response using Phi3 model"""
        import torch
        
        # Format prompt
        # prompt = f"User: {message}\nAssistant:"
        prompt = message
        
        # Tokenize
        inputs = self.tokenizer.encode(prompt, return_tensors="pt", truncation=True, max_length=1024)
        inputs = inputs.to(next(self.model.parameters()).device)
        
        # Generate
        with torch.no_grad():
            outputs = self.model.generate(
                inputs,
                max_new_tokens=min(max_length, 150),
                temperature=0.7,
                do_sample=True,
                pad_token_id=self.tokenizer.eos_token_id,
                eos_token_id=self.tokenizer.eos_token_id,
                repetition_penalty=1.1
            )
        
        # Decode response
        full_response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        response = full_response[len(prompt):].strip()
        
        return response

    async def health_check(self) -> bool:
        """Health check for Ray Serve"""
        return not self.fallback_mode


# Ray Serve application
phi3_app = Phi3ServeDeployment.bind()

if __name__ == "__main__":
    # Connect to Ray cluster
    try:
        ray.init(address='ray://ray-cluster-head-svc:10001', ignore_reinit_error=True)
        logger.info("🔗 Connected to Ray cluster!")
        logger.info(f"📊 Cluster resources: {ray.cluster_resources()}")
    except Exception as e:
        logger.error(f"❌ Failed to connect to Ray: {e}")
        exit(1)
    
    # Start Ray Serve with default settings
    logger.info("🚀 Starting Ray Serve deployment...")
    serve.start()
    
    # Deploy the main Phi3 model
    logger.info("📦 Deploying Phi3 model...")
    serve.run(phi3_app, name="phi3-model", route_prefix="/")
    
    # Keep the service running
    logger.info("✅ Ray Serve deployment started successfully!")
    logger.info("🔄 Service is now running and ready to accept requests...")
    
    import time
    try:
        while True:
            time.sleep(10)
            logger.info("💓 Service heartbeat - still running...")
    except KeyboardInterrupt:
        logger.info("🛑 Service shutdown requested")
        serve.shutdown()
        ray.shutdown()