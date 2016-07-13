//
//  LootboxOverwatchAPI.swift
//  OverwatchKit
//
//  Created by Carlos Grossi on 20/6/16.
//  Copyright © 2016 Carlos Grossi. All rights reserved.
//

import Foundation
import ExtensionKit

public class LootboxOverwatchAPI {
    
    static public let standardAPI = LootboxOverwatchAPI()
    
    public func getPatchNotes(completitionHandler:(NSArray?, NSError?)->()) {
        guard let url = patchNotesURL() else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url, completitionHandler: completitionHandler)
    }
    
    public func getProfileStats(plataform:String, region:String, tag:String, completitionHandler:(NSDictionary?, NSError?)->()) {
        guard let url = profileStatsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url, completitionHandler: completitionHandler)
    }
    
    public func getAchievements(plataform:String, region:String, tag:String, completitionHandler:(NSDictionary?, NSError?)->()) {
        guard let url = achievementsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url, completitionHandler: completitionHandler)
    }
    
    public func getHeroesStats(plataform:String, region:String, tag:String, completitionHandler:(NSDictionary?, NSError?)->()) {
        guard let url = heroesStatsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url, completitionHandler: completitionHandler)
    }
    
    public func getHeroStats(plataform:String, region:String, tag:String, hero:String, completitionHandler:(NSDictionary?, NSError?)->()) {
        guard let url = heroStatsURL(plataform, region: region, tag: tag, hero: hero) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url, completitionHandler: completitionHandler)
    }
    
    public func getOverallHeroesStats(plataform:String, region:String, tag:String, completitionHandler:(NSArray?, NSError?)->()) {
        guard let url = overallHeroesStatsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url, completitionHandler: completitionHandler)
    }
    
    public func getPlataforms(plataform:String, region:String, tag:String, completitionHandler:(NSDictionary?, NSError?)->()) {
        guard let url = plataformsURL(plataform, region: region, tag: tag) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getInfo(url, completitionHandler: completitionHandler)
    }
    
    // MARK: - Private Methods
    private func getInfo(url:NSURL, completitionHandler:(NSDictionary?, NSError?)->()) {
        NSURLSession.urlSessionDataTaskWithURL(url) { (data, response, error) in
            NSURLSession.validateURLSessionDataTask(data, response: response, error: error, completitionHandler: { (data, error) in
                if (error == nil) {
                    completitionHandler(NSJSONSerialization.serializeDataToDictionary(data), nil)
                } else {
                    completitionHandler(nil, error)
                }
            })
        }
    }
    
    private func getInfo(url:NSURL, completitionHandler:(NSArray?, NSError?)->()) {
        NSURLSession.urlSessionDataTaskWithURL(url) { (data, response, error) in
            NSURLSession.validateURLSessionDataTask(data, response: response, error: error, completitionHandler: { (data, error) in
                if (error == nil) {
                    completitionHandler(NSJSONSerialization.serializeDataToArray(data), nil)
                } else {
                    completitionHandler(nil, error)
                }
            })
        }
    }
    
    private func patchNotesURL() -> NSURL? {
        return NSURL(string: LootboxOverwatchAPIConstants.PatchNotesURL, args: [])
    }
    
    private func profileStatsURL(plataform:String, region:String, tag:String) -> NSURL? {
        return NSURL(string: LootboxOverwatchAPIConstants.ProfileStatsURL, args: [plataform, region, tag])
    }
    
    private func achievementsURL(plataform:String, region:String, tag:String) -> NSURL? {
        return NSURL(string: LootboxOverwatchAPIConstants.AchievementsURL, args: [plataform, region, tag])
    }
    
    private func heroesStatsURL(plataform:String, region:String, tag:String) -> NSURL? {
        return NSURL(string: LootboxOverwatchAPIConstants.HeroesStatsURL, args: [plataform, region, tag])
    }
    
    private func heroStatsURL(plataform:String, region:String, tag:String, hero:String) -> NSURL? {
        return NSURL(string: LootboxOverwatchAPIConstants.HeroStatsURL, args: [plataform, region, tag, hero])
    }
    
    private func overallHeroesStatsURL(plataform:String, region:String, tag:String) -> NSURL? {
        return NSURL(string: LootboxOverwatchAPIConstants.OverallHeroesStatsURL, args: [plataform, region, tag])
    }
    
    private func plataformsURL(plataform:String, region:String, tag:String) -> NSURL? {
        return NSURL(string: LootboxOverwatchAPIConstants.PlataformsURL, args: [plataform, region, tag])
    }
}