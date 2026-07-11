#!/usr/bin/env bash

echo "===== CURRENT DIRECTORY ====="
pwd

echo "===== REQUIREMENTS FILE ====="
cat requirements.txt

pip install -r requirements.txt

echo "===== GUNICORN CHECK ====="
pip show gunicorn

python manage.py collectstatic --noinput
python manage.py migrate