# SwiftXML

A library written in Swift to process XML.

This library is published under the Apache License 2.0.

```Swift
let transformation = XTransformation {
    
    XRule(forElements: "table") { table in
        table.insertNext {
            XElement("caption") {
                "Table: "
                table.children({ $0.name.contains("title") }).content
            }
        }
    }
    
    XRule(forElements: "tbody", "tfoot") { tablePart in
        tablePart
            .children("tr")
            .children("th")
            .forEach { cell in
                cell.name = "td"
            }
    }
    
    XRule(forAttributes: "label") { label in
        label.element["label"] = label.value + ")"
    }
    
}
```

---
**NOTE**

**This library is not in a “final” state yet** despite its high version number, i.e. there might still be bugs, or some major improvements will be done, and breaking changes might happen without the major version getting augmented. Addionally, there will be more comments in the code. Also, when such a final state is reached, the library might be further developed using a new repository URL (and the version number set back to a lower one). Further notice will be added here. See [there](https://stefanspringer.com) for contact information.

---

## Related packages

When using SwiftXML in the context of the [SwiftWorkflow](https://github.com/stefanspringer1/SwiftWorkflow) framework, you might include the [WorkflowUtilitiesForSwiftXML](https://github.com/stefanspringer1/WorkflowUtilitiesForSwiftXML).

## Properties of the library

The library reads XML from a source into an XML document instance, and provides methods to transform (or manipulate) the document, and others to write the document to a file.

The library should be efficient and applications that use it should be very intelligible.

### Manipulation of an XML document

Other than some other libraries for XML, the manipulation of the document as built in memory is “in place”, i.e. no new XML document is built. The goal is to be able to apply many isolated manipulations to an XML document efficiently. But it is always possible to clone a document easily with references to or from the old version.

The following features are important:

- All iteration over content in the document using the according library functions are lazy by default, i.e. the iteration only looks at one item at a time and does not (!) collect all items in advance.
- While lazily iterating over content in the document in this manner, the document tree can be changed without negatively affecting the iteration.
- Elements or attributes of a certain name can be efficiently found without having to traverse the whole tree. An according iteration proceeds in the order by which the elements or attributes have been added to the document. When iterating in this manner, newly added elements or attributes are then also processed as part of the same iteration.

The following code takes any `<item>` with an integer value of `multiply` larger than 1 and additionally inserts an item with a `multiply` number one less, while removing the `multiply` value on the existing item (the library will be explained in more detail in subsequent sections):

```Swift
let document = try parseXML(fromText: """
<a><item multiply="3"/></a>
""")

document.elements(ofName: "item").forEach { item in
    if let multiply = item["multiply"], let n = Int(multiply), n > 1 {
        item.insertPrevious {
            XElement("item", ["multiply": n > 2 ? String(n-1) : nil])
        }
        item["multiply"] = nil
    }
}

document.echo()
```

The output is:

```text
<a><item/><item/><item/></a>
```

Note that in this example – just to show you that it works – each new item is being inserted _before_ the current node but is then still being processed.

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

document.echo()
```

The output is:

```text
<a><item id="2"/><item id="4"/></a>
```

Of course, since those iterations are regular sequences, all according Swift library functions like `map` and `filter` can be used. But in many cases, it might be better to use conditions on the content iterators (see the section on finding related content with filters) or chaining of content iterators (see the section on chained iterators).

The user of the library can also provide sets of rules to be applied (see the code at the beginning and a full example in the section about rules). In such a rule, the user defines what to do with an element or attribute with a certain name. A set of rules can then be applied to a document, i.e. the rules are applied in the order of their definition. This is repeated, guaranteeing that a rule is only applied once to the same object (if not fully removed from the document and added again, see the section below on document membership), until no more application takes places. So elements can be added during application of a rule and then later be processed by the same or another rule.

### Other properties

The library uses the [SwiftXMLParser](https://github.com/stefanspringer1/SwiftXMLParser) to parse XML which implements the according protocol from [SwiftXMLInterfaces](https://github.com/stefanspringer1/SwiftXMLInterfaces).

Depending on the configuration of the parse process, all parts of the XML source can be retained in the XML document, including all comments and parts of an internal subset e.g. all entity or element definitions. (Elements definitions and attribute list definitions are, besides their reported element names, only retained as their original textual representation, they are not parsed into any other representation.) 

In the current implementation, the XML library does not implement any validation, i.e. validation against a DTD or other XML schema, telling us e.g. if an element of a certain name can be contained in an element of another certain name. The user has to use other libraries (e.g. [Libxml2Validation](https://github.com/stefanspringer1/Libxml2Validation)) for such validation before reading or after writing the document. Besides validating the structure of an XML document, validation is also important for knowing if the occurrence of a whitespace text is significant (i.e. should be kept) or not. (E.g., whitespace text between elements representing paragraphs of a text document is usually considered insignificant.) To compensate for that last issue, the user of the library can provide a function that decides if an instance of whitespace text between elements should be kept or not. Also, possible default values of attributes have to be set by the user if desired once the document tree is built.

This library gives full control of how to handle entities. Named entity references can persist inside the document event if they are not defined. Named entity references are being scored as internal or external entity references during parsing, the external entity references being those which are referenced by external entity definitions in the internal subset inside the document declaration of the document. Replacements of internal entity references by text can be done automatically according to the internal subset and/or controlled by the application.

Automated inclusion of the content external parsed entities can be configurated, the content might then be wrapped by elements with according information of the enities.

In the current state, the library does not recognize XML namespaces; elements or attributes with namespace prefixes are give the full name “prefix:unprefixed". See the section on handling of namespaces for motivation and about how to handle namespaces.

The encoding of the source should always be UTF-8 (ASCII is considered as a subset of it). The parser checks for correct UTF-8 encoding and also checks (according to the data available to the currently used Swift implementation) if a found codepoint is a valid Unicode codepoint.

For any error during parsing an error is thrown and no document is then provided.

An XML tree (e.g. a document) must not be examined or changed concurrently.

---
**NOTE**

The description of the library that follows might not include all types and methods. Please see the documentation produced by DocC or use autocompletion in an according integrated development environment (IDE).

---

## Reading XML

The following functions take a source and return an XML document instance (`XDocument`). The source can either be provided as a URL, a path to a file, a text, or binary data.

Reading from a URL which references a local file:

```Swift
func parseXML(
    fromURL: URL,
    sourceInfo: String?,
    textAllowedInElementWithName: ((String) -> Bool)?,
    internalEntityAutoResolve: Bool,
    internalEntityResolver: InternalEntityResolver?,
    insertExternalParsedEntities: Bool,
    externalParsedEntitySystemResolver: ((String) -> URL?)?,
    externalParsedEntityGetter: ((String) -> Data?)?,
    externalWrapperElement: String?,
    keepComments: Bool,
    keepCDATASections: Bool,
    eventHandlers: [XEventHandler]?
) throws -> XDocument
```

And accordingly:

```Swift
func parseXML(
    fromPath: String,
    ...
) throws -> XDocument
```

```Swift
func parseXML(
    fromText: String,
    ...
) throws -> XDocument
```

```Swift
func parseXML(
    fromData: Data,
    ...
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

If `internalEntityAutoResolve` is set to `true`, the parser first tries to replace the internal entities by using the declarations in the internal subset of the document before calling an `InternalEntityResolver`.

The content of external parsed entities are not inserted by default, but they are if you set `insertExternalParsedEntities` to `true`. You can provides a method in the argument `externalParsedEntitySystemResolver` to resolved the system identitfier of the external parsed entity to an URL. You can also provide a method in the argument `externalParsedEntityGetter` to get the data for the system identifier (if `externalParsedEntitySystemResolver` is provided, then `externalParsedEntitySystemResolver` first has to return `nil`). At the end the system identifier is just added as path component to the source URL (if it exists) and the parser tries to load the entity from there.

When the content of an external parsed entitiy is inserted, you can declare an element name `externalWrapperElement`: the inserted content then gets wrapped into an element of that name with the information about the entity in the attributes `name`, `systemID`, and `path` (`path` being optional, as an external parsed entity might get resolved without an explicit path). (During later processing, you might want to change this representation, e.g. if the external parsed entity reference is the only content of an element, you might replace the wrapper by its content and set the according information as some attachments of the parent element, so validation of the document succeeds.)

One a more event handlers can be given a `parseXML` call, which implement `XEventHandler` from [XMLInterfaces](https://github.com/stefanspringer1/SwiftXMLInterfaces). This allows for the user of the library to catch any event during parsing like entering or leaving an element. E.g., the resolving of an internal entity reference could depend on the location inside the document (and not only on the name of the element or attribute), so this information can be collected by such an event handler.

`keepComments` (default: `false`) decides if a comment should be preserved (as `XComment`), else they will be discarded without notice. `keepCDATASections` (default: `false`) decides if a CDATA section should be preserved (as `XCDATASection`), else all CDATA sections get resolved as text.

## Content of a document

An XML document (`XDocument`) can contain the following content:

- `XElement`: an element
- `XText`: a text
- `XInternalEntity`: an internal entity reference
- `XExternalEntity`: an external entity reference
- `XCDATASection`: a CDATA section
- `XProcessingInstruction`: a processing instruction
- `XComment`: a comment
- `XLiteral`: containing text that is meant to be serialized “as is”, i.e. no escaping e.g. of `<` and `&` is done, it could contain XML code that is to be serialized _literally,_ hence its name

`XLiteral` is never the result of parsing XML, but might get added by an application. Subsequent `XLiteral` content is (just like `XText`, see the section on handling of text) always automatically combined.

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
func echo(pretty: Bool, indentation: String, terminator: String)
```

`pretty` defaults to `false`; if it is set to `true`, linebreaks and spaces are added for pretty print. `indentation` defaults to two spaces, `terminator` defaults to `"\n"`, i.e. a linebreak is then printed after the output.

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
func write(toURL: URL, usingProduction: XProduction) throws
```

```Swift
func write(toFile: String, usingProduction: XProduction) throws
```

```Swift
func write(toFileHandle: FileHandle, usingProduction: XProduction) throws
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

try document.write(toFile: "myFile.xml", usingProduction: MyProduction())
```

For generality, the following method is provided to apply any `XProduction` to a node and its contained tree:

```Swift
func applyProduction(production: XProduction) throws
```

## Cloning and document versions

Any node (including an XML document) can be cloned, including the tree of nodes that is started by it, using the following method:

```Swift
func clone() -> XNode
```

(The result will be more specific if the subject is known to be more specific.)

Any content and the document itself possesses the property `backLink` that can be used as a relation between a clone and the original node. If you create a clone by using the `clone()` method, the `backLink` value of a node in the clone points to the original node. So when working with a clone, you can easily look at the original nodes.

Note that the `backLink` reference references the original node weakly, i.e. if you do not save a reference to the original node or tree then the original node disapears and the `backLink` property will be `nil`.

If you would like to use cloning to just save a version of your document to a copy, use its following method:

```Swift
func makeVersion()
```

In that case a clone of the document will be created, but with the `backLink` property of an original node pointing to the clone, and the `backLink` property of the clone will point to the old `backLink` value of the original node. I.e. if you apply `saveVersion()` several times, when following the `backLink` values starting from a node in your original document, you will go through all versions of this node, from the newer ones to the older ones. The `backLinks` property gives you exactly that chain of backlinks. Other than when using `clone()`, a strong reference to such a document version will be remembered by the document, so the nodes of the clone will be kept. Use `forgetVersions(keeping:Int)` on the document in order to stop this remembering, just keeping the last number of versions defined by the argument `keeping` (`keeping` defaults to 0). In the oldest version then still remembered or, if no remembered version if left, in the document itself all `backLink` values will then be set to `nil`.

The `finalBackLink` property follows the whole chain of `backLink` values and gives you the last value in this chain.

Sometimes, only a “shallow” clone is needed, i.e. the node itself without the whole tree of nodes with the node as root. In this case, just use:

```Swift
func shallowClone(forwardref: Bool) -> XNode
```

The `backLink` is then set just like when using `clone()`.

## Content properties

### Source range

If the parser (as it is the case with the [SwiftXMLParser](https://github.com/stefanspringer1/SwiftXMLParser)) reports the where a part of the document it is in the text (i.e. at what line and column it starts and at what line and column it ends), the property `sourceRange: XTextRange` (using `XTextRange` from [SwiftXMLInterfaces](https://github.com/stefanspringer1/SwiftXMLInterfaces)) returns it for the respective node:

Example:

```Swift
let document = try parseXML(fromText: """
<a>
    <b>Hello</b>
</a>
""", textAllowedInElementWithName: { $0 == "b" })

document.allContent.forEach { content in
    if let sourceRange = content.sourceRange {
        print("\(sourceRange): \(content)")
    }
    else {
        content.echo()
    }
}
```

Output:

```text
1:1 - 3:4: <a>
2:5 - 2:16: <b>
2:8 - 2:12: Hello
```

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

You can also get a sequence of attribute values (optional Strings) from a sequence of elements.

Example:

```Swift
let document = try parseXML(fromText: """
    <test>
      <b id="1"/>
      <b id="2"/>
      <b id="3"/>
    </test>
    """)
print(document.children.children["id"].joined(separator: ", "))
```

Result:

```text
1, 2, 3
```

To get the names of all attributes of an element, use:

```Swift
var attributeNames: [String]
```

### Attachments

All nodes can have “attachments”. Those are objects that can be attached via a textual key to those branches but that not considered as belonging to the actual XML tree.

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

You can also set attachments immediately when creating en element or a document by using the argument `attached:` of the initializer.

### XPath

Get the XPath of a node via:

```Swift
var xPath: String
```

## Traversals

Traversing a tree depth-first starting from a node (including a document) can be done by the following methods:

```Swift
func traverse(down: (XNode) throws -> (), up: ((XNode) throws -> ())? = nil) rethrows
```

```Swift
func traverse(down: (XNode) async throws -> (), up: ((XNode) async throws -> ())? = nil) async rethrows
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
myDocument.attributes(ofName: "id").forEach { id in
    if id.element.name == "paragraph" {
        print("found paragraph with ID \"\(id.value)\"")
    }
}
```

Note that we did not use something like `...forEach { attribute in ... attribute.value ...}` but we used the attribute name for the name of the variable in the `forEach` loop to make clear what attribute is used, without an unnecesary complex variable name.

Find the elements of several names or the attributes of several names by using sevearal names in `elements(ofName:)` or `attributes(ofName:)`, respectively. Note that just like the methods for single names, what you add during the iteration will then also be considered.

## Finding related content

Starting from some content, you might want to find related content, e.g. its children. The names chosen for the accordings methods come from the idea that all content have a natural order, namely the order of a depth-first traversal, which is the same order in which the content of an XML document is stored in a text file. This order gives a meaning to method names such a `nextTouching`. Note that, other than for the iterations you get via `elements(ofName:)` and `attributes(ofName:)`, even nodes that stay in the same document can occur in such an iteration sevaral times if moved accordingly during the iteration.

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

If there is exactly one node contained, get it, else get `nil`:

```Swift
var singleContent: XContent?
```

The direct content of a document or an element (“direct” means that their parent is this document or element):

```Swift
var content: XContentSequence
```

The direct content that is an element, i.e. all the children:

```Swift
var children: XElementSequence
```

The direct content that is text:

```Swift
var texts: XTextSequence
```

For the `content` and `children` sequences, there also exist the sequences `contentReversed`, `childrenReversed`, and `textsReversed` which iterate from the last corresponding item to the first.

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

All texts in the tree of nodes that is started by the node itself, without the node itself, in the order of a depth-first traversal:

```Swift
var allTexts: XTextSequence
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

You might also just be interested if a previous or next node exists:

```Swift
var hasPrevious: Bool
var hasNext: Bool 
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

Example:

```Swift
myElement.descendants.forEach { descendant in
    print("the name of the descendant is \(descendant.name)")
}
```

Note that a sequence might be used several times:

```Swift
let document = try parseXML(fromText: """
<a><c/><d/><e/></a>
""")

let insideA = document.children.children

insideA.echo()
print("again:")
insideA.echo()
```

Output:

```text
<c/>
<d/>
<e/>
again:
<c/>
<d/>
<e/>
```

Once you have such a sequence, you can get the first item in the sequence via its property `first` (which is introduced by this package in addition to the already defined `first(where:)`).

The usual methods of sequences can be used. E.g., use `mySequence.dropFirst(n)` to drop the first `n` items of the sequence `mySequence`. E.g. to get the third item of the sequence, use ``mySequence.dropFirst(2).first`.

Note that there is no property getting you the last item of those sequences, as it would be quite inefficient. Better use `contentReversed` or `childrenReversed` in combination with `first`.

Test if something exists in a sequence by using `exist`:

```Swift
var exist: Bool
```

Note that after using `exist`, you can still iterate normally along the same sequence, without loosing an item.

Test if nothing exists in a sequence by using `absent`:

```
var absent: Bool
```

If you would like to test if certain items exist, and many cases you would also then use those items. The property `existing` of a sequence of content or elements returns the sequence itself if items exist, and `nil` otherwise:

```Swift
var existing: XContentSequence?
var existing: XElementSequence?
```

In the following example, a sequence is first tested for existing items and, if items exist, then used:

```Swift
let document = try parseXML(fromText: """
<a><c/><b id="1"/><b id="2"/><d/><b id="3"/></a>
""")

if let theBs = document.descendants("b").existing {
    theBs.echo()
}
```

Note that what you get by using `existing` still is a lazy sequece, i.e. if you change content between the `existing` test and using its result, then there might be no more items left to be found.

You may also ask for the previous or next content item in the tree, in the order of a depth-first traversal. E.g. if a node is the last node of a subtree starting at a certain element and the element has a next sibling, this next sibling is “the next node in the tree” for that last node of the subtree. Getting the next or previous node in the tree is very efficient, as the library keep track of them anyway.

The next content item in the tree:

```Swift
var nextInTreeTouching: XContent?
```

The previous content item in the tree:

```Swift
var previousInTreeTouching: XContent?
```

Find all text contained in a node (being composed into a single `String`):

```Swift
var text: String
```

You might also turn a single content item or, more specifically, an element into an appropriate sequence using the following methods:

For any content:

```Swift
var asSequence: XContentSequence
```

For an element:

```Swift
var asElementSequence: XElementSequence
```

(These two methods are used in the tests of the library.)

## Finding related nodes with filters

All of the methods in the previous section that return a sequence also allow a condition as a first argument for filtering. We distinguish between the case of all items of the sequence fullfilling a condition, the case of all items while a condition is fullfilled, and the case of all items until a condition is fullfilled (excluding the found item where the condition fullfilled):

```Swift
func content((XContent) -> Bool) -> XContentSequence
func content(while: (XContent) -> Bool) -> XContentSequence
func content(until: (XContent) -> Bool) -> XContentSequence
```

Sequences of a more specific type are returned in sensible cases.

Example:

```Swift
let document = try parseXML(fromText: """
<a><b/><c take="true"/><d/><e take="true"/></a>
""")

document
    .descendants({ element in element["take"] == "true" })
    .forEach { descendant in 
        print(descendant)
    }
```

Output:
```text
<c take="true">
<e take="true">
```

Note that the round parentheses “(...)” around the condition in the example is needed to distinguish it from the `while:` and `until:` versions. (There is no `where:` argument name, because without it the less common case `while:` – and to a lesser degree `until:` – is more easily visually distinguished from it, the more common case being syntactically the shortest. This plays out well in actual code.)

There also exist a shortcut for the common of filtering elements according to a name:

```Swift
document
    .descendants("paragraph")
    .forEach { _ in
        print("found a paragraph!")"
    }
```

You can also use multiple names (e.g. `descendants("paragraph", "table")`). If no name is given, all elements are given in the result regardless the name, e.g. `children()` means the same as `children`.

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

Also, in those chains operations finding single nodes when applied to a single node like `parent` also work, and you can use e.g. `insertNext` (see the section on tree manipulations), or `applying` (see the next section on constructing XML), or `echo()`.

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

For resulting arrays of more complex content, use the property `asContent` to insert them (`asContent` also flattens arrays of sequences):

```Swift
let myElement = XElement("div") {
    ["Hello ", " ", "World"].asContent
    myDocument.children.map{ $0.children }.asContent
    ["a","b"].map{ XElement($0) }.asContent
}
```

You might also use `as XContentLike` to set a common appropriate type where necessary:

```Swift
let myElement = XElement("p") {
    unpack ? myOtherElement.content : myOtherElement as XContentLike
    setPredefinedText ? "my text" : anotherElement.content as XContentLike
    wrapped ? "my other text" : XElement("wrapper") { "my other text" } as XContentLike
}
```

By using the method `applying((XNode) -> ()) -> XNode` to a node (the argument and the return value are more specific if the subject is more specific) you can apply a function to a content node before returning it:

Example:

```Swift
let myDocument = XDocument {
    myElement.applying{ $0["level"] = "top" }
}
```

`applying` can also be used on a content sequence or element sequence where it is shorter than using the `map` method in the general case (where a `return` statement might have to be included) and you can directly use it to define content (without the `asContent` property decribed above):

```Swift
let myDocument = XDocument {
    myElement.descendants.applying{ $0["inserted"] = "yes" }
}
```

When not defining content, using `map` might be a sensible option:

```Swift
let element = XElement("z") {
    XElement("a") {
        XElement("a1")
        XElement("a2")
    }
    XElement("b") {
        XElement("b1")
        XElement("b2")
    }
}

element.children.map{ $0.children.first }.forEach { print($0?.name ?? "-") }
```

Output:

```text
a1
b1
```

The same applies to e.g. the `filter` method, which, besides letting the code look more complex when used instead of the filter options described above, is not a good option when defining content.

For a single node, use the `havingProperties(...)` method to see if a condition is met; if yes, the node is returned, if not, `nil` is returned. Use `hasProperties(...)` to just see if a node has a certain properties., without returning the node.

The content of elements containing other elements while defining their content is being built from the inside to the ouside: Consider the following example:

```Swift
let b = XElement("b")

let a = XElement("a") {
    b
    "Hello"
}

a.echo(pretty: true)

print("\n------\n")

b.replace {
    XElement("wrapper1") {
        b
        XElement("wrapper2") {
            b.next
        }
    }
}

a.echo(pretty: true)
```

First, the element “wrapper2” is built, and at that moment the sequence `b.next` contains the text `"Hello"`. So we will get as output:

```text
<a><b/>Hello</a>

------

<a>
  <wrapper1>
    <b/>
    <wrapper2>Hello</wrapper2>
  </wrapper1>
</a>
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

document.echo()
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

Add nodes at the end of the content of an element or a document respectively:

```Swift
func add(builder: () -> [XContent])
```

Add nodes to the start of the content of an element or a document respectively:

```Swift
func addFirst(builder: () -> [XContent])
```

Add nodes as the nodes previous to the node:

```Swift
func insertPrevious(builder: () -> [XContent])
```

Add nodes as the nodes next to the node:

```Swift
func insertNext(builder: () -> [XContent])
```

A more precise type is returned from `insertPrevious` and `insertNext` if the type of the subject is more precisely known.

By using the next two methods, a node gets removed.

Remove the node from the tree structure and the document:

```Swift
func remove()
```

Replace the node by other nodes:

```Swift
func replace(builder: () -> [XContent])
```

Clear the contents of an element or a document respectively:

```Swift
func clear()
```

Test if an element or a document is empty:

```Swift
var isEmpty: Bool
```

Set the contents of an element or a document respectively:

```Swift
func setContent(builder: () -> [XContent])
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

Note that by default iterations continue while disregarding new nodes inserted by `insertPrevious` or `insertNext`, so that e.g. the following example works intuitively:

```Swift
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

element.content.forEach { content in
    content.replace {
        content.content
    }
}

element.echo(pretty: true)

print("\n---- 2 ----\n")

element.contentReversed.forEach { content in
    content.insertPrevious {
        XElement("I" + ((content as? XElement)?.name ?? "?"))
    }
}

element.echo(pretty: true)
```

Output:

```text
<top>
  <a1>
    <a2/>
  </a1>
  <b1>
    <b2/>
  </b1>
  <c1>
    <c2/>
  </c1>
</top>

---- 1 ----

<top>
  <a2/>
  <b2/>
  <c2/>
</top>

---- 2 ----

<top>
  <Ia2/>
  <a2/>
  <Ib2/>
  <b2/>
  <Ic2/>
  <c2/>
</top>
```

Note that there is no such mechanism to skip inserted content when not using `insertPrevious`, `insertNext`, or `replace`, e.g. when using `add`. Consider the combination `descendants.add`: there is then no “natural” way to correct the traversal of the tree. (A more common use case would be something like `descendants("table").add { XElement("caption") }`, so this should not be a problem in common cases, but something you should be aware of.)

When using `insertNext`, `replace` etc. in chained iterators, what happens is that the definition of the content in the parentheses `{...}` get _executed_ each item in the sequence. In the genaral case, you should use the `collect` function to build content specifically for the current item. E.g. in the last example, you might use with the same result:

```Swift
print("\n---- 1 ----\n")

element.content.replace { content in
    collect {
        content.content
    }
}

element.echo(pretty: true)

print("\n---- 2 ----\n")

element.contentReversed.insertPrevious { content in
    find {
        XElement("I" + ((content as? XElement)?.name ?? "?"))
    }
}

element.echo(pretty: true)
```

You may also not use `collect`:

```Swift
let e = XElement("a") {
    XElement("b")
    XElement("c")
}

e.descendants({ $0.name != "added" }).add {
    XElement("added")
}

e.echo(pretty: true)
```

Output:

```Swift
<a>
  <b>
    <added/>
  </b>
  <c>
    <added/>
  </c>
</a>
```

Note that a new `<added/>` is created each time. From what has already bee said, it should be clear that this “duplication” does not work with existing content (unless you use `clone()` or `shallowClone()`):

```Swift
let myElement = XElement("a") {
    XElement("to-add")
    XElement("b")
    XElement("c")
}

myElement.descendants({ $0.name != "to-add" }).add {
    myElement.descendants("to-add")
}

myElement.echo(pretty: true)
```

Output:

```text
<a>
  <b/>
  <c>
    <to-add/>
  </c>
</a>
```

As a general rule, when inserting a content, and that content is already part of another element or document, that content does not get duplicated, but removed from its original position.

Use `clone()` (or `shallowClone()`) when you actually want content to get duplicated, e.g. using `myElement.descendants("to-add").clone()` in the last example would then output:

```text
<a>
  <to-add/>
  <b>
    <to-add/>
  </b>
  <c>
    <to-add/>
    <to-add/>
  </c>
</a>
```

When you _do_ want to also operate on the newly insert content, set `keepPosition: true` on `insertPrevious` or `insertNext`. For example, consider the following code:

```Swift
let myElement = XElement("top") {
    XElement("a")
}

myElement.descendants.forEach { element in
    if element.name == "a" {
        element.insertNext() {
            XElement("b")
        }
    }
    else if element.name == "b" {
        element.insertNext {
            XElement("c")
        }
    }
}

myElement.echo(pretty: true)
```

Output:

```text
<top>
  <a/>
  <b/>
</top>
```

When `<b/>` gets inserted, the traversal is skipping it. When you would like `<b/>` to be included in the iteration, tell `insertNext` to keep the position (so the iteration continues from there, _not_ skipping `<b/>`):

```Swift
    ...
        element.insertNext(keepPosition: true) {
            XElement("b")
        }
    ...
```

Output:

```text
<top>
  <a/>
  <b/>
  <c/>
</top>
```

Similarly, if you replace a node, the content that gets inserted in place of the node is by default not included in the iteration. Example: Assume you would like to replace every occurrence of some `<bold>` element by its content. You might first try:

```Swift
let document = try parseXML(fromText: """
    <text><bold><bold>Hello</bold></bold></text>
    """)
document.descendants("bold").forEach { b in b.replace { b.content } }
document.echo()
```

But the output is:

```text
<text><bold>Hello</bold></text>
```

If you would like to also iterate over the inserted content, use `follow: true` in the call to `replace`. E.g. in the last example:

```Swift
...
document.descendants("bold").forEach { b in b.replace(follow: true) { b.content } }
...
```

The output then becomes:

```text
<text>Hello</text>
```

## Handling of text

Subsequent text nodes (`XText`) are always automatically combined, and text nodes with empty text are automatically removed.

This can be very convenient when processing text, e.g. it is then very straightforward to apply regular expressions to the text in a document. But there might be some stumbling blocks involved here, when the different behaviour of text nodes and other nodes affects the result of your manipulations.

You can avoid merging of text `text` with other texts by setting the `isolated` property to `true` (you can also choose to set this value during initialization of an XText). Consider the following example where the occurrences of a search text gets a greenish background. In this example, you do not want `part` to be added to `text` in the iteration:

```Swift
let searchText = "world"

document.traverse { node in
    if let text = node as? XText {
        if text.value.contains(searchText) {
            text.isolated = true
            var addSearchText = false
            text.value.components(separatedBy: searchText).forEach { part in
                text.insertPrevious {
                    addSearchText ? XElement("span", ["style": "background:LightGreen"]) {
                        searchText
                    } : nil
                    part
                }
                addSearchText = true
            }
            text.remove()
            text.isolated = false
        }
    }
}

document.echo()
```

Output:

```text
<a>Hello <span style="background:LightGreen">world</span>, the <span style="background:LightGreen">world</span> is nice.</a>
```

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
    
    XRule(forElements: "formula") { element in
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
    
    XRule(forElements: "image") { element in
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
    
    XRule(forAttributes: "id") { id in
        print("\n----- Rule for attribute \"id\" -----\n")
        print("  \(id.element) --> ", terminator: "")
        id.element["id"] = "done-" + id.value
        print(id.element)
    }
    
}

transformation.execute(inDocument: document)

print("\n----------------------------------------\n")

document.echo()
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

A transformation can be stopped by calling `stop()` on the transformation, although that only works indirectly:

```Swift
var transformationAlias: XTransformation? = nil

let transformation = XTransformation {
    
    XRule(forElements: "a") { _ in
        transformationAlias?.stop()
    }
    
}

transformationAlias = transformation

transformation.execute(inDocument: myDocument)
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

## Handling of namespaces

The library is very strong when it comes to tracking element or attributes of a certain name and in that respect coping with manipulations of the XML tree. Adding an additional layer by supporting namespace directly by the library would make the implementaion of the library more complicated and less efficient. Let us see then how one would then handle XML documents which are using namespaces.

### How to handle namespaces

First, you can always look up the namespace prefix settings (attributes `xmlns:...`) in your document. When you then like to change element in that namespace, add this prefix dynamically in your code:


```Swift
let transformation = XTransformation {
    
    XRule(forElements: "\(myprefix):a") { a in
        ...
    }
    
    ...
```

Also, in most applications you have control over the namespace prefixes, so you do not even need to handle the prefix dynamically in those cases.

### Using async/await

You can use `traverse` with closures using `await`. And you can use the `async` property of the [Swift Async Algorithms package](https://github.com/apple/swift-async-algorithms) (giving a `AsyncLazySequence`) to apply `map` etc. with closures using `await` (e.g. `element.children.async.map { await a.f($0) }`).

Currently the SwiftXML packages defined a `forEachAsync` method for closure arguments using `await`, but this method might be removed in future versions of the package if the Swift Async Algorithms package should define it for `AsyncLazySequence`.

### Possible future directions

Although we do not think that a special treatment of namespaces by the library is necessary, we certainly could add some features in case our current approach should prove to be insufficient. The following possibilities immediately come to mind:

1. Add support for namespaces in the whole handling of element and attribute names (in a transparent way). As explained above, this would make the library more complicated and less efficient, but the library should then still be very efficient in comparsion to other libraries.
2. Add some helper functions e.g. for understanding the prefix settings in the document.
