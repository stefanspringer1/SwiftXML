# SwiftXML

A library written in Swift to process XML.

This library is published under the Apache License 2.0.

```Swift
let transformation = XTransformation {
    
    XRule(forElement: "table") { table in
        table.insertNext {
            XElement("caption") {
                "this is the table caption"
            }
        }
    }

    XRule(forAttribute: "label") { (value,element) in
        element["label"] = value + ")"
    }
}
```

---
**NOTE**

This library is not in a “final” state yet. Also, when such a final state is reached, the library might be further developed using a new repository URL. Further notice will be added here. See [there](https://stefanspringer.com) for contact information.

---

## Properties of the library

The library reads XML from a source into an XML document instance, and provides methods to transform (or manipulate) the document, and others to write the document to a file. (The reading of a JSON source into an XML document structure is also implemented, but currently only in experimental state.)

### Manipulation of an XML document

Other than some other libraries for XML, the manipulation of the document as built in memory is “in place", i.e. no new XML document is built. The goal is to be able to apply many isolated manipulations to an XML document efficiently. But it is always possible to clone a document easily with references to or from the old version.

All iteration over elements in the document using the according library functions are lazy by default. While iterating over elements in the document using the according library functions, the document tree can be changed without negatively affecting the iteration.

Part of the effiency is the possibility to efficiently find elements or attributes of a certain name without having to traverse the whole tree. An according iteration proceeds in the order by which the elements or attributes have been added to the document. When iterating in this manner, newly added elements or attributes are then also processed as part of the same iteration.

The user of the library can also provide a sets of rules to be applied. In such a rule, the user defines what to do with an element or attribute with a certain name. The set of rules can then be applied to a document, i.e. the rules are applied in the order of their definition. This is repeated, garanteeing that a rule is only applied once to the same object (if not detached from the document and added again), until no application takes places. So elements can be added during apllication of a rule and then later be processed by the same or another rule.

### Other properties

The library uses the [SwiftXMLParser](https://github.com/stefanspringer1/SwiftXMLParser) to parse XML which implements the according protocol from [XMLInterfaces](https://github.com/stefanspringer1/SwiftXMLInterfaces).

All parts of the XML source are retained in the XML document built in memory, including all comments and parts of an internal subset e.g. all entity or element definitions. (Elements definitions and attribute list definitions are, besides their reported element names, only retained as their original textual represenation, they are not parsed into any other representation.) 

In the current implementation, the XML library does not implement any validation, i.e. validation against a DTD or other XML schema. The user has to use other libaries (e.g. [Libxml2Validation](https://github.com/stefanspringer1/Libxml2Validation)) for such validation. To compensate for that, the user of the library can provide a function that decides if encountered whitespace between elements should be kept or not. Also, possible default values of attributes have to be set by the user if desired once the document tree is built.

This library gives full control of how to handle entities. Named entity references can persist inside the document event if they are not defined. Named entity references are being scored as internal or external entity rerefences during parsing, the external entity references being those which are referenced by external entity definitions in the internal subset inside the document declaration of the document. Possible replacements of internal entity references by text can be controlled by the application.

No automated inclusion of external parsed entities takes place. The user of the library has to implement such features herself if needed.

In the current state, the library does not recognize XML namespaces; elements or attributes with namespace prefixes are give the full name “prefix:unprefixed".

The encoding of the source should always be UTF-8 (ASCII is considered as a subset of it). The parser checks for correct UTF-8 encoding and also checks (according to the data available to the currently used Swift implementation) if a found codepoint is a valid Unicode codepoint.

For any error during parsing an error is thrown and no document is then provided.

The library is not to be used in concurrent contexts. 

## Reading XML

The following functions take a source and return an XML document instance (`XDocument`). The source can either be provided as a URL, a path to a file, a text, or binary data.

```Swift
func parseXML(
    fromURL: URL,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowed: (() -> Bool)?
) throws -> XDocument
```

```Swift
func parseXML(
    fromPath: String,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowed: (() -> Bool)?
) throws -> XDocument
```

```Swift
func parseXML(
    fromText: String,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowed: (() -> Bool)?
) throws -> XDocument
```

```Swift
func parseXML(
    fromData: Data,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowed: (() -> Bool)?
) throws -> XDocument
```

All internal entity references in attribute values have to be replaced by text during parsing. In order to achieve this (in case that internal entity references occur at all in attribute values in the source), an `InternalEntityResolver` can be provided. An `InternalEntityResolver` has to implement the following method:

```Swift
func resolve(
    entityWithName: String,
    forAttributeWithName: String?,
    atElementWithName: String?
) -> String?
```

This method is always called when an named entity reference is encountered (either in text or attribute) which is scored as an internal entity. It returns the textual replacement for the entity or `nil`. If the method returns `nil`, then the entity reference is not replaced by a text, but is kept. In the case of a named entity in an attribute value, an error is thrown when no replacement is given. The function arguments `forAttributeWithName` (name of the attribute) and `atElementWithName` (name of the element) have according values if and only if the entity is encountered inside an attribute value.

One a more event handlers can be given a `parseXML` call, which implement `XEventHandler` from [XMLInterfaces](https://github.com/stefanspringer1/SwiftXMLInterfaces). This allows for the user of the library to catch any event during parsing like entering or leaving an element. E.g., the resolving of an internal entity reference could depend on the location inside the document (and not only on the name of the element or attribute), so this information can be collected by such an event handler.

## Writing XML

Any XML node (including an XML document) can be written, including the tree of nodes that is started by it, via the following methods.

```Swift
func write(toURL: URL, production: XProduction)
```

```Swift
func write(toFile: String, production: XProduction)
```

```Swift
func write(toFileHandle: FileHandle, production: XProduction)
```

The production argument has to implement the `XProduction` protocol and defines how each part of the document is written. The production defaults to an instance of `XDefaultProduction`, which also should be extended if only some details of how the document is written are to be changed, which is a common use case. E.g. you could override `func writeText(text: XText)` and `func writeAttributeValue(name: String, value: String, element: XElement)` to again write some characters as named entity references. Or you just provide an instance of `XDefaultProduction` itself and change its `linebreak` property to define how line breaks should be written (e.g. Unix or Windows style). You might also want to consider `func sortAttributeNames(attributeNames: [String], element: XElement) -> [String]` to sort the attributes for output.

For generality, the following method is provided to apply any `XProduction` to a node (and its containing tree):

```Swift
func applyProduction(production: XProduction)
```

To write to standard out (just print), the `echo` method can be used, with the production again defaulting to an instance of `XDefaultProduction`, and the terminator defaulting to a line break:

```Swift
func echo(production: XProduction, terminator: String)
```

In contrast to the above methods, when using a node as the argument to the `print` method, only some top-level printout results, e.g. only the start tag is printed.

## Cloning

Any node (including an XML document) can be cloned, including the tree of nodes that is started by it, using the following method:

```Swift
func clone(forwardref: Bool) -> XNode
```

Any node possesses the property `r` pointing to the node related to itself by (the last) cloning. By default, `r` points from the node in the clone to the according node in the original tree. By setting the argument `forwardref` to `true` (it defaults to `false`), this direction is reversed. By being able to set `forwardref` when cloning an XML document one can adjust to the situations of using the clone or the original tree for further manipulation. You might use the `clone` method several times, the property `rr` than goes along the whole chains of `r` values until the last one is reached. For a document, the following method formalises this:

```Swift
func saveVersion()
```

Use `saveVersion()` to save a certain state and then just continue manipulating the same document; the chain of `r` properties then just follows all versions.

Sometimes, only a “shallow” clone is needed, i.e. the node itself without the tree of nodes that is started by it. In this case, just use:

```Swift
func shallowClone(forwardref: Bool) -> XNode
```

## Traversals

Traversing a tree depth-first starting from a node (including a document) can be done by the follwoing methods:

```Swift
func traverse(down: (XNode) -> (), up: ((XBranch) -> ())?)
```

```Swift
func traverseAsync(down: (XNode) async -> (), up: ((XBranch) async -> ())?) async
```

```Swift
func traverseAsyncThrowing(down: (XNode) async throws -> (), up: ((XBranch) async throws -> ())?) async throws
```

For a “branch”, i.e. a node that might contain other nodes (like an element, opposed to e.g. text, which does not contain other nodes), when returning from from the travesal of its content (also in the case of an empty branch) the closure given an the optional `up:` argument is called.

Example:

```Swift
document.traverse { node in
    if let element = node as? XElement {
        print("entering element \(element.name)")
    }
}
up: { branch in
    if let element = branch as? XElement {
        print("leaving element \(element.name)")
    }
}
```

## Direct access to elements and attributes

As mentioned and the general description, the library allows to efficiently find elements or attributes of a certain name without having to traverse the whole tree. 

Finding the elements of a certain name:

```Swift
func elements(ofName: String) -> XElementsOfSameNameSequence
```

Example:

```Swift
myDocument.elements(ofName: "paragraph").forEach { paragraph in
    if let id = paragraph["id"] {
        print("found paragraph with ID \"\(ID)\")
    }
}
```

Finding the attributes of a certain name:

```Swift
func attributes(ofName: String) -> XAttributesOfSameNameSequence
```

The items of the returned sequence are of type `XAttributeSpot`, which is a pair of the value of the attribute at when it is found, and the `element`.

Example:

```Swift
myDocument.attributes(ofName: "id").forEach { (value,element) in
    if element.name == "paragraph" {
        print("found paragraph with ID \"\(value)\"")
    }
}
```

## Finding related nodes

Starting from some node, you might want to find related nodes, e.g. its children. The following methods are provided. Sequences returned are always lazy sequences, iterating through them gives items of the obvious type. As mentioned in teh general description of the library, manipulating the XML tree during such an iteration is allowed.

Finding the document the node is contained in:

```Swift
var document: XDocument?
```

Finding the parent element:

```Swift
var parent: XElement?
```

All its ancestor elements:

```Swift
var ancestors: XAncestorsSequence
```

The content of an document or an element:

```Swift
var content: XContentSequence
```

The content that is an element, i.e. all the children:

```Swift
var children: XChildrenSequence
```

All content in the tree of nodes that is started by the node itself, without the node itself:

```Swift
var allContent: XAllContentSequence
```

The descendants, i.e. all content in the tree of nodes that is started by the node itself, without the node itself, that is an element:

```Swift
var descendants: XDescendantsSequence
```

If a node is an element, the element itself and the descendants, starting with the element itself:

```Swift
var descendantsIncludingSelf: XDescendantsIncludingSelfSequence
```

All nodes next to the node (i.e. the next siblings):

```Swift
var next: XNextSequence
```

All next siblings that are elements:

```Swift
var nextElements: XNextElementsSequence
```

All nodes previous to the node (i.e. the previous siblings), in the order from the node:

```Swift
var previous: XPreviousSequence
```

All previous siblings that are elements:

```Swift
var previousElements: XPreviousElementsSequence
```

Example:

```Swift
myElement.descendants.forEach { descendant in
    print("the name of the descendant is \(descendant.name)")
}
```

## Constructing XML

### Constructing an empty element

When construction an element (without content), the name is given as the first (nameless) argument and the attrbute values are given as (nameless) a dictionary.

Example: constructing an empty “paragraph” element with attrbutes `id="1"` and `style="note"`:

```Swift
let myElement = XElement("paragraph", ["id": "1", "style": "note"])
```

### Reading and setting attributes

The attributes of an element can be read and set via the “index notation”. If an attribute is not set, `nil` is returned; reversely, settign an attribute to `nil` results in removing it.

Example:

```Swift
// setting the "id" attribute to "1":
myElement["id"] = "1"

// reading an attribute:
if let id = myElement["id"] {
    print("the ID is \(id)")
}
```

### Defining content

When constructing an element, its content are given in parantheses “{...}”:

```Swift
let myElement = XElement("div") {
    XElement("hr")
    XElement("paragraph") {
        "Hello World"
    }
    XElement("hr")
}
```

(The text `"Hello World"` could also be given as `XText("Hello World")`. The text will be converted in such an XML node automatically.)

The content might be given as an array or an appropriate sequence:

```Swift
let myElement = XElement("div") {
    XElement("hr")
    myOtherElement.content
    XElement("hr")
}
```

Sometimes the compiler needs a hint for the type (use `XNodeLike`):

```Swift
let myElement = XElement("div") {
    XElement("hr")
    ["Hallo ", "Welt"] as [XNodeLike]
    XElement("hr")
}
```

### Document membership during construction

If a node is already part of a document when it gets added to an element during construction of this element, it first gets removed from that document during construction, and subsequently count as a new element if the element gets added to the same document, so an active iteration might iterate over it twice.

### Subsequent or empyt text

Subsequent text nodes (`XText`) are always automatically combined, and text nodes with empty text are automatically removed.

## Tree manipulations

Besides changing the node properties, an XML tree can be changed by the following methods.

Add nodes to the end of the content of a branch:

```Swift
func add(skip: Bool, builder: () -> XNodeLike)
```

Add nodes to the start of the content of a branch (their order is kept):

```Swift
func addFirst(skip: Bool, builder: () -> XNodeLike)
```

Add nodes as the nodes next to the node:

```Swift
func insertNext(builder: () -> XNodeLike)
```

Add nodes as the nodes previous to the node (their order is kept):

```Swift
func insertPrevious(builder: () -> XNodeLike)
```

By using the next two methods, a node gets removed. If the argument `forward` is set to `true` (default is `false`), such an operation prefetches the next node in iterators that have the node as active node, else, the iterators all told to go to the previous node.

Remove the node from the tree structure and the document:

```Swift
func remove(forward: Bool)
```

Replace the node by other nodes; if `forward`, then detaching prefetches the next node in iterators:

```Swift
func set(forward: Bool, builder: () -> XNodeLike)
```

Example:

```Swift
myDocument.elements(ofName: "table").forEach { table in
    table.insertNext {
        XElement("legend") {
            "this is the table legend"
        }
        XElement("caption") {
            "this is the table caption"
        }
    }
}
```

## Rules

As mentioned in the general description, a sets of rules `XRule` in the form of a transformation instance of type `XTransformation` can be used as follows.

In a rule, the user defines what to do with an element or attribute with a certain name. The set of rules can then be applied to a document, i.e. the rules are applied in the order of their definition. This is repeated, garanteeing that a rule is only applied once to the same object (if not removed from the document and added again), until no application takes places. So elements can be added during apllication of a rule and then later be processed by the same or another rule.

Example:

```Swift
let document = try parseXML(fromText:
    #"""
    <a><formula id="1"/></a>
    """#
)

var count = 1

let transformation = XTransformation {
    
    XRule(forAttribute: "id") { (value,element) in
        print("\n----- Rule for attribute \"id\" -----\n")
        print("  \(element) --> ", terminator: "")
        element["id"] = "done-" + value
        print(element)
    }
    
    XRule(forElement: "formula") { element in
        print("\n----- Rule for element \"formula\" -----\n")
        print("  \(element)")
        if count == 1 {
            count += 1
            print("  add image")
            element.insertPrevious {
                XElement("image", ["id": "\(count)"])
            }
            
        }
    }
    
    XRule(forElement: "image") { element in
        print("\n----- Rule for element \"image\" -----\n")
        print("  \(element)")
        if count == 2 {
            count += 1
            print("  add formula")
            element.insertPrevious {
                XElement("formula", ["id": "\(count)"])
            }
        }
    }
    
}

transformation.execute(inDocument: document)

print("\n----------------------------------------\n")

document.write(toFileHandle: FileHandle.standardOutput); print(); print()
```

Output:

```text

----- Rule for attribute "id" -----

  <formula id="1"> --> <formula id="done-1">

----- Rule for element "formula" -----

  <formula id="done-1">
  add image

----- Rule for element "image" -----

  <image id="2">
  add formula

----- Rule for attribute "id" -----

  <image id="2"> --> <image id="done-2">

----- Rule for attribute "id" -----

  <formula id="3"> --> <formula id="done-3">

----- Rule for element "formula" -----

  <formula id="done-3">

----------------------------------------

<?xml version="1.0"?>
<!DOCTYPE a>
<a><formula id="done-3"/><image id="done-2"/><formula id="done-1"/></a>

```
