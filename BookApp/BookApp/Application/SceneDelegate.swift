import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let mainVC = UINavigationController(rootViewController: MainViewController())
        let listVC = UINavigationController(rootViewController: BookListViewController())
        
        let tabBarController = UITabBarController()
        
        tabBarController.setViewControllers([mainVC, listVC], animated: true)
        
        tabBarController.tabBar.tintColor = .black
        tabBarController.tabBar.unselectedItemTintColor = .darkGray
        
        if let items = tabBarController.tabBar.items {
            items[0].selectedImage = UIImage(systemName: "magnifyingglass.circle.fill")
            items[0].image = UIImage(systemName: "magnifyingglass.circle")
            items[0].title = "책 검색"
            
            items[1].selectedImage = UIImage(systemName: "folder.fill")
            items[1].image = UIImage(systemName: "folder")
            items[1].title = "책 리스트"
        }
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
