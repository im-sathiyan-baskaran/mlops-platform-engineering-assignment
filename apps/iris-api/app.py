import os
import time

import joblib
from fastapi import FastAPI, Response
from pydantic import BaseModel, Field
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

MODEL_NAME = os.getenv("MODEL_NAME", "iris-classifier")
MODEL_VERSION = os.getenv("MODEL_VERSION", "dev")
bundle = joblib.load(os.getenv("MODEL_PATH", "/app/model.joblib"))
model, classes = bundle["model"], bundle["classes"]

PREDICTIONS = Counter(
    "model_predictions_total", "Predictions served",
    ["model_name", "model_version", "predicted_class"],
)
LATENCY = Histogram("model_inference_seconds", "Inference latency", ["model_name"])

app = FastAPI(title="iris-api")


class Features(BaseModel):
    sepal_length: float = Field(..., gt=0, lt=100)
    sepal_width: float = Field(..., gt=0, lt=100)
    petal_length: float = Field(..., gt=0, lt=100)
    petal_width: float = Field(..., gt=0, lt=100)


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/readyz")
def readyz():
    return {"status": "ready", "model": MODEL_NAME, "version": MODEL_VERSION}


@app.post("/predict")
def predict(f: Features):
    start = time.perf_counter()
    x = [[f.sepal_length, f.sepal_width, f.petal_length, f.petal_width]]
    idx = int(model.predict(x)[0])
    confidence = float(model.predict_proba(x)[0][idx])
    LATENCY.labels(MODEL_NAME).observe(time.perf_counter() - start)
    PREDICTIONS.labels(MODEL_NAME, MODEL_VERSION, classes[idx]).inc()
    return {"model": MODEL_NAME, "version": MODEL_VERSION,
            "prediction": classes[idx], "confidence": round(confidence, 4)}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
