## Build

```
git clone https://github.com/fztcjjl/metoo.git
cd metoo
make
```

## Test
将tools/metoo.sql导入到mysql<br />
配置etc/config.test文件中的mysql连接信息<br />

```
./tools/redis.sh
./tools/startlogin.sh
./tools/startgame.sh
lua client.lua login 80 1
lua client.lua roleinit 80 1 "metoo"
```

##About skynet
[https://github.com/cloudwu/skynet](https://github.com/cloudwu/skynet)<br /> 
