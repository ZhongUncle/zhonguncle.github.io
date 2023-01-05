---
layout: article
category: SwiftUI
title: 「SwiftUI」推送通知（Notifications）二三事
---
<!-- excerpt-start -->
有很多需要推送通知的情况，但是关于SwiftUI的通知推送说的人却不多，这里就说一些相关内容。一方面是为了自己能以后再查阅，另外一方面也是想能帮到有需要的人。

本文将讲述：

 1. 基础款推送（最常见的通知）
 2. 定时型推送（例如闹铃，纪念日等）

**在讲述具体操作之前，需要注意一点：通知不能出现在app打开的时候。测试的时候使用模拟器或者实机测试，按完按钮要退出app一下。**

## 基础款推送
首先来讲述一下最基础的推送，也是最常用的。样式如下：

![请添加图片描述](/assets/images/b98af0a25c2b49049246400ad2045c34.png)
代码如下：

```swift
import SwiftUI
import UserNotifications

//询问用户是否允许该app推送通知
//由于推送系统中类型蛮多的，可以自己去“设置”中研究一下。这里的.alert表示是否允许弹窗； .sound表示是否允许提示音；.badge表示通知弹窗中的那个小图。
func setNotification(){
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){ (granted, _) in
        if granted {
            //用户同意我们推送通知
            print("用户同意我们推送通知")
        }else{
            //用户不同意
            print("用户不同意")
        }
    }
}

//推送通知
func makeNotification(){
    //设置通知的触发器：5秒后触发推送（这种通知推送不能重复）
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    //通知的内容
    let content = UNMutableNotificationContent()
    content.title = "通知的标题"
    content.body = "通知的内容"
    /* 通知提示音，default是“叮～”，就是短信的提示音。还有个defaultCritical，就是一般app推送通知的声音 */
    content.sound = UNNotificationSound.default 
    
    //完成通知的设置
    let request = UNNotificationRequest(identifier: "通知名称", content: content, trigger: trigger)
    //添加我们的通知到UNUserNotificationCenter推送的队列里
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
                setNotification()
            }) {
                Text("获取推送权限")
                    .padding()
            }
            Button(action: {
                makeNotification()
            }) {
                Text("推送通知")
                    .padding()
            }
        }
    }
}
```

## 定时推送通知
有时候闹钟或者To-Do类型的软件需要定时推送通知，样式和实现基础款差不多，只是触发器和提示音部分有点区别（**需要注意这个自定义的提示音不能超过30秒，不然系统会播放默认声音**），代码如下：

```swift
import SwiftUI
import UserNotifications

func setNotification(){
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){ (granted, _) in
        if granted {
            //用户同意我们推送通知
            print("用户同意我们推送通知")
        }else{
            //用户不同意
            print("用户不同意")
        }
    }
}

//推送通知
func makeNotification(){
    //设置通知的时间：推送时间为6点30分
    var dateComponents = DateComponents()
    dateComponents.hour = 6
    dateComponents.minute = 30
    //这里最后让repeats为true表示每天的6点30分都会推送通知
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    
    //通知的内容
    let content = UNMutableNotificationContent()
    content.title = "通知的标题"
    content.body = "通知的内容"
    /* 需要注意这个自定义的提示音不能超过30秒，不然系统会播放默认声音 */
    content.sound = UNNotificationSound.init(named: UNNotificationSoundName("ring.m4a"))
    
    //完成通知的设置
    let request = UNNotificationRequest(identifier: "通知名称", content: content, trigger: trigger)
    //添加我们的通知到UNUserNotificationCenter推送的队列里
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
                setNotification()
            }) {
                Text("获取推送权限")
                    .padding()
            }
            Button(action: {
                makeNotification()
            }) {
                Text("推送通知")
                    .padding()
            }
        }
    }
}
```

我们还可以调整通知音量等等属性，自己可以看看哦～