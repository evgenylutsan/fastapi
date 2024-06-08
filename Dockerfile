FROM python:3.11-slim

RUN mkdir /app

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--workers", "1","--worker-class", "uvicorn.workers.UvicornWorker", "--bind=0.0.0.0:8000"]

