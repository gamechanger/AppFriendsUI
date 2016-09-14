# AppFriends UI

AppFriendsUI is an open source library which provides customizable UI components and example usage of AppFriends. It's a great starting point to build an app using AppFriends. It can save you a lot of development hours. Besides UI components, this library also provides convenient methods for you to handles dialogs, send/receive messages and query for users. It uses CoreData to store dialogs and 

## Example App
You can checkout how to use this SDK together with the AppFriendsCore SDK by running the AFChatUISample app included in this repo.

## Integration

#### Step 1 - cocoapod installation
To integrate AppFriends iOS SDK to your Xcode iOS project, add this line in your `Podfile`

	pod 'AppFriendsUI'
	
Also, add `use_frameworks!` to the file. eg.

	platform :ios, "8.0"
	use_frameworks!
	...
	
#### Step 2 - initialization
After installation, the first thing you need to do is initializing the SDK. Look for `AppFriendsUI`, then invoke:
``
public func initialize(completion: ((success: Bool, error: NSError?) -> ())? = nil)
``
You need to do this after you initialize the `AppFriendsCore` library

#### Step 3 - Login
Then you need to login the user by using `AppFriendsCore`. After login is successful, you can start using all the components of `AppFriendsUI`

## UI Components

### AppFriends Chat Container
`AppFriendsUI` has a `HCChatContainerViewController` which contains a dialog list view, a friends list view and chat view. This is the easiest way to use AppFriends. You can use it by calling:

```
let chatContainer = HCChatContainerViewController(tabs:HCTitles.dialogsTabTitle, HCTitles.contactsTabTitle])
let nav = UINavigationController(rootViewController: chatContainer)
nav.navigationBar.tintColor = UIColor.whiteColor()
self.presentVC(nav)
```

### Dialog List
`HCDialogsListViewController` is a class to help you display your dialogs list. 

![Alt text](http://res.cloudinary.com/hacknocraft-appfriends/image/upload/v1473191446/dialogsList_zwzuiz.png "Dialogs List Example")

### Chat UI
`HCBaseChatViewController` or `HCDialogChatViewController` is a class you can use to display a chat UI. It provides basic chat UI.

### Typing Indicator
You can send typing events with startTyping and endTyping. If you use the chat view provided by this library, type indicator is provided for you automatically, so you don't have to write any additional code.

![Alt text](http://res.cloudinary.com/hacknocraft-appfriends/image/upload/c_scale,w_200/v1473730653/Simulator_Screen_Shot_Sep_12_2016_5.28.26_PM_uetywi.png "Search User Example")

#### Start typing
`DialogsManager.sharedInstance.startTyping(_dialogID, dialogType: _dialogType)`

#### End typing
`DialogsManager.sharedInstance.endTyping(_dialogID, dialogType: _dialogType)`


### Search User
`AppFriendsUI` offers a convenient UI for you to search for users. To use this UI, you can either directly use `HCUserSearchViewController` or create its sub class. 

![Alt text](http://res.cloudinary.com/hacknocraft-appfriends/image/upload/v1473189966/Simulator_Screen_Shot_Sep_6_2016_3.25.43_PM_auyjtu.png "Search User Example")

### Side Panel
Sometimes, you may not wish to leave the current screen to show the chat. With `AppFriendsUI`, you can achieve this very easily by using a side panel. 

![Alt text](http://res.cloudinary.com/hacknocraft-appfriends/image/upload/c_scale,w_200/v1473185124/screenshot_fuwkjq.png "Side Panel Example")

#### Example
```
// use this code in one of your view controller
AppFriendsUI.sharedInstance.presentVCInSidePanel(fromVC: self, showVC: channelChatVC, direction: .Left)
```

## UI Customization
`AppFriendsUI` customization can be done through `HCUIConfiguration`. You can change the color, font, and text. Example:

```
HCColorPalette.chatBackgroundColor = UIColor(hexString: "0d0e28")
HCColorPalette.SegmentSelectorOnBgColor = UIColor(hexString: "3c3a60")
```

If more advanced customizations are needed, you can sub class components of AppFriendsUI. 

## Logout
When you want to switch user, don't forget to log out the user by 
`AppFriendsUI.sharedInstance.logout()`