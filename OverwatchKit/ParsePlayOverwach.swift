 //
//  ParsePlayOverwach.swift
//  OverwatchKit
//
//  Created by Carlos Grossi on 21/6/16.
//  Copyright © 2016 Carlos Grossi. All rights reserved.
//

import Foundation
import ExtensionKit

open class PlayOverwatchProfile {
    
    static open let defaultProfile = PlayOverwatchProfile()
    
    open func getAccountByName(_ accountName:String, completitionHandler:@escaping (_ userInfo:[[String:String?]]?, NSError?)->()) {
        guard let url = PlayOverwatchAccountByNameURL(accountName) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getAccountByName(url, completitionHandler: completitionHandler)
    }
    
    open func getProfile(_ language:String = "en-us", carrerLink:String, completitionHandler:@escaping (NSDictionary?, NSError?)->()) {
        guard let url = PlayOverwatchProfileURL(language, carrerLink: carrerLink) else { completitionHandler(nil, NSError.noURLFound()); return }
        self.getProfileData(url, completitionHandler: completitionHandler)
    }
    
    // MARK: - Private Methods
    fileprivate func PlayOverwatchAccountByNameURL(_ accountName:String) -> URL? {
        return URL(string: PlayOverwatchParseConstants.AccountByNameURL, args: [accountName])
    }
    fileprivate func PlayOverwatchProfileURL(_ language:String, carrerLink:String) -> URL? {
        return URL(string: PlayOverwatchParseConstants.ProfileStatsURL, args: [language, carrerLink])
    }
    
    fileprivate func getAccountByName(_ url:URL, completitionHandler:@escaping ([[String:String?]]?, NSError?)->()) {
        URLSession.urlSessionDataTaskWithURL(url) { (data, response, error) in
            URLSession.validateURLSessionDataTask(data, response: response, error: error as NSError?, completitionHandler: { (accountData, error) in
                if (error == nil) {
                    if (data != nil) {
                        self.getAccountId(JSONSerialization.serializeDataToArray(accountData), completitionHandler: completitionHandler)
                    } else {
                        completitionHandler(nil, NSError.errorBattleTagNotFound())
                    }
                } else {
                    completitionHandler(nil, NSError.errorGettingBattleNetID())
                }
            })
        }
    }
    
