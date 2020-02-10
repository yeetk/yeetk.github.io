# Ubuntu 16.04 安装显卡驱动后循环登录和无法设置分辨率的一种解决方案

seniusen
获取更多精彩，请关注公众号「seniusen」！

## 1. 安装环境

电脑：MSI GP63
显卡：GeForce GTX 1070
系统：Ubuntu 16.04
驱动版本：NVIDIA 384.130

## 2. 循环登录

如果按照这篇文章Ubuntu 16.04 安装 CUDA、CUDNN 和 GPU 版本的 TensorFlow 一般步骤总结中说的直接在设置中安装驱动的话，就会遇到在登录界面循环登录的问题。

于是我们转而利用从官网下载的 run 文件来安装，而驱动的版本则选择和在设置中附加驱动里看到的一样。

在 BIOS 里面关闭快速启动和安全启动
进入 Ubuntu 系统，Ctrl+Alt+F1 进入 tty1 模式
输入用户名和密码进行登录
关闭图形界面sudo service lightdm stop
给 run 文件赋予执行权限sudo chmod +x NVIDIA*.run(代表下载的安装文件)
sudo ./NVIDIA*.run -no-x-check -no-nouveau-check -no-opengl-files(避免循环登陆), 中间有警告的话选继续安装，不认证
打开图形界面sudo service lightdm start
重启

按照这个方法安装驱动后可以正常登录进系统，运行nvidia-smi命令也可以看到显卡信息，但在设置中依然只有一个 800*600 的分辨率选项。

## 3. 无法设置分辨率

具体表现：设置里分辨率只有一个选项；设置里电脑详情看不到独立英伟达显卡；nvidia-settings无法打开设置；

设置xrandr:
sudo vim /etc/profile

xrandr报错 Failed to get size of gamma for output default。

暂时的解决方法：

sudo gedit /etc/default/grub
在文件中添加以下两行：

`GRUB_GFXMODE=1920x1080`
`GRUB_GFXPAYLOAD_LINUX=1920x1080`

sudo update-grub
重启

按照这个方法设置里分辨率仍然只有一个选项 1920*1080，电脑详情里仍然看不到英伟达显卡，只能先将就用着，还好不影响 CUDA 以及深度学习框架的使用。
