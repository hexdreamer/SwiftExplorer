//
//  HiraganaKeyboard.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/30/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI

struct HiraganaKeyboard: View {        
    static let single_columns:[GridItem] = Array(
        repeating:GridItem(.fixed(25), spacing:0, alignment:.center),
        count:5)
    static let multi_columns:[GridItem] = Array(
        repeating:GridItem(.fixed(42), spacing:0, alignment:.center),
        count:3)
    static let columns:[GridItem] = {
        single_columns
            + [GridItem(.fixed(10), spacing:0, alignment:.center)]
            + multi_columns
    }()
    
    static let kana = [
        "あ", "い", "う", "え", "お", "",   "", "ゔ",     "",
        "か", "き", "く", "け", "こ", "","きゃ", "きゅ", "きょ",
        "さ", "し", "す", "せ", "そ", "","しゃ", "しゅ", "しょ",
        "た", "ち", "つ", "て", "と", "","ちゃ", "ちゅ", "ちょ",
        "な", "に", "ぬ", "ね", "の", "","にゃ", "にゅ", "にょ",
        "は", "ひ", "ふ", "へ", "ほ", "","ひゃ", "ひゅ", "ひょ",
        "ま", "み", "む", "め", "も", "","みゃ", "みゅ", "みょ",
        "や",  "",  "ゆ",  "", "よ", "",    "",    "",    "",
        "ら", "り", "る", "れ", "ろ", "","りゃ", "りゅ", "りょ",
        "わ", "ゐ",   "", "ゑ", "を", "",   "",    "",    "",
        "",    "", "ん",   "", "ー", "",  "っ",  "ゝ",   "ゞ",
        "が", "ぎ", "ぐ", "げ", "ご", "","ぎゃ", "ぎゅ", "ぎょ",
        "ざ", "じ", "ず", "ぜ", "ぞ", "","じゃ", "じゅ", "じょ",
        "だ", "ぢ", "づ", "で", "ど", "","ぢゃ", "ぢゅ", "ぢょ",
        "ば", "び", "ぶ", "べ", "ぼ", "","びゃ", "びゅ", "びょ",
        "ぱ", "ぴ", "ぷ", "ぺ", "ぽ", "","ぴゃ", "ぴゅ", "ぴょ",
    ]
    
    struct Key {
        let id:UInt
        let character:String
    }
    static let items:[Key] = {
        var keys = [Key]()
        for (index,character) in kana.enumerated() {
            keys.append(Key(id:UInt(index), character:character))
        }
        return keys
    }()
    
    var body: some View {
        LazyVGrid(columns:Self.columns, alignment:.center, spacing:6) {
            ForEach(Self.items, id:\.id) { item in
                Text(item.character)
            }
        }
    }
}

struct HiraganaKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        HiraganaKeyboard()
    }
}
