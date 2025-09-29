# Devops

Devops tool for self host server

## Usage

1. deploy redis

```shell
make redis {up}{down}{logs}{shell}{rm-volumes} 

# optional parameters
make redis up REDIS_PASSWORD=MySecret123 REDIS_PORT=6380
```

2. deploy openresty

```shell
# install
make openresty install

# uninstall
make openresty uninstall

# clean
make openresty clean
```

## Standard

- data store in HOST_DATA_DIR=/opt/service/*
