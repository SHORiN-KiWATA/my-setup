#=========== tools===================

########从fstab中找出某个目录挂载的子卷########
find_subvol_in_fstab(){
        local dir_name=$1
        # -v 声明一个变量t，把shell变量传递给awk
        # awk ''是awk的具体功能
        # $2 == t找出第二列中有指定内容的行
        # {} 内用函数
        # match($4, /.../); 寻找第四列（$4）中指定内容所在位置，输出的是匹配到的第一个字符所在位置的数字。
        # subvol= 字符
        # [^,]+ 正则，[...]代表字符集，^代表非，,逗号是字符，+代表一个或者多个。完整意思是：一个或者多个非逗号的字符（遇到逗号即停止匹配）
        # print substr($4, RSTART+8)，RSTART代表match函数匹配到的位置+8跳过subvol=/这八个字符
        awk -v t="${dir_name}" '$2 == t { match ($4, /subvol=[^,]+/); print substr($4, RSTART+8) }' /etc/fstab
}
######检测是否为btrfs#####
check_btrfs(){
        # 如果根是btrfs文件系统，则安装snapper和相关组件
        if findmnt / | grep -q "btrfs"; then
                pacman -Syu --needed --noconfirm snapper snap-pac btrfs-assistant
                return 0
        else 
                log_info "Not btrfs, snapper setup skipped."
                return 1
        fi
}

#########创建某个路径的快照配置并关闭timeline#########
creat_snapper_config(){
        if [ ! -f "/etc/snapper/configs/${1}" ]; then
                snapper -c $1 create-config $2
                sed -i 's/TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/$1
        fi
}
#############创建某个配置的快照###############
creat_snapshot_of(){
        local config_name=$1
        local discription=$2
        snapper -c $config_name -d "$discription" -t single
}

#============执行=================
PROGRESS_NAME="btrfs-snapper"
#检测是否为btrfs文件系统，是的话配置快照
if ! if_is_complete; then  
        if check_btrfs; then 
                #检测是否存在根目录的子卷，存在的话创建快照配置
                ROOT_SUBVOL=$(find_subvol_in_fstab "/")
                if [ -z "${ROOT_SUBVOL}" ]; then
                        creat_snapper_config "root" "/"
                        log_info "root subvolume snapper setup completed"
                        creat_snapshot_of "root" "Before Setup"
                else
                        return 1
                fi
                #检测是否存在home目录的子卷，存在的话创建快照配置
                HOME_SUBVOL=$(find_subvol_in_fstab "/home")
                if [ -z "${HOME_SUBVOL}" ]; then
                        creat_snapper_config "home" "/home"
                        log_info "home subvolume snapper setup completed"
                        creat_snapshot_of "home" "Before Setup"
                else
                        return 1
                fi
                is_complete
        fi
fi

