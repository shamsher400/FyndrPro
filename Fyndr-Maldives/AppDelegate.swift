//
//  AppDelegate.swift
//  Fyndr
//
//  Created by BlackNGreen on 15/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import CoreData
import FacebookCore
import GoogleSignIn
import KYDrawerController
import Firebase
import UserNotifications
import SwiftyJSON
import Fabric
import Crashlytics

//let GOOGLE_API_KEY = "AIzaSyCgODTpgOsrcqSstI07B9oo6cmHDZyi_b0"

enum ScreenName {
    case intro
    case registartion
    case cretaeProfile
    case interest
    case dashboard
}

enum AppState : String{
    case background
    case froground
    case start
    case stop
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCurrentState = AppState.background.rawValue
    let TAG = "AppDelegate :: "
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // UIApplication.shared.statusBarStyle = .lightContent
        // Facebook
     //   SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        
      
        if let langCode = (UserDefaults.standard.object(forKey: "AppleLanguages") as? [String])?.first
        {
            Bundle.set(language: Language.init(languageCode: langCode) ?? Util.getDeviceDefaultLanguage())
        }
        else {
            Bundle.set(language: Util.getDeviceDefaultLanguage())
        }
        
        registerForPushNotifications()
        setupNavBarDesign()
        initChatManager(myProfile: nil, chatConfiguration: nil)
        
        // Configure Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        
        openScreen(screenName: Util.getCurrentScreen().0  , firstScreen: true)
        
        handleIncomingPushNotification(application, launchOptions: launchOptions)
        if ChatManager.share.isReady
        {
            ChatManager.share.connect()
        }
        checkForAnyUpdate()
        
        AppAnalytics.log(.start)
        TPAnalytics.log(.start)
        
        GIDSignIn.sharedInstance().clientID = "226037568216-bpfpeum9ick73vq0tbou6n5g79ckfhba.apps.googleusercontent.com"

        UITextField.appearance().defaultFont = UIFont.appFont()
        registerTransactionObserver()
        
        updateLayoutForLanguage()
        
