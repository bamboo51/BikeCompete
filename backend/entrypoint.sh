#!/bin/sh
set -e

echo "Waiting for postgres..."
until pg_isready -h db -U "${POSTGRES_USER:-bike_user}"; do
  sleep 1
done

echo "Running migrations..."
alembic upgrade head

echo "Starting server..."
exec gunicorn --bind 0.0.0.0:5000 app.main:app
