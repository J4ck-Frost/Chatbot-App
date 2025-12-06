# Ray GPU (CUDA 12.1) - bản mới nhất
FROM rayproject/ray:2.52.0-py310-gpu

WORKDIR /app

# Cài PyTorch CUDA 12.1 trước
RUN pip install --no-cache-dir \
    torch==2.5.1 \
    torchvision==0.20.1 \
    torchaudio==2.5.1 \
    --index-url https://download.pytorch.org/whl/cu121

# Cài libs phục vụ model + API
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn \
    pydantic \
    transformers==4.46.3 \
    accelerate==1.0.1 \
    sentencepiece \
    bitsandbytes==0.43.3

# Copy code
COPY . /app

# Entrypoint (có thể override bằng k8s args)
CMD ["python", "/app/ray-serve/qwen_serve.py"]
