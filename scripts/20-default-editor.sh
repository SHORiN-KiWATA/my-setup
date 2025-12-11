

PROGRESS_NAME="default-editor"

# grep看看/etc/environment里有没有设置EDITOR，如果没有的话echo设置追加写入设置默认文本编辑器为vim
if ! if_is_complete; then

        if grep "EDITOR" /etc/environment >/dev/null; then
                log_info "Default editor is already set."
                is_complete
        else
                pacman -Syu --needed --noconfirm vim
                echo "EDITOR=vim" >> /etc/environment
                log_info "Defautl editor set to vim."
                is_complete
        fi

fi