# Build
git clone https://github.com/fztcjjl/metoo.git<br />
cd metoo<br />
make
# Test
将tools/metoo.sql导入到mysql<br />
配置etc/config.test文件中的mysql连接信息<br />
启动redis<br />
./tools/redis.sh<br />
./skynet/skynet etc/config.test
#About skynet
[https://github.com/cloudwu/skynet](https://github.com/cloudwu/skynet)<br /> 
