//
//  SimpleEditViewController.swift
//  phixer
//
//  Created by Philip Price on 9/6/16.
//  Copyright © 2016 Nateemma. All rights reserved.
//

import UIKit
import CoreImage
import Neon
import AVFoundation
import MediaPlayer
import AudioToolbox
import Photos

import GoogleMobileAds



private var filterList: [String] = []
private var filterCount: Int = 0

// This View Controller handles simple editing of a photo

class SimpleEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var theme = ThemeManager.currentTheme()
    
    
    
    // Banner/Navigation View (title)
    fileprivate var bannerView: TitleView! = TitleView()
    
    
    // Main Display View
    var editImageView: EditImageDisplayView! = EditImageDisplayView()
    
    // Views for holding the (modal) overlays. Note: must come after EditImageDisplayView()
    //var filterControlsView : FilterControlsView! = FilterControlsView()
    
    // The Edit controls/options
    var editControlsView: EditControlsView! = EditControlsView()
    
    // Image Selection (& save) view
    var imageSelectionView: ImageSelectionView! = ImageSelectionView()
    
    // The filter configuration subview
    var filterParametersView: FilterParametersView! = FilterParametersView()
    
    // image picker for changing edit image
    let imagePicker = UIImagePickerController()
    
    var filterManager: FilterManager? = FilterManager.sharedInstance
    
    var currCategory:String? = nil
    var currFilterKey:String? = nil
    
    var currFilterDescriptor:FilterDescriptor? = nil
    var currIndex:Int = 0
    
    var isLandscape : Bool = false
    var screenSize : CGRect = CGRect.zero
    var displayWidth : CGFloat = 0.0
    var displayHeight : CGFloat = 0.0
    
    let bannerHeight : CGFloat = 64.0
    let buttonSize : CGFloat = 48.0
    fileprivate let statusBarOffset : CGFloat = 2.0
    
    let editControlHeight = 96.0
    
    // child view controller
    var optionsController: EditMainOptionsController? = nil
    
    
    
    convenience init(){
        self.init(nibName:nil, bundle:nil)
        //doInit()
    }
    
    static var initDone:Bool = false
    
    func doInit(){
        
        EditManager.reset()
        
        if (currFilterDescriptor == nil){
            currFilterDescriptor = filterManager?.getFilterDescriptor(key: "NoFilter")
        }
        if currCategory == nil {
            currCategory = filterManager?.getCurrentCategory()
        }
        
        if (!SimpleEditViewController.initDone){
            SimpleEditViewController.initDone = true
            log.verbose("init")
            
            filterManager?.setCurrentCategory("none")
            currFilterDescriptor = filterManager?.getFilterDescriptor(key: "NoFilter")
            filterParametersView.setConfirmMode(true)
            filterParametersView.delegate = self
            //filterParametersView.setConfirmMode(false)
            editImageView.setFilter(key: "NoFilter")
            SimpleEditViewController.initDone = true
            updateCurrentFilter()
        }
    }
    
    
    open func suspend(){
        editImageView.suspend()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Logging nicety, show that controller has changed:
        print ("\n========== \(String(describing: self)) ==========")

        // load theme here in case it changed
        theme = ThemeManager.currentTheme()
        
        view.backgroundColor = theme.backgroundColor
        
        // get display dimensions
        displayHeight = view.height
        displayWidth = view.width
        
        log.verbose("h:\(displayHeight) w:\(displayWidth)")
        
        // get orientation
        //isLandscape = UIDevice.current.orientation.isLandscape // doesn't always work properly, especially in simulator
        isLandscape = (displayWidth > displayHeight)
        
        //filterManager?.reset()
        doInit()
        
        checkPhotoAuth()

        
        // set up layout based on orientation
        
        layoutBanner()
        
        
        // Only Portrait mode supported (for now)
        // TODO: add landscape mode
        
        imageSelectionView.frame.size.height = CGFloat(bannerHeight)
        imageSelectionView.frame.size.width = displayWidth

        editImageView.frame.size.width = displayWidth
        editImageView.frame.size.height = displayHeight - bannerView.frame.size.height - CGFloat(editControlHeight)
        
        /***
        editControlsView.frame.size.height = CGFloat(editControlHeight)
        editControlsView.frame.size.width = displayWidth

        filterControlsView.frame.size.height = bannerHeight * 0.5
        filterControlsView.frame.size.width = displayWidth
        
        filterSelectionView.frame.size.height = 1.7 * bannerHeight
        filterSelectionView.frame.size.width = displayWidth
        
        categorySelectionView.frame.size.height = 1.7 * bannerHeight
        categorySelectionView.frame.size.width = displayWidth
         ***/

        filterParametersView.frame.size.width = displayWidth
        filterParametersView.frame.size.height = bannerHeight // will be adjusted based on selected filter
 
        // Note: need to add subviews before modifying constraints
        view.addSubview(bannerView)
        //view.addSubview(filterInfoView)
        view.addSubview(editImageView)
        view.addSubview(imageSelectionView)
        view.addSubview(filterParametersView)

        /***
       view.addSubview(editControlsView)
 
       // hidden views:
         view.addSubview(filterSelectionView)
        view.addSubview(filterControlsView) // must come after editImageView
        view.addSubview(categorySelectionView)
         ***/

        hideModalViews()

        // set layout constraints
        
        // top
        bannerView.anchorAndFillEdge(.top, xPad: 0, yPad: statusBarOffset/2.0, otherSize: bannerView.frame.size.height)
        
        imageSelectionView.align(.underCentered, relativeTo: bannerView, padding: 0, width: displayWidth, height: imageSelectionView.frame.size.height)
        
        // main window
        editImageView.align(.underCentered, relativeTo: imageSelectionView, padding: 0, width: displayWidth, height: editImageView.frame.size.height)
        
        filterParametersView.anchorAndFillEdge(.bottom, xPad: 0, yPad: 0, otherSize: filterParametersView.frame.size.height)

/***
       // bottom
        editControlsView.anchorToEdge(.bottom, padding: 0, width: displayWidth, height: editControlsView.frame.size.height)
        
        filterControlsView.align(.aboveCentered, relativeTo: editControlsView, padding: 0, width: displayWidth, height: filterControlsView.frame.size.height)
        
        
        categorySelectionView.align(.aboveCentered, relativeTo: filterControlsView, padding: 0,
                                    width: categorySelectionView.frame.size.width, height: categorySelectionView.frame.size.height)
        
        filterParametersView.align(.aboveCentered, relativeTo: filterControlsView, padding: 4,
                                   width: filterParametersView.frame.size.width, height: filterParametersView.frame.size.height)

 ***/
        
        //TMP:
        editControlsView.isHidden = true
        optionsController = EditMainOptionsController()
        optionsController?.view.frame = CGRect(origin: CGPoint(x: 0, y: (displayHeight-CGFloat(editControlHeight))), size: CGSize(width: displayWidth, height: CGFloat(editControlHeight)))
        optionsController?.delegate = self
        add(optionsController!)

        // add delegates to sub-views (for callbacks)
        imageSelectionView.delegate = self
        imagePicker.delegate = self
/***
        editControlsView.delegate = self
        filterControlsView.delegate = self
        filterSelectionView.delegate = self
        categorySelectionView.delegate = self
***/
        
        
        // set gesture detection for the edit display view
        setGestureDetectors(view: editImageView)
        
        // listen to key press events
        setVolumeListener()
        
        //update filtered image
        editImageView.updateImage()
        
    }
    
    /*
     override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
     if UIDevice.current.orientation.isLandscape {
     log.verbose("Preparing for transition to Landscape")
     } else {
     log.verbose("Preparing for transition to Portrait")
     }
     }
     */
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation.isLandscape{
            log.verbose("### Detected change to: Landscape")
        } else {
            log.verbose("### Detected change to: Portrait")
            
        }
        //TODO: animate and maybe handle before rotation finishes
        self.viewDidLoad()
        //editImageView.setFilter(nil)
        editImageView.setFilter(key:(currFilterDescriptor?.key)!) // forces reset of filter pipeline
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        log.warning("Low Memory Warning")
        // Dispose of any resources that can be recreated.
    }
    
    
    // Autorotate configuration
    
    //NOTE: only works for iOS 10 and later
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    private func checkPhotoAuth() {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    log.debug("Photo access granted")
                } else {
                    log.warning("Photo access NOT granted")
                }
            })
            
        }
    }
    
    //////////////////////////////////////
    // MARK: - Sub-View layout
    //////////////////////////////////////

    
    // layout the banner view, with the Back button, title etc.
    func layoutBanner(){
        bannerView.frame.size.height = bannerHeight * 0.75
        bannerView.frame.size.width = displayWidth
        bannerView.title = "\'Simple\' Photo Editor"
        bannerView.delegate = self
    }
    

    
    @objc func acceptDidPress() {
        
        // make the change permanent
        EditManager.savePreviewFilter()
    }
    
    @objc func defaultDidPress(){
        currFilterDescriptor?.reset()
        DispatchQueue.main.async(execute: { () -> Void in
            self.editImageView.updateImage()
        })
   }
    
    @objc func undoDidPress(){
        // restore saved parameters
        currFilterDescriptor?.restoreParameters()
        EditManager.popFilter()
        DispatchQueue.main.async(execute: { () -> Void in
            self.editImageView.updateImage()
        })
   }
    
    
    //////////////////////////////////////
    // MARK: - Volume buttons
    //////////////////////////////////////
    
    
    func setVolumeListener() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryAmbient, mode: AVAudioSessionModeDefault, options: [])
            try audioSession.setActive(true, with: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions(), context: nil)
        } catch {
            log.error("\(error)")
        }
        
        //TODO: hide system volume HUD
        self.view.addSubview(volumeView)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        log.debug("Key event: \(String(describing: keyPath))")
        if keyPath == "outputVolume" {
            log.debug("Volume Button press detected, taking picture")
            saveImage()
        }
    }
    
    // redefine the volume view so that it isn't really visible to the user
    lazy var volumeView: MPVolumeView = {
        let view = MPVolumeView()
        view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        view.alpha = 0.000001
        return view
    }()
    
    

    
    
    
    //////////////////////////////////////
    // MARK: - Gesture Detection
    //////////////////////////////////////
    
    
    var gesturesEnabled:Bool = true
    
    func enableGestureDetection(){
        gesturesEnabled = true
        editImageView.isUserInteractionEnabled = true
        filterParametersView.isHidden = false
    }
    
    func disableGestureDetection(){
        gesturesEnabled = false
        editImageView.isUserInteractionEnabled = false
        filterParametersView.isHidden = true
    }

    func setGestureDetectors(view: UIView){
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        /***
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
         ***/
    }
    
    
    @objc func swiped(_ gesture: UIGestureRecognizer)
    {
        if gesturesEnabled {
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction {
                    
                case UISwipeGestureRecognizerDirection.right:
                    //log.verbose("Swiped Right")
                    //previousFilter()
                    break
                    
                case UISwipeGestureRecognizerDirection.left:
                    //log.verbose("Swiped Left")
                    //nextFilter()
                    break
                    
                case UISwipeGestureRecognizerDirection.up:
                    //log.verbose("Swiped Up")
                    showFilterSettings()
                    break
                    
                case UISwipeGestureRecognizerDirection.down:
                    hideFilterSettings()
                    //log.verbose("Swiped Down")
                    break
                    
                default:
                    log.debug("Unhandled gesture direction: \(swipeGesture.direction)")
                    break
                }
            }
        }
    }
    
    
    //////////////////////////////////////
    //MARK: - Navigation
    //////////////////////////////////////
    @objc func backDidPress(){
        log.verbose("Back pressed")
        exitScreen()
    }
    
    
    func exitScreen(){
        guard navigationController?.popViewController(animated: true) != nil else { //modal
            //log.debug("Not a navigation Controller")
            suspend()
            dismiss(animated: true, completion:  { })
            return
        }
    }
    
    
    //////////////////////////////////////
    //MARK: - Utility functions
    //////////////////////////////////////
    
    open func saveImage(){
        editImageView.saveImage()
        playCameraSound()
    }
    
    fileprivate func playCameraSound(){
        AudioServicesPlaySystemSound(1108) // undocumented iOS feature!
    }
    
    
    
    //////////////////////////////////////
    // MARK: - Filter Management
    //////////////////////////////////////
    
    
    func changeFilterTo(_ key:String){
        //TODO: make user accept changes before applying? (Add buttons to parameter display)
        currFilterKey = key
        // setup the filter descriptor
        if (key != filterManager?.getCurrentFilterKey()){
            log.debug("Filter Selected: \(key)")
            filterManager?.setCurrentFilterKey(key)
            currFilterDescriptor = filterManager?.getFilterDescriptor(key:key)
            updateCurrentFilter()
        }
    }
    
    
    func filterChanged(){
        updateCurrentFilter()
    }
    
    // retrive current settings from FilterManager and store locally
    func updateCurrentFilter(){
        if (currFilterKey != nil) {
            editImageView.setFilter(key:currFilterKey!)
        }
    }
    
    
    // convenience function to hide all modal views
    func hideModalViews(){
        filterParametersView.isHidden = true
    }
    
    
    
    
    
    // Management of Filter Parameters view
    fileprivate var filterSettingsShown: Bool = false
    
    fileprivate func showFilterSettings(){
        optionsController!.view.isHidden = true
        //updateCurrentFilter()
        if (currFilterDescriptor != nil) {
            // re-layout based on selecetd filter
            filterParametersView.frame.size.height = CGFloat(((currFilterDescriptor?.numParameters)! + 1)) * bannerHeight * 0.75
            filterParametersView.anchorInCorner(.bottomLeft, xPad: 0, yPad: 0, width: filterParametersView.frame.size.width, height: filterParametersView.frame.size.height)
            
            filterParametersView.setFilter(currFilterDescriptor)
            
            //filterParametersView.align(.aboveCentered, relativeTo: filterControlsView, padding: 4, width: filterParametersView.frame.size.width, height: filterParametersView.frame.size.height)
            filterParametersView.isHidden = false
            filterParametersView.delegate = self // can be reset if bouncing between screens
            filterSettingsShown = true
            view.bringSubview(toFront: filterParametersView)
            //filterParametersView.show()
        }
    }
    
    fileprivate func hideFilterSettings(){
        optionsController!.view.isHidden = false
        filterParametersView.dismiss()
        filterParametersView.isHidden = true
        filterSettingsShown = false
    }
    
    func toggleFilterSettings(){
        if (filterSettingsShown){
            hideFilterSettings()
        } else {
            showFilterSettings()
        }
    }
    
    fileprivate func updateFilterSettings(){
        if (filterSettingsShown){
            //hideFilterSettings()
            showFilterSettings()
        }
    }
    
    
    
    
    
    //////////////////////////////////////////
    // MARK: - ImagePicker handling
    //////////////////////////////////////////
    
    func changeImage(){
        DispatchQueue.main.async(execute: { () -> Void in
            log.debug("imagePreview pressed - launching ImagePicker...")
            // launch an ImagePicker
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            
            self.present(self.imagePicker, animated: true, completion: {
            })
        })
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
            let assetResources = PHAssetResource.assetResources(for: asset)
            let name = assetResources.first!.originalFilename
            let id = assetResources.first!.assetLocalIdentifier
            
            log.verbose("Picked image:\(name) id:\(id)")
            ImageManager.setCurrentEditImageName(id)
            DispatchQueue.main.async(execute: { () -> Void in
                self.editImageView.updateImage()
            })
        } else {
            log.error("Error accessing image data")
        }
        picker.dismiss(animated: true)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
    
    
    //////////////////////////////////////////
    // MARK: - Position handling
    //////////////////////////////////////////
    
    
    // Note: general gestures are disabled while position tracking is active. Too confusing if we don't do this
    
    var touchKey:String = ""
    
    func handlePositionRequest(key:String){
        if !key.isEmpty{
            log.verbose("Position Request for parameter: \(key)")
            disableGestureDetection()
            touchKey = key
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchKey.isEmpty{
            if let touch = touches.first {
                let position = touch.location(in: editImageView)
                let imgPos = editImageView.getImagePosition(viewPos:position)
                currFilterDescriptor?.setPositionParameter(touchKey, position:imgPos!)
                editImageView.runFilter()
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchKey.isEmpty{
            if let touch = touches.first {
                let position = touch.location(in: editImageView)
                let imgPos = editImageView.getImagePosition(viewPos:position)
                currFilterDescriptor?.setPositionParameter(touchKey, position:imgPos!)
                editImageView.runFilter()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchKey.isEmpty{
            if let touch = touches.first {
                let position = touch.location(in: editImageView)
                let imgPos = editImageView.getImagePosition(viewPos:position)
                currFilterDescriptor?.setPositionParameter(touchKey, position:imgPos!)
                //log.verbose("Touches ended. Final pos:\(position) vec:\(imgPos)")
                editImageView.runFilter()
            }
            touchKey = ""
        }
        
        enableGestureDetection()
    }

    
    //////////////////////////////////////////
    // MARK: - Not yet implemented notifier
    //////////////////////////////////////////
    
    func notYetImplemented(){
        DispatchQueue.main.async(execute: { () -> Void in
            let alert = UIAlertController(title: "Oops!", message: "Not yet implemented. Sorry!", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        })
    }
    
    
} // SimpleEditViewController
//########################






//////////////////////////////////////////
// MARK: - Delegate methods for sub-views
//////////////////////////////////////////



// TitleViewDelegate
extension SimpleEditViewController: TitleViewDelegate {
    func backPressed() {
        backDidPress()
    }
}

// ImageSelectionViewDelegate
extension SimpleEditViewController: ImageSelectionViewDelegate {
    
    func changeImagePressed(){
        self.changeImage()
        DispatchQueue.main.async(execute: { () -> Void in
            self.imageSelectionView.update()
        })
    }

    func changeBlendPressed() {
        let vc = BlendGalleryViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: { })

    }
    
    func savePressed() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.saveImage()
            log.verbose("Image saved")
            self.imageSelectionView.update()
        })
    }
    
}


// GalleryViewControllerDelegate(s)

extension SimpleEditViewController: GalleryViewControllerDelegate {
    func galleryCompleted() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.imageSelectionView.update()
            self.imageSelectionView.update()
            log.verbose("Returned from gallery")
        })

    }
    
    func gallerySelection(key: String) {
        log.debug("Filter selection: \(key)")
        self.changeFilterTo(key)
        self.showFilterSettings()
    }
}

