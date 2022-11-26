### 安装Openresty

### 安装luarocks

### 解决安装OrdSys依赖项中xml包的错误
gcc: error trying to exec 'cc1plus': execvp: 没有那个文件或目录
```
zypper in gcc-c++
```

### 安装PostgreSQL
```
sudo zypper addrepo http://download.opensuse.org/repositories/server:database:postgresql/openSUSE_Leap_15.3/ PostgreSQL
sudo zypper refresh
sudo zypper in postgresql postgresql-server postgresql-contrib
```

### 对于 15.3，请以根用户 root 运行下面命令：
```
zypper addrepo https://download.opensuse.org/repositories/server:database:postgresql/15.3/server:database:postgresql.repo
zypper refresh
zypper install pgadmin4
```

### 查询监听端口
lsof -i -nP

### Pgadmin4远程无法访问，本地正常
vim /usr/lib/python3.6/site-packages/pgadmin4-web/config_local.py

替换

#DEFAULT_SERVER = '127.0.0.1'

`
DEFAULT_SERVER = '0.0.0.0'
`

service pgadmin4 restart
