# multilib.sh

#脚本功能：检测/etc/pacman.conf中的[multilib]两行是否取消注释，没有的话取消。

PROGRESS_NAME="enable_multilib"

if ! if_is_complete; then

        log_info "Checking [multilib] repository status..."
        if grep -q "^\[multilib\]" /etc/pacman.conf; then
                log_info "[multilib] has already enabled."
                is_complete
        else
                log_info "Enabling [multilib] ..."
                # $代表行尾
                sed -i /\[multilub\]$/,/Include/s/^#// /etc/pacman.conf
                pacman -Sy
                is_complete
        fi
fi

