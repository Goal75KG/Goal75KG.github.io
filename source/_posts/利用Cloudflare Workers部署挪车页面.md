---
title: 利用Cloudflare Workers部署挪车页面
tags: Cloudflare
categories: 教程
abbrlink: e4cc6b22
date: 2024-11-12 19:28:29
---
# 前言

论坛中刷到有人利用Cloudflare Workers部署挪车页面，看到有人不会部署，遂写此文，分享一下如何部署到Cloudflare Workers并绑定域名。

# 前期准备

- 已经托管到Cloudflare的域名一个
- 挪车源代码
- WXPusher的`AppToken`、`UIDs`

若未注册Cloudflare，未托管域名到Cloudflare，请移步完成上述操作后再阅读本教程。

> 提供一个Cloudflare托管阿里云域名的教程（仅供参考）：https://blog.csdn.net/zhyl8157121/article/details/100551592

# 部署流程

## WxPuhser

1. 访问[WxPusher官网](https://wxpusher.zjiecode.com/)，微信扫码登录
2. 单击「应用管理」，「应用信息」，应用名字填写`movecar`，联系方式填写手机号，推送内容随便写，这里填写`挪车`

![image-20241112172836932](https://blogimg.situ.edu.kg/PicGo/202411121728012.png)

3. 单击左侧「appToken」，未创建应用可能显示创建`appToken`等字样，创建后这里仅显示`重置appToken`，创建后记录下`AppToken`
4. 单击左侧「用户管理」、「用户列表」，记录下个人UID

![image-20241112173103996](https://blogimg.situ.edu.kg/PicGo/202411121731074.png)

## Cloudflare Workers

1. 访问[Cloudlare](https://dash.cloudflare.com/)并登录。
2. 单击「Workers 和 Pages」，「创建」

![image-20241112165513293](https://blogimg.situ.edu.kg/PicGo/202411121655382.png)

3. 单击「创建Worker」
  ![image-20241112165611685](https://blogimg.situ.edu.kg/PicGo/202411121656763.png)

4. 为Worker命名，我这里填写movecar，单击页面下方「部署」

![image-20241112165805708](https://blogimg.situ.edu.kg/PicGo/202411121658790.png)

5. 单击「编辑代码」

![image-20241112165901508](https://blogimg.situ.edu.kg/PicGo/202411121659593.png)

6. 将提前准备好的挪车页面代码粘贴进去，替换好`WXPusher`相关的值，单击右上地址栏右面的「预览」

![image-20241112170239557](https://blogimg.situ.edu.kg/PicGo/202411121702656.png)

**这里附上源代码：**

```js
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const phone = '18888888888' // 车主的手机号
  const wxpusherAppToken = 'AT_vAxWMmK123UyvrBZszr123fWeGqW1e17' // Wxpusher APP Token
  const wxpusherUIDs = ['UID_x5dZ9X3P123VOE3ttPvfX12341xU'] // 车主的UIDs  , 'UID_d0pycYubbK6d766GNDo5deknw4i4'  

  const htmlContent = `
    <!DOCTYPE html>
    <html lang="zh-CN">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>通知车主挪车</title>
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body { font-family: Arial, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; background: #f0f2f5; color: #333; }
          .container { text-align: center; padding: 20px; width: 100%; max-width: 400px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); background: #fff; }
          h1 { font-size: 24px; margin-bottom: 20px; color: #007bff; }
          p { margin-bottom: 20px; font-size: 16px; color: #555; }
          button { 
            width: 100%; 
            padding: 15px; 
            margin: 10px 0; 
            font-size: 18px; 
            font-weight: bold; 
            color: #fff; 
            border: none; 
            border-radius: 6px; 
            cursor: pointer; 
            transition: background 0.3s; 
          }
          .notify-btn { background: #28a745; }
          .notify-btn:hover { background: #218838; }
          .call-btn { background: #17a2b8; }
          .call-btn:hover { background: #138496; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>通知车主挪车</h1>
          <p>如需通知车主，请点击以下按钮</p>
          <button class="notify-btn" onclick="notifyOwner()">通知车主挪车</button>
          <button class="call-btn" onclick="callOwner()">拨打车主电话</button>
        </div>

        <script>
          // 调用 Wxpusher API 来发送挪车通知
          function notifyOwner() {
            fetch("https://wxpusher.zjiecode.com/api/send/message", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                appToken: "${wxpusherAppToken}",
                content: "您好，有人需要您挪车，请及时处理。",
                contentType: 1,
                uids: ${JSON.stringify(wxpusherUIDs)}
              })
            })
            .then(response => response.json())
            .then(data => {
              if (data.code === 1000) {
                alert("通知已发送！");
              } else {
                alert("通知发送失败，请稍后重试。");
              }
            })
            .catch(error => {
              console.error("Error sending notification:", error);
              alert("通知发送出错，请检查网络连接。");
            });
          }

          // 拨打车主电话
          function callOwner() {
            window.location.href = "tel:${phone}";
          }
        </script>
      </body>
    </html>
  `

  return new Response(htmlContent, {
    headers: { 'Content-Type': 'text/html;charset=UTF-8' },
  })
}

```



7. 单击「通知车主挪车」，测试是否正常推送消息。

![image-20241112170352346](https://blogimg.situ.edu.kg/PicGo/202411121703429.png)

![image-20241112170417085](https://blogimg.situ.edu.kg/PicGo/202411121704129.png)

8. 单击右上「部署」，等待部署完成
9. 回到[Cloudflare主页](https://dash.cloudflare.com/)，单击托管的「域名」

![image-20241112170626925](https://blogimg.situ.edu.kg/PicGo/202411121706005.png)

10. 单击左侧「DNS」

![image-20241112170740394](https://blogimg.situ.edu.kg/PicGo/202411121707474.png)

11. 单击「添加记录」，类型选择`A`，名称随意（该名称为二级域名），IPV4随意填写，这里名称我填写`movecar`，IPV4填写`2.2.2.2`，填写完成单击「保存」

![image-20241112171051194](https://blogimg.situ.edu.kg/PicGo/202411121710277.png)

12. 单击左侧「Workers 路由」，「添加路由」，路由填写刚才设置的二级域名，Worker选择刚才创建的Worker，这里我的路由填写`movecar.**.com`，Worker选择`movecar`，单击「保存」

![image-20241112171439121](https://blogimg.situ.edu.kg/PicGo/202411121714210.png)

13. 保存成功后，尝试访问设定好的域名，单击「通知车主挪车」，测试是否正常发送

![image-20241112171638756](https://blogimg.situ.edu.kg/PicGo/202411121716858.png)

**以上就是利用Cloudflare Workers部署挪车页面的过程了，码字不易，请多多支持！**

## 选做

- 加密JS代码防止别人获取你的推送Token等信息

访问[在线JavaScript混淆加密](https://www.lddgo.net/encrypt/js)，将部署好的代码粘贴进来，单击「混淆」，将混淆后的代码粘贴回Cloudflare Workers代码编辑页面，单击「部署」即可

![image-20241112174047764](https://blogimg.situ.edu.kg/PicGo/202411121740873.png)

![image-20241112174214060](https://blogimg.situ.edu.kg/PicGo/202411121742155.png)

# 二维码转换

1. 访问[草料二维码](https://console.cli.im/)
2. 输入上面建好的页面网址，单击「生成」，注意：一定要加上https，否则微信有可能会拦截。

![image-20241112175434242](https://blogimg.situ.edu.kg/PicGo/202411121754342.png)

3. 还可以根据自己的喜好进行美化，例如我使用微信配色，让人一眼就知道要用微信扫码挪车。

![image-20241112175526935](https://blogimg.situ.edu.kg/PicGo/202411121755061.png)

4. 打印粘贴就可以了。

# 写在结尾

对于该挪车程序，有一些个人思考：

1. 避免访问者无限制地发送，应该在发送次数/时间上做一个限制。
2. 添加邮件、钉钉、Server酱等常见推送方式，以满足多样化推送需求。
3. 使用Cloudflare Workers必须添加自定义域名，否则国内大概率访问失败。