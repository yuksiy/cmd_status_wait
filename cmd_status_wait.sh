#!/bin/sh

# ==============================================================================
#   機能
#     コマンド実行結果が期待状態になるまで待機する
#   構文
#     USAGE 参照
#
#   Copyright (c) 2011-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 関数定義
######################################################################
USAGE() {
	cat <<- EOF 1>&2
		Usage:
		  cmd_status_wait.sh [OPTIONS ...] [ARGUMENTS ...]
		
		ARGUMENTS:
		    STATUS
		       Specify the status.
		    CMD_LINE
		       Specify command line.
		
		OPTIONS:
		    -C (colored)
		       Colored output.
		    -t RETRY_NUM
		       Specify the number of retry times. Default is ${RETRY_NUM}.
		       Specify 0 for infinite retrying.
		    -T RETRY_INTERVAL
		       Specify the interval seconds of retries. Default is ${RETRY_INTERVAL}.
		    -S "SSH_OPTIONS ..."
		    -H REMOTE_HOST
		    --help
		       Display this help and exit.
	EOF
}

. is_numeric_function.sh

######################################################################
# 変数定義
######################################################################
# ユーザ変数

# プログラム内部変数
COLOR_ECHO="color_echo.sh"
COLOR_INFO="light_blue"
COLOR_ERR="light_red"

ECHO_INFO="echo"
ECHO_ERR="${ECHO_INFO}"

RETRY_NUM="30"
RETRY_INTERVAL="1"
SSH_OPTIONS=""
REMOTE_HOST=""

######################################################################
# メインルーチン
######################################################################

# オプションのチェック
CMD_ARG="`getopt -o Ct:T:S:H: -l help -- \"$@\" 2>&1`"
if [ $? -ne 0 ];then
	echo "-E ${CMD_ARG}" 1>&2
	USAGE;exit 1
fi
eval set -- "${CMD_ARG}"
while true ; do
	opt="$1"
	case "${opt}" in
	-C)
		ECHO_INFO="${COLOR_ECHO} -F ${COLOR_INFO}"
		ECHO_ERR="${COLOR_ECHO} -F ${COLOR_ERR}"
		shift 1
		;;
	-t|-T)
		# 指定された文字列が数値か否かのチェック
		IS_NUMERIC "$2"
		if [ $? -ne 0 ];then
			echo "-E argument to \"-${opt}\" not numeric -- \"$2\"" 1>&2
			USAGE;exit 1
		fi
		case ${opt} in
		-t)	RETRY_NUM="$2";;
		-T)	RETRY_INTERVAL="$2";;
		esac
		shift 2
		;;
	-S)
		SSH_OPTIONS="${SSH_OPTIONS:+${SSH_OPTIONS} }$2"
		shift 2
		;;
	-H)
		REMOTE_HOST="$2"
		shift 2
		;;
	--help)
		USAGE;exit 0
		;;
	--)
		shift 1;break
		;;
	esac
done

# 第1引数のチェック
if [ $# -lt 1 ];then
	echo "-E Missing STATUS argument" 1>&2
	USAGE;exit 1
else
	STATUS="$1"
fi

# 第2引数のチェック
if [ "$2" = "" ];then
	echo "-E Missing CMD_LINE argument" 1>&2
	USAGE;exit 1
else
	CMD_LINE="$2"
fi

# sshコマンドの実行チェック
if [ ! "${REMOTE_HOST}" = "" ];then
	cmd_line="ssh ${SSH_OPTIONS:+${SSH_OPTIONS} }${REMOTE_HOST} \":\""
	output="$(${cmd_line} 2>&1)"
	if [ $? -ne 0 ];then
		echo "-E 'ssh' command execution check failed" 1>&2
		echo "     Command:" 1>&2
		echo "       ${cmd_line}" 1>&2
		echo "     Response:" 1>&2
		echo "${output}" | sed 's#^#       #' 1>&2
		exit 1	# USAGE表示なし
	fi
fi

# 処理開始メッセージの表示
if [ ! "${REMOTE_HOST}" = "" ];then
	echo -n " Waiting for \"${CMD_LINE}\" of ${REMOTE_HOST} to be \"${STATUS}\" "
else
	echo -n " Waiting for \"${CMD_LINE}\" to be \"${STATUS}\" "
fi

# コマンド実行結果が期待状態になるまで待機
if [ ! "${REMOTE_HOST}" = "" ];then
	cmd_line="ssh ${SSH_OPTIONS:+${SSH_OPTIONS} }${REMOTE_HOST} \"${CMD_LINE}\""
else
	cmd_line="${CMD_LINE}"
fi
count=1
while : ; do
	if test "$(${cmd_line} 2>&1)" = "${STATUS}" ; then
		${ECHO_INFO} " OK!"
		exit 0
	fi
	count=`expr ${count} + 1`
	echo -n "."
	if [ \( ${RETRY_NUM} -ne 0 \) -a \( ${count} -gt ${RETRY_NUM} \) ];then
		${ECHO_ERR} " NG! (timed out)"
		exit 1
	fi
	sleep ${RETRY_INTERVAL}
done

