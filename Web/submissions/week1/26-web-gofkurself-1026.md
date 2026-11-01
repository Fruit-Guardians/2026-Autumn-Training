# Web 方向 week1 作业

| 项目 | 内容 |
| --- | --- |
| 姓名 / ID | 刘鑫灿 / gofkurself |
| 年级-方向 | 26-web |
| 周次 | week1（10.12 - 10.18） |
| 完成日期 | 2026-10-26 |
| 任务来源 | [培训文档](https://hnusec-star.feishu.cn/wiki/U2xfwfP39iWhISkZOa4c1UtInxd) · week1 |

## 本周任务

1. [SWPUCTF 2021新生赛] gift_F12
2. [qsnctf-NO.0902] robots.txt
3. [MoeCTF 2021] Web安全入门指北—GET

| # | 任务 | 状态 | 证据 |
| --- | --- | --- | --- |
| 1 | [SWPUCTF 2021新生赛] gift_F12 | 完成 | 见 1.3 |
| 2 | [qsnctf-NO.0902] robots.txt | 完成 | 见 2.3 |
| 3 | [MoeCTF 2021] Web安全入门指北—GET | 完成 | 见 3.3 |

## 一、[SWPUCTF 2021新生赛] gift_F12

### 1.1 题目 / 目标

- 附件或地址：[SWPUCTF 2021新生赛] gift_F12
- 已知信息：F12 开发者工具

### 1.2 过程

1. 注意到题目中的 F12 字样，于是使用 F12 打开开发者工具对 html 源码进行查询
2. 于是进行 Ctrl+F 操作，得到 flag

### 1.3 结果

- flag：`flag="WLLMCTF(WelcOme_tO_WLLMCTF_Thls_ls_th3_G1ft)`

## 二、[qsnctf-NO.0902] robots.txt

### 2.1 题目 / 目标

- 附件或地址：[[qsnctf-NO.0902] robots.txt](https://www.qsnctf.com/#/main/driving-range?page=1&category=&difficulty=&keyword=robots.txt)
- 已知信息：robots.txt

### 2.2 过程

1. 题目就叫 robots.txt，所以优先查看靶场的 robots.txt
2. disallow 目录有 login、admin 和 secret 目录，于是查看 secret 目录
3. 有明文的账号密码，于是直接登录拿到 flag

### 2.3 结果

- flag：`flag{8e5d8e66e1f04fbc8cc779cd58623c07}`
- 验证方式：对照官方答案

## 三、[MoeCTF 2021] Web安全入门指北—GET

### 3.1 题目 / 目标

- 附件或地址：[MoeCTF 2021] Web安全入门指北—GET

### 3.2 过程

1. 注意到有 if($moe==flag) 的判定
2. 所以 GET 同时附加 moe==flag 的参数
3. 拿到 flag

### 3.3 结果

- 结论：`(http://node5.anna.nssctf.cn:28056/?moe=flag)`
- 验证方式：对照官方答案

## 踩坑记录

| 现象 | 原因 | 怎么解决的 |
| --- | --- | --- |
| HTTP GET 拿不到东西 | 语法搞错了 | LLM 神力 |

## 没做完 / 没搞懂

无。