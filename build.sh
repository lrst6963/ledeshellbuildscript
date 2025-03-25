#!/bin/bash
set -euo pipefail

# 颜色定义
COLOR_RED='\033[31m'
COLOR_GREEN='\033[32m'
COLOR_RESET='\033[0m'
COLOR_BLUE='\033[34m'

# 全局配置
PROJECT_NAME="lede"
CPU_CORES=8 #$(nproc)  # 自动获取CPU核心数
BUILD_VERBOSE=""    # 默认为非详细编译模式
LEDE_DIR="$HOME/$PROJECT_NAME"

# 暂停函数，支持自定义提示信息
pause() {
    local message="${1:-按任意键继续...}"
    read -n1 -r -p "$message" _
    echo
}

# 更新源码
git_pull() {
    cd "$LEDE_DIR" || exit 1
    git pull
}

# 更新组件
update_feeds() {
    ./scripts/feeds update -a
    ./scripts/feeds install -a
}

# 编译函数
start_compile() {
    cd "$LEDE_DIR" || exit 1
    if make -j"$CPU_CORES" $BUILD_VERBOSE; then
        echo -e "\n${COLOR_GREEN}编译成功！${COLOR_RESET}"
        # package_artifacts  # 如需打包取消注释
    else
        echo -e "\n${COLOR_RED}编译出错！${COLOR_RESET}"
        exit 1
    fi
}

# 打包制品（示例函数）
package_artifacts() {
    local output_dir="$LEDE_DIR/bin/targets/rockchip/armv8"
    local zip_file="openwrt-$(date +%Y%m%d%H%M).zip"
    cd "$output_dir" || return
    find . -size +10M -print0 | xargs -0 zip -q "$zip_file"
    mv "$zip_file" "/var/www/html/"
}

# 清理临时文件
clean_tmp() {
    read -rp "${COLOR_RED}确定要清理编译文件？(y/N): ${COLOR_RESET}" answer
    if [[ "$answer" =~ [Yy] ]]; then
        make clean
        rm -rf "$LEDE_DIR/tmp"
    fi
}

# 重新配置
reconfigure() {
    read -rp "${COLOR_RED}确定要重新配置？(y/N): ${COLOR_RESET}" answer
    if [[ "$answer" =~ [Yy] ]]; then
        rm -f .config
        make menuconfig
    fi
}

# 克隆仓库
clone_repo() {
    git clone https://github.com/coolsnowwolf/lede.git "$LEDE_DIR"
    sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' "$LEDE_DIR/feeds.conf.default"
}

# 安装编译依赖
install_dependencies() {
    sudo apt update -y
    sudo apt full-upgrade -y
    sudo apt install -y \
        ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
        bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext \
        git gperf haveged help2man intltool libelf-dev libglib2.0-dev libgmp3-dev \
        libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev \
        libssl-dev libtool lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch \
        pkgconf python2.7 python3 python3-pyelftools qemu-utils rsync scons squashfs-tools \
        subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
}

# 显示菜单
show_menu() {
#    clear
    echo -e "${COLOR_BLUE}"
    echo "========================================"
    echo "        OpenWrt 自动化编译脚本         "
    echo "========================================"
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_GREEN}1.${COLOR_RESET} 更新源码"
    echo -e "${COLOR_GREEN}2.${COLOR_RESET} 更新软件包"
    echo -e "${COLOR_GREEN}3.${COLOR_RESET} 配置编译选项"
    echo -e "${COLOR_GREEN}4.${COLOR_RESET} 下载预编译文件"
    echo -e "${COLOR_GREEN}5.${COLOR_RESET} 开始编译（快速模式）make -j$CPU_CORES"
    echo -e "${COLOR_GREEN}6.${COLOR_RESET} 清理编译文件"
    echo -e "${COLOR_GREEN}7.${COLOR_RESET} 重新配置"
    echo -e "${COLOR_GREEN}8.${COLOR_RESET} 克隆仓库"
    echo -e "${COLOR_GREEN}9.${COLOR_RESET} 安装编译依赖"
    echo -e "${COLOR_GREEN}55.${COLOR_RESET} 开始编译（详细模式）"
    echo -e "${COLOR_GREEN}0.${COLOR_RESET} 退出脚本"
    echo -e "\n请输入选项：\c"
}

# 主逻辑
main() {
    # 权限检查
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${COLOR_RED}错误：请使用普通用户执行本脚本！${COLOR_RESET}"
        exit 1
    fi

    # 创建项目目录
    mkdir -p "$LEDE_DIR"

    while true; do
        show_menu
        read -r option
        case "$option" in
            1) git_pull ;;
            2) update_feeds ;;
            3) make menuconfig ;;
            4) make -j8 download ;;
            5) BUILD_VERBOSE="" && start_compile ;;
            6) clean_tmp ;;
            7) reconfigure ;;
            8) clone_repo ;;
            9) install_dependencies ;;
            55) BUILD_VERBOSE="V=s" && start_compile ;;
            0) exit 0 ;;
            *) echo -e "${COLOR_RED}无效选项！${COLOR_RESET}" ;;
        esac
        pause
    done
}

# 执行主函数
main
