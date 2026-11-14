第一周:
2026年10月13日
学习内容：学习使用git，解第一题，学习python
# git 学习笔记
## cd ~/Desktop/--打开某个文件夹
## git init--保存状态，创建1个gi仓库，保存版本
# git status--查看当前git仓库的状态---Untracked未跟踪的文件
# git add--将工作区复制到暂存区，git commit--将暂存区打包放到提交历史里
# changes to  be committed---以被提交到暂存区
#  git config --global user.name"ligui-yue"
#  git config --global user.email "mark.tech.18789570063@163.com"
# git commit -m"添加解释"   -m--付上说明
# git log--查看commit历史
# commit 984a5ec77f3215a81854255bbc7cc919adb1f877 (HEAD -> main)提交的编号
# Author: ligui-yue <mark.tech.18789570063@163.com>提交人
# Date:   Tue Oct 13 19:52:19 2026 +0800 提交的时间
# clear 清扫
# # modified--已被修改
## git diff--查看修改内容
### git restore后面加文件（可在后面追加所有文件）（.带表目录，可以用来回滚所有文件）==撤销改动（工作区）
### git restore --staged(加文件名)（占存区变为工作区）
## git reset --hard HEAD(hard)（reset重置）（HEAD位置）（--haed仨个区域）
## --mixed（保留工作区，回归暂存和提交）默认情况
## --soft（只回滚提交）
## --git revert HEAD（revert回滚）
题目：[SWPUCTF 2021 新生赛]gift_F12
解题思路：打开靶场页面，页面提示需要等待很久，判断是前端欺骗，查看网页源代码寻找flag。
步骤：
1. 启动靶场，访问靶场页面
2. 在靶场页面右键，查看网页源代码
3. Ctrl+F搜索flag，找到flag
flag：NSSCTF{We1c0me_t0_WLLMCTF_Th1s_1s_th3_G1ft}
 ps：为什么查看网业源代码会卡死


2026年10月14日
学习内容：继续学习git，解第二题，学习爬虫，学习python
## --vim.gitignore(建立一个文件--gitigore(git忽略))----gitignore文件夹中ESc退出编辑模式后：wq保存退出
User-agent: ### 爬虫
Disallow: /login.php###登录页面
Disallow: /admin.php###管理员页面
Disallow: /secret.php###密码页面
# python -m dirsearch -u(直接暴力)-u是参数
# 用powershell扫描发现没有secret.php路径（被隐藏）
题目：QSNCTF robots
解题思路：访问robots.txt，发现禁止访问secret.php，访问secret.php拿到账号密码，登录login.php拿到flag。
步骤：直接试错法
1. 启动靶场，访问靶场主页
2. 访问 /robots.txt，发现secret.php路径
3. 访问 /secret.php，获取账号密码
4. 访问 /login.php，输入账号密码登录，得到flag
ps：服了，CTF练习平台老是拒绝连接




2026年10月15日
学习内容:Robots.txt 详解,Web安全入门指北—GET,做第三题，学习python
第3题 [MoeCTF 2021]Web安全入门指北—GET
 
解题思路：了解GET请求原理，修改URL地址栏的参数，构造GET参数，传递指定数据，服务器校验成功后返回flag。
步骤：
1. 打开靶场页面，阅读题目提示
2. GET请求的参数直接写在网址（URL）后面，格式： ?参数名=值 
3. 修改URL中的参数，构造符合题目要求的GET请求
4. 提交请求，页面返回flag
flag：（做题后填入）
ps：GET请求参数附加在网址后面，所有人都可以在地址栏直接看见，是Web最基础的请求方式。




2026年10月17日
学习内容：- 搭建一个linux环境，学习python
- 学习linux命令行中的基本命令
题目：https://www.ctfplus.cn/problem-detail/2105939188284133376/description
##  pwd        # 查看当前所在目录（print working directory）
ls         # 列出当前文件夹文件
ls -la     # 列出全部文件（包括隐藏文件，详细权限信息，CTF高频）
cd         # 切换目录  cd /home
cat xxx.txt # 读取文件内容（看flag最常用）
mkdir      # 创建文件夹
rm         # 删除文件
cp         # 复制文件
mv         # 移动/重命名文件
whoami     # 查看当前是什么用户
id         # 查看用户id、权限
find       # 搜索文件！CTF找flag神器：find / -name "flag*"
grep       # 文本搜索，查找关键词