#!/usr/bin/bash


docker system df

docker system prune -a --volumes

docker builder prune -a -f

docker system df