        return true
    }
    
    func checkForAnyUpdate() // Check for any update on server like version update
    {
        if Util.getProfile() != nil
        {
            if Reachability.isInternetConnected()
            {
                RequestManager.shared.appConfigurationRequest(configurationType : .basic, onCompletion: { (responseJson) in
                    // TODO: - Handle update
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue {
                        let appConfig = AppConfiguration.init(json: responseJson)
                        print("basic configuration check \(appConfig)")
                        
                    }

                    
                }) { (error) in
                }
            }
        }
    }
    
    func setupNavBarDesign()
    {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.appPrimaryBlueColor
        //navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, .font : UIFont.monospacedDigitSystemFont(ofSize: 22, weight: UIFont.Weight.medium)]
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appPrimaryBlueColor, .font : UIFont.autoScale(weight: .semibold, size: 17)]
            navigationBarAppearace.barTintColor = UIColor.appPrimaryColor
        navigationBarAppearace.semanticContentAttribute = .forceLeftToRight

        
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.appPrimaryColor], for: .normal)
        barButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.appPrimaryColor], for: .highlighted)
        barButtonItemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [CitySearchViewController.self]).setTitleTextAttributes([.foregroundColor: UIColor.blue], for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIImagePickerController.self]).setTitleTextAttributes([.foregroundColor: UIColor.appPrimaryColor], for: .normal)
    }
    
    func openScreen(screenName : ScreenName, firstScreen : Bool)
    {
        var viewController : UIViewController?
        
        switch screenName {
        case .intro:
            viewController = UIStoryboard.getViewController(identifier: "IntroViewController")
        case .registartion:
            viewController = UIStoryboard.getViewController(identifier: "RegistrationViewController")
        case .cretaeProfile:
            viewController = UIStoryboard.getViewController(identifier: "CreateProfileViewController")
        case .interest:
            viewController = UIStoryboard.getViewController(identifier: "InterestViewController")
        case .dashboard:
            viewController = UIStoryboard.getViewController(identifier: "DashboardViewController")
        }
        
        guard let vc = viewController else {
            return
        }
        
        var drawerController : KYDrawerController?
        
        if firstScreen
        {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.backgroundColor = UIColor.white
            window?.makeKeyAndVisible()
            
            drawerController = KYDrawerController(drawerDirection: .left, drawerWidth: SCREEN_WIDTH)
            let navController = UINavigationController.init(rootViewController: vc)
            drawerController?.mainViewController = navController
            window?.rootViewController = drawerController
        }else{
            drawerController = self.window?.rootViewController as? KYDrawerController
            let navController = drawerController?.mainViewController
            (navController as! UINavigationController).setViewControllers([vc], animated: false)
        }
        
        if screenName == .dashboard
        {
            let drawerViewController = UIStoryboard.getViewController(identifier: "ProfileViewController")
            let navigationController = UINavigationController.init(rootViewController: drawerViewController)
            drawerController?.drawerViewController = navigationController
        }
        
        updateLayoutForLanguage()
    }
    
    // Authenticate and open callbackScreens
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookLogin = ApplicationDelegate.shared.application(app, open: url, options: options)
        let googleLoginHandler = GIDSignIn.sharedInstance()?.handle(url)
        
        var fromApp = false
        print(TAG + "app open url " + url.absoluteString)
        if url.absoluteString.contains("ewoutpewout"){
            print(TAG + "app open url " + url.absoluteString)
            fromApp = true
            getTopViewController()?.dismiss(animated: true, completion: nil)
        }
        
        return facebookLogin || googleLoginHandler! || fromApp
                
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
//    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        appCurrentState = AppState.background.rawValue
        
        ChatManager.share.manageChatMangerState(isForground: false)
        
        AppAnalyticsEngine.init().uploadEventOnServer()
        BookmarkManager.shared.updateBookmarkOnServer()
        
        AppAnalytics.log(.enterBackground)
        TPAnalytics.log(.enterBackground)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        ChatManager.share.manageChatMangerState(isForground: true)

        if application.applicationIconBadgeNumber > 0 {
            clearPushBadge()
        }
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        appCurrentState = AppState.froground.rawValue
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if application.applicationIconBadgeNumber > 0 {
            clearPushBadge()
        }
        application.applicationIconBadgeNumber = 0
        appCurrentState = AppState.froground.rawValue
        AppAnalytics.log(.enterForeground)
        TPAnalytics.log(.enterForeground)
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        AppAnalyticsEngine.init().uploadEventOnServer()
        if ChatManager.share.isReady {
            ChatManager.share.disconnect()
        }
        
        AppAnalytics.log(.terminate)
        TPAnalytics.log(.terminate)
    }
    
    
    // MARK: - Chat
    func initChatManager(myProfile : Profile?, chatConfiguration : ChatConfiguration?)
    {
        var profileObj : Profile?
        if myProfile != nil
        {
            profileObj = myProfile
        }else{
            profileObj = Util.getProfile()
        }
        guard let profile = profileObj else {
            print("Chat : not init due to invalid profile")
            return
        }
        print("Chat : Init ChatManager : \(String(describing: profile.uniqueId))")
        
        guard let chatConfiguration = chatConfiguration else {
            print("Chat : chat configuration not found ")
            return
        }
        
        ChatManager.share.configure(profile: profile, chatConfiguration: chatConfiguration)
        if ChatManager.share.isReady {
            ChatManager.share.connect()
        }
    }
    
    func logoutFromDevice(message : String?)
    {
        DispatchQueue.main.async{
            if Util.getCurrentScreen().0 == ScreenName.intro {
                return
            }
            self.logout()
            if let message = message
            {
                AlertView().showNotficationMessage(message: message)
            }
            self.openScreen(screenName: .intro, firstScreen: true)
        }
    }
    
    // MARK: - Logout
    func sessionExpired()
    {
        DispatchQueue.main.async{
            if Util.getCurrentScreen().0 == ScreenName.intro {
                return
            }
            self.logout()
            self.openScreen(screenName: .intro, firstScreen: true)
        }
    }
    
    func logout()
    {
        if ChatManager.share.isReady {
            ChatManager.share.disconnect()
        }
                
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.MY_PROFILE)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.USER_ID)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.AUTH_TOKEN)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.BROWSE_PROFILE_LIST)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.BROWSE_CATEGORY_LIST)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.REPORT_REASONS)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.SIP_CONFIG)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.CHAT_CONFIG)

        UserDefaults.standard.synchronize()
        
        AppFileManager().deleteMyRecodingFile()
        DatabaseManager.shared.clearAllStoredData(exceptChat : false)
    }
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Fyndr")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    public func updateLayoutForLanguage(){
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        UITextField.appearance().semanticContentAttribute = .forceLeftToRight
        UILabel.appearance().semanticContentAttribute = .forceLeftToRight
        setupNavBarDesign()
    }
}


