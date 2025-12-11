PROGRESS_NAME="archlinuxcn_aur_helper"

log_info "Checking archlinuxcn mirror status...."

if ! if_is_complete; then

        if grep "\[archlinuxcn\]" /etc/pacman.conf; then
                log_info "Archlinuxcn is already set."
                if ! has_cmd "yay"; then
                        pacman -Syu yay
                fi
                is_complete

        else
                log_info "Enabling archlinuxcn..."
                #告诉shell接下来遇到EOT（end of text）前的所有内容都追加写入/etc/pacman.conf
                cat <<EOT >> /etc/pacman.conf

[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch
Server = https://mirrors.hit.edu.cn/archlinuxcn/\$arch
Server = https://repo.huaweicloud.com/archlinuxcn/\$arch 
EOT
        
                pacman -Sy --noconfirm archlinuxcn-keyring 
                if ! has_cmd "yay"; then
                        pacman -Syu yay
                fi
                log_info "Archlinuxcn enabled."
                is_complete
        fi
        
fi

