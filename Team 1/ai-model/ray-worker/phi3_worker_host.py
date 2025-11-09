import ray
import logging
import time
import asyncio
from typing import Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# FastAPI app
app = FastAPI(
    title="Phi3-Mini Unified API",
    description="Phi3-mini model with FastAPI - unified service",
    version="1.0.0"
)

# Global variables for API
model_actor = None
ray_connected = False

# Pydantic models for API
class ChatRequest(BaseModel):
    message: str
    max_length: Optional[int] = 200

class ChatResponse(BaseModel):
    response: str
    processing_time: float
    model_status: str

class StatusResponse(BaseModel):
    ray_connected: bool
    model_loaded: bool
    cluster_info: dict
    gpu_info: dict

# Connect to Ray cluster
try:
    ray.init(address='ray://ray-cluster-head-svc:10001', ignore_reinit_error=True)
    logger.info("Connected to Ray cluster!")
    logger.info(f"Cluster resources: {ray.cluster_resources()}")
except Exception as e:
    logger.error(f"Failed to connect to Ray: {e}")
    exit(1)

# Ray remote class for Phi3-mini hosted directly on worker
@ray.remote(num_gpus=1.0, num_cpus=1.5)  # Use the full GPU worker resource
class Phi3MiniWorkerModel:
    def __init__(self):
        """Initialize Phi3-mini model directly on Ray worker"""
        logger.info("Loading Phi3-mini model on Ray worker...")
        
        # Install required packages
        import subprocess
        import sys
        
        try:
            # Add user site-packages to path for Ray workers
            import site
            user_site_packages = site.getusersitepackages()
            if user_site_packages not in sys.path:
                sys.path.insert(0, user_site_packages)
            
            logger.info("Installing PyTorch with CUDA support...")
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", "--no-cache-dir",
                "torch", "torchvision", "torchaudio", 
                "--index-url", "https://download.pytorch.org/whl/cu121"
            ])
            
            logger.info("Installing transformers and dependencies...")
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", "--no-cache-dir",
                "transformers", "accelerate", "sentencepiece", "bitsandbytes"
            ])
            logger.info("Package installation completed!")
        except Exception as e:
            logger.error(f"Package installation failed: {e}")
            self.fallback_mode = True
            return
        
        # Import and initialize model
        try:
            import torch
            from transformers import AutoTokenizer, AutoModelForCausalLM
            
            self.model_name = "microsoft/Phi-3-mini-4k-instruct"
            
            logger.info(f"Loading tokenizer for {self.model_name}...")
            self.tokenizer = AutoTokenizer.from_pretrained(
                self.model_name,
                trust_remote_code=True,
                cache_dir="/tmp/model_cache"
            )
            
            logger.info(f"Loading model {self.model_name} on GPU...")
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
            
            logger.info("Phi3-mini model loaded successfully on Ray worker!")
            logger.info(f"Model device: {next(self.model.parameters()).device}")
            logger.info(f"GPU memory allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB")
            
            self.fallback_mode = False
            
        except Exception as e:
            logger.error(f"Model loading failed: {e}")
            self.fallback_mode = True
    
    def chat(self, message: str, max_length: int = 200):
        """Generate chat response"""
        try:
            if self.fallback_mode:
                return f"[Fallback] You asked: '{message}'. Model is not available, but Ray worker is responding!"
            
            import torch
            
            logger.info(f"Generating response for: {message[:50]}...")
            
            # Format prompt
            prompt = f"User: {message}\nAssistant:"
            
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
            
            if not response:
                response = "I understand your question, but I'm having trouble generating a response right now."
            
            logger.info(f"Generated response: {response[:50]}...")
            return response
            
        except Exception as e:
            logger.error(f"Chat generation error: {e}")
            return f"Sorry, I encountered an error: {str(e)}"
    
    def get_status(self):
        """Get model status"""
        try:
            if self.fallback_mode:
                return {
                    "status": "fallback_mode",
                    "model": "unavailable",
                    "gpu_available": False,
                    "message": "Model failed to load, using fallback responses"
                }
            
            import torch
            return {
                "status": "ready",
                "model": self.model_name,
                "gpu_available": torch.cuda.is_available(),
                "gpu_memory_allocated": f"{torch.cuda.memory_allocated() / 1024**3:.2f} GB",
                "device": str(next(self.model.parameters()).device),
                "message": "Phi3-mini model loaded and ready on Ray worker"
            }
        except Exception as e:
            return {"status": "error", "error": str(e)}

# Connect to Ray cluster
try:
    ray.init(address='ray://ray-cluster-head-svc:10001', ignore_reinit_error=True)
    logger.info("Connected to Ray cluster!")
    logger.info(f"Cluster resources: {ray.cluster_resources()}")
except Exception as e:
    logger.error(f"Failed to connect to Ray: {e}")
    exit(1)

