//
//  GlassSphereRefractionDescriptor.swift
//  FilterCam
//
//  Created by Philip Price on 10/8/16.
//  Copyright © 2016 Nateemma. All rights reserved.
//


import Foundation
import GPUImage


class GlassSphereRefractionDescriptor: FilterDescriptorInterface {
    
    
    
    let key = "GlassSphereRefraction"
    let title = "Glass Sphere Refraction"
    let category = FilterCategoryType.colorAdjustments
    
    var filter: BasicOperation?  = nil
    let filterGroup: OperationGroup? = nil
    
    let numSliders = 2
    let parameterConfiguration = [ParameterSettings(title:"radius", minimumValue:0.0, maximumValue:1.0, initialValue:0.15),
                                  ParameterSettings(title:"refraction", minimumValue:0.0, maximumValue:1.0, initialValue:0.71)]
    
    
    let filterOperationType = FilterOperationType.singleInput
    
    private var lclFilter:GlassSphereRefraction = GlassSphereRefraction() // the actual filter
    private var stash_radius: Float
    private var stash_refractiveIndex: Float
    
    
    init(){
        filter = lclFilter // assign the filter defined in the interface to the instantiated filter of the desired sub-type
        lclFilter.radius = parameterConfiguration[0].initialValue
        lclFilter.refractiveIndex = parameterConfiguration[1].initialValue
        stash_radius = lclFilter.radius
        stash_refractiveIndex = lclFilter.refractiveIndex
        log.verbose("config: \(parameterConfiguration)")
    }
    
    
    //MARK: - Required funcs
    
    func configureCustomFilter(_ input:(filter:BasicOperation, secondInput:BasicOperation?)){
        // nothing to do
    }
    
    
    func getParameter(index: Int)->Float {
        switch (index){
        case 1:
            return lclFilter.radius
            break
        case 2:
            return lclFilter.refractiveIndex
            break
        default:
            return parameterNotSet
        }
    }
    
    
    func setParameter(index: Int, value: Float) {
        switch (index){
        case 1:
            lclFilter.radius = value
            log.debug("\(parameterConfiguration[0].title):\(value)")
            break
        case 2:
            lclFilter.refractiveIndex = value
            log.debug("\(parameterConfiguration[1].title):\(value)")
            break
        default:
            log.error("Invalid parameter index (\(index)) for filter: \(key)")
        }
    }
    
    
    //func updateParameters(value1:Float, value2:Float,  value3:Float,  value4:Float){
    //    lclFilter.radius = value1
    //}
    
    func stashParameters() {
        stash_radius = lclFilter.radius
        stash_refractiveIndex = lclFilter.refractiveIndex
    }
    
    func restoreParameters(){
        lclFilter.radius = stash_radius
        lclFilter.refractiveIndex = stash_refractiveIndex
    }
}