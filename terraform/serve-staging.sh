#!/usr/bin/env bash
cd /home/ubuntu/app
docker-compose -f production.yml -f staging.yml run --rm django python manage.py migrate
docker-compose -f production.yml -f staging.yml up --build -d
