//
//  GureumTests.swift
//  OSX
//
//  Created by Jim Jeon on 16/09/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import XCTest
import Gureum
import Hangul


class GureumTests: XCTestCase {
    let moderate: VirtualApp = ModerateApp()
    let terminal: VirtualApp = TerminalApp()
    let greedy: VirtualApp = GreedyApp()
    var apps: [VirtualApp] = []
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.apps = [self.moderate]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearchEmoticonTable() {
        let bundle: Bundle = Bundle.main
        let path: String? = bundle.path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")
        let table: HGHanjaTable = HGHanjaTable.init(contentOfFile: path ?? "")
        let list: HGHanjaList = table.hanjas(byPrefixSearching: "hushed") ?? HGHanjaList() // 현재 5글자 이상만 가능
        XCTAssert(list.count > 0)
    }
    
    func testCommandkeyAndControlkey() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("a", key: 0, modifiers: NSEvent.ModifierFlags.command)
            app.inputText("a", key: 0, modifiers: NSEvent.ModifierFlags.control)
            XCTAssertEqual("", app.client.string, "");
            XCTAssertEqual("", app.client.markedString(), "")
        }
    }

    func testHanjaSyllable() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: 46, modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: 3, modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: 1, modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("\n", key: 36, modifiers: NSEvent.ModifierFlags.option)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString.init(string: "韓: 나라 이름 한"))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString.init(string: "韓: 나라 이름 한"))
            XCTAssertEqual("韓", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaWord() {
        for app in self.apps {
            if app == self.terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            // hanja search mode
            app.inputText("\n", key: UInt(kVK_Return), modifiers: NSEvent.ModifierFlags.option)
            app.inputText("i", key: UInt(kVK_ANSI_I), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: UInt(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: UInt(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: UInt(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("n", key: UInt(kVK_ANSI_N), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: UInt(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString.init(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString.init(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")

            // 연달아 다음 한자 입력에 들어간다
            app.inputText(" ", key: UInt(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("i", key: UInt(kVK_ANSI_I), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 ㅁ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("ㅁ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("b", key: UInt(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: UInt(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: UInt(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("n", key: UInt(kVK_ANSI_N), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: UInt(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString.init(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水 물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString.init(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水 水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
        }
    }
}
