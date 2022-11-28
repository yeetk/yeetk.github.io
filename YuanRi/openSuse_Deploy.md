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

### postgresql鉴权方式设置

`vim /var/lib/pgsql/data/pg_hba.conf`

```
# Database administrative login by Unix domain socket
local   all             postgres                                trust

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
```


### PostgreSQL初始密码设置

But if you want to have su postgres work, you would just need to have a password set for the user postgres. That can be achieved by running `passwd postgres` as root.

### 不设置postgres账号的密码直接访问psql
`sudo -u postgres psql`

### 设置远程连接postgresql

`vim /var/lib/pgsql/data/postgresql.conf`

`listen_addresses=’*’`

vim /var/lib/pgsql/data/pg_hba.conf

`host    all             ordsys_admin    0.0.0.0/0               md5`

https://www.postgresql.org/docs/current/auth-pg-hba-conf.html


##
###
####
