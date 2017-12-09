//
//  SFVPNManager.swift
//  
//
//  Created by yarshure on 16/2/5.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation
import NetworkExtension

struct XVPNError: Error {
    enum ErrorKind {
        case notActive
        case noManager
    }
    let kind:ErrorKind
}


public extension NETunnelProviderManager {
    //var pluginType:String = "com.yarshure.Surf"
    public class func loadOrCreateDefaultWithCompletionHandler(_ completionHandler: ((NETunnelProviderManager?, Error?) -> Void)?) {
        self.loadAllFromPreferences { (managers, error) -> Void in
            if let error = error {
                print("Error: Could not load managers:  \(error.localizedDescription)")
                if let completionHandler = completionHandler {
                    completionHandler(nil, error)
                }
                return
            }
            if let managers = managers {
                if managers.indices ~= 0 {
                    if let completionHandler = completionHandler {
                        var m:NETunnelProviderManager?
                        for mm in managers {
                            let _ = mm.protocolConfiguration as! NETunnelProviderProtocol
                            
                            
                        }
                        if m == nil {
                            m = managers[0]
                        }
                        print("manager \(managers.count) \n Config:\(String(describing: m!.protocolConfiguration!))")
                        completionHandler(m, nil)

                        
                        
                    }
                    return
                }else {
                    completionHandler?(nil, nil)
                }
            }else {
                //create
                completionHandler?(nil, nil)
            }
            
            
        }
    }
    public  func createProfile(_ providerProtocol:NETunnelProviderProtocol,_ completionHandler: ((NETunnelProviderManager?, Error?) -> Void)?) {
        //let config = NETunnelProviderProtocol()
        let env = XVPNManager.sharedManager
        //config.providerConfiguration = env.providerConfig
        //config.providerBundleIdentifier = env.providerBundle
        //config.serverAddress = env.serverAddress
        
        
       // let manager = NETunnelProviderManager()
        self.protocolConfiguration = providerProtocol
        self.localizedDescription = env.profileName
        print(env.profileName)
        self.saveToPreferences(completionHandler: { (error) -> Void in
            if let completionHandler = completionHandler {
                if error != nil {
                    //NSLog("Error: Could not create manager: %@", error)
                }
                completionHandler(self, error)
            }
        })
    }
}
public extension NETunnelProviderProtocol{
    public func config() {
        //let config = NETunnelProviderProtocol()
        let env = XVPNManager.sharedManager
        self.providerConfiguration = env.providerConfig
        self.providerBundleIdentifier = env.providerBundle
        self.serverAddress = env.serverAddress
    }
}

public class SFVPNManager {
    public static let shared:SFVPNManager =  SFVPNManager()
    public var manager:NETunnelProviderManager?
    var proVersion:String = ""
    var config:String = ""
    var loading:Bool = false
    var session:String = ""
    var vpnmanager:NEVPNManager = NEVPNManager.shared()
    func loadVPNManager(_ completionHandler: @escaping (Error?) -> Void){
        vpnmanager.loadFromPreferences { (error) -> Void in
            completionHandler(error)
        }
    }
    
    func saveVPNManger(_ completionHandler: ((Error?) -> Void)?) {
        if vpnmanager.isEnabled == false{
            vpnmanager.isEnabled = true
            vpnmanager.saveToPreferences(completionHandler: { (error) in
                completionHandler!(error)
            })
            
        } else {
            completionHandler!(nil)
        }
    }
    func startStopVPNConnect() throws {
        let c = vpnmanager.connection
        if c.status == .disconnected || c.status == .invalid {
            if c.status == .disconnected {
      
              do {
                
                try c.startVPNTunnel(options: [:])
            }catch let e as NSError {
                    throw e
                }
                
            }else {
                c.stopVPNTunnel()
            }
        }
    }
    public func verify (_ completionHandler: ((NETunnelProviderManager?, Error?) -> Void)?) {
        
        guard let _ = manager else {
            if let handler = completionHandler{
                handler(nil, nil)
            }
            return
        }
        loading = true
        NETunnelProviderManager.loadOrCreateDefaultWithCompletionHandler() { [weak self] (manager, error) -> Void in
            if let m = manager {
                self!.manager = manager
                if let handler = completionHandler{
                    if m.onDemandRules == nil {
                        //self!.addOnDemandRule([])
                    }
                    self!.loading = false
                    handler(m, error)
                }
            }
        }
    }
    public func loadManager(_ completionHandler: ((NETunnelProviderManager?, Error?) -> Void)?) {
        
        if let m = manager {
            if let handler = completionHandler{
                handler(m, nil)
            }
            
            //self.xpc()
        }else {
            loading = true
            NETunnelProviderManager.loadOrCreateDefaultWithCompletionHandler() { [weak self] (manager, error) -> Void in
                if let m = manager {
                    self!.manager = manager
                    if let handler = completionHandler{
                        if m.onDemandRules == nil {
                            //self!.addOnDemandRule([])
                        }
                        self!.loading = false
                        handler(m, error)
                    }
                }else {
                    let m = NETunnelProviderManager()
                    let p = NETunnelProviderProtocol()
                    p.config()
                    m.createProfile(p,{ (m, e) in
                        guard let m = m else {
                            completionHandler?(nil, e)
                            return
                        }
                        if let handler = completionHandler{
                            if m.onDemandRules == nil {
                                //self!.addOnDemandRule([])
                            }
                            self!.loading = false
                            handler(m, error)
                        }
                    })
                }
            }
        }
    }
    
