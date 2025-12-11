

# 0. 如果检测到有多个普通用户的话，弹出选择框问要给哪个用户安装
# 1. xdg user dirs
# 2. 基础字体
# 3. 安装桌面环境需要的所有软件包
# 4. 复制配置文件


#===========工具===============
cleanup_temp_sudo() {
    if [ -f /etc/sudoers.d/99_temp_install ]; then
        rm -f /etc/sudoers.d/99_temp_install
        echo "Safety cleanup: Temporary sudo permissions removed."
    fi
}
create_xdg_user_dirs(){
        pacman -Syu --noconfirm xdg-user-dirs
        sudo -u shorin xdg-user-dirs-update
}

install_applist(){
        local applist_path="$1"
        # 用括号定义空数组
        local pacman_list=()
        local aur_list=()
        local flatpak_list=()
        
        
        # read循环读取done后面导入的文件放入line变量，-r原样读取，不转义。
        log_info "Processing pkg list...."
        while read -r line; do
                #如果是注释就跳过
                [[ "$line" =~ ^# ]] && continue
                #如果是空行就跳过 
                [[ -z "$line" ]] && continue

                # 如果包是AUR：开头的（这里也是正则匹配，== AUR：通配符）
                if [[ "$line" == AUR:* ]]; then
                        # var+=(value)意思是追加赋值，line#AUR:意思是把变量值里开头的AUR：去掉
                        aur_list+=("${line#AUR:}")
                elif [[  "$line" == flatpak:* ]]; then
                        flatpak_list+=("${line#flatpak:}")
                else
                        pacman_list+=("$line")
                fi
        done < "$applist_path"
        log_info "Pkg list complete; installing pkgs...."
        #如果数组中值的个数大于等于零，#代表列出数组中值的数量。
        if [ ${#pacman_list[@]} -gt 0 ]; then 
                #将数组变量里的每一个值逐个传给pacman，类似"vim" "firefox" "mission-center"这样
                pacman -Syu --needed --noconfirm "${pacman_list[@]}"
        fi

        # 循环安装aur包，失败则重试
        
        if [ ${#aur_list[@]} -gt 0 ]; then 
                
                #临时免密
                log_info "Creating passport..."
                echo "$TARGET_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99_temp_install
                #逐一安装aur包
                for pkg in "${aur_list[@]}"; do
                        #重试机制
                        local tried_times=1
                        local max_tried_times=3
                        while [ "$tried_times" -le "$max_tried_times" ]; do

                                log_info "Installing AUR package: $pkg ..."
                                # 安装成功的话跳出此次重试循环
                                if sudo -u "$TARGET_USER" yay -Syu --needed --noconfirm --noanswerclean --noansweredit --noanswerdiff --noanswerupgrade "$pkg"; then
                                        log_info "$pkg installed."
                                        break
                                # 安装失败的话尝试计数加1，再次尝试
                                else
                                        log_info "$pkg installation failed, retrying, tried times: $tried_times ...."
                                        ((tried_times++))
                                fi
                        done
                done
                #全部安装完成后销毁通行证
                log_info "Deleting passport...."
                rm -f /etc/sudoers.d/99_temp_install
        fi
        if [ ${#flatpak_list[@]} -gt 0 ]; then
                for pkg in "${flatpak_list[@]}"; do
                        log_info "Installing flatpak package: $pkg ..."
                        flatpak install -y "$pkg"
                done
        fi
}

deploy_dotfiles(){
        git clone https://github.com/SHORiN-KiWATA/ShorinArchExperience-ArchlinuxGuide.git
        local dotfile_path="ShorinArchExperience-ArchlinuxGuide"
        mkdir -p /home/$TARGET_USER/Pictures/Wallpapers
        cp -afv $dotfile_path/wallpapers/* /home/$TARGET_USER/Pictures/Wallpapers
        cp -afv $dotfile_path/dotfiles/. /home/$TARGET_USER
        chown -R "$TARGET_USER" /home/$TARGET_USER/Pictures/Wallpapers
        chown -R "$TARGET_USER" /home/$TARGET_USER
}
#==============执行================
PROGRESS_NAME="install_desktop_environment"
TARGET_USER=$(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd | head -n 1)
if ! if_is_complete; then
        install_applist "niri-applist.txt"
        create_xdg_user_dirs
        deploy_dotfiles
fi



# 退出、中断、中止后自动触发清理临时sudo文件
trap cleanup_temp_sudo EXIT SIGINT SIGTERM