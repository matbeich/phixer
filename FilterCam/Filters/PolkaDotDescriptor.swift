//
//  PolkaDotDescriptor.swift
//  FilterCam
//
//  Created by Philip Price on 10/8/16.
//  Copyright © 2016 Nateemma. All rights reserved.
//


import Foundation
import GPUImage


class PolkaDotDescriptor: FilterDescriptorInterface {
    
    
    
    let key = "PolkaDot"
    let title = "Polka Dot"
    
    var filter: BasicOperation?  = nil
    let filterGroup: OperationGroup? = nil
    
    let numParameters = 1
    let parameterConfiguration = [ParameterSettings(title:"size", minimumValue:0.0, maximumValue:0.1, initialValue:0.05, isRGB:false)]
  
    //TODO: add dotscaling parameter
    
    let filterOperationType = FilterOperationType.singleInput
    
    fileprivate var lclFilter:PolkaDot = PolkaDot() // the actual filter
    fileprivate var stash_fractionalWidthOfAPixel: Float
    
    
    init(){
        filter = lclFilter // assign the filter defined in the interface to the instantiated filter of the desired sub-type
        lclFilter.fractionalWidthOfAPixel = parameterConfiguration[0].initialValue
        stash_fractionalWidthOfAPixel = lclFilter.fractionalWidthOfAPixel
        log.verbose("config: \(parameterConfiguration)")
    }

    
    
    //MARK: - Required funcs
    
    func configureCustomFilter(_ input:(filter:BasicOperation, secondInput:BasicOperation?)){
        // nothing to do
    }
    
    
    func getParameter(_ index: Int)->Float {
        switch (index){
        case 1:
            return lclFilter.fractionalWidthOfAPixel
        default:
            return parameterNotSet
        }
    }
    
    
    func setParameter(_ index: Int, value: Float) {
        switch (index){
        case 1:
            lclFilter.fractionalWidthOfAPixel = value
            log.debug("\(parameterConfiguration[0].title):\(value)")
            break
        default:
            log.error("Invalid parameter index (\(index)) for filter: \(key)")
        }
    }
    
    
    
    func getColorParameter(_ index: Int)->UIColor { return UIColor.blue }
    func setColorParameter(_ index:Int, color:UIColor) {}
    
    
    func stashParameters() {
        stash_fractionalWidthOfAPixel = lclFilter.fractionalWidthOfAPixel
    }
    
    func restoreParameters(){
        lclFilter.fractionalWidthOfAPixel = stash_fractionalWidthOfAPixel
    }
}
