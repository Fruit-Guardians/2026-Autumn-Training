# 24\-re\-qiuyu\-1018

# Writeup

- ID:qiuyu

- 方向：Re

- 日期：2026/10/18

    

## DIE和UPX使用

- DIE与UPX使用过程：

1. 使用ai推荐的一个文件测试

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=YzY5NTA4MGFmYmVkMGI0MjA3ZTRiMjI5NDJjZjdkYTBfNjBmZTNhYmY2NjQzMjA5MWRmNDk5YzY2NzhkMDFmYTZfSUQ6NzY5NzkyODYzMzUzNjUzMTM4OF8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

然后尝试进行UPX加壳

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=NmZhNTY2N2I0MzQzZmU2MThhNmQ4YjljOTJhZjQ5ZGZfYTk1ZWNjNTkyNzA0ZGNkM2IyNWM4Y2Q0MjYwNzRkNGZfSUQ6NzY5NzkyODgzNjc1NTA2NjA5Ml8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

不允许 微软保护用上次ctf比赛的一个exe文件



![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=MjcxYjBkZjM4ZTU4N2M3MTk4OWU2M2U3YjliODU0ZGVfOWEzOThjNTVjOTYyZDY0OGM4NGY5MGZiMDgyNTY3ZDJfSUQ6NzY5NzkzMDgzNjkwNTUxMTkzOF8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

用upx加壳

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ZWQ5ZTRkNzlhOTU4YWY0MzI0YTU4YzE2MDM4NGUyOTFfMjRlNjczYmYxMDAwZjhmNzIzNTU2ZGM0MTY5YzgzZTRfSUQ6NzY5NzkzMTE5MzQ2MzA4MTk5M18xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

再用DIE测试

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=YjlhZGJiOGVkZWZjZmZjMzE0NGJkOWZhZmNjYjNkYzNfZDMyNzQ1MjBmNzE0NjFhOTAwMzY5MTgwYzgwNTEwNmFfSUQ6NzY5NzkzMTQxMzkxMTYyMDkwN18xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

有packer加壳成功

- IDA处理脱壳前

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=YjgxNmE4ZmYzYzNjMjQ4YjkxZTU5OWI2OGYxNjkxYWNfOWNiMWY1ZTFhYTU3M2MxZTI1ZjgwOGZkZDgyOWM2ZTlfSUQ6NzY5Nzk0OTIyNTc0MDk3OTIxMl8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

- IDA处理脱壳后

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=MzQ4N2M4OTU1MzA4ZjVlMDMxMzU5NjA2ZTk3MDhhZGFfMzlhMjVjMTRmYzgwM2RkMGE5MjllNWFiYzI1ZmFhYzBfSUQ6NzY5Nzk1MTE4NTgxODQ3MTY2OF8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

- 做一道入门题目

1\.链接：https://www\.nssctf\.cn/problem/4529

2\.使用工具：ida 9\.4 upx 5\.2\.1

3\.环境：window11

4\.流程：

先解压题目文件得到upx\.exe

用upx脱壳该文件

cd /d D:\\UPX\\UPX

"D:\\upx\-5\.2\.1\-win64\\upx\.exe" \-d upx\.exe \-o upx\_restored\.exe

得到

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=NzU0YTQ5N2U5ZmEwYjQ3MmRmNDhmZjhlN2NjZjc5NjhfODVkOTEwOGJkYmIwNzRkZWIzZjNkZTM1YmI5NTY5YTNfSUQ6NzY5Nzk1MjUxNTE1NzEzNDMyOV8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

IDA查找flag

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=OTUzZDBhZDgyZjBiNzcxMDFkYWMxMGU3YmZmMmFjZDVfYTU0ZDkzOWZkYjEyOGJiNWZhM2ZmYTIzYWQ1MThiZDNfSUQ6NzY5Nzk1MjcxNjA1OTk3MDg0OV8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

结果：NSSCTF\{UPX\_c4n\_3as1ly\_5h3ll\_pr0gr4m\!\}



## 花指令

- 题目：jump\_by\_jump

- 地址：https://www\.nssctf\.cn/problem/2313

- 做题思路：

先查找花指令shift\+t找

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=YjVkMzk0ODlmMzU0ZTNjNmNjNjkyODgyY2VmMjEyOWZfY2VjZTU1MThiMjVlZjFjMjQ5ZTI4ZjU4ZTY2NTg2YjlfSUQ6NzY5Nzk3MjkxNzU1Nzc5MTY3NV8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

发现jz jnz明显花指令

没有思路了去看别人的WP发现，将下面的E8改为90即nop了，询问ai了解原因

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=NGQ0NzY3NzI3NGUyYzdlNzRiMzdhNmQxYzhjNjk5YjVfNzA5MzcxNzFhZmFiNjc3NmM5YzA5MDUwZWYxMDFhNjJfSUQ6NzY5Nzk3NjQxMzA4MDY4NTU5MV8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

所以将其改为nop

将多余的删除将main函数复原即可

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ZGY5N2RlNmVmZWMyMTZmMWRiYmQwZGViNDk2NWZmNWNfODYxMjIxZmU4NTc0NDAwMmRmMjExZjg3NjY4ZDQwOTFfSUQ6NzY5Nzk3ODg0MzUzMjk3MTAwNl8xNzkyMzI3MDQ2OjE3OTI0MTM0NDZfVjM)

NSSCTF\{Jump\_b9\_jump\!\}



C语言、汇编语言等主要是复习就没写

