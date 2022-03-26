//
//  File.swift
//  
//
//  Created by Stefan Springer on 26.03.22.
//

import Foundation

let document = XDocument {
    XElement("a1") {
        XElement("a2")
    }
    XElement("b1") {
        XElement("b2")
    }
    XElement("c1") {
        XElement("c2")
    }
}


document.echo()

document.content.replace { content in
    find {
        content.content
    }
}

print("\n---------\n")

document.echo()

document.contentReversed.insertPrevious { content in
    find {
        XElement("I" + ((content as? XElement)?.name ?? "?"))
    }
}

print("\n---------\n")

document.echo()
