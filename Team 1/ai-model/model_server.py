from fastapi import FastAPI
from pydantic import BaseModel
import numpy as np
import pickle
import logging
from sklearn.linear_model import LinearRegression
from sklearn.datasets import make_regression
import uvicorn

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Simple AI Model API", version="1.0.0")

# Initialize a simple model
logger.info("Initializing AI model...")
X, y = make_regression(n_samples=100, n_features=1, noise=10, random_state=42)
model = LinearRegression()
model.fit(X, y)
logger.info("Model trained successfully!")

class PredictionRequest(BaseModel):
    features: list[float]

class PredictionResponse(BaseModel):
    prediction: float
    model_info: str

@app.get("/")
async def root():
    return {
        "message": "Simple AI Model API", 
        "status": "running",
        "model": "Linear Regression",
        "endpoints": ["/predict", "/health", "/model-info"]
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "model": "loaded"}

@app.get("/model-info")
async def model_info():
    return {
        "model_type": "Linear Regression",
        "features": 1,
        "trained_samples": 100,
        "coefficients": model.coef_.tolist(),
        "intercept": float(model.intercept_)
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    try:
        # Convert input to numpy array
        X_input = np.array(request.features).reshape(-1, 1)
        
        # Make prediction
        prediction = model.predict(X_input)[0]
        
        logger.info(f"Prediction made for input {request.features}: {prediction}")
        
        return PredictionResponse(
            prediction=float(prediction),
            model_info="Linear Regression model"
        )
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        raise Exception(f"Prediction failed: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)