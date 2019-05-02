![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/ToolManTogether/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60%402x.png)
# Toolgather App

## Main concept 
工聚人是款當遇到困擾的事情卻無能為力時，讓你可以透過發出任務來使用他人的生活技能，同時也分享自己的專長來回饋，就此形成一個工具人社群網路。


##  Key function
### 點擊地圖上的任務圖標，秀出任務細節畫面的動畫效果

![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/IMG_01.PNG) ![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/IMG_02.PNG)
#### 三個步驟:
1. 我們可以透過 MapKit 本身提供的方法來拿到使用者點擊了哪個 Annotation，同時拿到該點的經緯度資料，進行後續動作。
```javascript
func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
  
        guard let coordinate = view.annotation?.coordinate else {
            return
        }
        
        animateViewUp()
        ...
        ...
    }
```

2. 將手勢加到地圖上，讓使用者點擊其他地方可以將任務詳細頁面縮回。
```javascript
  func addTap(taskCoordinate: CLLocationCoordinate2D) {
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(animateViewDown))
        mapView.addGestureRecognizer(mapTap)
  }
```
3. 任務細節 view 的動畫效果，可以透過動態調整該 view 的高來達到彈出又隱藏的動畫效果。




## Remote Push Notification
### 當使用者申請的任務狀態被拒絕或同意，或是任務聊天室新訊息，使用者會收到訊息，點擊通知後會直接進入該資訊的頁面。

#### 必須執行的三個前置任務:
1. 必須正確配置應用程序並向 Apple 推送通知服務（APNS）註冊才能在每次啟動時接收推送通知。
2. 服務器必須向指向一個或多個特定設備的APNS發送推送通知。
3. 該應用程式必須收到推送通知後，它可以進一步使用應用程序中的function 來執行任務或處理操作。

#### 配置推送:
1. 在 Xcode 中啟用推播通知權利 （需要同時登錄 Apple 開發人員中心創建App ID，並添加通知選項），
![](https://i.imgur.com/HB3cud7.png)

![](https://i.imgur.com/L6vbhUf.png)

2. 在 Appdelegate.swift 添加以下代碼：

```javascript
func registerForPushNotifications() {
  UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
    (granted, error) in
    print("Permission granted: \(granted)")
  }
}
```
* .badge 允許在 icon 的角落顯示一個數字。
* .sound 允許該播放聲音。
* .alert 允許該顯示文字。


#### 註冊推送:

1. 驗證使用者是否已授權註冊
```javascript
func getNotificationSettings() {
  UNUserNotificationCenter.current().getNotificationSettings { (settings) in
    print("Notification settings: \(settings)")
    guard settings.authorizationStatus == .authorized else { return }
    UIApplication.shared.registerForRemoteNotifications()
  }
}
```
2. 藉由此方法，拿到該裝置的專屬推播 Token，他是 APNS 所提供，發送推播通知時，此 Token 就像地址一樣，向正確的裝置發送通知。
```javascript
InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")

```

3. 在 HTTP Request 部分，如果是透過 Firebase 的推播服務，需要拿到該伺服器金鑰，並在發送 HTTP 請求時輸入在 Header 裡，同時上傳自己的 APNS 憑證
![](https://i.imgur.com/YPAY3EE.png)
![](https://i.imgur.com/cUdrU95.png)

```javascript
let headers = [金鑰]
```

4. 在 parameters 裡透過 json 將訊息寫在裡面

```javascript![](https://i.imgur.com/kXPEywf.jpg)
{
  "aps": {
    "alert": "新訊息",
    "sound": "default",
    "自訂Key": Test
  }
}
```

* alert。這可以是字符，如前面的示例，或字典本身。
* badge。顯示在 icon 角落的數字。可以通過設置為0來刪除徽章。
* sound。可以播放位於應用程序中的自定義通知聲音，而不是默認通知聲音。自定義通知聲音必須短於30秒，並有一些限制。

如果一切順利的話，你將可以收到推播通知。

![](https://i.imgur.com/UfKYNQE.png)



### 收到推播然後呢？

當您的 App 收到推播通知後，需在 UIApplicationDelegate 裡處理收到的通知。

通常需要根據 App 收到時的狀態進行不同的處理：


* 1. 如果 App 沒有運行，使用者通過點擊推播通知啟動它，推播通知將傳遞到launchOptions的 application(_:didFinishLaunchingWithOptions:)。

* 2. 如果 App 在前台或後台運行，application(_:didReceiveRemoteNotification:fetchCompletionHandler:)則會被調用。如果用戶通過點擊推送通知打開應用程序，則可以再次調用此方法，以便您可以更新UI並顯示相關信息。

在第一種情況下，需將以下代碼加到application(_:didFinishLaunchingWithOptions:) return 之前，用來解析收到的 remoteNotification ，如果解析一切順利，後續可以加上使用者點擊之後的事件處理。


```javascript

if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
  
  let aps = notification["aps"] as! [String: AnyObject]
  ...
  ...
}
```

第二種情況則要使用此方法來處理收到的推播訊息。

```javascript

func application(
  _ application: UIApplication,
  didReceiveRemoteNotification userInfo: [AnyHashable : Any],
  fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  
  let aps = userInfo["aps"] as! [String: AnyObject]
}

```


＊備註
1. 要測試是否成功，需要特別設定一下 Xcode 設定，將會讓您的模擬裝置等待啟動，直到使用者點擊推播後才開啟。

![](https://i.imgur.com/U5Shgil.png) ![](https://i.imgur.com/VE6FqDN.png)

2. 需特別注意如果使用者重新卸載或是安裝此 App，則該裝置的 Token 將會更新。解決辦法就是使用者重新登入 App 時，重新取得該裝置目前最新的 Token，以確保問題不會發生。


## 聊天室顯示未讀訊息
* 收到新訊息時，會收到推播訊息以及聊天室未讀UI

![](https://i.imgur.com/wLFKSX8.png)![](https://i.imgur.com/bMRHfwa.png)

* 利用 Firebase realtime database ，在一對一聊天室中，拿到每筆  message 後，同時上傳該使用者的 ID 加上特定 key，藉此來判斷兩位聊天室成員是否都看過此訊息。所以在聊天室列表中，最後一筆留言沒有該使用者的特定 key 就顯示未讀的 UI。 



## 使用總覽

### 收尋任務頁面
* 選擇任務

![](https://i.imgur.com/Kwm4JID.png)

### 已接任務頁面
* 任務狀態改變時，會立即收到通知

![](https://i.imgur.com/7AY4GmC.png)![](https://i.imgur.com/ImXA4hp.png)


### 新增任務頁面
* 輸入任務內容 

![](https://i.imgur.com/CNInCi2.png)
* 自訂任務地點

![](https://i.imgur.com/NPLxau8.png)



### 任務配對頁面 
* 查詢申請者資訊

![](https://i.imgur.com/SbNukgC.png)

* 透過聊天室與對方聯繫

![](https://i.imgur.com/kcUlbTI.png)![](https://i.imgur.com/SD9QpOM.png)





## Libraries
* Crashlytics
* Firebase SDK
* Facebook SDK
* IQKeyboardManagerSwift
* KeychainSwift
* Kingfisher
* Lottie
* SwiftLint

## Requirement
* iOS 11.4 +
* XCode 10.0


## Version
* 2.0 - 2018/10/31
  * 新增任務聊天室
  * 新增地圖縮放顯示任務圖標功能

* 1.0 - 2018/10/20
  * 第一版上架
 

## Contacts
Spock Hsueh spock.hsu@gmail.com





 

