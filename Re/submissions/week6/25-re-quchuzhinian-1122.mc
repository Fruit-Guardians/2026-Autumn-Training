### Ollydbg
OllyDbg 是一个 32 位汇编级别的分析调试器，和IDA的区别是Ollydbg是动态调试器，用于专门查看寄存器，内存等。IDA主要是静态分析    
在实际操作中，发现IDA的动态调试和Ollydbg的动态调试有很大区别  
hello world程序测试  
#include<stdio.h>  
#include<string.h>  
int main()  
{  
	printf("hello world!");  
	return 0;  
}  
编译运行后，把.exe文件用Ollydbg打开  
分析一下打开的图片，**右上角是寄存器，右下角是栈，最左侧一栏是地址**  
**左上角左上角第二列是机器码，第三列是汇编指令。左下角Dump 窗口是 地址 / 16 字节 HEX / ASCII 三列，第一列是地址**  
![](img/ScreenShot_2026-11-21_143511_496.png)
先记住最简单的有关调试的快捷键  
**F2下断点	  
F7单步执行(若遇到调用命令，将进入函数代码内部)  
F8单步执行(若遇到调用命令，仅执行函数自身，不跟随进入)  
F9直接运行，到断点位置会自动停下  
Ctrl+F2	重新开始调试(内存补丁全部还原)  
Ctrl+F9	执行到返回(Execute till return)  
Ctrl+A  分析代码   
Ctrl+F	查找命令**  
设置断点也可以直接CTRl+G打开跟踪表达的对话框，写入地址，该地址对应的位置即为断点   
可使用ALT+B按键查看已设置的断点  
![](img/ScreenShot_2026-11-21_145818_856.png)
查找字符串的步骤  
**在 CPU 反汇编窗口右键 → Search for → All referenced text strings**  
**在弹出字符串列表窗口右键 → Search for text**，输入文字  找到之后，复制十六进制地址  
按**Ctrl+G** 查找，粘贴这个地址，就能找到这个字符串的内存位置  
![](img/ScreenShot_2026-11-21_150106_007.png)
修改字符串的步骤  
在带有**hello world注释的地址**下断点，开启调试，在这里断下后单步运行，**发现右下角栈出现了hello world** ，写入了00405044，对应mov dword ptr [esp], 00405044 
![](img/ScreenShot_2026-11-21_152303_849.png)
在CPU的指令行选中hello world注释的**地址**，按下**CTRL+E**，发现待修改的地址不对  
![](img/ScreenShot_2026-11-21_152645_839.png)
这里Edit code at 0040141E，修改的是那几条指令的机器码，而不是字符串  
正确的的做法应该是**在右下角栈这一行右键Follow in Dump，进入dump窗口(位于左下角)**，此时发现hex dump窗口里的十六进制字节对应了ASCII hello world  
**选中 13 个字节（68 65 6C 6C 6F 20 77 6F 72 6C 64 21 00），再按 Ctrl+E。这里 Edit data beginning from address: 00405044，才是正确的位置**  
![](img/ScreenShot_2026-11-21_153310_819.png)
![](img/ScreenShot_2026-11-21_153404_340.png)
修改ASCII值后，注释立刻变成 ASCII "hello never"。在CPU的指令行选中hello never，**按F9继续运行，发现CPU的控制台(位于下方)改成了hello never**    
这种内存修改**只对当前调试进程有效**，如果退出程序重启，它就会还原  
如果想把程序也修改了，**需要Dump 里右键，Copy to executable All modifications，在新弹出的补丁窗口右键，Save file**   
![](img/ScreenShot_2026-11-21_155143_672.png)
举例子  
#### [BJDCTF 2020]Easy
先用IDA打开，先反编译main函数没发现什么有用的信息，尝试**反编译gues函数发现这个函数可能是有用的，但是main函数并没有调用**。先把这个函数的地址记下来0x00401520  
![](img/ScreenShot_2026-11-22_155312_984.png)
在IDA view里找存在分支或者跳转的句子，发现存在机器码**call system**分支，可以考虑直接patch这个机器码
![](img/ScreenShot_2026-11-22_155416_423.png)
**查缺资料，32位call rel的地址=目标地址-call的地址-5  
0x00401520-0x00401768-5=0xFFFFFDAD  
小端序是AD FD FF FF，这是4字节的偏移，头字节必须是E8**   
选中该指令的地址，**点击file patch program change byte**把原来的前五个字节更改为E8 AD FD FF FF，直接运行程序，发现直接终止。并没有出现弹窗  
![](img/ScreenShot_2026-11-22_161736_008.png)
尝试用ollydbg打开文件，并重试刚才所有的操作，发现成功了，出现了弹窗，这里我也不清楚是为什么  
![](img/ScreenShot_2026-11-22_154728_046.png)
![](img/ScreenShot_2026-11-22_154831_122.png)
![](img/ScreenShot_2026-11-22_155019_730.png)
#### [HNCTF 2022 Week1]CrackMe
首先需要定位到有关密文的函数
使用**智能搜索**，查找到**Congrals,u did it!!!**的文本字符串，点击进去发现一个比较函数LstrcmpA，比较的string1,string2应该有一个就是待获取的密文。  
![](img/ScreenShot_2026-11-21_171323_231.png)  
在该函数位置下断点，运行时输入一个错误的序列号    
**卡在LstrcmpA后进行单步调试，留意string1,string2的变化**  
运行到弹出报错时点确定，重新查看string1,string2，尝试string2发现密文符合  
![](img/ScreenShot_2026-11-21_171454_172.png)
### SMC,IDC 脚本
SMC是代码自修改，也就是**在执行之前先修改代码的内容，使原有的内存指令发生变化**  
具体的执行过程:
**先调用VirtualProtect：把代码段权限从「只读 + 可执行」改成可写**
解密循环，把这块乱码原地解密，**覆盖改写内存里的指令**
再改回权限，然后 **jmp /call 跳过去执行刚解密出来的真实代码**
举一个例子
#include <stdio.h>  
#include <windows.h>  
void anti_debug() {  
    unsigned char *code = (unsigned char *)anti_debug;  
    DWORD oldProtect;  
    if (!VirtualProtect(code, 1, PAGE_EXECUTE_READWRITE, &oldProtect)) {  
        return;  
    }  
    code[0] = 0xCC;  
    VirtualProtect(code, 1, oldProtect, &oldProtect);  
}  
int main() {  
    printf("Running normal code...\n");  
    anti_debug();  
    printf("This line will not be reached if under debugger.\n");  
    return 0;  
}
if (!VirtualProtect(code, 1, PAGE_EXECUTE_READWRITE, &oldProtect)) {
        return;
    } 这一段是修改权限
