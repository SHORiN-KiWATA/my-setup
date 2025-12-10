# 从ipapi获取国家代码
update_mirrorlist(){

        local CURRENT_TZ=$(timedatectl show --property=Timezone --value)
        local ARGS='-a 24 -f 10 --sort score --v --save /etc/pacman.d/mirrorlist'
        local COUNTRY=$(curl -s https://ipapi.co/country_name)

        pacman -S --needed --noconfirm reflector
        # 用timedatectl显示时区
        if [ "$CURRENT_TZ" == "Asia/Shanghai" ];then 
                true # 检测到时区为上海则跳过reflector设置镜像源的步骤
        else
                reflector $ARGS -c $COUNTRY
        fi
}

log_info "Updating pacman mirrorlist..."
update_mirrorlist
