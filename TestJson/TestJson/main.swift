//
//  main.swift
//  TestJson
//
//  Created by Yu Lo on 3/11/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import Foundation

let filePath = "/Users/leeloo/Projects/iOS_test/tlg_contest/chart_data.json"

func main() {
    print("Hello, main())")

    let url = URL(fileURLWithPath: filePath)
    do {
        let jsonData = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        do {
            let qqq = try decoder.decode(GraphicsContainer.self, from: jsonData)
            print("qqq: \(qqq)")
        } catch {
            print("cannot decode json")
        }
    } catch {
        print("cannot read file at \(url)")
    }
}

main()
