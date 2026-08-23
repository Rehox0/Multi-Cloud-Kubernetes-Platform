FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
ENV PYTHONPATH=/app/backend
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "backend.wsgi:application"]