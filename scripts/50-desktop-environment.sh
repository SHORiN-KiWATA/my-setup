PROGRESS_NAME="install_desktop_environment"

# 0. 如果检测到有多个普通用户的话，弹出选择框问要给哪个用户安装
# 1. xdg user dirs
# 2. 基础字体
# 3. 安装桌面环境需要的所有软件包
# 4. 复制配置文件



create_xdg_user_dirs(){
        pacman -Syu --noconfirm xdg-user-dirs
}