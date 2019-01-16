//
//  AppCoordinator.swift
//  phixer
//
//  Created by Philip Price on 1/14/19.
//  Copyright © 2019 Nateemma. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleMobileAds

// class that implements the coordination for the main (top-level) App
// Note that this Coordinator is different from others in that it interacts with the ppDelegate to set up the root view controller etc.

class AppCoordinator: Coordinator {
   
    
    
    /////////////////////////////
    // MARK:  Interaction with AppDelegate. Do not put this in any other Coodinator classes
    /////////////////////////////

    var window: UIWindow? = nil
    
    init(window: UIWindow?) {
        self.window = window
        Coordinator.navigationController = UINavigationController()
   }
    
    
    
    /////////////////////////////
    // MARK:  Delegate Functions
    /////////////////////////////
    
    override func startRequest(completion: @escaping ()->()){
        // Logging nicety, show that controller has changed:
        print ("\n========== \(String(describing: type(of: self))) ==========\n")
        
        guard let window = window else {
            return
        }
        
        window.rootViewController = Coordinator.navigationController
        window.makeKeyAndVisible()

        // reset controller/coordinator vars
        self.completionHandler = completion
        self.subCoordinators = [:]
        self.mainController = nil
        self.subControllers = [:]
        self.validControllers = []

        //TODO: display transition screen while the App is being prepared???
        
        prepareApp()
        
        startMainController()
        
    }
    
    /////////////////////////////
    // MARK:  Initial Setup
    /////////////////////////////
 
    func prepareApp(){
        
        setupAds()
        setupTheme()
        setupConfig()
        setupCoordinator()
    }

    private func setupAds() {
        // set up Google banner ad framework. Use the Firebase library to configure APIs
        FirebaseApp.configure()
        
        //GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511"); // Test ID, replace when ready
        GADMobileAds.configure(withApplicationID: Admob.appID)
    }
    
     private func setupTheme() {

        // set the global colour scheme
        ThemeManager.applyTheme(key: ThemeManager.getSavedTheme())
    }
    
    private func setupConfig() {
        // Create an instance of Filteranager. This will take care of reading the configuration file etc.
        Coordinator.filterManager = FilterManager.sharedInstance
        
        setupFrames()
        
    }
    
    private func setupCoordinator() {
        
        self.mainControllerId = .home
        
        // define the list of valid Controllers
        self.validControllers = [ .home, .edit, .browseFilters, .browseStyleTransfer, .settings ]
        
        // map controllers to their associated coordinators
        self.coordinatorMap [ControllerIdentifier.edit] = CoordinatorIdentifier.edit
        self.coordinatorMap [ControllerIdentifier.browseFilters] = CoordinatorIdentifier.browseFilters
        self.coordinatorMap [ControllerIdentifier.browseStyleTransfer] = CoordinatorIdentifier.browseStyleTransfer
        self.coordinatorMap [ControllerIdentifier.settings] = CoordinatorIdentifier.settings

    }


    // set up frames for the various types of controllers:
    private func setupFrames() {

        let w = UIScreen.main.bounds.size.width
        let h = UIScreen.main.bounds.size.height
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (Coordinator.navigationController?.navigationBar.frame.height ?? 0.0)
        let menuHeight:CGFloat = 88.0
        
        let fullFrame:CGRect = CGRect(x: 0, y: topBarHeight, width: w, height: h-topBarHeight)
        let menuFrame:CGRect = CGRect(x: 0, y: h-menuHeight, width: w, height: menuHeight)
        let toolFrame:CGRect = CGRect(x: menuHeight/2.0, y: menuHeight, width: w-2.0*menuHeight, height: w-2.0*menuHeight)
        
        ControllerFactory.setFrame(.fullscreen, frame: fullFrame)
        ControllerFactory.setFrame(.menu, frame: menuFrame)
        ControllerFactory.setFrame(.tool, frame: toolFrame)

        log.debug("screen: (\(w),\(h)), top bar h: \(topBarHeight)")
    }

    
    /////////////////////////////
    // MARK:  Main Logic
    /////////////////////////////

    private func startMainController() {
        
        // a little different since nothing is running yet
        
        self.mainController = MainMenuController()
        self.mainController?.coordinator = self
        self.mainControllerTag = (self.mainController?.getTag())!
        self.mainControllerId = .home
        Coordinator.navigationController?.setViewControllers([self.mainController!], animated: true)

       // self.activate(self.mainControllerId)
//        if self.mainController != nil {
//            Coordinator.navigationController = UINavigationController(rootViewController: self.mainController!)
//            //window?.rootViewController = self.mainController
//        }
    }
}