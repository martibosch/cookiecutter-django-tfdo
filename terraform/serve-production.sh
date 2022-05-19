#!/usr/bin/env bash
cd /home/ubuntu/app
docker-compose -f production.yml run --rm django python manage.py migrate
docker-compose -f production.yml up --build -d
