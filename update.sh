#!/bin/bash

docker compose build
docker exec -it php composer update --no-dev
docker compose down
docker compose up -d
sleep 10
docker exec -it php ./maho migrate
docker exec -it php ./maho cache:flush
docker exec -it php ./maho index:reindex:all
