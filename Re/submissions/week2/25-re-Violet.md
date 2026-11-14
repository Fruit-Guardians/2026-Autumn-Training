# uv环境配置
<img width="403" height="64" alt="image" src="https://github.com/user-attachments/assets/f6f6e510-9dfc-4be5-b56d-638518213dfd" />

# GCC使用

GCC是常用的C/C++编译器
| 参数 | 作用 | 示例 |
|---|---|---|
| `-o` | 指定输出文件名 | `gcc main.c -o main` |
| `-S` | 只生成汇编文件，不继续生成目标文件和可执行文件 | `gcc main.c -S -o main.s` |
| `-c` | 只生成目标文件 `.o`，不链接 | `gcc main.c -c -o main.o` |
| `-E` | 只进行预处理，查看宏展开和头文件展开结果 | `gcc main.c -E -o main.i` |
| `-g` | 保留调试信息，方便 GDB 调试 | `gcc main.c -g -o main` |
| `-s` | 去掉符号信息，生成的程序更不利于分析 | `gcc main.c -s -o main_strip` |
| `-O0` | 关闭优化，适合初学者观察汇编和调试 | `gcc main.c -O0 -o main` |
| `-O2` | 开启较高优化，编译结果可能和源码差异更大 | `gcc main.c -O2 -o main` |
| `-Wall` | 开启常见警告 | `gcc main.c -Wall -o main` |
| `-m32` | 尝试生成 32 位程序，需要本机有 32 位编译环境 | `gcc main.c -m32 -o main32` |
| `-static` | 尽量静态链接，生成的文件通常更大 | `gcc main.c -static -o main` |
| `-masm=intel` | 生成 Intel 风格汇编，通常更接近 IDA 中看到的格式 | `gcc main.c -O0 -S -masm=intel -o main_intel.s` |
| `-masm=att` | 生成 AT&T 风格汇编，GCC 默认常见格式 | `gcc main.c -O0 -S -masm=att -o main_att.s` |

# 汇编指令
| 指令 | 含义 |
|---|---|
| `mov` | 数据移动 |
| `lea` | 取地址或计算地址 |
| `cmp` | 比较两个值 |
| `test` | 按位测试，常用于判断是否为 0 |
| `jmp` | 无条件跳转 |
| `jz` / `je` | 相等或结果为 0 时跳转 |
| `jnz` / `jne` | 不相等或结果不为 0 时跳转 |
| `ja` / `jb` | 无符号大于 / 小于 |
| `jg` / `jl` | 有符号大于 / 小于 |
| `call` | 调用函数 |
| `ret` | 函数返回 |
| `push` / `pop` | 入栈 / 出栈 |
| `xor` | 异或 |
| `add` / `sub` | 加 / 减 |
| `shl` / `shr` | 左移 / 右移 |
| `nop` | 空操作 |

# 题目
## UPX
https://www.nssctf.cn/problem/4529
<img width="1279" height="683" alt="image" src="https://github.com/user-attachments/assets/ccc1e6c7-f0dc-4318-9138-6e751c52a89c" />
DIE查看有UPX壳
<img width="843" height="154" alt="image" src="https://github.com/user-attachments/assets/8327dd23-aa98-436c-9541-2a32a8b95e8d" />

去壳

<img width="325" height="163" alt="image" src="https://github.com/user-attachments/assets/9e9b1fb9-ee5e-4b98-9f4f-e4ec56999cb1" />

去壳后ida里查看main函数可以直接从strcmp函数里看出flag为： NSSCTF{UPX_c4n_3as1ly_5h3ll_pr0gr4m!}

## 花指令

### 花指令1

https://www.nssctf.cn/problem/2313

<img width="440" height="145" alt="image" src="https://github.com/user-attachments/assets/f1ddc476-8fe3-4ab1-a141-d63387760e61" />

直接在字符串里看到了flag：NSSCTF{Jump_b9_jump!}

### 花指令2

https://www.nssctf.cn/problem/880

DIE看到是ELF，也就是Linux运行程序，同时程序入口是1050
<img width="1279" height="685" alt="image" src="https://github.com/user-attachments/assets/656f0bc8-3d6d-4c65-8d3b-14ae2c35c57e" />

