# Check_redis

在redis配置了密码的情况下，若仍使用keepalived的检测redis存活的脚本，则需要在脚本中明文写入redis的密码，因此设计了使用go编写连接redis的检测程序，编译为可执行文件，以确保密码不会泄露。

需要在go环境下复制该代码，且确保go调用模块开启
```
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```
下载go-redis库
```
go get github.com/go-redis/redis/v8
```
之后直接编译即可，得到可执行命令check_redis
```
go build check_redis.go
```

当redis启动时返回`PONG`，当redis未启动时返回`DEAD`