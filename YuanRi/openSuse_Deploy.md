### 安装Openresty

### 安装luarocks


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
