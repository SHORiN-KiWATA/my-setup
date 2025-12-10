# grep看看/etc/environment里有没有设置EDITOR，如果没有的话echo设置追加写入设置默认文本编辑器为vim
if grep "EDITOR" /etc/environment >/dev/null 2>&1; then
        log_info "Default editor is already set."
else
        pacman -S --needed --noconfirm vim
        echo "EDITOR=vim" >> /etc/environment
        log_info "Defautl editor set to vim."
fi
