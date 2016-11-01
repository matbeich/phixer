//
//  DifferenceBlendDescriptor.swift
//  FilterCam
//
//  Created by Philip Price on 10/4/16.
//  Copyright © 2016 Nateemma. All rights reserved.
//

import Foundation
import GPUImage


class DifferenceBlendDescriptor: FilterDescriptorInterface {
    
    
    let key = "DifferenceBlend"
    let title = "Difference Blend"
    
    var filter: BasicOperation?  = nil
    let filterGroup: OperationGroup? = nil
    
    let numParameters = 0
    let parameterConfiguration:[ParameterSettings] = []
    
    
    let filterOperationType = FilterOperationType.blend
    
    fileprivate var lclFilter:DifferenceBlend = DifferenceBlend() // the actual filter
    
    
    init(){
        filter = lclFilter // assign the filter defined in the interface to the instantiated filter of the desired sub-type
    }
    
    
    //MARK: - Required funcs
    
    
    func reset(){
        lclFilter.removeAllTargets()
        lclFilter = DifferenceBlend()
        restoreParameters()
    }
    
   
    // stubs for required but unused functions

    func configureCustomFilter(_ input:(filter:BasicOperation, secondInput:BasicOperation?)){ }
    func getParameter(_ index: Int)->Float { return parameterNotSet }
    func setParameter(_ index: Int, value: Float) { log.error("No parameters to set for filter: \(key)") }
    func getColorParameter(_ index: Int)->UIColor { return UIColor.blue }
    func setColorParameter(_ index:Int, color:UIColor) {}
    func stashParameters(){ }
    func restoreParameters(){ }
}