# Initialize the model on Ray worker
logger.info("Creating Phi3-mini model actor on Ray worker...")
phi3_model = Phi3MiniWorkerModel.remote()
model_actor = phi3_model  # For API use

# API startup and shutdown events
@app.on_event("startup")
async def startup_event():
    """API startup - model is already initialized"""
    global ray_connected, model_actor
    ray_connected = True
    model_actor = phi3_model
    logger.info("✅ FastAPI startup complete - model ready!")

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on API shutdown"""
    if ray.is_initialized():
        ray.shutdown()
        logger.info("Ray connection closed")

# API Endpoints
@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "Phi3-Mini Unified API",
        "version": "1.0.0",
        "ray_connected": ray_connected,
        "model_loaded": model_actor is not None,
        "endpoints": {
            "chat": "POST /chat - Chat with Phi3-mini",
            "status": "GET /status - System status", 
            "health": "GET /health - Health check",
            "docs": "GET /docs - API documentation"
        }
    }

@app.get("/health")
async def health():
    """Health check"""
    return {
        "status": "healthy",
        "ray_connected": ray_connected,
        "model_available": model_actor is not None,
        "timestamp": time.time()
    }

@app.get("/status", response_model=StatusResponse)
async def get_status():
    """Get detailed system status"""
    try:
        cluster_info = {}
        gpu_info = {}
        model_loaded = False
        
        if ray_connected:
            cluster_info = {
                "resources": ray.cluster_resources(),
                "nodes": len(ray.nodes()),
                "status": "connected"
            }
        
        if model_actor:
            model_status = await asyncio.get_event_loop().run_in_executor(
                None, lambda: ray.get(model_actor.get_status.remote())
            )
            model_loaded = model_status.get("status") == "ready"
            gpu_info = {
                "gpu_available": model_status.get("gpu_available", False),
                "gpu_memory": model_status.get("gpu_memory_allocated", "Unknown"),
                "device": model_status.get("device", "Unknown")
            }
        
        return StatusResponse(
            ray_connected=ray_connected,
            model_loaded=model_loaded,
            cluster_info=cluster_info,
            gpu_info=gpu_info
        )
        
    except Exception as e:
        return StatusResponse(
            ray_connected=False,
            model_loaded=False,
            cluster_info={"error": str(e)},
            gpu_info={}
        )

@app.post("/chat", response_model=ChatResponse)
async def chat_with_model(request: ChatRequest):
    """Chat with Phi3-mini model"""
    if not ray_connected or not model_actor:
        raise HTTPException(status_code=503, detail="Model not available")
    
    start_time = time.time()
    
    try:
        logger.info(f"💬 Processing chat request: {request.message[:50]}...")
        
        # Send message to model actor
        response = await asyncio.get_event_loop().run_in_executor(
            None, 
            lambda: ray.get(model_actor.chat.remote(request.message, request.max_length))
        )
        
        processing_time = time.time() - start_time
        
        logger.info(f"✅ Chat response generated in {processing_time:.3f}s")
        
        return ChatResponse(
            response=response,
            processing_time=processing_time,
            model_status="ready"
        )
        
    except Exception as e:
        processing_time = time.time() - start_time
        logger.error(f"❌ Chat error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Chat processing failed: {str(e)}"
        )

# Wait for initialization
logger.info("Waiting for model initialization...")
try:
    status = ray.get(phi3_model.get_status.remote())
    logger.info(f"Model status: {status}")
except Exception as e:
    logger.error(f"Model initialization failed: {e}")

# Example usage function for direct testing
def chat_with_model(message: str):
    """Simple function to chat with the model"""
    try:
        response = ray.get(phi3_model.chat.remote(message))
        return response
    except Exception as e:
        return f"Error: {e}"

# Main execution
if __name__ == "__main__":
    import sys
    
    # Check if we should run as API server or interactive mode
    if len(sys.argv) > 1 and sys.argv[1] == "--api":
        logger.info("🌐 Starting FastAPI server...")
        uvicorn.run(app, host="0.0.0.0", port=8000)
    else:
        logger.info("🤖 Starting in interactive mode...")
        
        print("=" * 60)
        print("🤖 Phi3-mini Model Running on Ray Worker")
        print("💡 Use '--api' argument to start as web API server")
        print("=" * 60)
        
        # Get status
        try:
            status = ray.get(phi3_model.get_status.remote())
            print(f"Status: {status}")
            print()
        except Exception as e:
            print(f"Status check failed: {e}")
        
        # Interactive chat
        print("Type 'quit' to exit")
        while True:
            try:
                user_input = input("\nYou: ").strip()
                if user_input.lower() in ['quit', 'exit', 'q']:
                    break
                
                if user_input:
                    print("Assistant: ", end="", flush=True)
                    response = chat_with_model(user_input)
                    print(response)
                    
            except KeyboardInterrupt:
                print("\nGoodbye!")
                break
            except Exception as e:
                print(f"Error: {e}")
        
        # Cleanup
        ray.shutdown()
        print("Ray connection closed.")