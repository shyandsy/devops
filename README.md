# Devops

Devops tool for self host server

## Usage

1. deploy redis

```shell
make redis {up}{down}{logs}{shell}{rm-volumes} 

# optional parameters
make redis up REDIS_PASSWORD=MySecret123 REDIS_PORT=6380
```

## Standard

- data store in HOST_DATA_DIR=/opt/service/*
