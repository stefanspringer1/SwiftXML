//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

extension XNode {
    
    public var ancestors: XAncestorsSequence {
        get {
            return XAncestorsSequence(node: self)
        }
    }
    
    public var content: XContentSequence {
        get {
            return XContentSequence(node: self)
        }
    }
    
    public var children: XChildrenSequence {
        get {
            return XChildrenSequence(node: self)
        }
    }
    
    public var next: XNextSequence {
        get {
            return XNextSequence(node: self)
        }
    }
    
    public var previous: XPreviousSequence {
        get {
            return XPreviousSequence(node: self)
        }
    }
    
    public var nextElements: XNextElementsSequence {
        get {
            return XNextElementsSequence(node: self)
        }
    }
    
    public var previousElements: XPreviousElementsSequence {
        get {
            return XPreviousElementsSequence(node: self)
        }
    }
    
    public var allContent: XAllContentSequence {
        get {
            return XAllContentSequence(node: self)
        }
    }
    public var allContentIncludingSelf: XAllContentIncludingSelfSequence {
        get {
            return XAllContentIncludingSelfSequence(node: self)
        }
    }
    
    public var descendants: XDescendantsSequence {
        get {
            return XDescendantsSequence(node: self)
        }
    }
    
    public var descendantsIncludingSelf: XDescendantsIncludingSelfSequence {
        get {
            return XDescendantsIncludingSelfSequence(node: self)
        }
    }

}
