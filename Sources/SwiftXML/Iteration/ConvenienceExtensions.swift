//===--- ConvenienceExtensions.swift -------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com) and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

public protocol Applying {}

public extension Applying {
  
  /// Apply an operation on the instance and return the changed instance.
  func applying(_ operation: (inout Self) throws -> Void) rethrows -> Self {
    var copy = self
    try operation(&copy)
    return copy
  }
    
}

public protocol Pulling {}

public extension Pulling {
  
  /// Apply an operation on the instance and return the changed instance.
  func pulling<T>(_ operation: (inout Self) throws -> T) rethrows -> T {
    var copy = self
    return try operation(&copy)
  }
    
}

public protocol Fullfilling {}

public extension Fullfilling {
    
  /// Test if a certain condition is true for the instance, return the instance if the condition is `true`, else return `nil`.
  func fullfilling(_ condition: (Self) throws -> Bool) rethrows -> Self? {
      return try condition(self) ? self : nil
  }
  
}

public protocol Fullfill {}

public extension Fullfill {

  /// Test if a certain condition is true for the instance, return the result of this test.
  func fullfills(_ condition: (Self) throws -> Bool) rethrows -> Bool {
      return try condition(self)
  }
}

extension XContent: Applying, Fullfilling, Fullfill, Pulling {}
