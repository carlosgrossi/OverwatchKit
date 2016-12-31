//
//  LootboxOverwatchAPI.swift
//  OverwatchKit
//
//  Created by Carlos Grossi on 20/6/16.
//  Copyright © 2016 Carlos Grossi. All rights reserved.
//

import Foundation
import ExtensionKit

open class LootboxOverwatchAPI {
    
    static open let standardAPI = LootboxOverwatchAPI()
    
    open func getPatchNotes(_ completitionHandler:@escaping (NSArray?, NSError?)->()) {
        guard let url = patchNotesURL() else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url: url, completitionHandler: completitionHandler)
    }
    
    open func getProfileStats(_ plataform:String, region:String, tag:String, completitionHandler:@escaping (NSDictionary?, NSError?)->()) {
        guard let url = profileStatsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url: url, completitionHandler: completitionHandler)
    }
    
    open func getAchievements(_ plataform:String, region:String, tag:String, completitionHandler:@escaping (NSDictionary?, NSError?)->()) {
        guard let url = achievementsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url: url, completitionHandler: completitionHandler)
    }
    
    open func getHeroesStats(_ plataform:String, region:String, tag:String, completitionHandler:@escaping (NSDictionary?, NSError?)->()) {
        guard let url = heroesStatsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url: url, completitionHandler: completitionHandler)
    }
    
    open func getHeroStats(_ plataform:String, region:String, tag:String, hero:String, completitionHandler:@escaping (NSDictionary?, NSError?)->()) {
        guard let url = heroStatsURL(plataform, region: region, tag: tag, hero: hero) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url: url, completitionHandler: completitionHandler)
    }
    
    open func getOverallHeroesStats(_ plataform:String, region:String, tag:String, completitionHandler:@escaping (NSArray?, NSError?)->()) {
        guard let url = overallHeroesStatsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url: url, completitionHandler: completitionHandler)
    }
    
    open func getPlataforms(_ plataform:String, region:String, tag:String, completitionHandler:@escaping (NSDictionary?, NSError?)->()) {
        guard let url = plataformsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url: url, completitionHandler: completitionHandler)
    }
    
    // MARK: - Private Methods
    fileprivate func getInfo(url:URL, completitionHandler:@escaping (NSDictionary?, NSError?)->()) {
        URLSession.urlSessionDataTaskWithURL(url) { (data, response, error) in
            URLSession.validateURLSessionDataTask(data, response: response, error: error as NSError?, completitionHandler: { (data, error) in
                if (error == nil) {
                    completitionHandler(JSONSerialization.serializeDataToDictionary(data), nil)
                } else {
                    completitionHandler(nil, error)
                }
            })
        }
    }
    
    fileprivate func getInfo(url:URL, completitionHandler:@escaping (NSArray?, NSError?)->()) {
        URLSession.urlSessionDataTaskWithURL(url) { (data, response, error) in
            URLSession.validateURLSessionDataTask(data, response: response, error: error as NSError?, completitionHandler: { (data, error) in
                if (error == nil) {
                    completitionHandler(JSONSerialization.serializeDataToArray(data), nil)
                } else {
                    completitionHandler(nil, error)
                }
            })
        }
    }
    
    fileprivate func patchNotesURL() -> URL? {
        return URL(string: LootboxOverwatchAPIConstants.PatchNotesURL, args: [])
    }
    
    fileprivate func profileStatsURL(_ plataform:String, region:String, tag:String) -> URL? {
        return URL(string: LootboxOverwatchAPIConstants.ProfileStatsURL, args: [plataform, region, tag])
    }
    
    fileprivate func achievementsURL(_ plataform:String, region:String, tag:String) -> URL? {
        return URL(string: LootboxOverwatchAPIConstants.AchievementsURL, args: [plataform, region, tag])
    }
    
    fileprivate func heroesStatsURL(_ plataform:String, region:String, tag:String) -> URL? {
        return URL(string: LootboxOverwatchAPIConstants.HeroesStatsURL, args: [plataform, region, tag])
    }
    
    fileprivate func heroStatsURL(_ plataform:String, region:String, tag:String, hero:String) -> URL? {
        return URL(string: LootboxOverwatchAPIConstants.HeroStatsURL, args: [plataform, region, tag, hero])
    }
    
    fileprivate func overallHeroesStatsURL(_ plataform:String, region:String, tag:String) -> URL? {
        return URL(string: LootboxOverwatchAPIConstants.OverallHeroesStatsURL, args: [plataform, region, tag])
    }
    
    fileprivate func plataformsURL(_ plataform:String, region:String, tag:String) -> URL? {
        return URL(string: LootboxOverwatchAPIConstants.PlataformsURL, args: [plataform, region, tag])
    }
}
