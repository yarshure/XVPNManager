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
    //类变量变化后只能被实例方法使用？
    //这个最好设计成singleton
    //不变的参数可以设计成类变量
    public static var sharedManager = XVPNManager()
    var mainBundle:String = "com.yarshure.vpn"
    var providerBundle:String = "com.yarshure.vpn.provider"
    var providerConfig:[String:Any]?// ["App": bId,"PluginType":"com.yarshure.Surf"]
    var serverAddress:String = "240.84.1.24"
    var profileName:String = "Surfing"
    var isSetup:Bool = false
    public  func setup(bundle:String,provider:String,serverAddress:String,pName:String,config:[String:Any]?){
        self.mainBundle = bundle
        self.providerBundle = provider
        self.providerConfig = config
        self.profileName = pName
        isSetup = true
    }
}