    public func xpc(_ completionHandler: @escaping ((String,Error?) -> Void)) {
        // Send a simple IPC message to the provider, handle the response.
        //AxLogger.log("send Hello Provider")
        if let m = manager {
            let me = SFVPNXPSCommand.HELLO.rawValue + "|Hello Provider"
            if let session = m.connection as? NETunnelProviderSession,
                 let message = me.data(using: .utf8), m.connection.status != .invalid
            {
                do {
                    try session.sendProviderMessage(message) { response in
                        if let response = response  {
                            if let responseString = String.init(data:response , encoding: .utf8){
                                let list = responseString.components(separatedBy: ":")
                                self.session = list.last!
                                print("Received response from the provider: \(responseString)")
                                completionHandler(responseString,nil)
                            }
                            
                            //self.registerStatus()
                        } else {
                            completionHandler("Got a nil response from the provider",XVPNError.init(kind: .notActive))
                        }
                    }
                } catch let e {
                    completionHandler("Failed to send a message to the provider",e)
                    
                }
            }
        }else {
           
            completionHandler("message dont init",XVPNError.init(kind: .noManager))
        }
        
    }
    /// De-register for configuration change notifications.
    /// Handle the user toggling the "enabled" switch.
    func test(_ domains:[String],enable:Bool,wifiEnable:Bool){
        var onDemandRules  = [NEOnDemandRule]()
        let newRule = NEOnDemandRuleEvaluateConnection()
        var connectionRules:[NEEvaluateConnectionRule] = []
        //print(newRule.connectionRules)
        //newRule.DNSSearchDomainMatch = domains
        
        let  r:NEEvaluateConnectionRule = NEEvaluateConnectionRule.init(matchDomains: domains, andAction: .connectIfNeeded)
        
        if wifiEnable {
            newRule.interfaceTypeMatch = .any
        }else {
            #if os(iOS)
                newRule.interfaceTypeMatch = .cellular
                #else
                newRule.interfaceTypeMatch = .any
                #endif
           
            
        }
        connectionRules.append(r)
        newRule.connectionRules = connectionRules
        newRule.interfaceTypeMatch = .any
        
        
        
        onDemandRules.append(newRule)
        print(onDemandRules)
    }
    func test2(_ domains:[String],enable:Bool,wifiEnable:Bool)   {
    
        var onDemandRules  = [NEOnDemandRule]()
        
        
        let newRule = NEOnDemandRuleConnect()
        
        newRule.dnsSearchDomainMatch = domains
        
        if wifiEnable {
            newRule.interfaceTypeMatch = .any
        }else {
            #if os(iOS)
                newRule.interfaceTypeMatch = .cellular
            #else
                newRule.interfaceTypeMatch = .any
            #endif
            //newRule.interfaceTypeMatch = .Cellular
        }
        
        onDemandRules.append(newRule)
        print(onDemandRules)
        
        
    }
    func addOnDemandRule(_ domains:[String],wifiEnable:Bool,enable:Bool,completion: ((Error?) -> Void)?){
        if let m = manager {
            
            var onDemandRules  = [NEOnDemandRule]()
            let newRule = NEOnDemandRuleEvaluateConnection()
            var connectionRules:[NEEvaluateConnectionRule] = []
            //print(newRule.connectionRules)
            //newRule.DNSSearchDomainMatch = domains
            
            let  r:NEEvaluateConnectionRule = NEEvaluateConnectionRule.init(matchDomains: domains, andAction: .connectIfNeeded)
            
            if wifiEnable {
                newRule.interfaceTypeMatch = .any
            }else {
                #if os(iOS)
                    newRule.interfaceTypeMatch = .cellular
                #else
                    newRule.interfaceTypeMatch = .any
                #endif
                //newRule.interfaceTypeMatch = .Cellular
            }
            if connectionRules.count > 0 {
                connectionRules.removeAll()
            }
            connectionRules.append(r)
            newRule.connectionRules = connectionRules
            
            
            
            
            onDemandRules.append(newRule)
            print(onDemandRules)
            
            
            m.onDemandRules = onDemandRules
            m.isOnDemandEnabled = enable
            //fixme
            m.saveToPreferences(completionHandler: { (error) -> Void in
                if let completion = completion {
                     completion(error)
                }
            })
           
            
        }
        
    }
    func enabledToggled(_ start:Bool) {
        if let m = manager {
            m.isEnabled = true
            
            m.saveToPreferences {  error in
                guard error == nil else {
                    //self.enabledSwitch.on = self.targetManager.enabled
                    //self.startStopToggle.enabled = self.enabledSwitch.on
                    print("show update status")
                    
                    return
                }
                
                
                m.loadFromPreferences { (error) in
                    //self.enabledSwitch.on = self.targetManager.enabled
                    //self.startStopToggle.enabled = self.enabledSwitch.on
                    if let e = error {
                        print("loadFromPreferencesWithCompletionHandler \(String(describing: e.localizedDescription))")
                    }
                    
                  
                    if start {
                        do {
                            _ = try self.startStopToggled(self.config)
                        }catch let error {
                            print(error)
                        }
                        
                    }
                    
                }
                
            }
        }
    
    }
    /// Handle the user toggling the "VPN" switch.
    public func startStopToggled(_ config:String) throws ->Bool{
        if let m = manager {
            self.config = config
            if self.config.isEmpty{
                self.config = ""
            }
            if m.connection.status == .disconnected || m.connection.status == .invalid {
                do {
                    
                    if  m.isEnabled {
                        
                        try m.connection.startVPNTunnel(options: [:])
                    }else {
                        enabledToggled(true)
                    }
                }
                catch let error  {
                    throw error
                    //mylog("Failed to start the VPN: \(error)")
                }
            }
            else {
                print("stoping!!!")
                m.connection.stopVPNTunnel()
            }
        }else {
            
            return false
        }
        return true
    }
}