1050下面看到  lea     rdi, main       ; main   main的地址取给了rdi

<img width="486" height="214" alt="image" src="https://github.com/user-attachments/assets/6287dc05-a2f8-492a-969c-c366b1abc4d1" />

然后来到main 1135，看到下面1144 jmp 1145，所以我们可以把1144改成nop，这样也不影响正常的程序运行顺序，同时简化程序复杂度

<img width="532" height="136" alt="image" src="https://github.com/user-attachments/assets/e251761b-4882-44e5-860f-dbae597f2d59" />
<img width="419" height="120" alt="image" src="https://github.com/user-attachments/assets/0c6f188a-48ac-4852-8722-2673295df6a9" />

但是发现后面有非常多的相同情况，可以写脚本自动化这个程序，下面是ai辅助脚本代码
```python
import ida_bytes
import ida_ua
import ida_funcs
import ida_auto


def main():
    # 等待 IDA 当前的自动分析完成
    ida_auto.auto_wait()

    # 本题 main 的范围：包含 START，不包含 END
    START = 0x1135
    END = 0x30F9

    blocks = []

    # 第一步：逐字节扫描，先找齐所有结构
    for ea in range(START, END - 12):
        data = ida_bytes.get_bytes(ea, 13)

        if data is None:
            continue

        # 原始结构，或已经把 EB 改成 90 的结构
        prefix_ok = data[:4] in (
            b"\xEB\xFF\xC0\xBF",
            b"\x90\xFF\xC0\xBF",
        )

        # 偏移 8 处应当是 call 的操作码 E8
        if prefix_ok and data[8] == 0xE8:
            blocks.append(ea)

    print("找到的结构数量：", len(blocks))

    # 针对本题检查数量，检查通过后才开始修改
    if len(blocks) != 623:
        raise RuntimeError("数量与本题不符，尚未修改任何字节")

    # 第二步：只修改尚未修补的 EB
    changed = 0

    for ea in blocks:
        if ida_bytes.get_byte(ea) == 0xEB:
            ida_bytes.patch_byte(ea, 0x90)
            changed += 1

    print("本次修改的字节数：", changed)

    # 第三步：取消旧的函数和指令定义，再重新识别
    ida_funcs.del_func(START)
    ida_bytes.del_items(
        START, ida_bytes.DELIT_SIMPLE, END - START
    )

    ea = START

    while ea < END:
        size = ida_ua.create_insn(ea)

        if size <= 0:
            raise RuntimeError(f"无法识别指令：{ea:X}")

        ea += size

    # 将这段代码重新建立为函数
    if not ida_funcs.add_func(START, END):
        raise RuntimeError("创建 main 函数失败")

    ida_auto.auto_wait()
    print("完成：花指令已修补，main 已重新识别")


main()
```
<img width="226" height="93" alt="image" src="https://github.com/user-attachments/assets/fea0fc84-ac7b-4823-aed6-7673f469fd4e" />

经过漫长的往下翻，可以发现此处不再是简单的输出字符了

.text:0000000000002D4C                 cmp     [rbp+var_4], 0

.text:0000000000002D50                 jz      loc_2FE5


也就是：

变量等于 0 → 跳到 2FE5

变量不等于 0 → 继续执行 2D56

<img width="343" height="116" alt="image" src="https://github.com/user-attachments/assets/fead9dd2-2a46-418a-bf44-2c6724b7ae97" />

跳到2FE5可以看到，逐个输出了字符you did't find the flag

<img width="379" height="410" alt="image" src="https://github.com/user-attachments/assets/6c9d12db-d54e-4692-8d1a-9a297e69319e" />

所以我们重点看一下2D56后面的

<img width="332" height="410" alt="image" src="https://github.com/user-attachments/assets/4a18cbf1-6205-4c0d-9408-12fc6e540d63" />

可以看到flag出来了：GFCTF{u_are2wordy}，但是题目平台要求前缀改为NSSCTF，所以最终flag为NSSCTF{u_are2wordy}

<img width="830" height="491" alt="image" src="https://github.com/user-attachments/assets/354222fb-cc14-4042-bc44-b9a4c30a4350" />

