### cannot open shared object file 问题的解决
运行程序时提示 cannot open shared object file: ...，是因为找不到共享库，即.so文件，可通过如下方式设置共享库的搜索路径：
1. 编辑/etc/ld.so.conf文件，加上一行.so文件路径
2. 运行ldconfig，更新/etc/ld.so.cache
