#!/bin/bash

docker compose build
docker exec -it php composer update --no-dev
docker compose down
docker compose up -d
docker exec -it php ./maho cache:f
docker exec -it php ./maho index:reindex:all
