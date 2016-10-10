//
//  SketchFilter.swift
//  FilterCam
//
//  Created by Philip Price on 10/4/16.
//  Copyright © 2016 Nateemma. All rights reserved.
//

import Foundation
import GPUImage


class SketchDescriptor: FilterDescriptorInterface {



    let key = "Sketch"
    let title = "Sketch"
    let category = FilterCategoryType.visualEffects
    
    var filter: BasicOperation?  = nil
    let filterGroup: OperationGroup? = nil
    
    let numSliders = 1
    let parameterConfiguration = [ParameterSettings(title:"edge strength", minimumValue:0.0, maximumValue:4.0, initialValue:1.0)]

    
    let filterOperationType = FilterOperationType.singleInput
    
    private var lclFilter:SketchFilter = SketchFilter() // the actual filter
    private var stash_edgeStrength: Float
    

    init(){
        filter = lclFilter // assign the filter defined in the interface to the instantiated filter of the desired sub-type
        lclFilter.edgeStrength = parameterConfiguration[0].initialValue
        stash_edgeStrength = lclFilter.edgeStrength
        log.verbose("config: \(parameterConfiguration)")
    }
    
    
    //MARK: - Required funcs
    
    func configureCustomFilter(_ input:(filter:BasicOperation, secondInput:BasicOperation?)){
        // nothing to do
    }
    
    
    func getParameter(index: Int)->Float {
        switch (index){
        case 1:
            return lclFilter.edgeStrength
            break
        default:
            return parameterNotSet
        }
    }
    
    
    func setParameter(index: Int, value: Float) {
        switch (index){
        case 1:
            lclFilter.edgeStrength = value
            log.debug("\(parameterConfiguration[0].title):\(value)")
            break
        default:
            log.error("Invalid parameter index (\(index)) for filter: \(key)")
        }
    }
    
    
    //func updateParameters(value1:Float, value2:Float,  value3:Float,  value4:Float){
    //    lclFilter.edgeStrength = value1
    //}
    
    func stashParameters() {
        stash_edgeStrength = lclFilter.edgeStrength
    }
    
    func restoreParameters(){
        lclFilter.edgeStrength = stash_edgeStrength
    }
}