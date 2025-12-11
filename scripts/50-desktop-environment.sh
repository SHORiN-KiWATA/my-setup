PROGRESS_NAME="install_desktop_environment"

# 0. 如果检测到有多个普通用户的话，弹出选择框问要给哪个用户安装
# 1. xdg user dirs
# 2. 基础字体
# 3. 安装桌面环境需要的所有软件包
# 4. 复制配置文件



create_xdg_user_dirs(){
        pacman -Syu --noconfirm xdg-user-dirs
}

get_applist(){
        local applist_path="$1"
        local pacman_list=""
        local aur_list=""
        local flatpak_list=""
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
        if [ -z "$pacman_list" ]; then 
                #将数组变量里的每一个值逐个传给pacman，类似"vim" "firefox" "mission-center"这样
                pacman -Syu --needed --noconfirm "${pacman_list[@]}"
        fi
        if [ -z "$aur_list" ]; then 
                yay -Syu --needed --noconfirm --noanswerclean --noansweredit --noanswerdiff --noanswerupgrade "${aur_list[@]}"
        fi
        if [ -z "$flatpak_list" ]; then
                flatpak install "${flatpak[@]}"
        fi
}

get_applist "niri-applist.txt"