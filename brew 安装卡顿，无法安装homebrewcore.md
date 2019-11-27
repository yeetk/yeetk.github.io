# brew 安装卡顿，无法安装homebrewcore

2019-04-18 15:11:28 [那一年-漫天雪](https://me.csdn.net/winter199) 阅读数 209

版权声明：本文为博主原创文章，遵循[ CC 4.0 BY-SA ](http://creativecommons.org/licenses/by-sa/4.0/)版权协议，转载请附上原文出处链接和本声明。 本文链接：https://blog.csdn.net/winter199/article/details/89379352

cd ~
 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install >> brew_install
vim brew_install 

BREW_REPO = "https://github.com/Homebrew/brew".freeze
CORE_TAP_REPO = "https://github.com/Homebrew/homebrew-core".freeze
换为

BREW_REPO = “https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git”.freeze
CORE_TAP_REPO = “https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git”.freeze
\#就是“BREW_REPO”和“CORE_TAP_REPO”这两项，将其修改为清华的镜像
 

/usr/local/bin/ruby ~/brew_install
安装brew，在安装的时候，会卡在安装homebrewcore 界面，

此时，直接git clone homebrewcore到homebrew里面
sudo git clone git://mirrors.ustc.edu.cn/homebrew-core.git/  /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core

或者清华大学镜像： sudo git clone https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core

大功告成。