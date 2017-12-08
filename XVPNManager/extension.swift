//
//  extension.swift
//  XVPNManager
//
//  Created by yarshure on 2017/12/8.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import NetworkExtension
extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .invalid: return "Invalid"
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnecting: return "Disconnecting"
        case .reasserting: return "Reconnecting"
        }
    }
    public var titleForButton:String {
        switch self{
        case .disconnected:
            
            return "Connect"
        case .invalid:
            return "Invalid"
        case .connected:
            return "Disconnect"
        case .connecting:
            return "Connecting"
        case .disconnecting:
            return "Disconnecting"
        case .reasserting:
            return "Reasserting"
        }
    }
}
public enum SFVPNXPSCommand:String{
    case HELLO = "HELLO"
    case RECNETREQ = "RECNETREQ"
    case RULERESULT = "RULERESULT"
    case STATUS = "STATUS"
    case FLOWS = "FLOWS"
    case LOADRULE = "LOADRULE"
    case CHANGEPROXY = "CHANGEPROXY"
    case UPDATERULE = "UPDATERULE"
    var description: String {
        switch self {
        case .LOADRULE: return  "LOADRULE"
        case .HELLO: return "HELLO"
        case .RECNETREQ : return "RECNETREQ"
        case .RULERESULT: return "RULERESULT"
        case .STATUS : return "STATUS"
        case .FLOWS : return "FLOWS"
        case .CHANGEPROXY : return "CHANGEPROXY"
        case .UPDATERULE: return "UPDATERULE"
        }
    }
}
