# SwiftXML

A library written in Swift to process XML.

This library is published under the Apache License 2.0.

```Swift
let transformation = XTransformation {
    
    XRule(forElements: ["table"]) { table in
        table.insertNext {
            XElement("caption") {
                "Table: "
                table.children{ $0.name.contains("title") }.content
            }
        }
    }
    
    XRule(forElements: ["tbody", "tfoot"]) { tablePart in
        tablePart
            .children("tr")
            .children("th")
            .forEach { cell in
                cell.name = "td"
            }
    }
    
    XRule(forAttributes: ["label"]) { (value,element) in
        element["label"] = value + ")"
    }
    
}
```

---
**NOTE**

**This library is not in a “final” state yet** despite its high version number, i.e. there might still be serious bugs, or maybe breaking changes will happen without the major version getting augmented, and there will be more comments in the code. Also, when such a final state is reached, the library might be further developed using a new repository URL (and the version number set back to a lower one). Further notice will be added here. See [there](https://stefanspringer.com) for contact information.

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

document.firstContent?.echo()
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

document.traverse { content in
    if let element = content as? XElement, element["remove"] == "true" {
        element.remove()
    }
}

document.firstContent?.echo()
```

The output is:

```text
<a><item id="2"/><item id="4"/></a>
```

Of course, since those iterations are regular sequences, all according Swift library functions like `map` and `filter` can be used. But in many cases, it might be better to use conditions on the content iterators (see the section on finding related content with filters) or chaining of content iterators (see the section on chained iterators).

The user of the library can also provide sets of rules to be applied (see the code at the beginning and a full example in the section about rules). In such a rule, the user defines what to do with an element or attribute with a certain name. A set of rules can then be applied to a document, i.e. the rules are applied in the order of their definition. This is repeated, guaranteeing that a rule is only applied once to the same object (if not fully removed from the document and added again, see the section below on document membership), until no more application takes places. So elements can be added during application of a rule and then later be processed by the same or another rule.

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

---
**NOTE**

The description of the library that follows might not include all types and methods. Please see the documentation produced by DocC or use autocompletion in an according integrated development environment (IDE).

---

## Reading XML

The following functions take a source and return an XML document instance (`XDocument`). The source can either be provided as a URL, a path to a file, a text, or binary data.

```Swift
func parseXML(
    fromURL: URL,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowedInElementWithName: ((String) -> Bool)?,
    keepComments: Bool,
    keepCDATASections: Bool
) throws -> XDocument
```

```Swift
func parseXML(
    fromPath: String,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowedInElementWithName: ((String) -> Bool)?,
    keepComments: Bool,
    keepCDATASections: Bool
) throws -> XDocument
```

```Swift
func parseXML(
    fromText: String,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowedInElementWithName: ((String) -> Bool)?,
    keepComments: Bool,
    keepCDATASections: Bool
) throws -> XDocument
```

```Swift
func parseXML(
    fromData: Data,
    sourceInfo: String?,
    internalEntityResolver: InternalEntityResolver?,
    eventHandlers: [XEventHandler]?,
    textAllowedInElementWithName: ((String) -> Bool)?,
    keepComments: Bool,
    keepCDATASections: Bool
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

`keepComments` (default: `false`) decides if a comment should be preserved (as `XComment`), else they will be discarded without notice. `keepCDATASections` (default: `false`) decides if a CDATA section should be preserved (as `XCDATASection`), else all CDATA sections get resolved as text.

## Content of a document

An XML document (`XDocument`) can contain the following content:

- `XDocument`: a whole document
- `XElement`: an element
- `XText`: a text
- `XInternalEntity`: an internal entity reference
- `XExternalEntity`: an external entity reference
- `XCDATASection`: a CDATA section
- `XProcessingInstruction`: a processing instruction
- `XComment`: a comment
- `XSpot`: see the section below on `XSpot` and handling of text

Those content are of type type `XContent`, whereas the more general type `XNode` might be content or an `XDocument`.

The following is read from the internal subset:

- `XInternalEntityDeclaration`: an internal entity declaration
- `XExternalEntityDeclaration`: an external entity declaration
- `XUnparsedEntityDeclaration`: a declaration of an unparsed external entity
- `XNotationDeclaration`: a notation declaration
- `XParameterEntityDeclaration`: a parameter entity declaration
- `XElementDeclaration`: an element declaration
- `XAttributeListDeclaration`: an attribute list declaration

They can be accessed via property `declarationsInInternalSubset`.

A document gets the following additional properties from the XML source (some values might be `nil`:

- `encoding`: the encoding from the XML declaration
- `publicID`: the public identifier from the document type declaration
- `sourcePath`: the source to the XML document
- `standalone`: the standalone value from the XML declaration
- `systemID`: the system identifier from the document type declaration
- `xmlVersion`: the XML version from the XML declaration

When not set explicitely in the XML source, some of those values are set to a sensible value.

## Displaying XML

When printing a content via `print(...)`, only a top-level represenation like the start tag is printed and never the whole tree. When you would like to print the whole tree or document, use:

```Swift
func echo(pretty: Bool, terminator: String)
```

`pretty` defaults to `false`; if it is set to `true`, linebreaks and spaces are added for pretty print. The terminator defaults to `"\n"`, i.e. a linebreak is then printed after the output.

With more control:

```Swift
func echo(usingProduction: XProduction, terminator: String)
```

Productions are explained in the next section. 

When you want a serialization of a whole tree or document as text (`String`), use the following method:

```Swift
func serialized(pretty: Bool) -> String
```

`pretty` again defaults to `false` and has the same effect.

With more control:

```Swift
func serialized(usingProduction: XProduction) -> String
```

Do not use `serialized` to print a tree or document, use `echo` instead, because using `echo` is more efficient in this case.

## Writing XML

Any XML node (including an XML document) can be written, including the tree of nodes that is started by it, via the following methods.

```Swift
func write(toURL: URL, production: XProduction) throws
```

```Swift
func write(toFile: String, production: XProduction) throws
```

```Swift
func write(toFileHandle: FileHandle, production: XProduction) throws
```

The production argument has to implement the `XProduction` protocol and defines how each part of the document is written, e.g. if `>` or `"` are written literally or as predefined XML entities in text sections. The production defaults to an instance of `XDefaultProduction`, which also should be extended if only some details of how the document is written are to be changed, which is a common use case. The productions `XPrettyPrintProduction` and `XHTMLProduction` already extend `XDefaultProduction`, which might be used to pretty-print XML or output HTML. But you also extend one of those classes youself, e.g. you could override `func writeText(text: XText)` and `func writeAttributeValue(name: String, value: String, element: XElement)` to again write some characters as named entity references. Or you just provide an instance of `XDefaultProduction` itself and change its `linebreak` property to define how line breaks should be written (e.g. Unix or Windows style). You might also want to consider `func sortAttributeNames(attributeNames: [String], element: XElement) -> [String]` to sort the attributes for output.

Example: write a linebreak before all elements:

```Swift
class MyProduction: XDefaultProduction {

    override func writeElementStartBeforeAttributes(element: XElement) throws {
        try write(linebreak)
        try super.writeElementStartBeforeAttributes(element: element)
    }
    
}

try document.write(toFile: "myFile.xml", production: MyProduction())
```

For generality, the following method is provided to apply any `XProduction` to a node and its contained tree:

```Swift
func applyProduction(production: XProduction) throws
```

## Cloning

Any node (including an XML document) can be cloned, including the tree of nodes that is started by it, using the following method:

```Swift
func clone(pointingFromClone: Bool) -> XNode
```

Any node possesses the property `r` pointing to the node related to itself by (the last) cloning. By default, `r` points from the node in the clone to the according node in the original tree. The `r` values of the clone are as in the document that is being cloned. By setting the argument `pointingFromClone` to `true` (it defaults to `false`), this direction is reversed. By setting `pointingFromClone` when cloning an XML document one can adjust to the situation of using the original tree for further manipulation and just saving an old version for reference; the following method does exactly this:

```Swift
func saveVersion()
```

You might use the `clone` method several times, the property `r` gives you the whole chains of `rpath` values and `rr` gives you the last value in this chain.

Sometimes, only a “shallow” clone is needed, i.e. the node itself without the tree of nodes that is started by it. In this case, just use:

```Swift
func shallowClone(forwardref: Bool) -> XNode
```

## Content properties

### Element names

Element names can be read and set by the using the property `name` of an element. After setting of a new name different from the existing one, the element is registered with the new name in the document, if it is part of a document. Setting the same name does not change anything (it is an efficient non-change).

### Text 

For a text content (`XText`) its text can be read and set via its property `value`. So there is no need to replace a `XText` content by another to change text. Please also see the section below on handling of text.

### Changing and reading attributes

The attributes of an element can be read and set via the “index notation”. If an attribute is not set, `nil` is returned; reversely, setting an attribute to `nil` results in removing it. Setting an attribute with a new name or removing an attribute changes the registering of attributes in the document, if the element is part of a document. Setting a non-nil value of an attribute that already exists is an efficient non-change concerning the registering if attributes.

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

Element, documents, and `XSpot` (see the section below on `XSpot` and handling of text) can have “attachments”. Those are objects that can be attached via a textual key to those branches but that not considered as belonging to the actual XML tree.

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
    print("note: \((note.firstContent as? XText)?.value ?? "")")
}

// removing the attached note:
myElement.attached["note"] = nil
```

## Traversals

Traversing a tree depth-first starting from a node (including a document) can be done by the following methods:

```Swift
func traverse(down: (XNode) -> (), up: ((XNode) -> ())?)
```

```Swift
func traverseThrowing(down: (XNode) throws -> (), up: ((XNode) throws -> ())?) throws
```

```Swift
func traverseAsync(down: (XNode) async -> (), up: ((XNode) async -> ())?) async
```

```Swift
func traverseAsyncThrowing(down: (XNode) async throws -> (), up: ((XNode) async throws -> ())?) async throws
```

For a “branch”, i.e. a node that might contain other nodes (like an element, opposed to e.g. text, which does not contain other nodes), when returning from the traversal of its content (also in the case of an empty branch) the closure given the optional `up:` argument is called.

Example:

```Swift
document.traverse { node in
    if let element = node as? XElement {
        print("entering element \(element.name)")
    }
}
up: { node in
    if let element = node as? XElement {
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

## Finding related content

Starting from some content, you might want to find related content, e.g. its children. The names chosen for the accordings methods come from the idea that all content have a natural order, namely the order of a depth-first traversal, which is the same order in which the content of an XML document is stored in a text file. This order gives a meaning to method names such a `nextSibling`. Note that, other than for the iterations you get via `elements(ofName:)` and `attributes(ofName:)`, even nodes that stay in the same document can occur in such an iteration sevaral times if moved accordingly during the iteration.

Sequences returned are always lazy sequences, iterating through them gives items of the obvious type. As mentioned in the general description of the library, manipulating the XML tree during such an iteration is allowed.

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
var ancestors: XElementSequence
```

Get the first content of a branch:

```Swift
var firstContent: XContent?
```

Get the last content of a branch:

```Swift
var lastContent: XContent?
```

The direct content of a document or an element (“direct” means that their parent is this document or element):

```Swift
var content: XContentSequence
```

The direct content that is an element, i.e. all the children:

```Swift
var children: XElementSequence
```

All content in the tree of nodes that is started by the node itself, without the node itself, in the order of a depth-first traversal:

```Swift
var allContent: XContentSequence
```

All content in the tree of nodes that is started by the node, starting with the node itself:

```Swift
var allContentIncludingSelf: XContentSequence
```

The descendants, i.e. all content in the tree of nodes that is started by the node, without the node itself, that is an element:

```Swift
var descendants: XElementSequence
```

If a node is an element, the element itself and the descendants, starting with the element itself:

```Swift
var descendantsIncludingSelf: XElementSequence
```

The (direct) content of an branch (element or document) are “siblings” to each other.

The content item previous to the subject:

```Swift
var previousTouching: XContent?
```

The content item next to the subject:

```Swift
var nextTouching: XContent?
```

The following very short method names `previous` and `next` actually mean “the previous content” and “the next content”, repectively. Those method names are chosen to be so short because they are such a common use case.

All nodes previous to the node (i.e. the previous siblings) _on the same level,_ i.e. of the same parent, in the order from the node:

```Swift
var previous: XContentSequence
```

Of those, the ones that are elements:

```Swift
var previousElements: XElementSequence
```

Analogously, the content next to the node:

```Swift
var next: XContentSequence
```

Of those, the ones that are elements:

```Swift
var nextElements: XElementSequence
```

Once you have such a sequence, you can get the first or the n'th itme in the sequence or just test if an item exists at all via:

```Swift
func findFirst() -> XContent?
func findFirst() -> XElement?
```

```Swift
func find(index: Int) -> XContent?
func find(index: Int) -> XElement?
```

```Swift
var exist: Bool
```

You may also ask for the previous or next content item in the tree, in the order of a depth-first traversal. E.g. if a node is the last node of a subtree starting at a certain element and the element has a next sibling, this next sibling is “the next node in the tree” for that last node of the subtree. Getting the next or previous node in the tree is very efficient, as the library keep track of them anyway.

The next content item in the tree:

```Swift
var nextInTreeTouching: XContent?
```

The previous content item in the tree:

```Swift
var previousInTreeTouching: XContent?
```

Example:

```Swift
myElement.descendants.forEach { descendant in
    print("the name of the descendant is \(descendant.name)")
}
```

## Finding related nodes with filters

All of the methods in the previous section that return a sequence also allow a condition as first argument for filtering:

```Swift
let document = try parseXML(fromText: """
<a><b/><c take="true"/><d/><e take="true"/></a>
""")

document
    .descendants{ element in element["take"] == "true" }
    .forEach { descendant in 
        print(descendant)
    }
```

Output:
```text
<c take="true">
<e take="true">
```

There also exist a shortcut for the common of filtering elements according to a name:

```Swift
document
    .descendants("paragraph")
    .forEach { _ in
        print("found a paragraph!")"
    }
```

A short note on coding style: It is recommended to not use spaces around the parantheses `{...}` describing the filter, the same recommendation applies to `map` etc., other than before the parantheses defining element content or a terminating closure that is not a filter as in the case of `forEach`, and it is recommended to write the content of a terminating closure in a new line separate from the parantheses. The reaaon os that after such a filter, there might be a dot continuing the expression:

```Swift
myElement.descendants{ $0.name.contains("title") }.contents
```

You might not want to set a space before `.contents`, and it would then look quite asymmetric to put a space before the opening paranthese. Whereas defining content of an element in parantheses `{...}` or the closure of a `forEach` is more like defining a code block in the traditional sense. (Of course, this is just a recommendation. You may choose your own style.)

Also note that if a filter is part of the condition of an `if` statement, you may get the warning “Trailing closure in this context is confusable with the body of the statement...” if you do not use the following notation:+

```Swift
if let label = section.children(where: { $0.name.contains("label") }).findFirst() {
   // ... 
}
```

## Chained iterators

Iterators can also be chained. The second iterator is executed on each of the node encountered by the first iterator. All this iteration is lazy, so the first iterator only searches for the next node if the second iterator is done with the current node found by the first iterator.

Example:

```Swift
let document = try parseXML(fromText: """
<a>
    <b>
        <c>
            <d/>
        </c>
    </b>
</a>
""")

document.descendants.descendants.forEach { print($0) }
```

Output:

```text
<b>
<c>
<d>
<c>
<d>
<d>
```

Also, in those chains operations resulting in single nodes like `parent` can be used.

## Constructing XML

### Constructing an empty element

When constructing an element (without content), the name is given as the first (nameless) argument and the attribute values are given as (nameless) a dictionary.

Example: constructing an empty “paragraph” element with attributes `id="1"` and `style="note"`:

```Swift
let myElement = XElement("paragraph", ["id": "1", "style": "note"])
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

For resulting arrays of more complex content, use the property `xml` to insert them (`xml` also flattens arrays of sequences):

```Swift
let myElement = XElement("div") {
    ["Hello ", " ", "World"].xml
    document.children.map{ $0.children }.xml
}
```

### Document membership in constructed elements

Elements that are part of a document (`XDocument`) are registered in the document. The same is true for its attributes. The reason is that this allows fast access to elements and attributes of a certain name via `elements(ofName:)` and `attributes(ofName:)` and the exact functioning of rules (see the section below on rules).

In the moment of constructing a new element with its content defined in `{...}` brackets during construction, the element is not part any document. The nodes inserted to it leave the document tree, but they are not (!) unregistered from the document. I.e. the iterations `elements(ofName:)` and `attributes(ofName:)` will still find them, and according rules will apply to them. The reason for this behaviour is the common case of the new element getting inserted into the same document. If the content of the new element would first get unregistered from the document and then get reinserted into the same document again, they would then count as new elements, and the mentioned iterations might iterate over them again.

If you would like to get the content a newly built element to get unregistered from the document, use its method `adjustDocument()`. This method diffuses the current document of the element to its content. For a newly built element this document is `nil`, which unregisters a node from its document. You might also set the attribute `adjustDocument` to `true` in the initializer of the element to automatically call `adjustDocument()` when the building of the new element is accomplished. This call or setting to adjust of the document is only necessary at the top-level element, it is dispersed through the whole tree.

Note that if you insert an element into another document that is part of a document, the new child gets registered in the document of its new parent if not already registered there (and unregistered from any different document where it was registered before).

Example: a newly constructed element gets added to a document:

```Swift
let document = try parseXML(fromText: """
<a><b id="1"/><b id="2"/></a>
""")

document.elements(ofName: "b").forEach { element in
    print("applying the rule to \(element)")
    if element["id"] == "2" {
        element.insertNext {
            XElement("c") {
                element.previous
            }
        }
    }
}

print("\n-----------------\n")

document.firstContent?.echo()
```

Output:

```text
applying the rule to <b id="1">
applying the rule to <b id="2">

-----------------

<a><b id="2"/><c><b id="1"/></c></a>
```

As you can see from the `print` commands in the last example, the element `<b id="1">` does not lose its “connection” to the document (although it seems to get added again to it), so it is only iterated over once by the iteration.

## Tree manipulations

Besides changing the node properties, an XML tree can be changed by the following methods. Some of them return the subject itself as a discardable result. For the content specified in `{...}` (the builder) the order is preserved.

Add nodes to the start of the content of an element or a document respectively:

```Swift
func add(skip: Bool, builder: () -> [XContent]) -> XElement
func add(skip: Bool, builder: () -> [XContent]) -> XDocument
```

Add nodes as the nodes previous to the node:

```Swift
func insertPrevious(builder: () -> [XContent]) -> XContent
```

Add nodes as the nodes next to the node:

```Swift
func insertNext(builder: () -> [XContent]) -> XContent
```

A more precise type is returned from `insertPrevious` and `insertNext` if the type of the subject is more precisely known.

By using the next two methods, a node gets removed. If the argument `forward` is set to `true` (default is `false`), such an operation prefetches the next node in iterators that have the node as active node, else, the iterators all told to go to the previous node.

Remove the node from the tree structure and the document:

```Swift
func remove(forward: Bool)
```

Replace the node by other nodes; if `forward`, then detaching prefetches the next node in iterators:

```Swift
func replace(forward: Bool, builder: () -> [XContent])
```

Clear the contents of an element or a document respectively:

```Swift
func clear(forward: Bool) -> XElement
func clear(forward: Bool) -> XDocument
```

Set the contents of an element or a document respectively:

```Swift
func setContent(forward: Bool, builder: () -> [XContent]) -> XElement
func setContent(forward: Bool, builder: () -> [XContent]) -> XDocument
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

## `XSpot` and handling of text

Subsequent text nodes (`XText`) are always automatically combined, and text nodes with empty text are automatically removed.

This can be very convenient when processing text, e.g. it is then very straightforward to apply regular expressions to the text in a document. But there might be some stumbling blocks involved here, when the different behaviour of text nodes and other nodes 
affects the result of your manipulations.

In those cases, you may use an `XSpot` node as a separator to a text. An `XSpot` “does nothing” besides existing at a certain spot in the XML tree (hence its name), it invisible when using a production. Consider e.g. the following example where the occurrences of a search text gets a greenish background. In this example, you do not want `part` to be added to `text` in the iteration:

```Swift
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
```

Output:

```text
<a>Hello <span style="background:LightGreen">world</span>, the <span style="background:LightGreen">world</span> is nice.</a>
```

An `XSpot` can also have attachments.

## Rules

As mentioned in the general description, a set of rules `XRule` in the form of a transformation instance of type `XTransformation` can be used as follows.

In a rule, the user defines what to do with elements or attributes certain names. The set of rules can then be applied to a document, i.e. the rules are applied in the order of their definition. This is repeated, guaranteeing that a rule is only applied once to the same object (if not removed from the document and added again), until no application takes place. So elements can be added during application of a rule and then later be processed by the same or another rule.

Example:

```Swift
let document = try parseXML(fromText: """
<a><formula id="1"/></a>
""")

var count = 1

let transformation = XTransformation {
    
    XRule(forElements: ["formula"]) { element in
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
    
    XRule(forElements: ["image"]) { element in
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
    
    XRule(forAttributes: ["id"]) { (value,element) in
        print("\n----- Rule for attribute \"id\" -----\n")
        print("  \(element) --> ", terminator: "")
        element["id"] = "done-" + value
        print(element)
    }
    
}

transformation.execute(inDocument: document)

print("\n----------------------------------------\n")

document.firstContent?.echo()
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

## Tracking changes

It might be helpful to get notified when certain things in the XML document are changed. A common use case is the change of an attribute. You can register for the notification for the change of the value of any attribute of a certain name using:

```Swift
func setChangedAction(forAttributeName: String, action: (XElement, String?, String?) -> ())
```

The string arguments are the new and the old value, respectively. Only one action can be set for a specific attribute name.

Example: get notified if an "id" attribute gets changed:

```Swift
myDocument.setChangedAction(forAttributeName: "id") { (element, oldValue, newValue) in
    // ... do something ...
}
```

To stop the notification, use

```Swift
func removeChangedAction(forAttributeName: String)
```

## Facilities for testing

For our tests of the library, we implemented the following properties to get a sequence iterating over a single element or content.

For any content:

```Swift
var asContentSequence: XContentSequence
```

For an element:

```Swift
var asElementSequence: XElementSequence
```
