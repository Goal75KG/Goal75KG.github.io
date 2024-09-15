---
title: 初尝试LateX
tags:
  - LateX
categories: LateX
abbrlink: 2dc79a79
date: 2024-09-11 16:21:25
---

## 写在前面

在撰写本科毕业设计论文的过程中，我就深刻感受到了LateX为我带来的便利。我的毕业设计与电机设计相关，论文中大多数时候都在与公式打交道，Word内置公式编辑器用起来效率很低，我便想起来与曾经一面之缘的LateX，果然他不负我望，极大地提高了论文撰写速度。高效，简洁的标签就是我为他量身定制的锦衣。但是在Word中使用LateX并不能完全体现LateX的特色，毕竟Word也是排版工具，而我只是利用了LateX特性之一，最近正好想起来，便有了这篇文章。

## 工具的选择

我的系统环境为：Windows 10 X64 专业工作站版 22H2。

LateX分为编辑器和编译器，这点倒是与编程语言很像，经过一番对比，我选择了TeXstudio作为编辑器，TeX Live作为编译器，因为这两个对新手比较友好。

## 安装及配置

### TeXstudio

[TeXstudio - A LaTeX editor](https://texstudio.sourceforge.net/)安装很简单，在[官网](https://texstudio.sourceforge.net/)首页，点击*Download now*按钮，即可下载对应安装包，一直下一步安装即可。

![image-20240911170504981](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409111705106.png)



### TeX Live

访问[TeX Live - TeX Users Group官网](https://tug.org/texlive/)，首页点击*install on Windows*下载安装包，一直下一步安装即可。

![image-20240911170916359](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409111709455.png)

> ⚠️注意：从官网下载需要有良好的科学网络环境，否则请从镜像源处下载。

安装过程需要耗费的时间比较长，共计耗时4小时，去喝一口茶，稍安勿躁。

![image-20240911204030907](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409112040969.png)

安装完成如图所示。

![image-20240911204130735](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409112041780.png)

安装好后打开终端，输入`latex -v`检查版本号，出现版本号代表安装成功，环境变量已添加。

![image-20240911204203286](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409112042338.png)

简单写一个hello world测试程序是否正常，打开TeXstudio，点击左上角新建文稿，输入：

```latex
\documentclass{article}
\begin{document}
Hello, world!
\end{document}
```

点击「工具」，「构建并查看」，构建成功！

![image-20240911205517460](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409112055567.png)

## 开始使用

由于第一次接触LateX写作，我认为有必要从LateX的写作教程开始，毕竟无米不成炊，不知道写作规则，是无法开始写作的。

