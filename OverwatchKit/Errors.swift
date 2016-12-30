//
//  Errors.swift
//  OverwatchKit
//
//  Created by Carlos Grossi on 20/6/16.
//  Copyright © 2016 Carlos Grossi. All rights reserved.
//

import Foundation

extension NSError {
    struct constants {
        @nonobjc static let errorDomain = "net.Day1Digital.OverwatchKit"
        @nonobjc static let noURLFoundNo:Int = 1000
        @nonobjc static let elementMissingErrorNo:Int = 1001
        @nonobjc static let errorGettingBattleNetID:Int = 1002
        @nonobjc static let errorGettingProfileData:Int = 1003
        @nonobjc static let errorBattleTagNotFound:Int = 1004
        
        static let errorGettingBattleNetIDDescr = "Unable to get information from the the BattleNet, maybe the battle net servers is offline, please try again in a few moments"
        static let battleTagNotFoundDescr = "Battle Tag not found, please check your Battle Tag and try loading again."
    }
    
    static func noURLFound() -> NSError {
        return NSError(domain: NSError.constants.errorDomain, code: NSError.constants.noURLFoundNo, userInfo: [NSLocalizedDescriptionKey : ""])
    }
    
    static func elementMissing() -> NSError {
        return NSError(domain: NSError.constants.errorDomain, code: NSError.constants.elementMissingErrorNo, userInfo: [NSLocalizedDescriptionKey : ""])
    }
    
    static func errorGettingBattleNetID() -> NSError {
        return NSError(domain: NSError.constants.errorDomain, code: NSError.constants.errorGettingBattleNetID, userInfo: [NSLocalizedDescriptionKey : NSError.constants.errorGettingBattleNetIDDescr])
    }
    
    static func errorGettingProfileData() -> NSError {
        return NSError(domain: NSError.constants.errorDomain, code: NSError.constants.errorGettingProfileData, userInfo: [NSLocalizedDescriptionKey : NSError.constants.errorGettingBattleNetIDDescr])
    }
    
    static func errorBattleTagNotFound() -> NSError {
        return NSError(domain: NSError.constants.errorDomain, code: NSError.constants.errorBattleTagNotFound, userInfo: [NSLocalizedDescriptionKey : NSError.constants.battleTagNotFoundDescr])
    }
}
