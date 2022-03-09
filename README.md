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

Other than some other libraries for XML, the manipulation of the document as built in memory is “in place”, i.e. no new XML document is built. The goal is to be able to apply many isolated manipulations to an XML document efficiently. But it is always possible to clone a document easily with references to or from the old version.

The following features are important:

- All iteration over elements in the document using the according library functions are lazy by default, i.e. the iteration only looks at one item at a time and does not (!) collect all items in advance.
- While iterating over elements in the document, the document tree can be changed without negatively affecting the iteration.
- Elements or attributes of a certain name can be efficiently found without having to traverse the whole tree. An according iteration proceeds in the order by which the elements or attributes have been added to the document. When iterating in this manner, newly added elements or attributes are then also processed as part of the same iteration.

The following code takes any `<item>` with an integer value of `multiply` larger than 1 and inserts an item with a `multiply` number one less than the next element (the library will be explained in more detail in subsequent sections):

```Swift
let document = try parseXML(fromText: """
<a><item multiply="3"/></a>
""")

document.elements(ofName: "item").forEach { item in
    if let multiply = item["multiply"], let n = Int(multiply), n > 1 {
        item.insertNext {
            XElement("item", ["multiply": n > 2 ? String(n-1) : nil])
        }
        item["multiply"] = nil
    }
}

document.first?.echo()
```

The output is:

```text
<a><item/><item/><item/></a>
```

The elements returned by an iteration can even be removed without stopping the (lazy!) iteration:

```Swift
let document = try parseXML(fromText: """
<a><item id="1" remove="true"/><item id="2"/><item id="3" remove="true"/><item id="4"/></a>
""")

document.traverse { node in
    if let element = node as? XElement, element["remove"] == "true" {
        element.remove()
    }
}

document.first?.echo()
```

The output is:

```text
<a><item id="2"/><item id="4"/></a>
```

Of course, since those iterations are regular sequences, all according Swift library functions like `map` and `filter` can be used. E.g., the `multiply` example could also have been implemented as follows:

```Swift
document.descendants
    .filter { element in element.name == "item" }
    .map { item in (item,Int(item["multiply"] ?? "") ?? 1) }
    .filter { (item,multiply) in multiply > 1 }
    .forEach { (item,multiply) in
        item.insertNext {
            XElement("item", [
                "multiply": multiply > 2 ? String(multiply-1) : nil
            ])
        }
        item["multiply"] = nil
    }
```

The user of the library can also provide sets of rules to be applied (see the code at the beginning and a full example in the section about rules). In such a rule, the user defines what to do with an element or attribute with a certain name. A set of rules can then be applied to a document, i.e. the rules are applied in the order of their definition. This is repeated, guaranteeing that a rule is only applied once to the same object (if not fully removed from the document and added again, cf. the section below on document membership), until no more application takes places. So elements can be added during application of a rule and then later be processed by the same or another rule.

### Other properties