extension SimpleEditViewController: EditChildControllerDelegate {
    func editFilterSelected(key: String) {
        log.verbose("Child selected filter: \(key)")
        DispatchQueue.main.async(execute: { () -> Void in
            self.changeFilterTo(key)
            self.showFilterSettings()
        })
    }
    
    func editRequestUpdate() {
        log.verbose("Child requested update")
        DispatchQueue.main.async(execute: { () -> Void in
            self.editImageView.updateImage()
            self.imageSelectionView.update()
        })
    }
    
    func editFinished() {
        log.verbose("Child finished")
    }
    
}


extension SimpleEditViewController: FilterParametersViewDelegate {
    func commitChanges(key: String) {
        // make the change permanent
        DispatchQueue.main.async(execute: { () -> Void in
        EditManager.savePreviewFilter()
        self.optionsController!.view.isHidden = false
        })
    }
    
    func cancelChanges(key: String) {
        // restore saved parameters
        currFilterDescriptor?.restoreParameters()
        EditManager.popFilter()
        DispatchQueue.main.async(execute: { () -> Void in
            self.editImageView.updateImage()
            self.optionsController!.view.isHidden = false
        })
    }
    
    
    func settingsChanged(){
        log.debug("Filter settings changed")
            self.editImageView.updateImage()
    }
    
    func positionRequested(key: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.handlePositionRequest(key:key)
        })
    }
}