    fileprivate func getProfileData(_ url:URL, completitionHandler:@escaping (NSDictionary?, NSError?)->()) {
        URLSession.urlSessionDataTaskWithURL(url) { (data, response, error) in
            URLSession.validateURLSessionDataTask(data, response: response, error: error as NSError?, completitionHandler: { (data, error) in
                if (error == nil) {
                    if (data.count > 0) {
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
    
    fileprivate func getAccountId(_ account:NSArray?, completitionHandler:([[String:String?]]?, NSError?)->()) {
        guard let account = account else { completitionHandler(nil, NSError.errorBattleTagNotFound()); return }
        guard account.count > 0 else { completitionHandler(nil, NSError.errorBattleTagNotFound()); return }
        
        var profiles:[[String:String?]] = []
        for accountDictionary in account {
            guard let carrerLink = (accountDictionary as AnyObject).value(forKey: "careerLink") as? String else { completitionHandler(nil, NSError.errorBattleTagNotFound()); return }
            guard let displayName = (accountDictionary as AnyObject).value(forKey: "platformDisplayName") as? String  else { completitionHandler(nil, NSError.errorBattleTagNotFound()); return }
            guard let portraitImage = (accountDictionary as AnyObject).value(forKey: "portrait") as? String   else { completitionHandler(nil, NSError.errorBattleTagNotFound()); return }
            
            var plataform:String?
            var region:String = ""
            
            let occurencesOfSlash = carrerLink.rangesOfSubstring("/")
            if occurencesOfSlash.count > 0 {
                var location = occurencesOfSlash[1].location + 1
                var length = occurencesOfSlash[2].location - occurencesOfSlash[1].location - 1
                
                if (length <= carrerLink.characters.count - location) {
                    plataform = (carrerLink as NSString).substring(with: NSRange(location: location, length: length))
                }
                
                if occurencesOfSlash.count > 3 {
                    location = occurencesOfSlash[2].location + 1
                    length = occurencesOfSlash[3].location - occurencesOfSlash[2].location - 1
                    
                    if (length <= carrerLink.characters.count - location) {
                        region = (carrerLink as NSString).substring(with: NSRange(location: location, length: length))
                    }
                }
                
            }
            
            var userInfo:[String:String?] = [:]
            userInfo.updateValue(carrerLink, forKey: "carrerLink")
            userInfo.updateValue(displayName, forKey: "displayName")
            userInfo.updateValue(portraitImage, forKey: "portraitImage")
            userInfo.updateValue(plataform, forKey: "plataform")
            userInfo.updateValue(region, forKey: "region")
            
            profiles.append(userInfo)
        }

        completitionHandler(profiles, nil)
    }
    
    fileprivate func parseProfileData(_ profileData:Data, completitionHandler:(NSDictionary?, NSError?)->()) {
        let profileParse = TFHpple(htmlData: profileData)
        let profile = NSMutableDictionary()
        
        profile.setValue(self.parseScreenName(profileParse!), forKey: "ScreenName")
        profile.setValue(self.parseLevelBadge(profileParse!), forKey: "LevelBadge")
        profile.setValue(self.parseLevelRank(profileParse!), forKey: "LevelRank")
        profile.setValue(self.parseCurrentLevel(profileParse!), forKey: "Level")
        profile.setValue(self.parseRankBadge(profileParse!), forKey: "RankBadge")
        profile.setValue(self.parseCurrentRank(profileParse!), forKey: "Rank")
        profile.setValue(self.parseMasterheadHero(profileParse!), forKey: "MasterheadHero")
        
        let quickPlay = NSMutableDictionary()
        if let quickPlaySection = profileParse?.search(withXPathQuery: "//div[@id='quickplay']") as? [TFHppleElement] {
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E00000FFFFFFFF']", parseSubject: quickPlaySection.first), forKey: "Overall")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000002']", parseSubject: quickPlaySection.first), forKey: "Reaper")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000003']", parseSubject: quickPlaySection.first), forKey: "Tracer")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000004']", parseSubject: quickPlaySection.first), forKey: "Mercy")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000005']", parseSubject: quickPlaySection.first), forKey: "Hanzo")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000006']", parseSubject: quickPlaySection.first), forKey: "Torbjorn")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000007']", parseSubject: quickPlaySection.first), forKey: "Reinhardt")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000008']", parseSubject: quickPlaySection.first), forKey: "Pharah")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000009']", parseSubject: quickPlaySection.first), forKey: "Winston")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000000A']", parseSubject: quickPlaySection.first), forKey: "Widowmaker")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000015']", parseSubject: quickPlaySection.first), forKey: "Bastion")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000040']", parseSubject: quickPlaySection.first), forKey: "Roadhog")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000042']", parseSubject: quickPlaySection.first), forKey: "McCree")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000065']", parseSubject: quickPlaySection.first), forKey: "Junkrat")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000068']", parseSubject: quickPlaySection.first), forKey: "Zarya")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000006E']", parseSubject: quickPlaySection.first), forKey: "Soldier76")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000079']", parseSubject: quickPlaySection.first), forKey: "Lucio")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000007A']", parseSubject: quickPlaySection.first), forKey: "DVa")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E00000000000DD']", parseSubject: quickPlaySection.first), forKey: "Mei")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000029']", parseSubject: quickPlaySection.first), forKey: "Genji")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000016']", parseSubject: quickPlaySection.first), forKey: "Symmetra")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000013B']", parseSubject: quickPlaySection.first), forKey: "Ana")
            quickPlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000020']", parseSubject: quickPlaySection.first), forKey: "Zenyatta")
        }
        
        let competitivePlay = NSMutableDictionary()
        if let competitivePlaySection = profileParse?.search(withXPathQuery: "//div[@id='competitive']") as? [TFHppleElement] {
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E00000FFFFFFFF']", parseSubject: competitivePlaySection.first), forKey: "Overall")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000002']", parseSubject: competitivePlaySection.first), forKey: "Reaper")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000003']", parseSubject: competitivePlaySection.first), forKey: "Tracer")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000004']", parseSubject: competitivePlaySection.first), forKey: "Mercy")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000005']", parseSubject: competitivePlaySection.first), forKey: "Hanzo")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000006']", parseSubject: competitivePlaySection.first), forKey: "Torbjorn")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000007']", parseSubject: competitivePlaySection.first), forKey: "Reinhardt")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000008']", parseSubject: competitivePlaySection.first), forKey: "Pharah")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000009']", parseSubject: competitivePlaySection.first), forKey: "Winston")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000000A']", parseSubject: competitivePlaySection.first), forKey: "Widowmaker")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000015']", parseSubject: competitivePlaySection.first), forKey: "Bastion")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000040']", parseSubject: competitivePlaySection.first), forKey: "Roadhog")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000042']", parseSubject: competitivePlaySection.first), forKey: "McCree")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000065']", parseSubject: competitivePlaySection.first), forKey: "Junkrat")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000068']", parseSubject: competitivePlaySection.first), forKey: "Zarya")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000006E']", parseSubject: competitivePlaySection.first), forKey: "Soldier76")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000079']", parseSubject: competitivePlaySection.first), forKey: "Lucio")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000007A']", parseSubject: competitivePlaySection.first), forKey: "DVa")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E00000000000DD']", parseSubject: competitivePlaySection.first), forKey: "Mei")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000029']", parseSubject: competitivePlaySection.first), forKey: "Genji")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000016']", parseSubject: competitivePlaySection.first), forKey: "Symmetra")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E000000000013B']", parseSubject: competitivePlaySection.first), forKey: "Ana")
            competitivePlay.setValue(self.parseCarrerStats("//div[@data-category-id='0x02E0000000000020']", parseSubject: competitivePlaySection.first), forKey: "Zenyatta")
        }
        
        profile.setValue(quickPlay, forKey: "QuickPlay")
        profile.setValue(competitivePlay, forKey: "CompetitivePlay")
        
        let achievements = NSMutableDictionary()
        achievements.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.0']", parseSubject: profileParse!), forKey: "General")
        achievements.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.1']", parseSubject: profileParse!), forKey: "Offense")
        achievements.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.2']", parseSubject: profileParse!), forKey: "Defense")
        achievements.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.3']", parseSubject: profileParse!), forKey: "Tank")
        achievements.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.4']", parseSubject: profileParse!), forKey: "Support")
        achievements.setValue(self.parseAchievements("//div[@data-category-id='overwatch.achievementCategory.5']", parseSubject: profileParse!), forKey: "Maps")
        
        profile.setValue(achievements, forKey: "Achievements")
        
        completitionHandler(profile, nil)
    }
    
    fileprivate func parseScreenName(_ parseSubject:TFHpple) -> String? {
        if let parseElement = parseSubject.search(withXPathQuery: "//h1[@class='header-masthead']").first as? TFHppleElement {
            return parseElement.content
        }
        return nil
    }
    
    fileprivate func parseLevelBadge(_ parseSubject:TFHpple) -> String? {
        if let parseElement = parseSubject.search(withXPathQuery: "//div[@class='player-level']").first as? TFHppleElement {
            if let elementAttribute = parseElement.attributes.first?.1 as? String {
                do {
                    let urlDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = urlDetector.matches(in: elementAttribute, options: [], range: NSRange(location: 0, length: elementAttribute.utf8.count))
                    
                    for match in matches {
                        return (elementAttribute as NSString).substring(with: match.range)
                    }
                } catch _ { }
            }
        }
        return nil
    }
    
    fileprivate func parseLevelRank(_ parseSubject:TFHpple) -> String? {
        if let parseElement = parseSubject.search(withXPathQuery: "//div[@class='player-rank']").first as? TFHppleElement {
            if let elementAttribute = parseElement.attributes.first?.1 as? String {
                do {
                    let urlDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = urlDetector.matches(in: elementAttribute, options: [], range: NSRange(location: 0, length: elementAttribute.utf8.count))
                    
                    for match in matches {
                        return (elementAttribute as NSString).substring(with: match.range)
                    }
                } catch _ { }
            }
        }
        return nil
    }
    
    fileprivate func parseRankBadge(_ parseSubject:TFHpple) -> String? {
        if let parseElement = parseSubject.search(withXPathQuery: "//div[@class='competitive-rank']/img").first as? TFHppleElement {
            return parseElement.attributes["src"] as? String
        }
        return nil
    }
    
    fileprivate func parseCurrentLevel(_ parseSubject:TFHpple) -> Int? {
        if let parseElement = parseSubject.search(withXPathQuery: "//div[@class='player-level']/div").first as? TFHppleElement {
            return Int(parseElement.content)
        }
        return nil
    }
    
    fileprivate func parseCurrentRank(_ parseSubject:TFHpple) -> Int? {
        if let parseElement = parseSubject.search(withXPathQuery: "//div[@class='competitive-rank']/div").first as? TFHppleElement {
            return Int(parseElement.content)
        }
        return nil
    }
    
    fileprivate func parseMasterheadHero(_ parseSubject:TFHpple) -> String? {
        //if let parseElement = parseSubject.searchWithXPathQuery("//div[starts-with(@class,'masthead-hero-image')]").first as? TFHppleElement {
        if let parseElement = parseSubject.search(withXPathQuery: "//div[starts-with(@data-js,'heroMastheadImage')]").first as? TFHppleElement {
            guard let masterheadHero = parseElement.attributes["data-hero-quickplay"] as? String else { return nil }
            return masterheadHero.lastWord
        }
        return nil
    }
    
    fileprivate func parseCarrerStats(_ xPath:String, parseSubject:TFHppleElement?) -> NSDictionary? {
        guard let parseSubject = parseSubject else { return nil }
        if let overallStats = self.parseStatsForPath(xPath, parseSubject: parseSubject) {
            return NSDictionary(dictionary: overallStats)
        }
        return nil
    }
    
    fileprivate func parseStatsForPath(_ XPathQuery:String, parseSubject:TFHppleElement) -> [String:AnyObject]? {
        guard let parseElements = parseSubject.search(withXPathQuery: XPathQuery) as? [TFHppleElement] else { return nil }
        
        for parseElement in parseElements {
            guard let parseElementChildren = parseElement.children as? [TFHppleElement] else { continue }
            return self.parseStatsChildren(parseElementChildren)
        }
        
        return nil
    }
    
    fileprivate func parseStatsChildren(_ children:[TFHppleElement]) -> [String:AnyObject]? {
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
                    
                    for tableNode in (parentNode?.children)! {
                        guard tableNode is TFHppleElement else { continue }
                        
                        if (tableNode as AnyObject).tagName == "tbody" {
                            for trNode in (tableNode as AnyObject).children {
                                guard trNode is TFHppleElement else { continue }
                                guard (trNode as AnyObject).tagName == "tr" else { continue }
                                
                                
                                var key:String = ""
                                var value:String = ""
                                
                                
                                var tdIndex:Int = 0
                                for tdNode in (trNode as AnyObject).children {
                                    
                                    switch tdIndex % ((trNode as AnyObject).children!).count {
                                    case 0:
                                        guard tdNode is TFHppleElement else { break }
                                        guard (tdNode as AnyObject).content != nil else { break }
                                        key = String((tdNode as AnyObject).content)
                                    case 1:
                                        guard tdNode is TFHppleElement else { break }
                                        guard (tdNode as AnyObject).content != nil else { break }
                                        value = String((tdNode as AnyObject).content)
                                    default: break
                                    }
                                    tdIndex += 1
                                }
                                stats.updateValue(value, forKey: key)
                            }
                        }
                    }
                    return [child.content:stats as AnyObject]
                }
            }
        }
        return carrerStats
    }
    
    fileprivate func parseAchievements(_ XPathQuery:String, parseSubject:TFHpple) -> NSArray? {
        guard let parseElements = parseSubject.search(withXPathQuery: XPathQuery) as? [TFHppleElement] else { return nil }
        
        for parseElement in parseElements {
            guard let parseElementChildren = parseElement.children as? [TFHppleElement] else { continue }
            return self.parseAchievementsChildren(parseElementChildren)
        }
        
        return nil
    }
    
    fileprivate func parseAchievementsChildren(_ children:[TFHppleElement]) -> NSArray? {
        let achievements = NSMutableArray()
        for child in children {
            if !child.isTextNode() {
                guard child.children.count > 0 else { continue }
                guard let parsedChildren = self.parseAchievementsChildren(child.children as! [TFHppleElement]) else { continue }
                guard parsedChildren.count > 0 else { continue }
                return parsedChildren
            } else {
                guard var nodeParent = child.parent else { return nil }
                while (( (nodeParent.attributes["class"] as AnyObject).contains("column")) == false ) {
                    guard nodeParent.parent != nil else { break }
                    nodeParent = nodeParent.parent
                }
                
                guard nodeParent.parent != nil else { return nil }
                
                let ulNode = nodeParent.parent
                
                
                for child in (ulNode?.children)! {
                    guard let ulNodeChildren = (child as AnyObject).children as? [TFHppleElement] else { return nil }
                    let achievement = NSMutableDictionary()
                    achievement.setValue(self.parseAchievementsImage(ulNodeChildren), forKey: "achievementImage")
                    achievement.setValue(self.parseAchievementName(ulNodeChildren), forKey: "achievementName")
                    achievement.setValue(self.parseAchievementDesctiption(ulNodeChildren), forKey: "achievementDescription")
                    achievement.setValue(self.parseAchievementUnlocked(ulNodeChildren), forKey: "achievementUnlocked")
                    achievements.add(achievement)
                }

                
                
                return achievements
            }
        }
        return achievements
    }
    
    fileprivate func parseAchievementUnlocked(_ children:[TFHppleElement]) -> Bool {
        for child in children {
            if child.attributes.filter({ ($0.1 as! NSString).contains("m-disabled") }).count > 0 {
                return false
            }
        }
        return true
    }
    
    fileprivate func parseAchievementsImage(_ children:[TFHppleElement]) -> String? {
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
    
    fileprivate func parseAchievementName(_ children:[TFHppleElement]) -> String? {
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
    
    fileprivate func parseAchievementDesctiption(_ children:[TFHppleElement]) -> String? {
        for child in children {
            if child.tagName != "p" {
                guard child.children.count > 0 else { continue }
                guard let description = self.parseAchievementDesctiption(child.children as! [TFHppleElement]) else { continue }
                return description
            } else {
                return (child.children.first as AnyObject).content
            }
        }
        return nil
    }
}
 
 
extension String {
    mutating func removeComma() {
        self = self.replacingOccurrences(of: ",", with: "")
    }
 }
 
 extension Dictionary where Value : Equatable {
    func allKeysForValue(_ val : Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
 }
 
 
 extension String {
    var byWords: [String] {
        var result:[String] = []
        let range = characters.startIndex ..< characters.endIndex
        
        enumerateSubstrings(in: range, options: .byWords) {w,_,_,_ in
            guard let word = w else {return}
            result.append(word)
        }
        
        return result
    }
    var lastWord: String {
        return byWords.last ?? ""
    }
    func lastWords(_ maxWords: Int) -> [String] {
        return Array(byWords.suffix(maxWords))
    }
 }
