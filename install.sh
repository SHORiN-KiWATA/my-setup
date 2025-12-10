#!/usr/bin/env bash
set -euo pipefail

#=======导入工具集=======
source utils.sh
#=======检查root权限====
echo "Checking root permission..."
if check_root; then
        log_info "root permission checked."
else
        log_error "Please run as root."
        exit 1 # 如果检测到没有权限则直接退出脚本
fi
#=======检查网络连接=======
echo "Checking Network connection..."
if ! check_network; then
        exit 1 # 没有网络连接则直接退出脚本
fi 


# 按照文件名顺序导入所有的脚本
for i in scripts/*.sh
do
        source "$i"
done



