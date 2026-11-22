# XXE课程的学习

### \-ID：孔令欣

### \-方向：Web

### \-日期:10\.26

### \-学习内容:xml的定义，xml与HTML的区别，xml的基本语法，使用PHP解析xml，学习DTD，xml几种实体

## 一、XML的定义

Xml:是把数据结构化后传输给对方，让对方在结构化的语言中读取。它的结构类似于“根”“枝”“叶”。它的标签没意义，可以自行定义。

## 二、xml与HTML的区别:

HTML的标签被预定义了，功能是用来开发；xml的功能是开发。

## 三、xml的语法:

1\.所有xml的标签都需要关闭。例如；\<p\>hello world\</p\>

2\.xml必须正确地嵌套。例如；\<b\>\<i\>hello world\</i\>\</b\>,后面的\</i\>\</b\>必须按顺序。

3\.xml标签对大小写敏感。例如；\<Letter\>与\<letter\>是不同的。

4\.xml文档必须要有根元素。

5\.xml中某些字符具有特殊含义,所以常进行实体应用。例如；\< \>

## 四、用php解析xml；

### 1\.用simplexml\-load\-file（）读取XML文档；

格式：

$xml=simplexml\-load\-file\(filename:""\);

print\-r\($xml\);

echo $xml\-\>xxx\[x\]\-\>xxx;

### 2\.用DOMDOCUMENT读取XML文档；

格式：$xml=include(" ");
     $

$doc=new DOMDocument\(\);

$$doc->loadXML($$xml\);

print\-r\($doc\-\>saveXML\(\)\);

也可以简化为:$doc=new DOMDocument();
            $

$doc\-\>load\(filename:""\);

$
            echo $$doc\-\>getElementsByTagName\(""\)\-\>item\(\)\-\>nodeValue;

## 五、DTD

DTD:定义我们自己所定义的标记的含义，规定和约束xml规则的定义和陈述。  

#### （1）内部引入

！DOCTYPE定义约束，！ELEMENT定义元素  ！ENTITY定义实体（这些实体可以再XML文档中被引用）

例如；\<\!DOCTYPE root\[

\<\!ELEMENT root\(man\)\>

\<\!ELEMENT man\(name,age,high\)\>

\<\!ELEMENT name \(\#PCDATA\)\>\]\>

通过这种方式约束了root下面只能有man这一个子节点，man下面只能有name，age，high这三个部分，还要按顺序输入这三个部分。还要求了

name中的东西只能是字符串（汉字，英文，数字，部分符号）（注意特殊符号需要进行实体引用）

#### （2）外部引入

格式；\<\!DOCTYPE root SYSTEM "filename"\>

此时一个漏洞隐患就出现了system有可能引入的是其他文件

## 六、实体

实体的作用：去掉符号的意义。除了参数实体外，其他实体都以\&开始，以;结束

### 1\.字符实体

如；\&lt即\<

### 2\.命名实体

\<\!DOCTYPE author\[

\<\!ELEMENT author \(\#PCDATA\)\>

\<\!ENTITY  writter "benben"\>

\]\>

\<author\>\&writter;\<author\>

这样就打印出\<author\> benben \<author\>,但是同时出现了安全隐患，即再给实体命名时对应的内容的安全隐患。

同时命名实体可以嵌套使用

### 3\.外部实体

即上述DTD的外部引入

#### 4\.参数实体

创建替换文本的可重用部分

格式为% ;

如：\<\!DOCTYPE author \[

\<\!ENTITY %area "name,sex,city"\>

\<\!ELEMENT office \(%area;\)\>

\]\>

