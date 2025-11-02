FROM python:3.10-slim

WORKDIR /app

# Install required packages
RUN pip install fastapi uvicorn scikit-learn numpy

# Copy model code
COPY model_server.py .

# Expose port
EXPOSE 8000

# Run the application
CMD ["python", "model_server.py"]