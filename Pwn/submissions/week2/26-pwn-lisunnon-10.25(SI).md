# week2 Linux（另一清单）

## 常用命令
- 看：pwd、ls -l、cat、less、head、tail -f、grep -n、wc -l、stat、file
- 找：find [起点] [条件] [动作]、grep -r、locate、man -k 关键词
- 改：cp -a、mv、rm、mkdir -p、ln -s、chmod、tar -xzvf、sed -i
- 系统：ps aux、top、df -h、du -sh *、free -h、uname -a、id
- 网络：ip a、ss -tulnp、ping、curl -v、nc -zv
- 命令从哪来：type -a、command -v、which
  - type -a 连别名和函数一起列，which 只查 PATH
- 组合范式
  - 命令 --help | head -30
  - 命令 -h 2>&1 | grep -i 关键词（有的帮助走 stderr）
  - ls -l | sort -k5 -n | tail -3
  - find . -type f -name '*.py' | xargs grep -n flag
  - tar -czvf out.tar.gz dir/
- grep 退出码 1 是没匹配，不是错误；2 才是错误（set -e 会踩）
- * 由 shell 展开；文件名有空格、特殊字符要引号
- tail -f 会跟丢轮转日志，用 tail -F
- cp 目录要 -r；cp -a 连权限时间一起保留
- rm 没有回收站；脚本写 rm -rf "${DIR:?}/"

## 标准流与重定向
- fd 0 输入、1 输出、2 错误、3 以上自定义
- 重定向改的是 fd 表指向，不是数据
- < file、> 覆盖、>> 追加、2> err、2>&1、&> 两者
- exec 3>file 之后用 >&3
- 顺序从左到右生效
  - cmd >out 2>&1 对：两个都进 out
  - cmd 2>&1 >out 错：错误还在终端
- 管道只接 stdout，stderr 直接漏屏幕；|& 就是 2>&1 |
- 管道退出码 = 最后一个命令；set -o pipefail；${PIPESTATUS[@]}
- 缓冲：连终端是行缓冲，进管道/文件变全缓冲
  - ./pwn | grep 没输出 = 没 flush，不是没跑
  - python3 -u、print(flush=True)、stdbuf -oL
- tee 屏幕和文件都要；2>&1 | tee log
- > 在命令执行前完成，先清空；cat a > a 会把 a 清空
- 调试时先别 2>/dev/null

## 进程与信号
- 一个进程 = PID + PPID + cwd + 环境 + fd 表 + 信号处理
- fork 是拷贝，exec 才换程序；exec 不改 cwd
- ps aux、ps -ef、ps -o pid,ppid,stat,cmd、pgrep -af、pstree -p、top
- ./a &、$!、Ctrl-Z 后 bg/fg、jobs、wait、nohup ... &、disown、timeout 5 ./a
- /proc/<pid>/：cwd、exe、maps、fd、environ、status
- STAT：R 运行、S 睡眠、D 不可中断、Z 僵尸、T 停止
  - 僵尸 kill -9 无效，只能等父进程 wait
- 退出码：0 成功、1 通用失败、2 用法错、126 不能执行、127 找不到
- 128+n 被信号杀：130 Ctrl-C、137 -9/OOM、139 段错误、141 SIGPIPE、143 TERM
- 139 是崩溃，126/127 是环境，137 先怀疑 OOM
- 信号：2 INT、3 QUIT、9 KILL、11 SEGV、13 PIPE、15 TERM、19 STOP、20 TSTP、1 HUP
  - 9 和 19 捕获不了；Ctrl-D 不是信号，是 EOF
  - 先 -15 再 -9；-9 不给清理机会
  - kill -l、kill -0 PID 探活、trap 'rm -f $tmp' EXIT

## 端口与连接
- 四元组：源IP:端口 ↔ 目的IP:端口，加协议
- ss -tulnp（l 监听、p 要 root）、ss -tanp、lsof -i :8080
- 绑 127.0.0.1 只本机；0.0.0.0 全部网卡；[::] 是 IPv6
- 绑 127 的服务，宿主机/VMware 外一定连不上；要绑 0.0.0.0 + 端口转发
- refused：IP 通、端口没人监听，内核回 RST
- timeout：包被丢，查防火墙、路由、绑错地址
- 解析失败：getent hosts、/etc/resolv.conf
- pwn：remote 报 refused 先 nc -zv 127.0.0.1 端口；EOFError 是对端崩了；卡住先想缓冲

## 包管理与 venv
- apt update 只更新清单不装；不 update 就 install 容易 Unable to locate package
- install / remove / purge / autoremove；search / show / policy
- dpkg -l 查版本、dpkg -L 列文件、dpkg -S 文件属于谁
- 本地包：apt install ./x.deb（./ 不能省）
- 源码：./configure --prefix、make -j$(nproc)、make install、ldconfig、pkg-config
  - configure 报 not found 缺 -dev；运行期缺 .so 用 ldd 看
- venv：apt install python3-venv → python3 -m venv .venv → source .venv/bin/activate → deactivate
- venv 的版本 = 建它的解释器版本，事后改不了
- externally-managed-environment 用 venv，别 --break-system-packages
- 用 python -m pip，保证 pip 和 python 同一套
- 确认装好三条：command -v、--version、sys.executable 加 pip show
- 装了找不到：PATH、hash -r、装给别的解释器、没 source 没重开

## 读报错
- 只看第一条 error；最后一行常是 See ... for details
- 先 echo $? 分类：126 权限、127 没装、137 OOM、139 崩溃
- 判断谁在说话：shell / loader / 解释器 / 编译器 / 内核 / 对端
- 顺序：最小复现 → 二分 → 上工具（strace -f、bash -x、gdb、python -X importtime）
- 用法错：invalid option、missing operand、syntax error、IndentationError → --help、bash -n
- 依赖缺：command not found、ModuleNotFoundError、cannot open shared object、undefined reference、Unable to locate package、configure error → command -v、ldd、dpkg -S
- 连接：refused、timed out、Could not resolve host、Network unreachable → ss、nc -zv、curl -v、proxy
- 资源：No space left（df -h、df -i）、Too many open files（ulimit -n）、Killed（dmesg）
- 文件在却 No such file or directory：shebang、readelf 的 interpreter、file 看架构、CRLF（od -c）
- Permission denied 但权限 755：namei -l 看每级 x、findmnt 看 noexec、SELinux

### 易错
- （>out 2>&1 的顺序；管道退出码不是第一个命令的
- 缓冲假象；grep 退出码 1
- 126 和 127 别混；139 和 137 别混
- 先 -15 后 -9；僵尸杀不掉
- 绑 127 从外面连不上
- update ≠ upgrade；venv 版本改不了
- 只看最后一行、把 warning 当 error、随手 2>/dev/null）