//
//  XVPNManager.swift
//  XVPNManager
//
//  Created by yarshure on 2017/12/8.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import NetworkExtension

public class XVPNManager {
    static var mainBundle:String = "com.yarshure.vpn"
    static var providerBundle:String = "com.yarshure.vpn.provider"
    static var providerConfig:[String:Any]?// ["App": bId,"PluginType":"com.yarshure.Surf"]
    static var serverAddress:String = "240.84.1.24"
    static var profileName:String = "Surfing"
    static var isSetup:Bool = false
    public static func setup(bundle:String,provider:String,serverAddress:String,pName:String,config:[String:Any]?){
        self.mainBundle = bundle
        self.providerBundle = provider
        self.providerConfig = config
        self.profileName = pName
        isSetup = true
    }
}
