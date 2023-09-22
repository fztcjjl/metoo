## Build

```
git clone https://github.com/fztcjjl/metoo.git
cd metoo
make
```

## Test
将tools/metoo.sql导入到mysql<br />

```
./tools/redis.sh
./tools/startlogin.sh
./tools/startgame.sh
./skynet/3rd/lua/lua client.lua login 80 1
```

## About skynet
[https://github.com/cloudwu/skynet](https://github.com/cloudwu/skynet)<br /> 
