## AppFriends UI

AppFriendsUI is an open source library which provides customizable UI components and example usage of AppFriends. It's a great starting point to build an app using AppFriends. It can save you a lot of development hours. Besides UI components, this library also provides convenient methods for you to handles dialogs, send/receive messages and query for users. It uses CoreData to store dialogs and 

### Example App
You can checkout how to use this SDK together with the AppFriendsCore SDK by running the AFChatUISample app included in this repo.

### Integration

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
This is typically done right after you initialize the `AppFriendsCore` library

### Components


### Usage

#### Basic

#### Advanced
