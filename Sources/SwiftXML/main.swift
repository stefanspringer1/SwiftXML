//
//  File.swift
//  
//
//  Created by Stefan Springer on 09.04.22.
//

import Foundation

let document = try parseXML(fromText: """
<a>Hello world, the world is nice.</a>
""")

let searchText = "world"

document.traverse { node in
    if let text = node as? XText {
        if text.value.contains(searchText) {
            let spot = XSpot()
            text.insertPrevious { spot }
            var addSearchText = false
            text.value.components(separatedBy: searchText).forEach { part in
                spot.insertPrevious {
                    addSearchText ? XElement("span", ["style": "background:LightGreen"]) {
                        searchText
                    } : nil
                    part
                }
                addSearchText = true
            }
            text.remove()
            spot.remove()
        }
    }
}

document.firstContent?.echo()
