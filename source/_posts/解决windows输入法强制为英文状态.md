---
title: 解决windows输入法强制为英文状态
tags:
  - windows
  - 教程
  - 输入法
categories: 疑难杂症
abbrlink: 7b932365
date: 2024-09-08 17:38:28
---
## 写在前面
在windows10中，默认输入法为中文，但某些时候输入法莫名其妙地强制切换为英文，具体现象是：切换窗口，输入法就变成英文了，想输入中文还要手动切换回来，非常影响效率。
![问题预览](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409081748937.gif)

## 产生原因及解决思路
在出现该问题前，我曾因为Macig keyboard2 无法通过fn+功能键实现翻页、DEL 等操作而安装了来自Github开源驱动和键盘布局，重启后就导致输入法无法切换为中文。将布局文件删除后，可以切换中文了，但是就像我所描述的那样，切换窗口就会自动变为英文，~~所以我猜测，安装键盘驱动或者布局文件会导致输入法某些状态被更改。~~

因为系统在正常运行时的上一个操作是添加了布局文件（Keyboard Layouts），于是我找到相关注册表位置进行一番摸索，果然让我发现了异常。在`计算机\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts`目录下存储着系统键盘布局表，而我在这里却没有发现简体中文（中国大陆）的身影，通过询问AI得知简体中文（中国大陆）的键为`00000804`，而布局文件中并没有（我这里有是因为后截的图hhh），相关注册表网络上也寻找不到，于是找到好友复制了一份，导入后恢复了正常。

![Keyboard Layouts注册表](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409082044968.png)

## 解决方案

如果和我一样都是缺失`00000804`，请复制下面的代码，保存为`00000804.reg`，双击运行导入即可。

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\00000804]
"Layout Display Name"=hex(7):40,00,25,00,53,00,79,00,73,00,74,00,65,00,6d,00,\
  52,00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,\
  00,32,00,5c,00,69,00,6e,00,70,00,75,00,74,00,2e,00,64,00,6c,00,6c,00,2c,00,\
  2d,00,35,00,30,00,37,00,32,00,00,00,00,00
"Layout File"="KBDUS.DLL"
"Layout Text"="Chinese (Simplified) - US Keyboard"
```

现将**Keyboards Layouts**注册表文件分享出来，如果有类似情况，无论是否是简体中文，都可以参考该思路。

> 下载地址：[Keyboard Layouts.reg](https://pan.baidu.com/s/1yTmRCOr2WcIGpuqIyN-3tg?pwd=cmc5)

![问题解决截图](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409082108048.gif)

##  写在最后

这次的经历警示我：在运行陌生**脚本**时先打开查看源码，评估风险后，如果依旧要执行，一定要在执行前备份好可能受影响的文件，以防遭遇不测。
