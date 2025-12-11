# user.sh

# 功能：如果没有创建普通用户则引导创建普通用户
#=========工具===========
if_has_normal_user(){
        # -F：指定用冒号作为分隔符
        # $3 >= 1000 && $3 != 65534筛选出第三列大于等于1000且不等于65534的行
        # print $1 打印第一列
        # grep -q .  点代表任意字符，如果检测到awk输出任意字符则状态码为0
        if awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd | grep -q .; then
                return 0
        else
                return 1
        fi
}
setup_new_user(){
        log_info "No normal user detected. Starting user creation ..."

        local username=""
        local passwd=""

        while true; do
                # -p 显示提示词，读取用户输入写入username变量中
                read -p "Please enter username: " username
                # =~是正则匹配符号，只能在双方括号内使用，如果左边的内容匹配右边的内容则0
                # 如果用户名为空或者包含空格则报错
                if [[ -z "$username" || "$username" =~ " " ]]; then
                        log_error "Invalid username."
                        # 回到循环的开头
                        continue
                fi

                
                # 让用户确认，把输入内容写入变量，再判断是否为Y，是的话则break
                # ${variable:-Y} 如果变量值是空的则使用Y作为值
                
                read -p "Confirm username as ${username}? [Y/n]: " username_confirm
                # ^代表开头，[...]是字符集，
                username_confirm=${username_confirm:-Y}
                if [[ ! "$username_confirm" =~ ^[yY] ]]; then 
                        continue
                fi

                break
        
        done


        # 设置密码
        while true; do
                # -s代表不回显
                read -p "Please enter password for $username: " -s passwd

                #检查是否为空，是否包含空格
                if [[ -z "$passwd" || "$passwd" =~ " " ]]; then
                        log_error "Invalid password."
                        continue
                fi

                break
        done

        # 检查sudo有没有安装
        log_info "Checking if sudo is installed...."
        if ! has_cmd "sudo"; then
                pacman -Syu --noconfirm sudo
        fi

        # 添加组
        log_info "Adding $username to group wheel..."
        useradd -m -G wheel -s /bin/bash "$username"
        
        # 配置sudo权限
        log_info "Enabling sudo permission....."
        echo "$username ALL=(ALL) ALL" > /etc/sudoers.d/00_$username
}

#=========执行=========
PROGRESS_NAME="create_user"

if ! if_is_complete; then

        if if_has_normal_user; then 
                echo "normal user detected...."
                is_complete
        else    
                setup_new_user
                is_complete
        fi

fi