#### Document Formats

- [lua-resty-libxl](https://github.com/bungle/lua-resty-libxl) — LuaJIT FFI-based LibXL (Excel) library for OpenResty
- [lua-resty-haru](https://github.com/bungle/lua-resty-haru) — LuaJIT FFI-based libHaru (PDF) library for OpenResty
- [lua-resty-hpdf](https://github.com/tavikukko/lua-resty-hpdf) — LuaJIT FFI-based libHaru (PDF) library for OpenResty

#### [](https://github.com/bungle/awesome-resty#image-formats)



### xlsxwriterlua已安装

https://xlsxwriterlua.readthedocs.io/getting_started.html#getting-started



luarocks install --lua-dir=/usr/local/openresty/luajit xlsxwriter --tree=deps --only-deps --local

### 

### 报错ZipWriter.lua:51: module 'zlib' not found:

#### 需要安装依赖lua-zlib

luarocks install lua-zlib --tree=deps



#### 遇到问题找不到zlib头文件，编译安装zlib后解决

wget http://www.zlib.net/zlib-1.2.12.tar.gz

tar -xvzf zlib-1.2.12.tar.gz

cd zlib-1.2.12

./configure --prefix=/usr/local/zlib

sudo make install


#### ZipWriter/binary_converter.lua:7: module 'struct' not found

luarocks install struct --lua-dir=/usr/local/openresty/luajit --tree=deps 






