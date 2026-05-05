# Works on both x86 and Raspberry Pi (ARM64/ARM32)
FROM python:3.11-slim

RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY alembic.ini .
COPY migrations/ ./migrations/
COPY app/ ./app/
COPY entrypoint.sh .
COPY seed.py .
RUN chmod +x entrypoint.sh

EXPOSE 5000

ENTRYPOINT ["./entrypoint.sh"]
