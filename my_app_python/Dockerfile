FROM python:3.11-slim

WORKDIR /app

# cpoy
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# boto3
RUN pip install --no-cache-dir boto3

# copy
COPY . .

# 🔥test
RUN echo "force rebuild v2"

EXPOSE 5000

CMD ["python", "app.py"]