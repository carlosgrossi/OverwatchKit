//
//  Constants.swift
//  OverwatchKit
//
//  Created by Carlos Grossi on 20/6/16.
//  Copyright © 2016 Carlos Grossi. All rights reserved.
//

import Foundation

public struct LootboxOverwatchAPIConstants {
    static let PatchNotesURL = "https://api.lootbox.eu/patch_notes"
    static let ProfileStatsURL = "https://api.lootbox.eu/%@/%@/%@/profile"          /* /{platform}/{region}/{tag}/profile       */
    static let AchievementsURL = "https://api.lootbox.eu/%@/%@/%@/achievements"     /* /{platform}/{region}/{tag}/achievements  */
    static let HeroesStatsURL = "https://api.lootbox.eu/%@/%@/%@/allHeroes/"        /* /{platform}/{region}/{tag}/allHeroes     */
    static let HeroStatsURL = "https://api.lootbox.eu/%@/%@/%@/hero/%@/"            /* /{platform}/{region}/{tag}/hero/{hero}/  */
    static let OverallHeroesStatsURL = "https://api.lootbox.eu/%@/%@/%@/heroes"     /* /{platform}/{region}/{tag}/heroes        */
    static let PlataformsURL = "https://api.lootbox.eu/%@/%@/%@/get-platforms"      /* /{platform}/{region}/{tag}/get-platforms */
    
    public struct ProfileStats {
        static public let screenNameKey = "data.username"
        static public let avatarURLKey = "data.avatar"
        static public let levelKey = "data.level"
        static public let playtime = "data.playtime"
        static public let gamesPlayed = "data.games.played"
        static public let gamesWon =  "data.games.wins"
        static public let gamesLost = "data.games.lost"
        static public let winPercentage = "data.games.win_percentage"
    }
    
    public struct PatchNotes {
        static let TitleKey = "title"
        static let TextKey = "text"
    }
    
    public struct Plataform {
        static public let PC = "pc"
        static public let XB = "xbl"
        static public let PS = "psn"
    }
    
    public struct Region {
        static public let US = "us"
        static public let EU = "eu"
        static public let BR = "br"
        static public let JP = "jp"
    }
}

public struct PlayOverwatchParseConstants {
    static let AccountByNameURL = "https://playoverwatch.com/search/account-by-name/%@"  /* {account name}                 */
    static let ProfileStatsURL = "https://playoverwatch.com/%@%@"                       /* /{language}/{carrer path}      */
}
