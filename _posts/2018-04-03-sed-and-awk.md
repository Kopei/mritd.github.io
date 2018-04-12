---
layout: post
title: SED and AWK
categories: [linux]
description: 
keywords: linux
catalog: true
multilingual: false
tags: linux
---

## 前言
SED和AWK都是平时会用的Linux命令，正好看到NYU的一个PPT, 觉得不错，做一下总结。

## SED
sed是一个流式、非交互的文本编辑器。类似grep, sed会读取一行文本然后查找一个pattern模板,再根据匹配与否做相应的动作。sed是可以改变文件内容的。
sed作为非交互文本编辑器需要以脚本执行命令，有一个叫ed的交互式编辑器可以执行相同的命令。sed也可以认为是一个unix过滤器（如果不改变原输入）。
所有的sed指令会在每一行执行，如果某一行执行了一行命令，后续还有命令会在这个改变的行继续执行指令。
- 优点：正则、快速、简洁
- 缺点：难以记忆、不能回退、不能前向引用、不能处理数字、语法笨拙

### sed脚本结构
`[address[,address]][!]command[arguments]`
sed脚本由一些命令组成，每一个命令由最多两个可选地址（address)和一个指令action组成, 如上所示（多个action可以用{}包住）。当一行输入时，sed读取一行命令，把它存入 _pattern space_ 检查address是否匹配当前行，如果满足就会执行指令，(如果没有address,命令会在每行执行).如果不满足就直接跳到下一行命令。
当某一行执行完所有命令，sed就会把当前处理过的行输出（处理过的行在pattern space里）。然后再读取下一行，循环执行命令直到文件最后一行。

### address
一个address可以是一个行号或者pattern模式(/pattern/), 如果是pattern那么它必须是正则表达式(basic regular expression)。`$`指最后一行。
如果有两个address, 那么命令会在这两个address之间执行（包括这两行）。可以使用！取反操作。`address!action`

### Action
sed的指令是一个单独的字母[s,a,i,c,d,p,y,q]。下面是一些例子：
- 6d #删除第六行
- /$^/d #删除所有空行
- 1,10d #删除1-10行（含）
- 1，/^$/d  #删除第一行以下的所有空行
- /^$/,$d  #删除第一个空行到结尾
- /^ya*y/,/[0-9]$/d # 把yay, yaay,yaaay等，并且以数字结尾的行删除。
但使用多个指令时，有一些语法要求，如下。第左括号必须是行结尾，右括号必须是单行结尾。
```
[/pattern/[,/pattern]]{
  action1
  action2
  action3
}
```
- **打印** `[address[,address]]p`用来打印pattern space的内容，可以配合`-n`使用，如果不指定`-n`, 但是指定p,结果会打印两次！
- **替换**`[address(es)]s/pattern/replacement/[flags]`, `flags`可以是[n,g,p],n代表替换几次，g代表pattern space中的全局替换,p代表打印.
  sed的replacement可以使用几个特殊字符：
  - `&`代表所有在pattern中匹配的文本部分，用这个`&`就可以在replacement中引用pattern中匹配的部分。比如：
  ```
  # user=&uidX
  sed -e 's/user=&uid/user=&sysuserid./g'
  user=user=&uidsystemid.X
  ```
  - `\n`代表了在pattern中`\(`,`\)`中匹配的部分，用`\n`可以在replacement中使用。
  - 替换例子：
  ```
  "the UNIX operating system ..."
  s/.NI./wonderful &/
  "the wonderful UNIX operating system ..."
  ---
  cat test1
  first:seconde
  one:two
  sed 's/\(.*\):\(.*\)/\2:\1/' test1
  seconde:fisrt
  two:one
  ---
  ```
- **叠加** **插入** **修改** 这三者的语法类似，需要更新的文本写在语句第二行. insert是在pattern space前面插入文本，
  append是在pattern space后面增加文本
  ```
  [address]a\   #append
  test  
  [address]i\   #insert
  test
  [address(es)]c\   #change
  test
  ```
  - insert例子
  ```
  /<Insert Text Here>/i\
  Line 1 of inserted text\
  \        Line 2 of inserted text

  Line 1 of inserted text
               Line 2 of inserted text
  <Insert Text Here>
  ```
- `y`是sed的逐字替换，`[address[,address]]y/abc/xyz`
- `q`是退出读取新的行，`sed '110q' filename`读取110行

### hold space
sed的临时交换空间

### sed语法
`sed [-n][-e]['command'][file...]`
`sed [-n][-f scriptfile][file...]`
`-n`只打印print命令指定的内容。`-e`后面跟command, 可以多条`-e`用于指定多个command, `-f`后面指定脚本，在脚本的第一行使用`#n`, 等同于`-n`
`-i`直接在原输入文件做修改。

### sed的特殊字符
sed中`$.*[\]^`必须转义，除非这些字符在[...]中，而`(){}+?|`有特殊的作用，转义的话就变成特殊用法了。如果需要插入环境变量，sed的命令需要使用 **双引号**。

## AWK
awk是三个发明者的名字首字母, awk的发明是为了提供一个可编程的过滤器来处理文本和数字，awk是一种
**pattern-action** 语言，这点和sed一样。但是和sed处理行不同，awk处理的是字段。(当然它们输入都是读取一行)
nawk是awk的新标准，用于大型awk程序，gawk是nawk的GNU版本。awk可以从文件、
重定向、pipe和标准输入建立输入。awk的语言有点像C,但是会自动处理输入，字段分割，初始化内存和管理。
数据类型支持字符串和数字，不需要变量类型声明。awk是一个非常优秀的原型语言，你可以一行一行加上程序逻辑直到满足需求。

