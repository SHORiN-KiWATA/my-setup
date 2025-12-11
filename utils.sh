#=====颜色===========
# readonly 让这个环境变量一但定义就无法被更改
# 
# \033 八进制数，告诉终端后面的内容是指令
# [ 控制序列引导（完全不知道这是什么东西
# 0清空样式
# 31颜色代码
# m代表指令结束
# 基本上就是说这段内容之后的东西变成某种样式
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NO_COLOR='\033[0;0m'

#===========log echo========
# 用来显示醒目日志的工具函数
# -e 让echo解析右斜杠后的转义字符
# ${}用大括号防止粘连
log_info(){
	echo -e "${GREEN}[INFO] $1 ${NO_COLOR}"
}
log_warn(){
	echo -e "${YELLOW}[WARN] $1 ${NO_COLOR}"
}
log_error(){
	echo -e "${RED}[ERROR] $1 ${NO_COLOR}" >&2
}

#========check if a command exists========
# 用command -v而不是which是因为command -v是posix通用。他会找到命令对应的程序，如果没有则返回错误码
# 用>dev/null 把输出丢到黑洞里，只需要状态码
# 2>&1 把stderr定向到stdout，相当于把报错信息和stdout一起丢进黑洞
has_cmd(){
	command -v "$1" >/dev/null 2>&1
}

#========check root============
# 用id -u获取用户id，root的id永远是0
check_root(){
	if [ "$(id -u)" -ne 0 ]; then # -ne代表不等于
		return 1 # 不为0说明不是root，返回状态码1
	else
		return 0 # 为0说明是root，返回状态码0
	fi
}

check_network(){
	# ping 三次 archlinux的网站，-w设置超时时间
	ping -c 2 archlinux.org >/dev/null 2>&1
	if [ $? -eq  0 ]; then
		log_info "Network is connected."
		return 0
	else
		log_error "Network is disconnected! Please check your connection!"
		return 1
	fi
}
if_is_complete(){
	log_info "Checking if $PROGRESS_NAME is completed ..."

	if cat "$STATUS_FILE_NAME" | grep "$PROGRESS_NAME"; then
		log_warn "Progress $PROGRESS_NAME has completed."
		return 0
	else
		return 1
	fi
	
}
is_complete(){
	echo "$PROGRESS_NAME" >> "$STATUS_FILE_NAME"
}