code[0] = 0xCC;    这一段是写入断点
VirtualProtect(code, 1, oldProtect, &oldProtect); 这一段是恢复权限  
IDC就是IDA的内置**脚本语言**，直接自动执行某些操作，比如说批量重命名函数、变量，自动 Patch 字节，提取字符串，交叉引用等
举一个例子  
**Nop掉所有指令** 
#include <idc.idc>  
static NopRange(start, end)  
{  
    auto ea;  
    for(ea = start; ea < end; ea++)  
    {  
        PatchByte(ea, 0x90);  
    }  
    MakeCode(start);  
    Refresh();  
    Message("NOP done: 0x%X ~ 0x%X\n", start, end);  
}
static main()
{
    auto START = 0x401050;
    auto END   = 0x401078;
    NopRange(START, END);
}
举例子   
#### [网鼎杯 2020 青龙组]jocker
打开后首先发现有红色报错，提示**sp-anaysis-failed**。F5也有红色报错。sp表示栈偏移，**只有call指令的esp变化能和ida的计算结果对应上**，(sp的偏移量前后对应)栈才能处于平衡状态  
![](img/ScreenShot_2026-11-20_191609_633.png)
![](img/ScreenShot_2026-11-20_191955_841.png)
这里报错内容表明此时栈没有平衡，为了平衡必须修改sp偏移量的值，**把2个call指令的sp都改为零**，函数就能有效平衡栈，此时再生成**伪代码**发现没有报错  
![](img/ScreenShot_2026-11-20_192711_916.png)
![](img/ScreenShot_2026-11-20_192844_192.png)
直接跟进wrong和omg两个函数，有加密逻辑，和enc密文，但是注释文字告诉你是不对的，手解一遍发现还真是错误的flag
![](img/ScreenShot_2026-11-20_193404_473.png)
问题出在smc上，**for ( i = 0; i <= 186; ++i ),((_BYTE )encrypt + i) ^= 0x41u;这两行即为自修改smc**，也就是说执行完自修改后的函数才是正确的
**必须使用动态调试，在smc执行完之后重新获得新的函数，在smc之前下断点即可**
![](img/ScreenShot_2026-11-20_194101_374.png)
执行完这187次smc后得到函数
int __cdecl encrypt(char *a1)  
{    
  int v2[19]; // [sp+1Ch] [bp-6Ch]@1  
  int v3; // [sp+68h] [bp-20h]@1  
  int i; // [sp+6Ch] [bp-1Ch]@1  
  v3 = 1;
  qmemcpy(v2, &amp;unk_403040, sizeof(v2));  
  for ( i = 0; i <= 18; ++i )  
  {  
    if ( (char)(a1[i] ^ aHahahaha_do_yo[i]) != v2[i] )  
    {  
      puts("wrong ~");  
      v3 = 0;  
      exit(0);  
    }  
  }  
  if ( v3 == 1 )  
    puts("come here");  
  return v3;  
}  
跟进**unk_403040,v2**能找到密文，函数的加密过程已经给了，解密过程反过来执行
#include<stdio.h>
#include<string.h>
int main(){
  char v3[9]="%tp&:"; 
  char v4; 
    char Buffer[]="hahahaha_do_you_find_me?";
    int v2[19]={14, 13, 9, 6, 19, 5, 88, 86, 62, 6, 12, 60, 31, 87, 20, 107, 87, 89, 13};
    char a1[19];
    for (  int i= 0; i <= 18; ++i ){
        a1[i]=v2[i]^Buffer[i];
        printf("%c",a1[i]);
    }
    for(int i= 0; i < 5; ++i  ){
        v4=v3[i]^71;
        printf("%c",v4);
    }
    return 0;
}
#### [GWCTF 2019]re3
发现sub_401129里面的函数无法再跟随了。**for ( i = 0; i <= 223; ++i )((_BYTE )sub_402219 + i) ^= 0x99u**;这两句是明显的smc语句  
![](img/ScreenShot_2026-11-20_202727_694.png)
按理说使用动态调试走完smc，但是循环太多了，借鉴别人写的一个**idc脚本**，自动执行这两句  
![](img/ScreenShot_2026-11-20_203037_664.png)
#include <idc.idc>  
static main()  
{  
    auto addr = 0x402219;  
    auto i = 0;  
    for(i=0;i<=223;i++)  
    {  
        PatchByte(addr+i,Byte(addr+i)^0x99);  
    }  
}  
运行完脚本，再找到**sub_401129**，在ida view里先**按F转为未定义**，再**按P重新定义**，出现机器码和var标记，再跟进sub_40196E函数寻找线索  
![](img/ScreenShot_2026-11-20_203517_254.png)
![](img/ScreenShot_2026-11-20_203819_130.png)
跟进了半天发现在函数sub_400BAC里有byte_4023A0数组，我并不知道这个数组是干啥用的，查看了别的题解才发现这是**AES算法的S盒**，AES就是根据盒进行逐字节的代换操作，而模式默认是ECB，偏移默认没有偏移  
![](img/ScreenShot_2026-11-20_203952_373.png)
主函数里的byte_6030A0应该就是密文，跟进得到BC0AADC0147C5ECCE0B140BC9C51D52B46B2B9434DE5324BAD7FB4B39CDB4B5B，还剩下密钥  
真正执行AES的最外层函数还是**sub_40196E**，所以**sub_40196E(v4,a1)里的v4应该是密钥**，直接跟进并没有，需要**动态调试**获得密钥CB8D493521B47A4CC1AE7E62229266CE  
有了密钥和密文，明确算法是AES，可以用工具解密了  
![](img/ScreenShot_2026-11-20_204940_504.png)    
#### [HDCTF 2023]enc
打开，生成伪代码，检查是否存在SMC。发现**跟进sub_411302**出现红色报错，**在IDA view里检查发现并没有报错**，这里应该就是SMC  
![](img/ScreenShot_2026-11-21_122111_853.png)
![](img/ScreenShot_2026-11-21_122129_595.png)
**跟进sub_411523**后发现里面是一个**TEA加密函数，而且是标准版**，但是在函数里面没有找到密文和密钥，在主函数里找到密钥和密文进行解密  
![](img/ScreenShot_2026-11-21_122528_466.png)
![](img/ScreenShot_2026-11-21_123811_311.png)
关键是如何去除SMC，由于没有明确的代码，**不能直接使用IDC脚本去除**，只能用动态调试  
动态调试后在**跟进sub_411302**，重新生成新的函数，生成伪代码
int __cdecl sub_41D000(char *Str)  
{  
  char v2; // [esp+0h] [ebp-558h]  
  size_t m; // [esp+190h] [ebp-3C8h]  
  BOOL v4; // [esp+19Ch] [ebp-3BCh]  
  int k; // [esp+1A8h] [ebp-3B0h]  
  int v6; // [esp+1B4h] [ebp-3A4h]  
  int v7; // [esp+1C0h] [ebp-398h]  
  int i; // [esp+1CCh] [ebp-38Ch]  
  int j; // [esp+1CCh] [ebp-38Ch]  
  int v10; // [esp+1CCh] [ebp-38Ch]  
  char v11; // [esp+1DBh] [ebp-37Dh]  
  char v12; // [esp+1DBh] [ebp-37Dh]  
  char v13[540]; // [esp+1E4h] [ebp-374h]  
  char v14[24]; // [esp+400h] [ebp-158h] BYREF  
  int v15; // [esp+418h] [ebp-140h]  
  char v16[264]; // [esp+424h] [ebp-134h] BYREF  
  char v17[40]; // [esp+52Ch] [ebp-2Ch] BYREF  
  __CheckForDebuggerJustMyCode(&unk_425036);  
  v17[0] = 15;  
  v17[1] = -108;  
  v17[2] = -82;  
  ....  
  j_memset(v16, 0, 0x100u);  
  v15 = j_strlen(Str);  
  strcpy(v14, "you_are_master");  
  v13[531] = 0;  
  ....
  if ( v4 )
    return sub_41114F("right!!!!", v2);
  else
    return sub_41114F("please try agin~", v2);
}  
根据伪代码内容应该是**使用RC4算法，v17是密文，you_are_master是密钥，即可解密**
### 虚拟环境的创建
尝试创建python虚拟环境
先做准备工作下载anaconda，conda应用程序，**激活anaconda powershell prompt终端，conda初始化**  
创建新的环境，指定python版本号conda create -n myenv python=3.8 -y，myenv是虚拟环境的名字  
激活并进入该虚拟环境conda activate myenv，**发现前面的base变为myenv**，成功激活  
![](img/ScreenShot_2026-11-18_164938_197.png)
在该环境下尝试安装一些三方库，尝试使用一些反编译工具 pip install requests，python pyinstxtractor.py Probe.exe  
![](img/ScreenShot_2026-11-18_172136_202.png)
![](img/ScreenShot_2026-11-18_172521_376.png)
退出虚拟环境 conda deactivate  
![](img/ScreenShot_2026-11-18_183225_164.png)
查看已经安装的所有配置 conda list  
查看已经安装的所有虚拟环境 conda env list  
![](img/ScreenShot_2026-11-18_180355_013.png)
再新建另外一个环境 conda create -n py311 python=3.11 -y  
![](img/ScreenShot_2026-11-18_183502_836.png)
再尝试安装一些三方库，尝试使用一些反编译工具  pip install uncompyle6，pip install gmpy2  
删除刚才安装好的myenv虚拟环境  conda remove -n myenv --all -y  
举例子
#### [HGAME 2023 week2]stream
常规进行解包和反编译都会出错，无论如何都改不对，后来发现解包时给的信息是**python3.10，必须在这个环境下进行解包才不出错**
这就要用到虚拟环境了，**启动anaconda的终端，激活已经新建好的python3.10环境，在这个环境下进行解包和反编译**，发现.py文件显示代码即为成功  
观察代码是base64和rc4两个算法，而且没有魔改，直接求解  