### awk比sed好的地方
- 方便数字处理
- 变量和控制流
- 方便找到行中的字段
- 灵活的打印功能print
- 内置算数和字符函数
- 类C语法

### awk的语法结构
awk的语法由三部分组成：
- 可选的BEGIN部分，用于先于文本输入执行逻辑
- pattern-action部分，根据输入数据，如果有pattern匹配，就采取对应的action。awk不会改变原输入文件, 可以用`>`重定向输出文件。
  - 每一个awk程序必须有一个pattern或者一个action, 或者两者都有。如果没有指定pattern, 默认pattern是匹配所有的行; 没有指定action,默认action是打印当前记录。patterns通过简单文本展示，action需要大括号{}包住来区分两者。
  - Patterns模式， 就是一个选择器，它决定了后续的action是否执行。pattern可以是正则表达式（//包住)，关系（大于等于）或者字符串匹配，！反向匹配，或通过&&，||任意组合。BEGIN和END是一个特殊的pattern, 用于初始化和总结。
  - Actions行动。action可以是一组类C表达式，也可以是数字或字符串表达式、赋值或格式化输出字符串流。action会在匹配的每一行执行，如果pattern没有提供，action会在每一行执行，如果action没有提供，所有pattern匹配的行会被打印到标准输出。action和pattern需要用有无{}来区分(有{}就是action)。
- 可选的END部分，用于文本处理完后进一步执行逻辑
```bash
ls |awk '
BEGIN {print "all html file"}
/\.html$/ {print}
END {print "There we go!"}
'
```

### 运行awk的方式
可以有三种方式执行awk命令：
- awk 'program' input_file(s)
  - 程序和输入文件通过命令行提供
- awk 'program'
  - 程序通过命令行提供，输入通过标准输入
- awk -f program_file input_file(s)
  - 程序是从文件读入的

### 变量
awk可以定义变量，不需要声明类型。
```
BEGIN { sum = 0 }
{ sum++ }
END { print sum }
```

### 条目(Records)
awk一行是一条记录，默认记录条目分隔符是换行符（\n)，但是可以是任何其他正则表达式。通过在BEGIN设置RS(record seperator).
NR是一个变量记录着当期条目的序号。

### 字段（Fields)
awk里每一行输入都会被分成字段，FS(field separator)可以指定分隔符，默认是空格。通过awk -F（分隔符）指定分隔符。
$0是整行，$1是第一个字段，一次递推。只有字段可以被通过$表示，变量无法这么做。

### awk输出
- 打印某个字段， action写成`{print $1, $3}`可以打印第一和第三个字段，默认采用空格分割。
- NF(Number of Fields), 当前字段序号，`{print NF, $1, $NF, $(NF-2)}`打印当前字段序号，第一个字段，最后一个字段, 倒数第三个字段。
- 可以对着$1做算术计算， `{print $1*$2}`
- 打印行号， `{print NR, $0}`
- 在打印的字段周围加一些字符，`{print "total pay for", $1, "is", $2*$3}`
- printf. awk也提供格式化输出，`printf(format, val1, val2, val3)`, {printf("total pay for %s is $%.2f\n", $1, $2*$3)}, 注意空格和换行需要手动输入，awk不会帮你插入。

### 选择器（selecton)
awk patterns十分适合选择某些行做处理，比如
- `$2 >= 5 {print}`比较选择
- `$2*$3 > 50 {printf("%6.2f for %s\n", $2*$3,$1)}` 计算
- `$1 == "NYU"`通过文本选择`$2 ~ /NYU/`
- `$2 >= 4 || $3 >= 20`组合比较
- `NR >= 10 && NR <= 20`通过行号

### 算术和变量
awk变量是数字类型或字符类型，用户定义的变量是不能用$的（unadorned), 默认用户定义的变量初始化为null, 值为0. 变量有这些：
- $0, $1, $NF
- NR
- NF
- FILENAME. 当前输入文件的名称
- FS
- OFS. 输出字段分隔符
- ARGC/ARGV. argument count/argument value array
  - 这两个变量用于从命令行得到参数
awk的运算符一共有如下这些：
- 赋值。 =
- 关系比较。 ==， >=, <等等
- 逻辑比较。 ||， &&， ！
- 算术运算符。+，-，/, %

```
$3 > 15 {emp=emp+1}
END {print emp, "employees worked more than 15 hrs"}
```

### 处理文本
awk处理文本的强大之处是可以方便地把数字和字符转换。
- 字符串拼接`{names=names $1 " "} END {print names}`

### 内建函数
awk有一些内建函数，比如length（wc简化版），`{nc = nc+length($0)+1}`; 比如substr(s,m,n), 生成字符s的子集，位置从s的m到n.
- 算术函数。 sin, cos, atan, exp, int, log,rand,sqrt
- 字符函数。length,substr, split
- 输出。 print, printf
- 特殊用途。`system（"clear")`执行unit命令。`exit`立即从输入退出，进入END区。
### 控制流if
```
$2 > 6 {n=n+1; pay=pay+$2*$3}
END {if (n>0) print n else print "no"}
```
```
{ i= 1
  while (i<= $3){
    printf("\t%.2f\n", $1*(1+$2)^i)
    i = i+1
  }
}
```
```
do {
  statement1
}while(expr)
```
```
{for (i=1; i<=$3;i=i+1)
printf("\t%.2f\n", $1*(1+$2)^i)
}
```

### 数组（Arrays)
awk的数组不需要声明。数组的下标可以是数字和字符。
```
{ line[NR] = $0 }
END {
  for (i=NR; i>0; i=i-1){
    print line[i]
  }
}
```
```
{ for (v in array){
    print array[v]
  }
}
```
