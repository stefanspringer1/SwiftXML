//
//  File.swift
//  
//
//  Created by Stefan Springer on 26.03.22.
//

import Foundation

let element = XElement("top") {
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

element.echo(pretty: true)

print("\n---- 1 ----\n")

element.content.replace { content in
    find {
        content.content
    }
}

element.echo(pretty: true)

print("\n---- 2 ----\n")

/*element.contentReversed.insertPrevious { content in
    find {
        XElement("I" + ((content as? XElement)?.name ?? "?"))
    }
}*/

element.contentReversed.forEach { content in
    content.insertPrevious {
        XElement("I" + ((content as? XElement)?.name ?? "?"))
    }
}

element.echo(pretty: true)
