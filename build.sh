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
echo "确定清理？(输入y执行！)"
read clearyes
if [ $clear -ne "y" ];then
	exit
else
	make clean && rm -rf ~/lede/tmp/
fi
}

reconfig(){
rm -rf .config
make menuconfig
}

gitclone(){
git clone https://github.com/coolsnowwolf/lede.git ~/
git clone https://github.com/kenzok8/small-package ~/lede/package/small-package
git clone https://github.com/thinktip/luci-theme-neobird.git ~/lede/package
}

opt(){
	echo "
	
		1.更新源码(git pull)

		2.更新组件(./scripts/feeds update -a && ./scripts/feeds install -a)

		3.更新配置(make menuconfig)

		4.下载编译库源码(make download)

		5.开始编译(make -j12 V=s)
		
		6.清理编译文件(make clean && rm tmp)
		
		7.重新配置(restart make config)
		
		8.退出脚本(Exit.)
		
		9.下载源码(git clone)

	"
	echo -e "$blue 输入选项: $een"
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
		        *)
		            echo "ERROR"
		            ;;
		    esac
}
	
while true
do
opt
done
