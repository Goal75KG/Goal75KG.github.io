---
title: Windows必备技能-注册表
tags:
  - Windows
  - 注册表
category: 电脑基础
author: isjingbin
abbrlink: 7a32b209
date: 2023-10-13 14:48:51
---

# 介绍
## 一切的发源——根键
- HKEY_CLASSES_ROOT：启动应用程序所需的全部信息，如扩展名，应用程序与文档之间的关系，驱动程序名，DDE和OLE信息，类ID编号和应用程序与文档的图标等。  
- HKEY_CURRENT_USER：当前登录用户的配置信息，如环境变量，个人程序以及桌面设置等。  
- HKEY_LOCAL_MACHINE：本地计算机的系统信息，如硬件和操作系统信息，安全数据和计算机专用的各类软件设置信息。  
- HKEY_USERS：计算机的所有用户使用的配置数据，这些数据只有在用户登录系统时才能访问。  
- HKEY_CURRENT_CONFIG：当前硬件的配置信息，其中的信息是从HKEY_LOCAL_MACHINE中映射出来的。  

## 键值类型
- REG_SZ
- REG_DWORD
- REG_EXPAND_SZ
- REG_MULTI_SZ
- REG_QWORD

# 操作

## 修改
对于注册表的增删改查以及导入导出

### 增加
示例：使用CMD在根键**HKEY_CURRENT_USER**下创建一个子键“Person”，在这个子键中，添加一个值名为name，类型为REG_ZS，数据为“Saul Goodman”。
```reg add hkcu\Person /v name /t REG_SZ /d "Saul Goodman"```
![未上传](https://cdn.jsdelivr.net/gh/isjingbin/diaryImage@main/img/2023%2F10%2F80b0883e21201d57c26e61123607163a.png)
![操作命令](https://cdn.jsdelivr.net/gh/isjingbin/diaryImage@main/img/2023%2F10%2F1d4368259492f782ff7f9de932da93a5.png)
![已上传](https://cdn.jsdelivr.net/gh/isjingbin/diaryImage@main/img/2023%2F10%2Fe611bf2f0fda4966f30a967a85d74caf.png)

HKCU：根键 **HKEY_CURRENT_USER**的缩写
另外几个缩写：HKCR、HKLM、HKU、HKCC。

参数列表：
- /v：需要创建的值的名称
- /t：值的类型
- /d：值的数据

TO BE END...:dash: