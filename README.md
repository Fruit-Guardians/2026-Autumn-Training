<h1 align="center">📘 HnuSec 2026-Autumn秋季培训</h1>

<p align="center">
  2026 秋季培训作业专用提交仓库
</p>

# 📚 培训文档

**[hnusec-star.feishu.cn/wiki/U2xfwfP39iWhISkZOa4c1UtInxd](https://hnusec-star.feishu.cn/wiki/U2xfwfP39iWhISkZOa4c1UtInxd?from=from_copylink)**

培训的整体安排、各方向学习内容与作业要求均以该飞书文档为准，请先阅读并收藏，随时留意更新。

> 「提交时间：2026-2027-1」

## ✨ 提交说明

| 项目     | 内容                    |
| -------- | ----------------------- |
| 提交范围 | 2026秋季培训作业        |
| 提交时间 | 2026-2027-1             |
| 提交格式 | 仅支持 Markdown（`.md`） |
| 命名格式 | `年级-方向-id-日期`     |
| PR 要求  | 一个作业对应一个 PR     |

**每周作业完成时间：**

- week1：10.12 - 10.18
- week2：10.19 - 10.25
- week3：10.26 - 11.1
- 以此类推.....
  
【晚进培训的同学可以按照自己的进入时间递推每周提交作业】

## 📂 项目结构

- 根目录按专业方向划分，当前包括 `Cry/`、`Misc/`、`Pwn/`、`Re/`、`Web/`。
- 每个方向目录的 `README.md` 收录该方向的**技术文档**链接，学习内容以技术文档为准。
- 每个方向下设置独立的 `submissions/` 目录用于提交作业。
- `submissions/` 下按周次划分，每周一个 `week<N>/` 目录。
- 每周的作业要求布置在对应周次目录的 `README.md` 中。
- 请将个人作业 PR 到「所属方向 + 对应周次」的目录中。

```text
2026-Autumn-Training/
├── Cry/
│   └── submissions/
│       ├── week1/
│       ├── week2/
│       ├── week3/
│       ├── week4/
│       ├── week5/
│       ├── week6/
│       └── week7/
├── Misc/
│   └── submissions/
│       ├── week1/
│       ├── week2/
│       ├── week3/
│       ├── week4/
│       ├── week5/
│       ├── week6/
│       └── week7/
├── Pwn/
│   └── submissions/
│       ├── week1/
│       ├── week2/
│       ├── week3/
│       ├── week4/
│       ├── week5/
│       ├── week6/
│       └── week7/
├── Re/
│   └── submissions/
│       ├── week1/
│       ├── week2/
│       ├── week3/
│       ├── week4/
│       ├── week5/
│       ├── week6/
│       └── week7/
├── Web/
│   └── submissions/
│       ├── week1/
│       ├── week2/
│       ├── week3/
│       ├── week4/
│       ├── week5/
│       ├── week6/
│       └── week7/
├── 如何PR.md
└── README.md
```

## 📝 提交规范

- 提交文件格式仅限 `.md`。
- 请自行学习 markdown 语法，这里提供一个学习链接：https://markdown.com.cn/basic-syntax/
- 文件名统一为 `年级-方向-id-日期.md`（日期为四位月日，如 `1012` 表示 10 月 12 日）。
- 请按所属方向和周次提交到对应的目录。
- 示例：`Web/submissions/week1/26-web-qing-1012.md`
- 示例：`Re/submissions/week2/26-re-xxx-1020.md`

## 📋 内容建议

建议作业文档包含以下内容：

- 标题与作业名称
- 简介或题目说明
- 环境与依赖信息
- 解题思路或步骤说明
- 关键代码片段
- 结果与总结
- 参考文章

代码片段建议使用标准 Markdown 代码块，并注明语言类型，例如：

```python
print("hello, world")
```

示例模板（大家参考就好，可以根据自己的情况修改，但是一定要具有格式化的 Markdown 语法）：

````
# Writeup 标题
- ID:your_id
- 方向：Cry / Misc / Pwn / Re / Web
- 日期：YYYY-MM-DD
- 平台/来源：CTFd / HackTheBox / AttackDefense / 其他
- 题目名称：Example Challenge
- 分类与分值：Web / 200 pts（难度：Medium）
- 题目链接/附件：<题目链接或附件说明>

## 目标与范围
- 靶机/远程地址：<host:port 或 docker>
- 漏洞类型：例如 SQLi / XSS / BOF / 逻辑漏洞
- 约束与规则：仅在授权范围内操作，避免影响真实生产环境

## 环境与依赖
- 操作系统：Windows / Linux / macOS
- 工具与版本：pwntools 4.x / nmap 7.x / BurpSuite / Ghidra / sqlmap / IDA Free 等
- 语言与版本：Python 3.10 / GCC 12 / Node.js 20
- 复现实验：提供启动/连接方式（如 docker、nc、ssh、HTTP）

## 解题过程
1. 信息收集与初步分析
2. 漏洞定位与可利用性验证
3. 构造 Payload / Exploit 步骤
4. 拿到 Flag 的过程（如需，flag 内容可脱敏为 `flag{redacted}`）
5. 常见坑与绕过技巧

## 关键代码
```python
# 示例代码
print("hello, world")
```

## 结果与总结
- 最终结果：<flag 或结论>
- 踩坑与收获：<记录遇到的问题及解决方式>

## 参考文章
- <链接>
````

**作业格式不重要，最重要的一定是自己人工撰写完成，有所体会和感悟，而不是简单的拿AI生成**

## 🔄 PR 规则

- 请阅读当前目录下的 `如何PR.md`
- PR 标题格式统一为：`年级-方向-id-日期`
- 示例：`26-web-qing-1012`

## 📌 提交提醒

- 本仓库接收 2026 秋季培训各周作业，请提交到对应周次的目录。
- 提交前请确认方向、周次无误，文件命名规范、文档内容完整。
- 请在每周截止时间前完成提交和 PR 发起。
