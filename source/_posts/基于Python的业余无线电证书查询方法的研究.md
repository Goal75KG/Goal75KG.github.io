---
title: 基于Python的业余无线电证书查询方法的研究
tags: '-业余无线电 -Python'
categories: 业余无线电
abbrlink: '60858e85'
date: 2024-09-25 00:15:08
---
## 前言

经过一段时间的备考，终于获得了回报。我参加的黑龙江省9月份场次的业余无线电A证考试中，获得了满分的成绩，如愿地拿到了属于自己的业余无线电操作证。

无论是作为一名业余无线电爱好者，还是一名一直在前进路上学习的人，最重要的一点就是要四处汲取，不要固步自封，深知这个道理的我遂加入了[HamCQ 社区](https://forum.hamcq.cn/)，打算与同样的爱好者友好交流一番。

当我发现该社区有操作证类别认证功能时，毫不犹豫就填写了姓名及个人身份证提交验证，很快便通过了验证。因为验证用时很短，我开始怀疑这个验证是否是人工操作，如果不是，那么是怎么查询对应的证书并验证的呢？怀着这个好奇心，开始了本篇文章记录的研究。

## 信息搜集

通过一番搜集，暂且发现只有[业余无线电台操作技术能力信息平台](https://yydtcznl.miit.gov.cn/#:~:text=业余无线电台操作技术)和[业余无线电台操作技术能力验证及信息管理系统](http://82.157.138.16:8091/CRAC/crac/pages/list_cert.html)可以查询证书，而工业和信息化部政务服务平台的业余无线电台操作技术能力信息平台需要姓名和手机号为查询条件，接收验证码才可查询，显然不满足社区查询验证所用的条件。

![业余无线电台操作技术能力信息平台](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409250031225.png)于是业余无线电台操作技术能力验证及信息管理系统则成为了这次的研究对象。![业余无线电台操作技术能力验证及信息管理系统](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409250032682.png)

该系统查询条件为姓名、证书编号（选填）、身份证号，符合社区查询条件，猜测社区认证过程可能是社区管理员手动查询或者调用了查询接口进行信息处理和判断，来了兴趣，一定要探索一番。

## 研究过程

对于前后端分离的网站，在操作数据时，尤其是增删改查，是要通过对API接口发送网络请求来实现的。

研究讲究**“望闻问切”**，对付这类问题，一定不可操之过急，好好观察再下手，对准弱点下狠手。

先从“望”开始，观察网页，经典的查询三部曲：「输入信息」，「点击查询」，「返回信息」。一般思路是输入信息，点击查询按钮后向后端发送Get或Post请求，服务器接受请求后查询数据库，返回一定格式的数据（例如json），页面每个列表项都是一个item，返回的信息经过js解析，输出到页面上。知晓了原理，则进行下一步的诊断—“闻”。

什么？你居然闻所未闻？我下面会尽量讲的通俗易懂，不过想要真正理解我在做什么，还是需要自行掌握一定的网络知识。

“问”则是通过分析发送的请求以及返回的数据，找到接口地址、判断用到的技术、分析所需的数据。先填入正确的信息模拟正常操作，查看网络请求的本体。打开开发者控制台，输入查询条件，点击查询，运气不错，发现唯一网络请求，这正是今天的主角。

![正确网络请求数据包](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409250049824.png)

### 请求分析

#### 请求头

点击标头，看得出这条请求是使用的POST方法，API接口地址是`http://82.157.138.16:8091/CRAC/app/businessSupport/cracOperationCert/getOperCertByParamWeb`，查看请求标头，请求没有加密参数，Cookie也是常见的延长Session生命周期的`JSESSIONID`，这意味着这条接口可以随意请求，且不需要任何身份验证。

```
accept:
*/*
accept-encoding:
gzip, deflate
accept-language:
zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6
connection:
keep-alive
content-length:
114
content-type:
application/json; chartset=UTF-8
cookie:
JSESSIONID=74D062BFB81FCD71961AD181B4C9D2D5
host:
82.157.138.16:8091
mm:
null
origin:
http://82.157.138.16:8091
qm:
null
referer:
http://82.157.138.16:8091/CRAC/crac/pages/list_cert.html
user-agent:
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0
x-requested-with:
XMLHttpRequest
```

#### 请求体

POST请求区别于GET请求的是POST请求是带有请求体，而不是在HTTP链接后面添加参数。所以想知道我们单击按钮后发送了什么，就需要查看请求体。

![请求体](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409250057440.png)

```json
{"req":{"page_no":"1","page_size":"100","name":"***","certificateNo":"","idCarNumber":"******************"}}
```

这段请求体是使用json格式化的，简单分析一下字段：`page_no`：页码、`page_size`：页面最多显示条数、`name`：姓名、`certificateNo`：证书编号、`idCarNumber`：身份证号

#### 测试请求

知道了请求体的内容以及格式，就可继续接下来的操作了。

“切”则是整个研究中想象力发挥最丰富的时刻了，利用接口的技术数不胜数，该研究我将用简单易上手的Python来完成接口调用。

在Python中有很多操作网络请求的库，比较好用的则莫过于`requests`，简单几步即可完成模拟网络请求。在该脚本中，为了使代码更健硕，在输入时自动进行输入验证，脚本会自动检测输入是否合法并做出提示；在请求时自动判断是否成功。请求成功后则将查询到的信息输出到界面上。

*错误输入结果*

![错误输入结果](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409250114539.png)

*正确输入结果*

![正确输入结果](https://isjingbincn-wordpress-image.oss-cn-beijing.aliyuncs.com/202409250116734.png)

源代码如下：

```python
import re
import requests
import json

# 中文姓名正则表达式
chinese_name_pattern = r'^[\u4E00-\u9FA5]{2,4}$'

# 身份证正则表达式
_IDRe18 = re.compile(r'^([1-6][1-9]|50)\d{4}(18|19|20)\d{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$')
_IDre15 = re.compile(r'^([1-6][1-9]|50)\d{4}\d{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)\d{3}$')

# 输入提示
page_no = 1
page_size = 100

while True:
    name = input("请输入姓名：")
    if re.match(chinese_name_pattern, name):
        break
    print("姓名应为2-4位中文，请重新输入。")

while True:
    certificateNo = input("请输入证书编号（选填）：")
    if not certificateNo:
        break
    pattern = r'^[ABC]\d{9}$'
    if re.match(pattern, certificateNo):
        break
    print("证书编号格式应为首字母 ABC 加 9 位数字，请重新输入。")

while True:
    idCarNumber = input("请输入身份证号：")
    if _IDRe18.match(idCarNumber) or _IDre15.match(idCarNumber):
        break
    print("身份证号格式不正确，请重新输入。")

# API 请求
url = "http://82.157.138.16:8091/CRAC/app/businessSupport/cracOperationCert/getOperCertByParamWeb"
headers = {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
    "Connection": "keep-alive",
    "Content-Type": "application/json; chartset=UTF-8",
    "Cookie": "",
    "Host": "82.157.138.16:8091",
    "Origin": "http://82.157.138.16:8091",
    "Referer": "http://82.157.138.16:8091/CRAC/crac/pages/list_cert.html",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0",
    "X-Requested-With": "XMLHttpRequest",
    "mm": "null",
    "qm": "null"
}
data = {
    "req": {
        "page_no": page_no,
        "page_size": page_size,
        "name": name,
        "certificateNo": certificateNo,
        "idCarNumber": idCarNumber
    }
}

try:
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()  # 检查请求是否成功
except requests.exceptions.RequestException as e:
    print(f"请求发送时发生错误：{e}")
    exit()

try:
    prc_list = response.json()['res']['prcList']
except json.JSONDecodeError:
    print("响应数据不是有效的 JSON 格式")
    exit()

if not prc_list:
    print("未找到相关证书信息")
    exit()

# 提取有用信息并格式化输出
for item in prc_list:
    print(f"身份 ID: {item.get('id', '')}")
    print(f"姓名: {item.get('name', '')}")
    print(f"性别: {item.get('sex', '')}")
    print(f"操作类别: {item.get('type', '')}")
    print(f"证书编号: {item.get('certificateNo', '')}")
    print(f"通过日期: {item.get('passDate', '')}")
    print(f"通过地点: {item.get('passAddr', '')}")
    print(f"核发日期: {item.get('issueDate', '')}")
    print(f"核发机构: {item.get('addr', '')}")
    print("---------------------------")
```

## 尾声

通过这次分析，我发现该查询接口并没有做加密措施，调用起来很容易，所以该社区很有可能自行利用该接口，二次开发完成证书验证的。这一次的分析让我重温了从判断页面类型，模拟网络请求，到分析网络请求并进行调用测试的过程，感觉不错。
希望未来能与更多的爱好者们相识，73！再会！
