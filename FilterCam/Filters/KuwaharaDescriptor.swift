//
//  KuwaharaDescriptor.swift
//  FilterCam
//
//  Created by Philip Price on 10/4/16.
//  Copyright © 2016 Nateemma. All rights reserved.
//

import Foundation
import GPUImage


class KuwaharaDescriptor: FilterDescriptorInterface {
    
    
    let key = "Kuwahara"
    let title = "Kuwahara Filter (Oil Painting)"
    
    var filter: BasicOperation?  = nil
    let filterGroup: OperationGroup? = nil
    
    let numParameters = 1
    let parameterConfiguration = [ParameterSettings(title:"radius", minimumValue:0.0, maximumValue:1.0, initialValue:0.5, isRGB:false)]
    
    
    let filterOperationType = FilterOperationType.singleInput
    
    private var lclFilter:KuwaharaFilter = KuwaharaFilter() // the actual filter
    private var stash_radius: Float
    
    
    init(){
        filter = lclFilter // assign the filter defined in the interface to the instantiated filter of the desired sub-type
        lclFilter.radius = Int(parameterConfiguration[0].initialValue)
        stash_radius = Float(lclFilter.radius)
        log.verbose("config: \(parameterConfiguration)")
    }
    
    
    //MARK: - Required funcs
    
    func configureCustomFilter(_ input:(filter:BasicOperation, secondInput:BasicOperation?)){
        // nothing to do
    }
    
    
    
    func getParameter(index: Int)->Float {
        switch (index){
        case 1:
            return Float(lclFilter.radius)
        default:
            return parameterNotSet
        }
    }
    
    
    func setParameter(index: Int, value: Float) {
        switch (index){
        case 1:
            lclFilter.radius = Int(value)
            log.debug("\(parameterConfiguration[0].title):\(value)")
            break
        default:
            log.error("Invalid parameter index (\(index)) for filter: \(key)")
        }
    }
    
    
    
    func getColorParameter(index: Int)->UIColor { return UIColor.blue }
    func setColorParameter(index:Int, color:UIColor) {}
    
    
    func stashParameters(){
        stash_radius = Float(lclFilter.radius)
    }
    
    func restoreParameters(){
        lclFilter.radius = Int(stash_radius)
    }
}
