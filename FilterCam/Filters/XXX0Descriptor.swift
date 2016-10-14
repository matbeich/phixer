//
//  XXXDescriptor.swift
//  FilterCam
//
//  Created by Philip Price on 10/4/16.
//  Copyright © 2016 Nateemma. All rights reserved.
//

import Foundation
import GPUImage


class XXX0Descriptor: FilterDescriptorInterface {
    
    
    let key = "XXX"
    let title = "XXX"
    
    var filter: BasicOperation?  = nil
    let filterGroup: OperationGroup? = nil
    
    let numParameters = 0
    let parameterConfiguration:[ParameterSettings] = []
    
    
    let filterOperationType = FilterOperationType.singleInput
    
    private var lclFilter:XXXFilter = XXXFilter() // the actual filter
    
    
    init(){
        filter = lclFilter // assign the filter defined in the interface to the instantiated filter of the desired sub-type
    }
    
    
    //MARK: - Required funcs
    
    
    // stubs for required but unused functions

    func configureCustomFilter(_ input:(filter:BasicOperation, secondInput:BasicOperation?)){ }
    func getParameter(index: Int)->Float { return parameterNotSet }
    func setParameter(index: Int, value: Float) { log.error("No parameters to set for filter: \(key)") }
    func getColorParameter(index: Int)->UIColor { return UIColor.blue }
    func setColorParameter(index:Int, color:UIColor) {}
    func stashParameters(){ }
    func restoreParameters(){ }
}