The library uses the [SwiftXMLParser](https://github.com/stefanspringer1/SwiftXMLParser) to parse XML which implements the according protocol from [SwiftXMLInterfaces](https://github.com/stefanspringer1/SwiftXMLInterfaces).

All parts of the XML source are retained in the XML document built in memory, including all comments and parts of an internal subset e.g. all entity or element definitions. (Elements definitions and attribute list definitions are, besides their reported element names, only retained as their original textual representation, they are not parsed into any other representation.) 

In the current implementation, the XML library does not implement any validation, i.e. validation against a DTD or other XML schema, telling us e.g. if an element of a certain name can be contained in an element of another certain name. The user has to use other libraries (e.g. [Libxml2Validation](https://github.com/stefanspringer1/Libxml2Validation)) for such validation before reading or after writing the document. Besides validating the structure of an XML document, validation is also important for knowing if the occurrence of a whitespace text is significant (i.e. should be kept) or not. (E.g., whitespace text between elements representing paragraphs of a text document is usually considered insignificant.) To compensate for that last issue, the user of the library can provide a function that decides if an instance of whitespace text between elements should be kept or not. Also, possible default values of attributes have to be set by the user if desired once the document tree is built.

This library gives full control of how to handle entities. Named entity references can persist inside the document event if they are not defined. Named entity references are being scored as internal or external entity references during parsing, the external entity references being those which are referenced by external entity definitions in the internal subset inside the document declaration of the document. Possible replacements of internal entity references by text can be controlled by the application.

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
    textAllowedInElementWithName: ((String) -> Bool)?
) throws -> XDocument
```

```Swift
func parseXML(
    fromPath: String,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowedInElementWithName: ((String) -> Bool)?
) throws -> XDocument
```

```Swift
func parseXML(
    fromText: String,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowedInElementWithName: ((String) -> Bool)?
) throws -> XDocument
```

```Swift
func parseXML(
    fromData: Data,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowedInElementWithName: ((String) -> Bool)?
) throws -> XDocument
```

The optional `textAllowedInElementWithName` method gets the name of the surrounding element when text is found inside an element and should notify whether text is allowed in the specific context. If not, the text is discarded is it is whitespace. If no text is allowed in the context but the text is not whitespace, an error is thrown. If you need a more specific context than the element name to decide if text is allowed, use an `XEventHandler` to track more specific context information.

All internal entity references in attribute values have to be replaced by text during parsing. In order to achieve this (in case that internal entity references occur at all in attribute values in the source), an `InternalEntityResolver` can be provided. An `InternalEntityResolver` has to implement the following method:

```Swift
func resolve(
    entityWithName: String,
    forAttributeWithName: String?,
    atElementWithName: String?
) -> String?
```

This method is always called when a named entity reference is encountered (either in text or attribute) which is scored as an internal entity. It returns the textual replacement for the entity or `nil`. If the method returns `nil`, then the entity reference is not replaced by a text, but is kept. In the case of a named entity in an attribute value, an error is thrown when no replacement is given. The function arguments `forAttributeWithName` (name of the attribute) and `atElementWithName` (name of the element) have according values if and only if the entity is encountered inside an attribute value.

One a more event handlers can be given a `parseXML` call, which implement `XEventHandler` from [XMLInterfaces](https://github.com/stefanspringer1/SwiftXMLInterfaces). This allows for the user of the library to catch any event during parsing like entering or leaving an element. E.g., the resolving of an internal entity reference could depend on the location inside the document (and not only on the name of the element or attribute), so this information can be collected by such an event handler.

## Displaying XML

When printing a node via `print(...)`, only a top-level represenation like the start tag is printed and never the whoel tree. When you would like to print the whole tree or document, use:

```Swift
func echo(usingProduction: XProduction, terminator: String)
```

(Productions are explained in the next section; as the `usingProduction` argument defaults to `XDefaultProduction`, you do not need to worry about them at the moment. The terminator default to `"\n"`, i.e. newlines are then printed after the output.)

When you want a serialization of a whole tree or document as text (`String`), use the following method:

```Swift
func serialized(usingProduction: XProduction) -> String
```

(The production again defaults to `XDefaultProduction`.)

But do not use `serialized` to print a tree or document, use `echo` instead, because using `echo` is more efficient in this case.

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

The production argument has to implement the `XProduction` protocol and defines how each part of the document is written, e.g. if `>` or `"` are written literally or as predefined XML entities in text sections. The production defaults to an instance of `XDefaultProduction`, which also should be extended if only some details of how the document is written are to be changed, which is a common use case. E.g. you could override `func writeText(text: XText)` and `func writeAttributeValue(name: String, value: String, element: XElement)` to again write some characters as named entity references. Or you just provide an instance of `XDefaultProduction` itself and change its `linebreak` property to define how line breaks should be written (e.g. Unix or Windows style). You might also want to consider `func sortAttributeNames(attributeNames: [String], element: XElement) -> [String]` to sort the attributes for output.

Example: write a linebreak before all elements:

```Swift
class MyProduction: XDefaultProduction {

    override func writeElementStartBeforeAttributes(element: XElement) {
        write(linebreak)
        super.writeElementStartBeforeAttributes(element: element)
    }
    
}

document.write(toFile: "myFile.xml", production: MyProduction())
```

For generality, the following method is provided to apply any `XProduction` to a node and its contained tree:

```Swift
func applyProduction(production: XProduction)
```

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

Traversing a tree depth-first starting from a node (including a document) can be done by the following methods:

```Swift
func traverse(down: (XNode) -> (), up: ((XBranch) -> ())?)
```

```Swift
func traverseAsync(down: (XNode) async -> (), up: ((XBranch) async -> ())?) async
```

```Swift
func traverseAsyncThrowing(down: (XNode) async throws -> (), up: ((XBranch) async throws -> ())?) async throws
```

For a “branch”, i.e. a node that might contain other nodes (like an element, opposed to e.g. text, which does not contain other nodes), when returning from the traversal of its content (also in the case of an empty branch) the closure given the optional `up:` argument is called.

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

As mentioned and the general description, the library allows to efficiently find elements or attributes of a certain name in a document without having to traverse the whole tree. 

Finding the elements of a certain name:

```Swift
func elements(ofName: String) -> XElementsOfSameNameSequence
```

Example:

```Swift
myDocument.elements(ofName: "paragraph").forEach { paragraph in
    if let id = paragraph["id"] {
        print("found paragraph with ID \"\(ID)\"")
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

Starting from some node, you might want to find related nodes, e.g. its children. The following methods are provided. Sequences returned are always lazy sequences, iterating through them gives items of the obvious type. As mentioned in the general description of the library, manipulating the XML tree during such an iteration is allowed.

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

The content of a document or an element:

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

Get the first content of a branch:

```Swift
var first: XNode?
```

Get the last content of a branch:

```Swift
var last: XNode?
```

Example:

```Swift
myElement.descendants.forEach { descendant in
    print("the name of the descendant is \(descendant.name)")
}
```

## Constructing XML

### Constructing an empty element

When constructing an element (without content), the name is given as the first (nameless) argument and the attribute values are given as (nameless) a dictionary.

Example: constructing an empty “paragraph” element with attributes `id="1"` and `style="note"`:

```Swift
let myElement = XElement("paragraph", ["id": "1", "style": "note"])
```

### Reading and setting attributes

The attributes of an element can be read and set via the “index notation”. If an attribute is not set, `nil` is returned; reversely, setting an attribute to `nil` results in removing it.

Example:

```Swift
// setting the "id" attribute to "1":
myElement["id"] = "1"

// reading an attribute:
if let id = myElement["id"] {
    print("the ID is \(id)")
}
```

### Attachments

Branches can have “attachments”. Those are objects that can be attached via a textual key to those branches but that not considered as belonging to the actual XML tree.

The attachments can be reached by the property `attached`, and accessing and setting them is analogous to attributes:

Example: attaching a “note” by attaching it with key `"note"` (it uses an element constructed with content as explained in the next section):

```Swift
myElement.attached["note"] = "this is a note"

// replacing the attached note by a more complex object:
myElement.attached["note"] = XElement("note") {
    "this is a note as element instead"
}

// getting the attached note:
if let note = myElement.attached["note"] as? XElement {
    print("note: \((note.first as? XText)?.value ?? "")")
}

// removing the attached note:
myElement.attached["note"] = nil
```

### Defining content

When constructing an element, its contents are given in parentheses `{...}` (those parentheses are the `builder` argument of the initializer).

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

### Document membership in constructed elements

Elements that are part of a document (`XDocument`) are registered in the document. The same is true for its attributes. The reason is that this allows fast access to elements and attributes of a certain name via `elements(ofName:)` and `attributes(ofName:)` and the exact functioning of rules (see the section below on rules).

In the moment of constructing a new element with its content defined in `{...}` brackets during construction, the element is not part any document. The nodes inserted to it leave the document tree, but they are not (!) unregistered from the document. I.e. the iterations `elements(ofName:)` and `attributes(ofName:)` will still find them, and according rules will apply to them. The reason for this behaviour is the common case of the new element getting inserted into the same document. If the content of the new element would first get unregistered from the document and then get reinserted into the same document again, they would then count as new elements, and the mentioned iterations might iterate over them again.

If you would like to get the content a newly built element to get unregistered from the document, use its method `adjustDocument()`. This method diffuses the current document of the element to its content. For a newly built element this document is `nil`, which unregisters a node from its document. You might also set the attribute `adjustDocument` to `true` in the initializer of the element to automatically call `adjustDocument()` when the building of the new element is accomplished. This call or setting to adjust of the document is only necessary at the top-level element, it is dispersed through the whole tree.

Example: a newly constructed element gets added to a document:

```Swift
let document = try parseXML(fromText: """
<a><b id="1"/><b id="2"/></a>
""")

document.elements(ofName: "b").forEach { element in
    print("applying the rule to \(element)"
    if element["id"] == "2" {
        element.insertNext {
            XElement("c") {
                element.previous
            }
        }
    }
}

print("\n-----------------\n")

document.first?.echo()
```

Output:

```text
applying the rule to <b id="1">
applying the rule to <b id="2">

-----------------

<a><b id="2"/><c><b id="1"/></c></a>
```

As you can see from the `print` commands in the last example, the element `<b id="1">` does not lose its “connection” to the document (although it seems to get added again to it), so it is only iterated over once by the iteration.

### Subsequent or empty text

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
func replace(forward: Bool, builder: () -> XNodeLike)
```

Clear the contents of the node:

```Swift
func clear(forward: Bool)
```

Set the contents of the branch:

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

As mentioned in the general description, a set of rules `XRule` in the form of a transformation instance of type `XTransformation` can be used as follows.

In a rule, the user defines what to do with an element or attribute with a certain name. The set of rules can then be applied to a document, i.e. the rules are applied in the order of their definition. This is repeated, guaranteeing that a rule is only applied once to the same object (if not removed from the document and added again), until no application takes place. So elements can be added during application of a rule and then later be processed by the same or another rule.

Example:

```Swift
let document = try parseXML(fromText: """
<a><formula id="1"/></a>
""")

var count = 1

let transformation = XTransformation {
    
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
    
    XRule(forAttribute: "id") { (value,element) in
        print("\n----- Rule for attribute \"id\" -----\n")
        print("  \(element) --> ", terminator: "")
        element["id"] = "done-" + value
        print(element)
    }
    
}

transformation.execute(inDocument: document)

print("\n----------------------------------------\n")

document.first?.echo()
```

```text

----- Rule for element "formula" -----

  <formula id="1">
  add image

----- Rule for element "image" -----

  <image id="2">
  add formula

----- Rule for attribute "id" -----

  <formula id="1"> --> <formula id="done-1">

----- Rule for attribute "id" -----

  <image id="2"> --> <image id="done-2">

----- Rule for attribute "id" -----

  <formula id="3"> --> <formula id="done-3">

----- Rule for element "formula" -----

  <formula id="done-3">

----------------------------------------

<a><formula id="done-3"/><image id="done-2"/><formula id="done-1"/></a>

```
