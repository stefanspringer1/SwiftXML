//
//  File.swift
//  
//
//  Created by Stefan Springer on 21.08.21.
//

import Foundation

public struct XMLTreeIterator: IteratorProtocol {
    public typealias Element = XMLNode
    
    var started = false
    var startNode: XMLNode
    var currentNode: XMLNode? = nil
    
    let down: ((XMLNode) -> ())?
    let up: ((XMLBranch) -> ())?
    
    public init(
        startNode: XMLNode,
        down: ((XMLNode) -> ())? = nil,
        up: ((XMLBranch) -> ())? = nil
    ) {
        self.startNode = startNode
        self.down = down
        self.up = up
    }

    public mutating func next() -> Element? {
        if started {
            var downDirection = true
            while true {
                if downDirection, let branch = currentNode as? XMLBranch, let firstChild = branch.firstChild {
                    currentNode = firstChild
                    down?(firstChild)
                    return currentNode
                }
                else if let next = currentNode?.next {
                    currentNode = next
                    downDirection = true
                    down?(next)
                    return next
                }
                else {
                    downDirection = false
                    currentNode = currentNode?.parent
                    if currentNode === startNode {
                        currentNode = nil
                    }
                    if let theCurrentNode = currentNode as? XMLBranch {
                        up?(theCurrentNode)
                    }
                    else {
                        return nil
                    }
                }
            }
        }
        else {
            currentNode = startNode
            started = true
            down?(startNode)
            return currentNode
        }
    }
}

extension XMLNode: Sequence {
    public func makeIterator() -> XMLTreeIterator {
        return XMLTreeIterator(startNode: self)
    }
}
