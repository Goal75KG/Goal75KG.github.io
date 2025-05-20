---
title: 彻底解决NVIDIA显卡驱动“没有找到兼容的图形硬件”问题​
tags:
  - NVDIA
  - 英伟达
  - 显卡
  - 驱动
categories: 教程
abbrlink: fb4d0ed4
date: 2025-05-20 20:22:58
---
# 前言
近日，朋友的红米 G 游戏本 2022 更新显卡驱动时出现了问题，主要现象为：安装来自英伟达官网的驱动程序时提示“此图形驱动程序无法找到兼容的硬件”，本文将提供一种解决方案，彻底解决该问题。

# 问题原因分析

![](https://files.mdnice.com/user/71387/342d6df1-bbdc-4db1-924a-7c6f569890f5.png)
在解决问题之前，先来看看为什么会出现这个问题。

英伟达驱动程序安装时会进行兼容性检查，这个过程中会检查计算机上的显卡硬件ID是否存在于驱动安装程序的INF文件中，如果不存在则会报出**没有找到兼容的图形硬件**。

# 驱动安装解决方案
## 查找硬件ID
1. 右键**“此电脑” → 管理 → 设备管理器 → 显示适配器**，
![](https://files.mdnice.com/user/71387/c5624db2-c979-4292-b2b3-0d93fdfe6a84.png)
2. 右键**独立显卡（这里为 3050 Ti） → 详细信息 → 属性下拉 → 硬件Id**
![](https://files.mdnice.com/user/71387/c2708ecf-7c21-4984-b4bc-c61d4fdb3094.png)

我这里的硬件Id为：`PCI\VEN_10DE&DEV_25A0&SUBSYS_21371D72
`

3. 复制下第二行硬件Id备用。

## 下载驱动程序
访问英伟达驱动程序官方网站：https://www.nvidia.cn/geforce/drivers/  
下载对应的驱动程序。

## 修改驱动安装程序INF文件
### 提取驱动程序安装文件
1. 双击运行驱动安装程序，复制安装路径，单击OK，开始执行解压程序。
![](https://files.mdnice.com/user/71387/08f806da-17fd-4cf0-8200-cbc6ee911d4c.png)

2. 等待驱动程序进行兼容性检查，检查失败后不要关闭窗口。 
![](https://files.mdnice.com/user/71387/342d6df1-bbdc-4db1-924a-7c6f569890f5.png) 

3. 复制步骤1的安装路径的所有文件到其他位置，依次进入`C:\NVIDIA\DisplayDriver\576.40\Win11_Win10-DCH_64\International\Display.Driver`，路径根据驱动程序的不同略有不同。
![](https://files.mdnice.com/user/71387/8b4d957f-ce67-4589-a22d-619223571a2e.png)

### 修改对应的INF文件
1. 修改INF文件中的显卡硬件iD
- 红米电脑对应的INF文件为：`nvqui.inf`，双击使用记事本打开。  
- 查找硬件Id后四位，我的硬件Id为`PCI\VEN_10DE&DEV_25A0&SUBSYS_21371D72`，则查找`1D72`。  
- 这里有多个以`1D72`结尾的项目，向下查找，直到找到`NVIDIA GeForce RTX 3050 Ti Laptop GPU`，可惜的是这里并没有（或非正常现象）。  
- 于是修改包含有`NVIDIA GeForce RTX 3050 Ti Laptop GPU`的项目。
- 将上面的硬件Id替换为本机的硬件Id。
```
#原始Id
NVIDIA_DEV.25A0.1362.152D = "NVIDIA GeForce RTX 3050 Ti Laptop GPU"
NVIDIA_DEV.25A0.1385.152D = "NVIDIA GeForce RTX 3050 Ti Laptop GPU"
NVIDIA_DEV.25A0.1481.152D = "NVIDIA GeForce RTX 3050 Ti Laptop GPU"

# 替换后
NVIDIA_DEV.25A0.2137.1D72 = "NVIDIA GeForce RTX 3050 Ti Laptop GPU"
NVIDIA_DEV.25A0.2137.1D72 = "NVIDIA GeForce RTX 3050 Ti Laptop GPU"
NVIDIA_DEV.25A0.2137.1D72 = "NVIDIA GeForce RTX 3050 Ti Laptop GPU"
```
具体的替换规则就是将本机的硬件Id后8位（这里是`PCI\VEN_10DE&DEV_25A0&SUBSYS_21371D72`）替换到INF文件对应位置中。

2. 修改INF文件中的设备标识符（Device ID）映射条目
- 查找INF文件中原对应显卡型号的Id后8位，`1362.152D`、`1385.152D`、`1481.152D`，`1362152D`、`1385152D`、`1481152D`将其统一修改为我们电脑的硬件Id后8位。**注意：前后都要修改，不要落下了。**
```
# 原始设备标识符映射条目
%NVIDIA_DEV.25A0.1362.152D% = Section066, PCI\VEN_10DE&DEV_25A0&SUBSYS_1362152D 
%NVIDIA_DEV.25A0.1385.152D% = Section067, PCI\VEN_10DE&DEV_25A0&SUBSYS_1385152D 
%NVIDIA_DEV.25A0.1481.152D% = Section069, PCI\VEN_10DE&DEV_25A0&SUBSYS_1481152D

# 修改后设备标识符映射条目
%NVIDIA_DEV.25A0.2137.1D72% = Section066, PCI\VEN_10DE&DEV_25A0&SUBSYS_21371D72 
%NVIDIA_DEV.25A0.2137.1D72% = Section067, PCI\VEN_10DE&DEV_25A0&SUBSYS_21371D72 
%NVIDIA_DEV.25A0.2137.1D72% = Section069, PCI\VEN_10DE&DEV_25A0&SUBSYS_21371D72
```
- 修改后记得保存文件，至此，所有修改均已完成。

## 安装修改后的驱动程序
因为修改后的驱动程序会令原始签名失效，在安装未经数字签名的驱动程序时，Windows 10 会阻止安装并提示“驱动程序未签名”。此时，可以通过**禁用驱动程序强制签名模式**来绕过限制。

**1. 进入高级启动选项**
**按 Win + I 打开“设置”** → **“更新和安全”** → **“恢复”**。
在 **“高级启动”** 下，点击 **“立即重新启动”**。
电脑会重启并进入选择菜单。

**2. 选择“疑难解答” → “高级选项”**
在重启后的蓝屏菜单中，选择 **“疑难解答”** → **“高级选项”**。
选择 **“启动设置”** → **“重启”**。

**3. 禁用驱动程序强制签名**
电脑再次重启后，会显示 **“启动设置”** 界面。
按 **F7**（或数字键 **7**）选择 **“禁用驱动程序强制签名”**。
（不同 Windows 版本可能按键不同，部分版本是 F9 或数字键 7）
电脑会正常启动，此时，正常运行`setup.exe`进行安装即可。

# 写在最后
本文写了如何解决红米GPro2022锐龙版游戏本无法正常更新英伟达显卡驱动问题，其他品牌电脑应该可以如法炮制，这里附上一份各品牌INF文件名以供参考：
```
nvam华硕

　　nvao是苹果

　　nvar是奇碁

　　nvbl是HP

　　nvct是仁宝，夹杂仁宝代工的DELL、联想

　　nvcv是Clevo

　　nvdm是DELL

　　nvfm是富士通

　　nvfu包含 精英、志合(Uniwill)、奶牛、富士通、西门子

　　nvfx是富士康

　　nvhm是HP

　　nviv是英业达

　　nvlo是LG

　　nvlt是联想

　　nvmi是微星

　　nvmm是纬创Wistron

　　nvmt包含顶星、神通，少量的NEC还有未知的两个1961、1A92

　　nvqn只有一款NEC

　　nvqu是广达，也包含广达代工的NEC、明基、LG。

　　nvsm是三洋

　　nvszc是索尼

　　nvtd是东芝Qosmio(200M系之后的新卡)

　　nvtm是东芝Qosmio(9系、8系显卡)

　　nvtq包含Trigem和两个未知1940、1B0A

　　nvts是东芝Tecra系列

　　nvtw是伦飞

　　nvvd未知1A46

　　nvwi是纬创，包含器代工的奶牛、NEC
  ```

