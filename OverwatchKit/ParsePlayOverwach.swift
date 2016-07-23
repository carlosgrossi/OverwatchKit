 //
//  ParsePlayOverwach.swift
//  OverwatchKit
//
//  Created by Carlos Grossi on 21/6/16.
//  Copyright © 2016 Carlos Grossi. All rights reserved.
//

import Foundation
import ExtensionKit

public class PlayOverwatchProfile {
    
    static public let defaultProfile = PlayOverwatchProfile()
    
    public func getAccountByName(accountName:String, completitionHandler:(carrerLink:String?, displayName:String?, portraitImage:String?, NSError?)->()) {
        guard let url = PlayOverwatchAccountByNameURL(accountName) else { completitionHandler(carrerLink: nil, displayName: nil, portraitImage: nil, NSError.noURLFound()); return }
        self.getAccountByName(url, completitionHandler: completitionHandler)
    }
    
    public func getProfile(language:String = "en-us", carrerLink:String, completitionHandler:(NSDictionary?, NSError?)->()) {
        guard let url = PlayOverwatchProfileURL(language, carrerLink: carrerLink) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getProfileData(url, completitionHandler: completitionHandler)
    }
    
    // MARK: - Private Methods
    private func PlayOverwatchAccountByNameURL(accountName:String) -> NSURL? {
        return NSURL(string: PlayOverwatchParseConstants.AccountByNameURL, args: [accountName])
    }
    private func PlayOverwatchProfileURL(language:String, carrerLink:String) -> NSURL? {
        return NSURL(string: PlayOverwatchParseConstants.ProfileStatsURL, args: [language, carrerLink])
    }
    
    private func getAccountByName(url:NSURL, completitionHandler:(String?, String?, String?, NSError?)->()) {
        NSURLSession.urlSessionDataTaskWithURL(url) { (data, response, error) in
            NSURLSession.validateURLSessionDataTask(data, response: response, error: error, completitionHandler: { (accountData, error) in
                if (error == nil) {
                    if (data != nil) {
                        self.getAccountId(NSJSONSerialization.serializeDataToArray(accountData), completitionHandler: completitionHandler)
                    } else {
                        completitionHandler(nil, nil, nil, NSError.errorBattleTagNotFound())
                    }
                } else {
                    completitionHandler(nil, nil, nil, NSError.errorGettingBattleNetID())
                }
            })
        }
    }
    
    private func getProfileData(url:NSURL, completitionHandler:(NSDictionary?, NSError?)->()) {
        NSURLSession.urlSessionDataTaskWithURL(url) { (data, response, error) in
            NSURLSession.validateURLSessionDataTask(data, response: response, error: error, completitionHandler: { (data, error) in
                if (error == nil) {
                    if (data.length > 0) {
                        self.parseProfileData(data, completitionHandler: completitionHandler)
                    } else {
                        completitionHandler(nil, NSError.errorGettingProfileData())
                    }
                } else {
                    completitionHandler(nil, NSError.errorGettingProfileData())
                }
            })
        }
    }
    
    private func getAccountId(account:NSArray?, completitionHandler:(String?, String?, String?, NSError?)->()) {
        guard account?.count > 0 else {
            completitionHandler(nil, nil, nil, NSError.errorBattleTagNotFound()); return }
        let accountDictionary = account?.firstObject
        
        guard let carrerLink = accountDictionary?.valueForKey("careerLink") as? String else {
            completitionHandler(nil, nil, nil, NSError.errorBattleTagNotFound()); return }
        guard let displayName = accountDictionary?.valueForKey("platformDisplayName") as? String  else {
            completitionHandler(nil, nil, nil, NSError.errorBattleTagNotFound()); return }
        guard let portraitImage = accountDictionary?.valueForKey("portrait") as? String   else {
            completitionHandler(nil, nil, nil, NSError.errorBattleTagNotFound()); return }
        
        completitionHandler(carrerLink, displayName, portraitImage, nil)
    }
    