extension AppDelegate {
    
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                print("Notification : permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                print("Notification : register")
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Notification : Device Token : ", token)
        NotificationManager.shared.registerForServerNotifications(pushToken: token)
    }
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error:Error){
        print("Notification : Failed to register: \(error)")
    }
    
    func handleIncomingPushNotification(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    {
        // Check if launched from notification
        print("AppDelegate: handleIncomingPushNotification()")
        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String: AnyObject],
            let _ = notification["aps"] as? [String: AnyObject] {
            NotificationManager.shared.handleNotification(userInfo: notification, application: application)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("AppDelegate: didReceiveRemoteNotification()")
        guard (userInfo["aps"] as? [String: AnyObject]) != nil else {
            completionHandler(.failed)
            return
        }
        NotificationManager.shared.handleNotification(userInfo: userInfo, application: application)
    }
    func clearPushBadge() {
        //CallORequestManager.sharedInstance.clearPushBadge { (response) in}
    }
}

extension AppDelegate {
    
    func getTopViewController() -> UIViewController?
    {
        return getTopViewControllerWithRootViewController(rootViewController: (UIApplication.shared.keyWindow?.rootViewController))
    }

    private func getTopViewControllerWithRootViewController(rootViewController : AnyObject?) -> UIViewController?
    {
        if let rootViewController = rootViewController
        {
            if let drawerController = rootViewController as? KYDrawerController {
                
                if drawerController.drawerState == .opened
                {
                    return getTopViewControllerWithRootViewController(rootViewController: drawerController.drawerViewController)
                }else{
                    return getTopViewControllerWithRootViewController(rootViewController: drawerController.mainViewController)
                }
            }
            
            if let navigation = rootViewController as? UINavigationController {
                return getTopViewControllerWithRootViewController(rootViewController: navigation.visibleViewController?.topMostViewController() ?? navigation)
            }
            
            if let viewController = rootViewController as? UIViewController {
                if viewController.presentedViewController != nil {
                    return getTopViewControllerWithRootViewController(rootViewController: viewController.presentedViewController)
                }
                return viewController
            }
        }
        return nil
    }
    
    func openRecentViewController()
    {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        {
            if let drawerController = rootViewController as? KYDrawerController {
                
                let topVC = drawerController.mainViewController
                if drawerController.drawerState == .opened
                {
                    let drawerVC = drawerController.drawerViewController
                    if drawerVC?.presentedViewController != nil
                    {
                        drawerVC?.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                    drawerController.setDrawerState(.closed, animated: false)
                }
                    
                if let navigation = topVC as? UINavigationController {
                    navigation.popToRootViewController(animated: false)
                    
                    if let dashBoardVC = navigation.topViewController as? DashboardViewController
                    {
                        dashBoardVC.openRecentViewController()
                    }
                }
            }
        }
    }
    
    
    func openChatViewController(uniqueId: String)
    {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        {
            if let drawerController = rootViewController as? KYDrawerController {
                let topVC = drawerController.mainViewController
                if let navigation = topVC as? UINavigationController {
                    if let dashBoardVC = navigation.topViewController as? RecentViewController
                    {
                        DispatchQueue.main.async {
                            dashBoardVC.openChatViewController(chatHistory: Util.getChatHistory(uniqId: uniqueId))
                        }
                    }
                }
            }
        }
    }
    
    
    func getChatHistory(chatModel: ChatModel) -> ChatHistory{
        
        var chatHistory = ChatHistory()
            if let uniqId = chatModel.uniqueId {
                chatHistory = DatabaseManager.shared.getChatHistory(for: uniqId)!
            }
        return chatHistory
        
    }
}


extension UIViewController {
    
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("userNotificationCenter - gotedd")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("userNotificationCenter - gotedc")
        
        completionHandler()
        
        // handle local notifications 

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificationCenter - goteddb")

    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let userData = notification.userInfo as NSDictionary? as? [AnyHashable: Any] ?? [:]
            print("userNotificationCenter - didReceiveFinal \(userData["uniqueId"] as? String ?? "heta")")
        if let uniqId = userData["uniqueId"] as? String {
            tapChatNotificationOpenScreens(uniqueId: uniqId)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("userNotificationCenter - didReceiveRemoteNotification")

    }
    
    func tapChatNotificationOpenScreens(uniqueId: String) {
        let topVC = APP_DELEGATE.getTopViewController()
        print("topVC : \(String(describing: topVC))")
        if topVC?.isKind(of: RecentViewController.self) ?? false {
            DispatchQueue.main.async {
                self.openChatViewController(uniqueId: uniqueId)
            }
        }else if let chatVC =  topVC as? ChatViewController {
            DispatchQueue.main.async {
                chatVC.refreshChatViews(chatHistory: Util.getChatHistory(uniqId: uniqueId))
            }
        }else {
            APP_DELEGATE.openRecentViewController()
        }
    }
    
    
    
    private func registerTransactionObserver(){
        
        InAppManager.sharedInstance.registerTransactionObserver()
    }
}
