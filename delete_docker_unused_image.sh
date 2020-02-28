#delete docker image for 1 week morethan unusing container
docker ps --filter status=exited | grep 'weeks ago' | awk '{print }' | xargs docker rm
