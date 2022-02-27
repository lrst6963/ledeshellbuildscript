#!/bin/bash
red='\033[31m'
green='\033[32m'
een='\033[0m'
blue='\033[34m'

pause(){
    get_char() {
        SAVEDSTTY=$(stty -g)
        stty -echo
        stty raw
        dd if=/dev/tty bs=1 count=1 2>/dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }

    if [ -z "$1" ]; then
        echo '按任意键继续...'
    else
        echo -e "$1"
    fi
    get_char
}

gitpull(){
git pull ~/lede/
git pull ~/lede/package/small-package/
git pull ~/lede/package/feeds/luci/luci-theme-neobird/
}

scriupda(){
./scripts/feeds update -a && ./scripts/feeds install -a
}

startmake(){
make -j12 V=s
if [ $? -ne 0 ];then
	echo
	echo "编译出错！"
	echo
else
	echo
	echo "编译成功！"
	echo
fi
}

cleartmp(){
echo -e "$red 确定清理？(输入y执行！): $een\c"
read clearyes
if [ $clearyes == "y" ];then
	make clean && rm -rf ~/lede/tmp/
else
	exit
fi
}

reconfig(){
echo -e "$red 确定重新配置？(输入y执行！): $een\c"
read reconfigyes
if [ $reconfigyes == "y" ];then
	rm -rf .config
	make menuconfig
else
	exit
fi
}

gitclone(){
git clone https://github.com/coolsnowwolf/lede.git ~/
git clone https://github.com/kenzok8/small-package ~/lede/package/small-package
git clone https://github.com/thinktip/luci-theme-neobird.git ~/lede/package
}

buildtools(){
sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync
}

opt(){
	echo -e "
	
$red ！！该脚本请在 ~/lede/ 目录下执行！！ $een

	
		1.更新源码(git pull)

		2.更新组件(./scripts/feeds update -a && ./scripts/feeds install -a)

		3.更新配置(make menuconfig)

		4.下载编译库源码(make download)

		5.开始编译(make -j12 V=s)
		
		6.清理编译文件(make clean && rm tmp)
		
		7.重新配置(restart make config)
		
		8.退出脚本(Exit.)
		
		9.下载源码(git clone)
		
		10.安装编译工具
		
		
$red ！！该脚本请在 ~/lede/ 目录下执行！！ $een

	"
	echo -e "$blue 输入选项: $een\c"
		    read oopt
		    case $oopt in
		        "1")
		            gitpull
		            pause
		            ;;
		        "2")
		            scriupda
		            pause
		            ;;
		        "3")
		            make menuconfig
		            pause
		            ;;
		        "4")
		            make -j8 download
		            pause
		            ;;
		        "5")
		            startmake
		            pause
		            ;;
		        "6")
		            cleartmp
		            pause
		            ;;
		        "7")
		            reconfig
		            pause
		            ;;
		        "8")
		            exit
		            ;;
		        "9")
		            gitclone
		            pause
		            ;;
		        "10")
		            buildtools
		            pause
		            ;;
		        *)
		            echo "ERROR"
		            ;;
		    esac
}
	
if [ $UID -ne 0 ];then
	while true
	do
	 opt
	done
else
	echo -e "
	
	$red请不要使用ROOT用户！请更换普通用户！$een
	
	"
	exit 127
fi

