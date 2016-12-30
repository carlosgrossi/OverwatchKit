//
//  OverwatchProfile.swift
//  OverwatchKit
//
//  Created by Carlos Grossi on 22/6/16.
//  Copyright © 2016 Carlos Grossi. All rights reserved.
//

import Foundation

public class OverwatchProfile {

    public var screenName:String?
    public var currentLevel:Int?
    public var levelBadge:String?
    public var portraitImage:String?
    public var carrerStats = CarrerStats()
    
    public struct CarrerStats {
        public var score:Int?
        public var timePlayed:Int?
        
        public var soloKills = SoloKills()
        public struct SoloKills {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var objectiveKills = ObjectiveKills()
        public struct ObjectiveKills {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var finalBlows = FinalBlows()
        public struct FinalBlows {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var damageDone = DamageDone()
        public struct DamageDone {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var eliminations = Eliminations()
        public struct Eliminations {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var enviromentalKills = EnviromentalKills()
        public struct EnviromentalKills {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var enviromentalDeaths = EnviromentalDeaths()
        public struct EnviromentalDeaths {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var multiKills = MultiKills()
        public struct MultiKills {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var deaths = Deaths()
        public struct Deaths {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var games = Games()
        public struct Games {
            public var played:Int?
            public var won:Int?
            public var lost:Int?
        }
        
        public var timeSpentOnFire = TimeSpentOnFire()
        public struct TimeSpentOnFire {
            public var overall:String?
            public var average:String?
            public var best:String?
        }
        
        public var objectiveTime = ObjectiveTime()
        public struct ObjectiveTime {
            public var overall:String?
            public var average:String?
            public var best:String?
        }
        
        public var healingDone = HealingDone()
        public struct HealingDone {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var teleporterPadsDestroyed = TeleporterPadsDestroyed()
        public struct TeleporterPadsDestroyed {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var defensiveAssists = DefensiveAssists()
        public struct DefensiveAssists {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
        
        public var offensiveAssists = OffensiveAssists()
        public struct OffensiveAssists {
            public var overall:Int?
            public var average:Double?
            public var best:Int?
        }
    }
    
    
    init() { }
}