    private func parseProfileData(profileData:NSData, completitionHandler:(NSDictionary?, NSError?)->()) {
        let profileParse = TFHpple(HTMLData: profileData)
        let profile = NSMutableDictionary()
        
        profile.setValue(self.parseScreenName(profileParse), forKey: "ScreenName")
        profile.setValue(self.parseLevelBadge(profileParse), forKey: "LevelBadge")
        profile.setValue(self.parseCurrentLevel(profileParse), forKey: "Level")
        profile.setValue(self.parseRankBadge(profileParse), forKey: "RankBadge")
        profile.setValue(self.parseCurrentRank(profileParse), forKey: "Rank")
        profile.setValue(self.parseMasterheadHero(profileParse), forKey: "MasterheadHero")
        
        if let quickPlaySection = profileParse.searchWithXPathQuery("//div[@id='quick-play']") as? [TFHppleElement] {
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E00000FFFFFFFF']", parseSubject: quickPlaySection.first), forKey: "Overall")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000002']", parseSubject: quickPlaySection.first), forKey: "Reaper")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000003']", parseSubject: quickPlaySection.first), forKey: "Tracer")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000004']", parseSubject: quickPlaySection.first), forKey: "Mercy")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000005']", parseSubject: quickPlaySection.first), forKey: "Hanzo")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000006']", parseSubject: quickPlaySection.first), forKey: "Torbjorn")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000007']", parseSubject: quickPlaySection.first), forKey: "Reinhardt")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000008']", parseSubject: quickPlaySection.first), forKey: "Pharah")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000009']", parseSubject: quickPlaySection.first), forKey: "Winston")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000000A']", parseSubject: quickPlaySection.first), forKey: "Widowmaker")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000015']", parseSubject: quickPlaySection.first), forKey: "Bastion")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000040']", parseSubject: quickPlaySection.first), forKey: "Roadhog")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000042']", parseSubject: quickPlaySection.first), forKey: "McCree")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000065']", parseSubject: quickPlaySection.first), forKey: "Junkrat")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000068']", parseSubject: quickPlaySection.first), forKey: "Zarya")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000006E']", parseSubject: quickPlaySection.first), forKey: "Soldier76")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000079']", parseSubject: quickPlaySection.first), forKey: "Lucio")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000007A']", parseSubject: quickPlaySection.first), forKey: "DVa")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E00000000000DD']", parseSubject: quickPlaySection.first), forKey: "Mei")
        }

        if let competitivePlaySection = profileParse.searchWithXPathQuery("//div[@id='competitive-play']") as? [TFHppleElement] {
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E00000FFFFFFFF']", parseSubject: competitivePlaySection.first), forKey: "cOverall")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000002']", parseSubject: competitivePlaySection.first), forKey: "cReaper")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000003']", parseSubject: competitivePlaySection.first), forKey: "cTracer")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000004']", parseSubject: competitivePlaySection.first), forKey: "cMercy")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000005']", parseSubject: competitivePlaySection.first), forKey: "cHanzo")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000006']", parseSubject: competitivePlaySection.first), forKey: "cTorbjorn")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000007']", parseSubject: competitivePlaySection.first), forKey: "cReinhardt")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000008']", parseSubject: competitivePlaySection.first), forKey: "cPharah")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000009']", parseSubject: competitivePlaySection.first), forKey: "cWinston")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000000A']", parseSubject: competitivePlaySection.first), forKey: "cWidowmaker")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000015']", parseSubject: competitivePlaySection.first), forKey: "cBastion")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000040']", parseSubject: competitivePlaySection.first), forKey: "cRoadhog")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000042']", parseSubject: competitivePlaySection.first), forKey: "cMcCree")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000065']", parseSubject: competitivePlaySection.first), forKey: "cJunkrat")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000068']", parseSubject: competitivePlaySection.first), forKey: "cZarya")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000006E']", parseSubject: competitivePlaySection.first), forKey: "cSoldier76")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000079']", parseSubject: competitivePlaySection.first), forKey: "cLucio")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000007A']", parseSubject: competitivePlaySection.first), forKey: "cDVa")
            profile.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E00000000000DD']", parseSubject: competitivePlaySection.first), forKey: "cMei")
        }
        
        profile.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.0']", parseSubject: profileParse), forKey: "GeneralAchievements")
        profile.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.1']", parseSubject: profileParse), forKey: "OffenseAchievements")
        profile.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.2']", parseSubject: profileParse), forKey: "DefenseAchievements")
        profile.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.3']", parseSubject: profileParse), forKey: "TankAchievements")
        profile.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.4']", parseSubject: profileParse), forKey: "SupportAchievements")
        profile.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.5']", parseSubject: profileParse), forKey: "MapsAchievements")
        
        completitionHandler(profile, nil)
    }
    
    private func parseScreenName(parseSubject:TFHpple) -> String? {
        if let parseElement = parseSubject.searchWithXPathQuery("//h1[@class='header-masthead']").first as? TFHppleElement {
            return parseElement.content
        }
        return nil
    }
    
    private func parseLevelBadge(parseSubject:TFHpple) -> String? {
        if let parseElement = parseSubject.searchWithXPathQuery("//div[@class='player-level']").first as? TFHppleElement {
            if let elementAttribute = parseElement.attributes.first?.1 as? String {
                do {
                    let urlDetector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
                    let matches = urlDetector.matchesInString(elementAttribute, options: [], range: NSRange(location: 0, length: elementAttribute.utf8.count))
                    
                    for match in matches {
                        return (elementAttribute as NSString).substringWithRange(match.range)
                    }
                } catch _ { }
            }
        }
        return nil
    }
    
    private func parseRankBadge(parseSubject:TFHpple) -> String? {
        if let parseElement = parseSubject.searchWithXPathQuery("//div[@class='competitive-rank']/img").first as? TFHppleElement {
            return parseElement.attributes["src"] as? String
        }
        return nil
    }
    
    private func parseCurrentLevel(parseSubject:TFHpple) -> Int? {
        if let parseElement = parseSubject.searchWithXPathQuery("//div[@class='player-level']/div").first as? TFHppleElement {
            return Int(parseElement.content)
        }
        return nil
    }
    
    private func parseCurrentRank(parseSubject:TFHpple) -> Int? {
        if let parseElement = parseSubject.searchWithXPathQuery("//div[@class='competitive-rank']/div").first as? TFHppleElement {
            return Int(parseElement.content)
        }
        return nil
    }
    
    private func parseMasterheadHero(parseSubject:TFHpple) -> String? {
        if let parseElement = parseSubject.searchWithXPathQuery("//div[starts-with(@class,'masthead-hero-image')]").first as? TFHppleElement {
            guard let masterheadHero = parseElement.attributes["class"] as? String else { return nil }
            return masterheadHero.lastWord
        }
        return nil
    }
    
    private func parseCarrerStats(xPath:String, parseSubject:TFHppleElement?) -> NSDictionary? {
        guard let parseSubject = parseSubject else { return nil }
        if let overallStats = self.parseStatsForPath(xPath, parseSubject: parseSubject) {
            return NSDictionary(dictionary: overallStats)
        }
        return nil
    }
    
    private func parseStatsForPath(XPathQuery:String, parseSubject:TFHppleElement) -> [String:AnyObject]? {
        guard let parseElements = parseSubject.searchWithXPathQuery(XPathQuery) as? [TFHppleElement] else { return nil }
        
        for parseElement in parseElements {
            guard let parseElementChildren = parseElement.children as? [TFHppleElement] else { continue }
            return self.parseStatsChildren(parseElementChildren)
        }
        
        return nil
    }
    
    private func parseStatsChildren(children:[TFHppleElement]) -> [String:AnyObject]? {
        var carrerStats:[String:AnyObject] = [:]
        for child in children {
            if !child.isTextNode() {
                guard child.children.count > 0 else { continue }
                let x = self.parseStatsChildren(child.children as! [TFHppleElement])!
                for (k, v) in x {
                    carrerStats.updateValue(v, forKey: k)
                }
            } else {
                guard var nodeParent = child.parent else { return nil }
                while ( nodeParent.tagName != "thead" && nodeParent.tagName != "tbody" ) {
                    guard nodeParent.parent != nil else { break }
                    nodeParent = nodeParent.parent
                }
                
                if nodeParent.tagName == "thead" {
                    guard nodeParent.parent != nil else { return nil }
                    let parentNode = nodeParent.parent
                    var stats:[String:String] = [:]
                    
                    for tableNode in parentNode.children {
                        guard tableNode is TFHppleElement else { continue }
                        
                        if tableNode.tagName == "tbody" {
                            for trNode in tableNode.children {
                                guard trNode is TFHppleElement else { continue }
                                guard trNode.tagName == "tr" else { continue }
                                
                                
                                var key:String = ""
                                var value:String = ""
                                
                                
                                var tdIndex:Int = 0
                                for tdNode in trNode.children {
                                    
                                    switch tdIndex % (trNode.children!).count {
                                    case 0:
                                        guard tdNode is TFHppleElement else { break }
                                        guard tdNode.content != nil else { break }
                                        key = String(tdNode.content)
                                    case 1:
                                        guard tdNode is TFHppleElement else { break }
                                        guard tdNode.content != nil else { break }
                                        value = String(tdNode.content)
                                    default: break
                                    }
                                    tdIndex += 1
                                }
                                stats.updateValue(value, forKey: key)
                            }
                        }
                    }
                    return [child.content:stats]
                }
            }
        }
        return carrerStats
    }
    
    private func parseAchievements(XPathQuery:String, parseSubject:TFHpple) -> NSArray? {
        guard let parseElements = parseSubject.searchWithXPathQuery(XPathQuery) as? [TFHppleElement] else { return nil }
        
        for parseElement in parseElements {
            guard let parseElementChildren = parseElement.children as? [TFHppleElement] else { continue }
            return self.parseAchievementsChildren(parseElementChildren)
        }
        
        return nil
    }
    
    private func parseAchievementsChildren(children:[TFHppleElement]) -> NSArray? {
        let achievements = NSMutableArray()
        for child in children {
            if !child.isTextNode() {
                guard child.children.count > 0 else { continue }
                return self.parseAchievementsChildren(child.children as! [TFHppleElement])!
            } else {
                guard var nodeParent = child.parent else { return nil }
                while (( nodeParent.attributes["class"]?.containsString("column")) == false ) {
                    guard nodeParent.parent != nil else { break }
                    nodeParent = nodeParent.parent
                }
                
                guard nodeParent.parent != nil else { return nil }
                
                let ulNode = nodeParent.parent
                
                
                for child in ulNode.children {
                    guard let ulNodeChildren = child.children as? [TFHppleElement] else { return nil }
                    
                    let achievement = NSMutableDictionary()
                    achievement.setValue(self.parseAchievementsImage(ulNodeChildren), forKey: "achievementImage")
                    achievement.setValue(self.parseAchievementName(ulNodeChildren), forKey: "achievementName")
                    achievement.setValue(self.parseAchievementDesctiption(ulNodeChildren), forKey: "achievementDescription")
                    achievements.addObject(achievement)
                }

                
                
                return achievements
            }
        }
        return achievements
    }
    
    private func parseAchievementsImage(children:[TFHppleElement]) -> String? {
        for child in children {
            if child.tagName != "img" {
                guard child.children.count > 0 else { continue }
                return self.parseAchievementsImage(child.children as! [TFHppleElement])
            } else {
                return child.attributes["src"] as? String
            }
        }
        return nil
    }
    
    private func parseAchievementName(children:[TFHppleElement]) -> String? {
        for child in children {
            if !child.isTextNode() {
                guard child.children.count > 0 else { continue }
                return self.parseAchievementName(child.children as! [TFHppleElement])
            } else {
                return child.content
            }
        }
        return nil
    }
    
    private func parseAchievementDesctiption(children:[TFHppleElement]) -> String? {
        for child in children {
            if child.tagName != "p" {
                guard child.children.count > 0 else { continue }
                guard let description = self.parseAchievementDesctiption(child.children as! [TFHppleElement]) else { continue }
                return description
            } else {
                return child.children.first?.content
            }
        }
        return nil
    }
}
 
 
extension String {
    mutating func removeComma() {
        self = self.stringByReplacingOccurrencesOfString(",", withString: "")
    }
 }
 
 extension Dictionary where Value : Equatable {
    func allKeysForValue(val : Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
 }
 
 
 extension String {
    var byWords: [String] {
        var result:[String] = []
        enumerateSubstringsInRange(characters.indices, options: .ByWords) {
            guard let substring = $0.substring else { return }
            result.append(substring)
        }
        return result
    }
    var lastWord: String {
        return byWords.last ?? ""
    }
    func lastWords(maxWords: Int) -> [String] {
        return Array(byWords.suffix(maxWords))
    }
 }