//
//  KatakanaKeyboard.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/30/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI

struct KatakanaKeyboard: View {        
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
        "ア", "イ", "ウ", "エ", "オ", "",    "",   "ヴ",    "",
        "カ", "キ", "ク", "ケ", "コ", "", "キャ", "キュ", "キョ",
        "サ", "シ", "ス", "セ", "ソ", "", "シャ", "シュ", "ショ",
        "タ", "チ", "ツ", "テ", "ト", "", "チャ", "チュ", "チョ",
        "ナ", "ニ", "ヌ", "ネ", "ノ", "", "ニャ", "ニュ", "ニョ",
        "ハ", "ヒ", "フ", "ヘ", "ホ", "", "ヒャ", "ヒュ", "ヒョ",
        "マ", "ミ", "ム", "メ", "モ", "", "ミャ", "ミュ", "ミョ",
        "ヤ",  "",  "ユ",  "", "ヨ", "",    "",     "",    "",
        "ラ", "リ", "ル", "レ", "ロ", "", "リャ", "リュ", "リョ",
        "ワ", "ヰ",   "", "ヱ", "ヲ", "",   "",     "",    "",
        "",    "", "ン",   "", "ー", "",  "ッ",   "ヽ",   "ヾ",
        "ガ", "ギ", "グ", "ゲ", "ゴ", "", "ギャ", "ギュ", "ギョ",
        "ザ", "ジ", "ズ", "ゼ", "ゾ", "", "ジャ", "ジュ", "ジョ",
        "ダ", "ヂ", "ヅ", "デ", "ド", "", "ヂャ", "ヂュ", "ヂョ",
        "バ", "ビ", "ブ", "ベ", "ボ", "", "ビャ", "ビュ", "ビョ",
        "パ", "ピ", "プ", "ペ", "ポ", "", "ピャ", "ピュ", "ピョ",
        "ヷ", "ヸ", "ヴ", "ヹ", "ヺ", "", "", "", ""
        //"", "", "", "", "", "", "", "", ""
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

struct KatakanaKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        KatakanaKeyboard()
    }
}
