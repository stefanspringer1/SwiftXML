# SwiftXML

A library written in Swift to process XML.

This library is published under the Apache License v2.0 with Runtime Library Exception.

```swift
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
        for cell in tablePart.children("tr").children("th") {
            cell.name = "td"
       }
    }
    
    XRule(forRegisteredAttributes: "label") { label in
        label.element["label"] = label.value + ")"
    }

}
```

---
**NOTE**

**This library is not in a “final” state yet** despite its high version number, i.e. there might still be bugs, or some major improvements will be done, and breaking changes might happen without the major version getting augmented. Addionally, there will be more comments in the code. Also, when such a final state is reached, the library might be further developed using a new repository URL (and the version number set back to a lower one). Further notice will be added here. See [there](https://stefanspringer.com) for contact information.

**We plan for a final release in early 2025.** (This library will then already be used in a production environment.) For all who are already been interested in this library, thank you for your patience!

**UPDATE 1 (May 2023):** We changed the API a little bit recently (no more public `XSpot`, but you can set `isolated` for `XText`) and fixed some problems and are currently working on adding more tests to this library and to the `SwiftXMLParser`.

**UPDATE 2 (July 2023):** In order to keep the XML tree small **we removed the ability to directly access the attributes of a certain name in a document,** and accordingly also to formulate rules for attributes (rules for attributes were rarely used in applications). Instead of directly accessing attributes of certain names, you will have to inspect the descendants of a document (if not catching according events during parsing), maybe saving the result. _An easier replacement for the lost functionality will be available when we add a validation tool:_ When using an appropriate schema you will then be able to look up which elements – according to the schema – could have a certain attribute set, and you can then access these elements directly.

**UPDATE 3 (July 2023):** Renamed `havingProperties` to `conformingTo`.

**UPDATE 4 (July 2023):** The namespace handling is now in a conclusive state, see the new section about limitations of the XML input and the changed section on how to handle XML namespaces.

**UPDATE 5 (July 2023):** In order to further streamline the library, the functionality for tracking changes (of attributes) was removed. In most cases when you have to track changes you need a better way of setting those attributes, so there was a burden whenever setting attributes, but without much use.

**UPDATE 6 (August 2023):** Renamed `conformingTo` to `when`.

**UPDATE 7 (August 2023):** In order to conform to some type checks in Swift 5.9, we have to demand macOS 13, iOS 16, tvOS 16, or watchOS 9 for Apple platforms.

**UPDATE 8 (August 2023):** Renamed `applying` to `with`.

**UPDATE 9 (September 2023):** Renamed `with` to `applying` again. Renamed `when` to `fullfilling`. Renamed `hasProperties` to `fullfills`. Their implementations for a single items is now done via protocols.

**UPDATE 10 (October 2023):** Instead of `element(ofName:)` use `element(_:)` to better match the other methods that take names.

**UPDATE 11 (October 2023):** Instead of `XProduction`, `XProductionTemplate` and `XActiveProduction` are now used, see the updated description below.

**UPDATE 11 (October 2023):** Dropping the “X” prefix for implementations of `XProductionTemplate` and `XActiveProduction`.

**UPDATE 12 (October 2023):** `XNode.write(toFile:)` is renamed to `XNode.write(toPath:)`, and `XNode.write(toFileHandle:)` is renamed to `XNode.write(toFile:)`.

**UPDATE 13 (December 2023):** `texts` is renamed to `immediateTexts` so as not to confuse it with `allTexts`, and `text` is renamed to `allTextsCollected`. `immediateTextsCollected` and the `allTextsReversed` variants are added.

**UPDATE 14 (December 2023):** The subscript notation with integer values for a sequence of XContent, XElement, or XText now starts counting at 1.

**UPDATE 15 (December 2023):** `immediateTextsCollected` is removed.

**UPDATE 16 (December 2023):** The method `child(...)` is renamed to `firstChild(...)`.

**UPDATE 17 (December 2023):** Added some tracing capabilities for complex transformations.

**UPDATE 18 (January 2024):** `XContentLike` is renamed to `XContentConvertible`. When using SwiftXML, a new type can conform to `XContentConvertible` and as such then can be inserted as XML. The `asContent` property is not necessary any more and is removed, and `... as XContentConvertible` (previously `... as XContentLike`) should also not be necessary any more.

**UPDATE 19 (March 2024):** `description` add quotation marks for `XText`.

**UPDATE 20 (May 2024):** Renamed `allTextsCollected` to `allTextsCombined`.

**UPDATE 21 (September 2024):** When creating a document, you may specify attribute names to be registered (again). Removed `extension FileHandle: TextOutputStream`.

**UPDATE 22 (October 2024):** More `...IncludingSelf` versions for iterations, e.g. `nextElementsIncludingSelf`.

**UPDATE 22 (October 2024):** By default, an internal entity resolver now has to resolve all entities presented to him.

**UPDATE 23 (October 2024):** Added `...Close...` versions e.g. `nextCloseElements`.

**UPDATE 24 (November 2024):** Use `hasNext` and `hasPrevious` instead of `hasNextTouching` ans `hasPreviousTouching`.

**UPDATE 25 (November 2024):** Use properties `clone` and `shallowCLone` instead of methods `clone()` and `shallowCLone()`.

**UPDATE 26 (November 2024):** HTML production: Renamed `suppressPrettyPrintBeforeLeadingAnchor` to `suppressUncessaryPrettyPrintAtAnchors`.

**UPDATE 27 (November 2024):** Remamed `backLink` to `backlink` and `finalBackLink` to `finalBacklink`. New methods `setting(backlink:)` and `copyingBacklink(from:)`.

**UPDATE 28 (December 2024):** New: `immediateTextsCombined`.

**UPDATE 29 (January 2025):** New: `backlinkOrSelf`.

**UPDATE 30 (February 2025):** New `namespaceAware:` in call to parse functions (default value is `false`).

**UPDATE 31 (March 2025):** You can now use the builder notation for CDATA sections and comments.

**UPDATE 32 (March 2025):** New property `prefixAndName` of `XElement`.

**UPDATE 33 (March 2025):** Removed property `prefixAndName` of `XElement`, added `XElement.has(prefix:name:)` instead.

**UPDATE 34 (April 2025):** Introduced registering of attribute values (e.g. `document.registeredValues("1", forAttribute: "id")`).

**UPDATE 35 (April 2025):** New: `XDocument.clone(keepAttachments:registeringAttributes:registeringValuesForAttributes:)`, `XElement.clone(keepAttachments:)`; added those arguments also to `makeVersion()`.

**UPDATE 35 (May 2025):** New additional second (!) argument `until: ...` or `while: ...` e.g. in `myElement.ancestors("x", until: { $0 === stop }`.

**UPDATE 36 (June 2025):** Namespaces at elements should now be completely handled. In particular, when elements have prefixes which do not reference a defined namespace (we call them “dead” prefixes), those prefixes are preserved in the name without notice and possible conflicts with defined prefixes avoided. (Namespaces at attributes are still not processed, this should be implemented in an upcoming version.)

**UPDATE 37 (July 2025):** Removed the `NamespaceReference` enumeration, dispense with the according argument for the HTZML production (use namespace awareness instead if nevcessary).

**UPDATE 38 (July 2025):** Renamed `recognizeNamespaces` to `namespaceAware` and renamed `noPrefixForPrefixlessNamespaceAtRoot` to `silentEmptyRootPrefix`.

**UPDATE 39 (July 2025):** New argument `suppressDeclarationForNamespaceURIs:` in the output methods. (An `XProductionTemplate` has to offer the according argument `declarationSupressingNamespaceURIs:` in its `activeProduction` method.)

**UPDATE 40 (July 2025):** Namespaces for attributes are now added (although some more tests should be added), but no registering of such attributes yet.

**UPDATE 41 (July 2025):** Registering of attributes with namespaces are now added, and some more tests.

**UPDATE 42 (August 2025):** More efficient FileWriter; FileWriter and CollectingWriter not public.

---

## Related packages

### The `LoopsOnOptionals` package

For-in loops do not work on optionals e.g. optional chains in Swift. But when working with this XML libary being able to do so might be convenient at times. In order to be able to loop on optionals, include the very small `LoopsOnOptionals` package from https://github.com/stefanspringer1/LoopsOnOptionals.

When having the following extension to `XDocument`:

```swift
extension XDocument {
   var metaDataSection: XElement? { ... }
}
```

then with the `LoopsOnOptionals` package you can write:

```swift
for metaDataItem in myDocument.metaDataSection?.children("item") {
    ...
}
```

Of course, especially in this simple case you can express the same as follows, without using the `LoopsOnOptionals` package:

```swift
if let metaDataSection = myDocument.metaDataSection {
    for metaDataItem in metaDataSection.children("item") {
        ...
    }
}
```

But even more so in more complex situations, the introduction of such a `if let` (or `case let`) expression makes the code harder to understand.


### The `Workflow` package

When using SwiftXML in the context of the [SwiftWorkflow](https://github.com/stefanspringer1/SwiftWorkflow) framework, you might include the [WorkflowUtilitiesForSwiftXML](https://github.com/stefanspringer1/WorkflowUtilitiesForSwiftXML).

## Properties of the library

The library reads XML from a source into an XML document instance, and provides methods to transform (or manipulate) the document, and others to write the document to a file.

The library should be efficient and applications that use it should be very intelligible.

### Limitations

- The encoding of the source must be UTF-8 (ASCII is considered as a subset of it). (So no UTF-16 as required by the XML standard is supported.) The parser checks for correct UTF-8 encoding and also checks (according to the data available to the currently used Swift implementation) if a found codepoint is a valid Unicode codepoint.
- Currently no Unicode character normalization is done, even if the declared XML version is 1.1.
- In the current state of the library, no namespace handling of attributes is available.
- Validation of an XML tree against an XML schema is not available yet (you might use [Libxml2Validation](https://github.com/stefanspringer1/Libxml2Validation) instead).

### Manipulation of an XML document

Other than some other libraries for XML, the manipulation of the document as built in memory is “in place”, i.e. no new XML document is built. The goal is to be able to apply many isolated manipulations to an XML document efficiently. But it is always possible to clone a document easily with references to or from the old version.

The following features are important:

- All iteration over content in the document using the according library functions are lazy by default, i.e. the iteration only looks at one item at a time and does not (!) collect all items in advance.
- While lazily iterating over content in the document in this manner, the document tree can be changed without negatively affecting the iteration.
- Elements of a certain name can be efficiently found without having to traverse the whole tree. An according iteration proceeds in the order by which the elements have been added to the document. When iterating in this manner, newly added elements are then also processed as part of the same iteration.

The following code takes any `<item>` with an integer value of `multiply` larger than 1 and additionally inserts an item with a `multiply` number one less, while removing the `multiply` value on the existing item (the library will be explained in more detail in subsequent sections):

```swift
let document = try parseXML(fromText: """
<a><item multiply="3"/></a>
""")

for item in document.elements("item") { in
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

```swift
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

For any error during parsing an error is thrown and no document is then provided.

An XML tree (e.g. a document) must not be examined or changed concurrently.

---
**NOTE**

The description of the library that follows might not include all types and methods. Please see the documentation produced by DocC or use autocompletion in an according integrated development environment (IDE).

---

## Reading XML

The following functions take a source and return an XML document instance (`XDocument`). The source can either be provided as a URL, a path to a file, a text, or binary data.

Reading from a URL which references a local file:

```swift
func parseXML(
    fromURL url: URL,
    namespaceAware: Bool = false,
    silentEmptyRootPrefix: Bool = false,
    registeringAttributes: AttributeRegisterMode = .none,
    registeringAttributeValuesFor: AttributeRegisterMode = .none,
    registeringAttributesForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    registeringAttributeValuesForForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    internalEntityResolverHasToResolve: Bool = true,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil,
    immediateTextHandlingNearEntities: ImmediateTextHandlingNearEntities = .atExternalEntities
) throws -> XDocument 
```

And accordingly:

```swift
func parseXML(
    fromPath: String,
    ...
) throws -> XDocument
```

```swift
func parseXML(
    fromText: String,
    ...
) throws -> XDocument
```

```swift
func parseXML(
    fromData: Data,
    ...
) throws -> XDocument
```

If you want to be indifferent about which kind of source to process, use `XDocumentSource` for the source definition and use:

```swift
func parseXML(
    from: XDocumentSource,
    ...
) throws -> XDocument
```

The optional `textAllowedInElementWithName` method gets the name of the surrounding element when text is found inside an element and should notify whether text is allowed in the specific context. If not, the text is discarded is it is whitespace. If no text is allowed in the context but the text is not whitespace, an error is thrown. If you need a more specific context than the element name to decide if text is allowed, use an `XEventHandler` to track more specific context information.

All internal entity references in attribute values have to be replaced by text during parsing. In order to achieve this (in case that internal entity references occur at all in attribute values in the source), an `InternalEntityResolver` can be provided. An `InternalEntityResolver` has to implement the following method:

```swift
func resolve(
    entityWithName: String,
    forAttributeWithName: String?,
    atElementWithName: String?
) -> String?
```

This method is always called when a named entity reference is encountered (either in text or attribute) which is scored as an internal entity. It either returns the textual replacement for the entity or it does not resolve the entity by returning `nil`. By default, the resolver has to resolve all entities presented to it, else an according error is thrown. You can remove this enforcement by setting `internalEntityResolverHasToResolve: false` in the call of the parse function; then, when the resolver returns `nil`, the entity reference is not replaced by a text, but is kept withput any further notice. In the case of a named entity in an attribute value, an error is always thrown when no replacement is given. The function arguments `forAttributeWithName` (name of the attribute) and `atElementWithName` (name of the element) have according values if and only if the entity is encountered inside an attribute value.

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

```swift
func echo(pretty: Bool, indentation: String, terminator: String)
```

`pretty` defaults to `false`; if it is set to `true`, linebreaks and spaces are added for pretty print. `indentation` defaults to two spaces, `terminator` defaults to `"\n"`, i.e. a linebreak is then printed after the output.

With more control:

```swift
func echo(usingProductionTemplate: XProductionTemplate, terminator: String)
```

Productions are explained in the next section.

When you want a serialization of a whole tree or document as text (`String`), use the following method:

```swift
func serialized(pretty: Bool) -> String
```

`pretty` again defaults to `false` and has the same effect.

With more control:

```swift
func serialized(usingProductionTemplate: XProductionTemplate) -> String
```

Do not use `serialized` to print a tree or document, use `echo` instead, because using `echo` is more efficient in this case.

## Writing XML

Any XML node (including an XML document) can be written, including the tree of nodes that is started by it, via the following methods.

```swift
func write(toURL: URL, usingProductionTemplate: XProductionTemplate) throws
```

```swift
func write(toPath: String, usingProductionTemplate: XProductionTemplate) throws
```

```swift
func write(toFile: FileHandle, usingProductionTemplate: XProductionTemplate) throws
```

```swift
func write(toWriter: Writer, usingProductionTemplate: XProductionTemplate) throws
```

You can also use the `WriteTarget` protocol to allow all the above possiblities:

```swift
func write(to writeTarget: WriteTarget, usingProductionTemplate: XProductionTemplate) throws
```

By the argument `usingProductionTemplate:` you can define a production, i.e. details of the serialization, e.g. if linebreaks are inserted to make the result look pretty. Its value defaults a an instance of `XActiveProductionTemplate`, which will give a a standard output.

The definition of such a production comes in two parts, a template that can be initialized with values for a further configuration of the serialization, and an active production which is to be applied to a certain target. This way the user has the ability to define completely what the serialization should look like, and then apply this definition to one or several serializations. In more detail:

A `XProductionTemplate` has a method `activeProduction(for writer: Writer) -> XActiveProduction` which by using the `writer` initializes an `XActiveProduction` where the according events trigger a writing to the `writer`. The configuration for such a production are to be provided via arguments to the initializer of the `XProductionTemplate`.

So an `XActiveProduction` defines how each part of the document is written, e.g. if `>` or `"` are written literally or as predefined XML entities in text sections. The production in the above function calls defaults to an instance of `DefaultProductionTemplate` which results in instances of `ActiveDefaultProduction`. `ActiveDefaultProduction` should be extended if only some details of how the document is written are to be changed. The productions `ActivePrettyPrintProduction` (which might be used by defining an `PrettyPrintProductionTemplate`) and `ActiveHTMLProduction` (which might be used by defining an `HTMLProductionTemplate`) already extend `ActiveDefaultProduction`, which might be used to pretty-print XML or output HTML. But you also extend one of those classes youself, e.g. you could override `func writeText(text: XText)` and `func writeAttributeValue(name: String, value: String, element: XElement)` to again write some characters as named entity references. Or you just provide an instance of `DefaultProduction` itself and change its `linebreak` property to define how line breaks should be written (e.g. Unix or Windows style). You might also want to consider `func sortAttributeNames(attributeNames: [String], element: XElement) -> [String]` to sort the attributes for output.

Example: write a linebreak before all elements:

```swift
class MyProduction: DefaultProduction {

    override func writeElementStartBeforeAttributes(element: XElement) throws {
        try write(linebreak)
        try super.writeElementStartBeforeAttributes(element: element)
    }

}

try document.write(toFile: "myFile.xml", usingProduction: MyProduction())
```

For generality, the following method is provided to apply any `XActiveProduction` to a node and its contained tree:

```swift
func applyProduction(activeProduction: XActiveProduction) throws
```

## Cloning and document versions

Any node (including an XML document) can be cloned, including the tree of nodes that is started by it, using the following method:

```swift
var clone: XNode
```
(The result will be more specific if the subject is known to be more specific.)

By default, the clone of a document will register the same attributes and values, but by default clones loose their attachments. You can change this by calling `clone(keepAttachments:registeringAttributes:registeringValuesForAttributes:)` for a document or `clone(keepAttachments:)` for an element. (Those arguments have default values which produce the defaut behaviour, use `nil` for the to `AttributeRegisterMode` values to achieve this explicitly.) Those argument are also available for `makeVersion().

Any content and the document itself possesses the property `backlink` that can be used as a relation between a clone and the original node. If you create a clone by using the `clone` property, the `backlink` value of a node in the clone points to the original node. So when working with a clone, you can easily look at the original nodes.

(A backlink might also be set manuallay by the methods `setting(backlink:)` or `copyingBacklink(from:)`, which might come in handy in transformations.)

Note that the `backlink` reference references the original node weakly, i.e. if you do not save a reference to the original node or tree then the original node disapears and the `backlink` property will be `nil`.

If you would like to use cloning to just save a version of your document to a copy, use its following method:

```swift
func makeVersion()
```

In that case a clone of the document will be created, but with the `backlink` property of an original node pointing to the clone, and the `backlink` property of the clone will point to the old `backlink` value of the original node. I.e. if you apply `saveVersion()` several times, when following the `backlink` values starting from a node in your original document, you will go through all versions of this node, from the newer ones to the older ones. The `backlinks` property gives you exactly that chain of backlinks. Other than when using `clone`, a strong reference to such a document version will be remembered by the document, so the nodes of the clone will be kept. Use `forgetVersions(keeping:Int)` on the document in order to stop this remembering, just keeping the last number of versions defined by the argument `keeping` (`keeping` defaults to 0). In the oldest version then still remembered or, if no remembered version if left, in the document itself all `backlink` values will then be set to `nil`.

The `finalBacklink` property follows the whole chain of `backlink` values and gives you the last value in this chain.

Sometimes, only a “shallow” clone is needed, i.e. the node itself without the whole tree of nodes with the node as root. In this case, just use:

```swift
func shallowClone(forwardref: Bool) -> XNode
```

The `backlink` is then set just like when using `clone`.

The property `backlinkOrSelf` gives the backlink or – it it is `nil` – the subject itself.

## Content properties

### Source range

If the parser (as it is the case with the [SwiftXMLParser](https://github.com/stefanspringer1/SwiftXMLParser)) reports the where a part of the document it is in the text (i.e. at what line and column it starts and at what line and column it ends), the property `sourceRange: XTextRange` (using `XTextRange` from [SwiftXMLInterfaces](https://github.com/stefanspringer1/SwiftXMLInterfaces)) returns it for the respective node:

Example:

```swift
let document = try parseXML(fromText: """
<a>
    <b>Hello</b>
</a>
""", textAllowedInElementWithName: { $0 == "b" })

for content in document.allContent {
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

```swift
// setting the "id" attribute to "1":
myElement["id"] = "1"

// reading an attribute:
if let id = myElement["id"] {
    print("the ID is \(id)")
}
```

You can also get a sequence of attribute values (optional Strings) from a sequence of elements.

Example:

```swift
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

If you want to get an attribute value and at the same time remove the attribute, use the method `pullAttribute(...)` of the element.

To get the names of all attributes of an element, use:

```swift
var attributeNames: [String]
```

Note that you also can a (lazy) sequence of the attribute values of a certain attribute name of a (lazy) sequence of elements by using the same index notation:

```swift
print(myElement.children("myChildName")["myAttributeName"].joined(separator: ", "))
```

### Attachments

All nodes can have “attachments”. Those are objects that can be attached via a textual key. Those attachments are not considered as belonging to the formal XML tree.

Those attachements are realized as a dictionary `attached` as a member of each node.

You can also set attachments immediately when creating en element or a document by using the argument `attached:` of the initializer. (Note that in this argument, some values might be `nil` for convenience.)

### XPath

Get the XPath of a node via:

```swift
var xPath: String
```

## Traversals

Traversing a tree depth-first starting from a node (including a document) can be done by the following methods:

```swift
func traverse(down: (XNode) throws -> (), up: ((XNode) throws -> ())? = nil) rethrows
```

```swift
func traverse(down: (XNode) async throws -> (), up: ((XNode) async throws -> ())? = nil) async rethrows
```

For a “branch”, i.e. a node that might contain other nodes (like an element, opposed to e.g. text, which does not contain other nodes), when returning from the traversal of its content (also in the case of an empty branch) the closure given the optional `up:` argument is called.

Example:

```swift
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

Note that the root of the traversal is not to be removed during the traversal.

## Direct access to elements

As mentioned and the general description, the library allows to efficiently find elements of a certain name in a document without having to traverse the whole tree.

Finding the elements of a certain name:

```swift
func elements(prefix:_: String...) -> XElementsOfSameNameSequence
```

Example:

```swift
for paragraph in myDocument.elements("paragraph") {
    if let id = paragraph["id"] {
        print("found paragraph with ID \"\(ID)\"")
    }
}
```

Find the elements of several name alternatives by using several names in the according argument. Note that just like the methods for single names, what you add during the iteration will then also be considered.

You can also use a prefix in the first (optional) argument for direct access to elements having a certain prefix (if you use `nil` as the value of this argument, the according elements that do not have a prefix are found). See more about prefixes in the section “Prefixes and namespaces” below.

## Direct access to attributes

To directly find where an attribut with a certain name is set, you can use an analogue to the direct access to elements, but for efficiency reason you have to specify the attribute names which can be used for such a direct access. You specify these attribute names when creating a document (e.g. `XDocument(registeringAttributes: .selected(["id", "label"]))`) or indirecting when using the parse functions (e.g. `try parseXML(fromText: "...", registeringAttributes: .selected(["id", "label"]))`). You can also register attributes for a certain namespace or a prefix and then list them by additionally using the `prefix:` argument, see the section on prefixes and namespaces.

Example:

```swift
let document = try parseXML(fromText: """
    <test>
      <x a="1"/>
      <x b="2"/>
      <x c="3"/>
      <x d="4"/>
    </test>
    """, registeringAttributes: .selected(["a", "c"]))

let registeredAttributesInfo = document.registeredAttributes("a", "b", "c", "d").map{ "\($0.name)=\"\($0.value)\" in \($0.element)" }.joined(separator: ", ")
print(registeredAttributesInfo) // "a="1" in <x a="1">, c="3" in <x c="3">"

let allValuesInfo = document.elements("x").compactMap{
    if let name = $0.attributeNames.first, let value = $0[name] { "\(name)=\"\(value)\" in \($0)" } else { nil }
}.joined(separator: ", ")
print(allValuesInfo) // "a="1" in <x a="1">, b="2" in <x b="2">, c="3" in <x c="3">, d="4" in <x d="4">"
```

You can register attributes _values_ by using the argument `registeringValuesForAttributes:` when parsing or creating a document:

```swift
let source = """
    <a>
        <b id="1"/>
        <b id="2"/>
        <b refid="1">First reference to "1".</b>
        <b refid="1">Second reference to "1".</b>
    </a>
    """

let document = try parseXML(fromText: source, registeringValuesForAttributes: .selected(["id", "refid"]))

print(#"id="1":"#)
print(document.registeredValues("1", forAttribute: "id").map{ $0.element.description }.joined(separator: "\n"))
print()
print(#"refid="1":"#)
print(document.registeredValues("1", forAttribute: "refid").map{ $0.element.serialized() }.joined(separator: "\n"))
```

Result:

```text
id="1":
<b id="1">

refid="1":
<b refid="1">First reference to "1".</b>
<b refid="1">Second reference to "1".</b>
```

If the value according to an attribute name should be unique, find the according element by::

```swift
if let element = document.registeredValues("1", forAttribute: "id").first?.element {
    ...
}
```

---
**NOTE**

- `document.registeredAttributes("id")` or `document.registeredAttributes("refid")` would give you an empty sequence in the above example, you would have to add `registeringAttributes: .selected(["id", "refid"]))` to also find these attributes by name only.
- As `registeredValues(forAttribute:)` returns a lazy sequence that also considers new values that are set during its iteration, you might first make an array out of the sequence via `ArrayArray(document.registeredValues(...))` if you plan to change the according values.
- It was decided not to introduce rules for attribute values for the time being.

---

## Finding related content

Starting from some content, you might want to find related content, e.g. its children. The names chosen for the accordings methods come from the idea that all content have a natural order, namely the order of a depth-first traversal, which is the same order in which the content of an XML document is stored in a text file. This order gives a meaning to method names such a `nextTouching`. Note that, other than for the iterations you get via `elements(_:)`, even nodes that stay in the same document can occur in such an iteration sevaral times if moved accordingly during the iteration.

Sequences returned are always lazy sequences, iterating through them gives items of the obvious type. As mentioned in the general description of the library, manipulating the XML tree during such an iteration is allowed.

Finding the document the node is contained in:

```swift
var document: XDocument?
```

Finding the parent element:

```swift
var parent: XElement?
```

All its ancestor elements:

```swift
var ancestors: XElementSequence
```

Get the first content of a branch:

```swift
var firstContent: XContent?
```

Get the last content of a branch:

```swift
var lastContent: XContent?
```

If there is exactly one node contained, get it, else get `nil`:

```swift
var singleContent: XContent?
```

The direct content of a document or an element (“direct” means that their parent is this document or element):

```swift
var content: XContentSequence
```

The direct content that is an element, i.e. all the children:

```swift
var children: XElementSequence
```

The direct content that is text:

```swift
var immediateTexts: XTextSequence
```

For the `content` and `children` sequences, there also exist the sequences `contentReversed`, `childrenReversed`, and `immediateTextsReversed` which iterate from the last corresponding item to the first.

All content in the tree of nodes that is started by the node itself, without the node itself, in the order of a depth-first traversal:

```swift
var allContent: XContentSequence
```

All content in the tree of nodes that is started by the node, starting with the node itself:

```swift
var allContentIncludingSelf: XContentSequence
```

All texts in the tree:

```swift
var allTexts: XTextSequence
```

The descendants, i.e. all content in the tree of nodes that is started by the node, without the node itself, that is an element:

```swift
var descendants: XElementSequence
```

If a node is an element, the element itself and the descendants, starting with the element itself:

```swift
var descendantsIncludingSelf: XElementSequence
```

All texts in the tree of nodes that is started by the node itself, without the node itself, in the order of a depth-first traversal:

```swift
var allTexts: XTextSequence
```

The same but only for the nodes contained as direct content:

```swift
var immediateTexts: XTextSequence
```

The (direct) content of an branch (element or document) are “siblings” to each other.

The content item previous to the subject:

```swift
var previousTouching: XContent?
```

The content item next to the subject:

```swift
var nextTouching: XContent?
```

(Note that for autocompletion it might be better to start type “touch...” instead of “prev...” or “next...”.)

You might also just be interested if a previous or next node exists:

```swift
var hasPrevious: Bool
var hasNext: Bool
```

The following very short method names `previous` and `next` actually mean “the previous content” and “the next content”, repectively. Those method names are chosen to be so short because they are such a common use case.

All nodes previous to the node (i.e. the previous siblings) _on the same level,_ i.e. of the same parent, in the order from the node:

```swift
var previous: XContentSequence
```

Of those, the ones that are elements:

```swift
var previousElements: XElementSequence
```

Analogously, the content next to the node:

```swift
var next: XContentSequence
```

Of those, the ones that are elements:

```swift
var nextElements: XElementSequence
```

`nextElements` and `previousElements` skip any non-elements. If you want to find elements with no non-elements in-between, use `nextCloseElements` and `previousCloseElements`.

---
**NOTE**

Remember that the versions without `...Close...` simply ignore all other node types in between.

---

There are also `...IncludingSelf` versions where the subject is included, e.g. `nextElementsIncludingSelf`.

Example:

```swift
for descendant in myElement.descendants {
    print("the name of the descendant is \(descendant.name)")
}
```

Note that a sequence might be used several times:

```swift
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

```swift
var exist: Bool
```

Note that after using `exist`, you can still iterate normally along the same sequence, without loosing an item.

Test if nothing exists in a sequence by using `absent`:

```
var absent: Bool
```

If you would like to test if certain items exist, and many cases you would also then use those items. The property `existing` of a sequence of content or elements returns the sequence itself if items exist, and `nil` otherwise:

```swift
var existing: XContentSequence?
var existing: XElementSequence?
```

In the following example, a sequence is first tested for existing items and, if items exist, then used:

```swift
let document = try parseXML(fromText: """
<a><c/><b id="1"/><b id="2"/><d/><b id="3"/></a>
""")

if let theBs = document.descendants("b").existing {
    theBs.echo()
}
```

Note that what you get by using `existing` still is a lazy sequence, i.e. if you change content between the `existing` test and using its result, then there might be no more items left to be found.

You may also ask for the previous or next content item in the tree, in the order of a depth-first traversal. E.g. if a node is the last node of a subtree starting at a certain element and the element has a next sibling, this next sibling is “the next node in the tree” for that last node of the subtree. Getting the next or previous node in the tree is very efficient, as the library keep track of them anyway.

The next content item in the tree:

```swift
var nextInTreeTouching: XContent?
```

The previous content item in the tree:

```swift
var previousInTreeTouching: XContent?
```

Find all text contained the tree of a node and compose them into a single `String`:

```swift
var allTextsCombined: String
```

You may use these text collecting properties even when you know that there is only one text to be “combined”, this case is efficiently implemented.

You might also turn a single content item or, more specifically, an element into an appropriate sequence using the following methods:

For any content:

```swift
var asSequence: XContentSequence
```

For an element:

```swift
var asElementSequence: XElementSequence
```

(These two methods are used in the tests of the library.)

## Finding related nodes with filters

Besides methods like `filter(_:)` and `prefix(while:)` that always come with Swift and that can be applied to the sequences defined by SwiftXML, the methods from SwiftXML for finding related nodes like `descendants` offer arguments for filtering and stop conditions that allow a short and concise notation, especially when a filter and a stop condition is combined.

In principle, we distinguish between the case of all items of the sequence fullfilling a condition, the case of all items while a condition is fullfilled, and the case of all items until a condition is fullfilled (excluding the found item where the condition fullfilled:

```swift
func content((XContent) -> Bool) -> XContentSequence
func content(while: (XContent) -> Bool) -> XContentSequence
func content(until: (XContent) -> Bool) -> XContentSequence
func content(untilAndIncluding: (XContent) -> Bool) -> XContentSequence
```

Sequences of a more specific type are returned in sensible cases. The `untilAndIncluding` version also stops where the condition is fullfilled, but _includes_ the according item.

Example:

```swift
let document = try parseXML(fromText: """
<a><b/><c take="true"/><d/><e take="true"/></a>
""")

for descendant in document.descendants({ element in element["take"] == "true" }) {
    print(descendant)
}
```

Output:
```text
<c take="true">
<e take="true">
```

Note that the round parentheses “(...)” around the condition in the example is needed to distinguish it from the `while:` and `until:` versions. (There is no `where:` argument name, because without it the less common case `while:` – and to a lesser degree `until:` – is more easily visually distinguished from it, the more common case being syntactically the shortest. This plays out well in actual code.)

There exist a shortcut for the common of filtering elements according to a name:

```swift
for _ in document.descendants("paragraph") {
    print("found a paragraph!")"
}
```

You can also use multiple names (e.g. `myElement.descendants("paragraph", "table")`).

In some cases, the filtering of nodes can be stopped according to an additional condition: e.g. `myElement.ancestors("x", until: { $0 === stop })` which is equivalent to `myElement.ancestors(until: { $0 === stop }).filter({ $0.name == "x" })`.  There also exist the according `while: ...` versions.

If you do not list any element names in methods like `descendants()` or `children()`, it lists elements independently of their names, but other than e.g. `descendants`, it only lists elements without prefix (cf. the section about prefixes and namespaces).

---
**NOTE**

Note that `nextElements("paragraph")` (filtering the next elements by name) is different from `nextElements(while: { $0.name == "paragraph" })`.

---

If you know that there at most one child element with a certain name, use the following method (it returns the first child with this name if it exist):

```swift
func firstChild(_ name: String) -> XElement?
```

You might then also consider alternative names (giving you the first child where the name matches):

```swift
func firstChild(_ names: String...) -> XElement?
```

If you want to get the first ancestor with a certain name, use one of the following methods:

```swift
func ancestor(_ name: String) -> XElement?
func ancestor(_ names: String...) -> XElement?
```

## Chained iterators

Iterators can also be chained. The second iterator is executed on each of the node encountered by the first iterator. All this iteration is lazy, so the first iterator only searches for the next node if the second iterator is done with the current node found by the first iterator.

Example:

```swift
let document = try parseXML(fromText: """
<a>
    <b>
        <c>
            <d/>
        </c>
    </b>
</a>
""")

for element in document.descendants.descendants { print(element) }
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

Also, in those chains operations finding single nodes when applied to a single node like `parent` also work, and you can use e.g. `insertNext` (see the section on tree manipulations), or `with` (see the next section on constructing XML), or `echo()`.

When using an index with a `String`, you get a sequence of the according attribute values (where set):

```swift
for childID in element.children["id"] {
    print("found child ID \(childID)")
}
```

Note that when using an `Int` as subscript value for a sequence of content, you get the child of the according index:

```swift
if let secondCHild = element.children[2] {
    print("second child: \(secondChild)")
}
```

---
**NOTE**

If you use this subscript notation `[n]` for a sequence of XContent, XElement, or XText, then – despite using integer values – this is not (!) a random access to the elements (each time using such a subscript, the sequence is followed until the according item is found by counting), and the counting starts at 1 as in the XPath language, and not at 0 as e.g. for Swift arrays.

You should see this integer subscript more as a subscript with names, the integer values being the names that the positions are given in the XML, where counting from 1 is common.

---

## Constructing XML

### Constructing an empty element

When constructing an element (without content), the name is given as the first (nameless) argument and the attribute values are given as (nameless) a dictionary.

Example: constructing an empty “paragraph” element with attributes `id="1"` and `style="note"`:

```swift
let myElement = XElement("paragraph", ["id": "1", "style": "note"])
```

### About the insertion of content

We would first like to give some important hints before we explain the corresponding functionalities in detail.

Note that when inserting content into an element or document and that content already exists somewhere else, the inserted content is _moved_ from its orginal place, and not copied. If you would like to insert a copy, insert the result of using the `clone` property of the content.

Be “courageous” when formulating your code, more might function than you might have thought. Anticipating the explanations in the following sections, e.g. the following code examples _do_ work:

Moving the “a” children and the “b” children of an element to the beginning of the element:

```swift
element.addFirst {
  element.children(“a”)
  element.children(“b”)
}
```

As the content is first constructed and then inserted, there is no inifinite loop here.

Note that in the result, the order of the content is just like defined inside the parentheses `{...}`, so in the example inside the resulting `element` there are first the “a” children and then the “b” children.

Wrap an element with another element:

```swift
element.replace {
   XElement("wrapper") {
      element
   }
}
```

The content that you define inside parentheses `{...}` is constructed from the inside to the outside. From the notes above you might then think that `element` in the example is not as its original place any more when the content of the “wrapper” element has been constructed, before the replacement could actually happen. Yes, this is true, but nevertheless the `replace` method still knows where to insert this “wrapper” element. The operation does work as you would expect from a naïve perspective.

An instance of any type conforming to `XContentConvertible` (it has to implement its `collectXML(by:)` method) can be inserted as XML:

```swift
struct MyStruct: XContentConvertible {
    
    let text1: String
    let text2: String
    
    func collectXML(by xmlCollector: inout XMLCollector) {
        xmlCollector.collect(XElement("text1") { text1 })
        xmlCollector.collect(XElement("text2") { text2 })
    }
    
}

let myStruct1 = MyStruct(text1: "hello", text2: "world")
let myStruct2 = MyStruct(text1: "greeting", text2: "you")

let element = XElement("x") {
    myStruct1
    myStruct2
}

element.echo(pretty: true)
```

Result:

```xml
<x>
  <text1>hello</text1>
  <text2>world</text2>
  <text1>greeting</text1>
  <text2>you</text2>
</x>
```

For `XContentConvertible` there is also the `xml` property that returns an according array of `XContent`.

When constructing CDATA sections and comments, you can aso use the `XCDATASection { ... }` and `XComment { ... }` notation, but only with `String` content.

### Defining content

When constructing an element, its contents are given in parentheses `{...}` (those parentheses are the `builder` argument of the initializer).

```swift
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

```swift
let myElement = XElement("div") {
    XElement("hr")
    myOtherElement.content
    XElement("hr")
}
```

When not defining content, using `map` might be a sensible option:

```swift
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

for content in element.children.map({ $0.children.first }) { print(content?.name ?? "-") }
```

Output:

```text
a1
b1
```

The same applies to e.g. the `filter` method, which, besides letting the code look more complex when used instead of the filter options described above, is not a good option when defining content.

The content of elements containing other elements while defining their content is being built from the inside to the ouside: Consider the following example:

```swift
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

Elements that are part of a document (`XDocument`) are registered in the document. The reason is that this allows fast access to elements respectively attributes of a certain name via `elements(_:)` respectively `attributes(_:)`, and the rules (see the section about rules) use these registers (note that for efficiency reasons, the attribute names to be used in such a way have to be configured when a document is created).

In the moment of constructing a new element with its content defined in `{...}` brackets during construction, the element is not part any document. The nodes inserted to it leave the document tree, but they are not (!) unregistered from the document. I.e. the iteration `elements(_:)` will still find them, and according rules will apply to them. The reason for this behaviour is the common case of the new element getting inserted into the same document. If the content of the new element would first get unregistered from the document and then get reinserted into the same document again, they would then count as new elements, and the mentioned iterations might iterate over them again.

If you would like to get the content a newly built element to get unregistered from the document, use its method `adjustDocument()`. This method diffuses the current document of the element to its content. For a newly built element this document is `nil`, which unregisters a node from its document. You might also set the attribute `adjustDocument` to `true` in the initializer of the element to automatically call `adjustDocument()` when the building of the new element is accomplished. This call or setting to adjust of the document is only necessary at the top-level element, it is dispersed through the whole tree.

Note that if you insert an element into another document that is part of a document, the new child gets registered in the document of its new parent if not already registered there (and unregistered from any different document where it was registered before).

Example: a newly constructed element gets added to a document:

```swift
let document = try parseXML(fromText: """
<a><b id="1"/><b id="2"/></a>
""")

for element in document.elements("b") {
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

```swift
func add(builder: () -> [XContent])
```

Add nodes to the start of the content of an element or a document respectively:

```swift
func addFirst(builder: () -> [XContent])
```

Add nodes as the nodes previous to the node:

```swift
func insertPrevious(_ insertionMode: InsertionMode = .following, builder: () -> [XContent])
```

Add nodes as the nodes next to the node:

```swift
func insertNext(_ insertionMode: InsertionMode = .following, builder: () -> [XContent])
```

A more precise type is returned from `insertPrevious` and `insertNext` if the type of the subject is more precisely known.

By using the next two methods, a node gets removed.

Remove the node from the tree structure and the document:

```swift
func remove()
```

You might also use the method `removed()` of a node to remove the node but also use the node.

Replace the node by other nodes:

```swift
func replace(_ insertionMode: InsertionMode = .following, builder: () -> [XContent])
```

Note that the content that replaces a node is allowed to contain the node itself.

Clear the contents of an element or a document respectively:

```swift
func clear()
```

Test if an element or a document is empty:

```swift
var isEmpty: Bool
```

Set the contents of an element or a document respectively:

```swift
func setContent(builder: () -> [XContent])
```

Example:

```swift
for table in myDocument.elements("table") {
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

Note that by default iterations continue with new nodes inserted by `insertPrevious` or `insertNext` also being considered. In the following cases, you have to add the `.skipping`  directive to get the output as noted below (in the second case, you even get an infinite loop if you do not set `.skipping`):

```swift
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

for content in element.content {
    content.replace(.skipping) {
        content.content
    }
}

element.echo(pretty: true)

print("\n---- 2 ----\n")

for content in element.contentReversed {
    content.insertPrevious(.skipping) {
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

Note that there is no such mechanism to skipping inserted content when not using `insertPrevious`, `insertNext`, or `replace`, e.g. when using `add`. Consider the combination `descendants.add`: there is then no “natural” way to correct the traversal of the tree. (A more common use case would be something like `descendants("table").add { XElement("caption") }`, so this should not be a problem in common cases, but something you should be aware of.)

When using `insertNext`, `replace` etc. in chained iterators, what happens is that the definition of the content in the parentheses `{...}` get _executed_ for each item in the sequence. You might should use the `collect` function to build content specifically for the current item instead. E.g. in the last example, you might use with the same result:

```swift
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

```swift
let e = XElement("a") {
    XElement("b")
    XElement("c")
}

for descendant in e.descendants({ $0.name != "added" }) {
    descendant.add { XElement("added") }
}

e.echo(pretty: true)
```

Output:

```swift
<a>
  <b>
    <added/>
  </b>
  <c>
    <added/>
  </c>
</a>
```

Note that a new `<added/>` is created each time. From what has already bee said, it should be clear that this “duplication” does not work with existing content (unless you use `clone` or `shallowClone`):

```swift
let myElement = XElement("a") {
    XElement("to-add")
    XElement("b")
    XElement("c")
}

for descendant in myElement.descendants({ $0.name != "to-add" }) {
    descendant.add {
        myElement.descendants("to-add")
    }
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

Use `clone` (or `shallowClone`) when you actually want content to get duplicated, e.g. using `myElement.descendants("to-add").clone` in the last example would then output:

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

By default, When you insert content, this new content is also followed (insertion mode `.following`), as this best reflects the dynamic nature of this library. If you do not want this, set `.skipping` as first argument of `insertPrevious` or `insertNext`. For example, consider the following code:

```swift
let myElement = XElement("top") {
    XElement("a")
}

for element in myElement.descendants {
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
  <c/>
</top>
```

When `<b/>` gets inserted, the traversal also follows this inserted content. When you would like to skip the inserted content, use `.skipping` as the first argument of `insertNext`:

```swift
    ...
        element.insertNext(.skipping) {
            XElement("b")
        }
    ...
```

Output:

```text
<top>
  <a/>
  <b/>
</top>
```

Similarly, if you replace a node, the content that gets inserted in place of the node is by default included in the iteration. Example: Assume you would like to replace every occurrence of some `<bold>` element by its content:

```swift
let document = try parseXML(fromText: """
    <text><bold><bold>Hello</bold></bold></text>
    """)
for bold in document.descendants("bold") { bold.replace { bold.content } }
document.echo()
```

The output is:

```text
<text>Hello</text>
```

## Handling of text

Subsequent text nodes (`XText`) are always automatically combined, and text nodes with empty text are automatically removed. The same treatment is applied to `XLiteral` nodes.

This can be very convenient when processing text, e.g. it is then very straightforward to apply regular expressions to the text in a document. But there might be some stumbling blocks involved here, when the different behaviour of text nodes and other nodes affects the result of your manipulations.

You can avoid merging of text `text` with other texts by setting the `isolated` property to `true` (you can also choose to set this value during initialization of an XText). Consider the following example where the occurrences of a search text gets a greenish background. In this example, you do not want `part` to be added to `text` in the iteration:

```swift
let document = try parseXML(fromText: """
    <doc>
        <paragraph>Hello world!</paragraph>
        <paragraph>world world world</paragraph>
    </doc>
    """)

let searchText = "world"

document.traverse { node in
    if let text = node as? XText {
        if text.value.contains(searchText) {
            text.isolated = true
            var addSearchText = false
            for part in text.value.components(separatedBy: searchText) {
                text.insertPrevious {
                    if addSearchText {
                        XElement("span", ["style": "background:LightGreen"]) {
                            searchText
                        }
                    }
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

Note that when e.g. inserting nodes, the `XText` nodes of them are then treated as being `isolated` while being moved.

A `String` can be used where an `XText` is required, e.g. you can write `"Hello" as XText"`.

`XText`, as well as `XLiteral` and `XCDATASection`, conforms to the `XTextualContentRepresentation` protocol, i.e. they all have a `String` property of name `value` that can be read and set and which represents content as it would be written into the serialized document (with some character escapes necessary in the case of `XText` when it is being written). Note that `XComment` does not conform to the `XTextualContentRepresentation` protocol.

## Rules

When you only want to apply a few changes to a document, just go directly to the few according elements and apply the changes you want. But if you would like to transform a whole document into “something else”, you need a better tool to organise your manipulations of the document, you need a “transformation”.

As mentioned in the general description, a set of rules `XRule` in the form of a transformation instance of type `XTransformation` can be used as follows.

In a rule, the user defines what to do with elements or attributes certain names. The set of rules can then be applied to a document, i.e. the rules are applied in the order of their definition. This is repeated, guaranteeing that a rule is only applied once to the same object (if not removed from the document and added again), until no application takes place. So elements can be added during application of a rule and then later be processed by the same or another rule.

Example:

```swift
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

----- Rule for element "formula" -----

  <formula id="3">

----------------------------------------

<a><formula id="3"/><image id="2"/><formula id="1"/></a>
```

You can also formulate rules with the `prefix:` argument, see the section on prefixes and namespaces.

As a side note, for such an `XTransformation` the lengths of the element names do not really matter: apart from the initialization of the transformation before the execution and from what happens inside the rules, the appliance of the rules is not less efficient if the element names are longer.

Instead of using a transformation with a very large number of rules, you should use several transformations, each dedicated to a separate “topic”. E.g. for some document format you might first transform the inline elements and then the block elements. Splitting a transformation into several transformations practically does not hurt performance.

Note that the order of the rules matters: If you need to look up e.g. the parent of the element in a rule, it is important to know if this parent has already been changed by another rule, i.e. if a preceding rule has transformed this element. An example is given in the following section “Transformations with inverse order”. The usage of several transformations as described in the preciding paragraph might help here. Methods to work with better contextual information are described in the sections “Transformations with attachments for context information”, “Transformations with document versions”, and “Transformations with traversals” below.

Also note that using an `XTransformation` you can only transform a whole document. In the section “Transformations with traversals” below, another option is described for transforming any XML tree.

A transformation can be stopped by calling `stop()` on the transformation, although that only works indirectly:

```swift
var transformationAlias: XTransformation? = nil

let transformation = XTransformation {

    XRule(forElements: "a") { _ in
        transformationAlias?.stop()
    }

}

transformationAlias = transformation

transformation.execute(inDocument: myDocument)
```

## Transformations with inverse order

As noted in the last section, the order of rules a crucial in some transformation, e.g. if the original context is important.

The “inverse order” of rules goes from the inner elements to the outer element so that the context is still unchanged when the rule applies, note the lookup of `element.parent?.name` to differentiate the color of the text:

```swift
let document = try parseXML(fromText: """
    <document>
        <section>
            <hint>
                <paragraph>This is a hint.</paragraph>
            </hint>
            <warning>
                <paragraph>This is a warning.</paragraph>
            </warning>
        </section>
    </document>
    """, textAllowedInElementWithName: { $0 == "paragraph" })

let transformation = XTransformation {

    XRule(forElements: "paragraph") { element in
        let style: String? = if element.parent?.name == "warning" {
            "color:Red"
        } else {
            nil
        }
        element.replace {
            XElement("p", ["style": style]) {
                element.content
            }
        }
    }

    XRule(forElements: "hint", "warning") { element in
        element.replace {
            XElement("div") {
                XElement("p", ["style": "bold"]) {
                    element.name.uppercased()
                }
                element.content
            }
        }
    }
}

transformation.execute(inDocument: document)

document.echo(pretty: true)
```

Result:

```XML
<document>
  <section>
    <div>
      <p style="bold">HINT</p>
      <p>This is a hint.</p>
    </div>
    <div>
      <p style="bold">WARNING</p>
      <p style="color:Red">This is a warning.</p>
    </div>
  </section>
</document>
```

This method might not be fully applicable in some transformations.

## Transformations with attachments for context information

To have information about the context in the original document of transformed elements, attachements might be used. See how in the following code `attached: ["source": element.name]` is used in the construction of the `div` element, and how this information is then used in the rules for the `paragraph` element (the input document is the same as in the section “Transformations with inverse order” above; note that the inverse order described in that section is _not_ used here):

```swift
let transformation = XTransformation {

    XRule(forElements: "hint", "warning") { element in
        element.replace {
            XElement("div", attached: ["source": element.name]) {
                XElement("p", ["style": "bold"]) {
                    element.name.uppercased()
                }
                element.content
            }
        }
    }

    XRule(forElements: "paragraph") { element in
        let style: String? = if element.parent?.attached["source"] as? String == "warning" {
            "color:Red"
        } else {
            nil
        }
        element.replace {
            XElement("p", ["style": style]) {
                element.content
            }
        }
    }
}

transformation.execute(inDocument: document)

document.echo(pretty: true)
```

The result is the same as in the section “Transformations with inverse order” above.

## Transformations with document versions

As explained in the above section about rules, sometimes you need to know the original context of a transformed element. For this you can use document versions, as explained below.

Note that this method comes with an penalty regarding efficiency because to need to create a (temparary) clone, but for very difficult transformations that might come in handy. The method might be used when you need to examine the orginal context in a complex way.

You first create a document version (this creates a clone such that your current document contains backlinks to the clone), and in certian rules, you might then copy the backlink from the node to be replaced by using the `withBackLinkFrom:` argument in the creation of an element (the input document is the same as in the section “Transformations with inverse order” above):

```swift
let transformation = XTransformation {

    XRule(forElements: "hint", "warning") { element in
        element.replace {
            XElement("div", withBackLinkFrom: element) {
                XElement("p", ["style": "bold"]) {
                    element.name.uppercased()
                }
                element.content
            }
        }
    }

    XRule(forElements: "paragraph") { element in
        let style: String? = if element.parent?.backlink?.name == "warning" {
            "color:Red"
        } else {
            nil
        }
        element.replace {
            XElement("p", ["style": style]) {
                element.content
            }
        }
    }
}

// make a clone with inverse backlinks,
// pointing from the original document to the clone:
document.makeVersion()

transformation.execute(inDocument: document)

// remove the clone:
document.forgetLastVersion()

document.echo(pretty: true)
```

The result is the same as in the section “Transformations with inverse order” above.

## Transformations with traversals

There is also another possibility for formulating transformations which uses traversals and which and can also be applied to parts of a document or to XML trees that are not part of a document.

As the XML tree can be changed during a traversal, you can traverse an XML tree and change the tree during the traversal by e.g. formulating manipulations according to the name of the current element inside a `switch` statement.

If you then formulate manipulations during the down direction of the traversal, you know that parents or other ancestors of the current node have already been transformed. Conversely, if you formulate manipulations only inside the `up:` traversal part and never manipulate any ancestors of the current element, you know that the parent and other ancestors are still the original ones (the input document is the same as in the section “Transformations with inverse order” above):

```swift
for section in document.elements("section") {
    section.traverse { node in
        // -
    } up: { node in
        if let element = node as? XElement {
            guard node !== section else { return }
            switch element.name {
            case "paragraph":
                let style: String? = if element.parent?.name == "warning" {
                    "color:Red"
                } else {
                    nil
                }
                element.replace {
                    XElement("p", ["style": style]) {
                        element.content
                    }
                }
            case "hint", "warning":
                element.replace {
                    XElement("div") {
                        XElement("p", ["style": "bold"]) {
                            element.name.uppercased()
                        }
                        element.content
                    }
                }
            default:
                break
            }
        }
    }
}

document.echo(pretty: true)
```

As the root of the traversal is not to be removed during the traversal, there is an according `guard` statement.

The result is the same as in the section “Transformations with inverse order” above.

Note that when using traversals for transforming an XML tree, using several transformations instead of one does have a negative impact on efficiency.

## Keeping element identity during transformations

When transforming elements, it might be convenient to keep the identity of transformed elements, so the `backlink` property works also e.g. for a parent. It then might be better to just change the name and the attributes of an element instead of replacing it by a new one during the transformation.

## Prefixes and namespaces

A namespace is referenced by a unique URI (Uniform Resource Identifier) and is supposed to differentiate between elements of different purpose or origin. Namespaces in the serialization of an XML document (i.e. the textual file) are defined as attributes in the form `xmlns:prefix="namespace URI"` or `xmlns="namespace URI"` (with some values for the prefix `prefix` and the namespace URI `namespace URI`) and are valid in their respective contexts (i.e. in the according part of the XML tree). Elements that belong to that namespace then have the name `prefix:name` (with some value for `name`) in this serialization. `prefix:name` is then also called the “qualified” name and the value `name` is called the “local” name. In the case of `xmlns="namespace URI"`, all elements in the context whitout a prefix are supposed to belong to the namespace, as long as no competing definition occurs. An attribute can also have a namespace prefix, it is then considered to be an extra thing to the attributes that an element already has and which should _not_ have a namespace prefix set.

The handling of namespaces in this library differs from other libraries for XML in that the prefix plays a more prominent role. In addition to the name, elements can also have a prefix, which is not only useful for referencing namespaces, but can also be used independently of namespaces to distinguish between elements with the same name during the processing of a document. It is also very straightforward to write code that works regardless of whether a namespace is used for the corresponding elements, without losing the definiteness if the namespace is declared.

In this library, an element has the `prefix` property which is `nil` by default and which denotes the prefix (without the colon), and the `name` property which denotes the “local” name (there is no method to get the “qualified” name, as this should not be of any use during processing). Prefixes are crucial for direct access to elements and thus also differentiate the rules accordingly. For elements with a prefix, rules or a searches based on the element names like `children("someName")` have to use the additional `prefix:` argument as in `children(prefix: myPrefix, "someName")` to find the according elements, the method call `children("someName")` only finds elements which do not have the prefix set. If really needed, use e.g. `children({ $0.name == "..." })` to find elements with a certain name independently of the prefix. You can also search only by prefix e.g. with `descendants(prefix: myPrefix)`. If you use these methods without any arguments e.g. `descendants()` note that _only elements without prefix are found,_ this is different from using the according property e.g. `descendants` which is independent of prefixes. Use the methods `has(prefix:name:)` and `set(prefix:name:)` of an element to conveniently check and set the two values ​​of `prefix` and `name`. Using an empty prefix value as in `myElement.prefix = ""` actually sets the prefix to `nil`.

If you need a new prefix independently of namespaces, use the method `registerIndependentPrefix(withPrefixSuggestion:)` of the document which returns an actual prefix to be used. If you add an element to a document with a literal prefix (not using the `prefix` property), this prefix will not be used as prefixes by subsequent uses of `register(namespaceURI:withPrefixSuggestion:)` or `registerIndependentPrefix(withPrefixSuggestion:)`, but nothing prevents collisions with previously registered prefixes.

When reading a document, namespace prefix definitions are only recognized if the argument `namespaceAware` is set to `true` in the call of the parse function used. The namespaces with their prefixes are registered at the document, according namespace attributes (`xmlns:...=...` or `xmlns=...`) are not (!) set in the tree and only appear in a serialization of the document or of parts of it (they appear after every other attribute at the top element of the serialization). To register a new namespace with its prefix, use the method `register(namespaceURI:withPrefixSuggestion:)` of the document which returns the actual prefix to be used.

During the reading of the document, an element that uses a namespace prefix defined in its context then gets the name _without_ the prefix (and without the separating colon), the prefix (without the separating colon) is separately stored in the `prefix` property of the element (which by default is `nil`). The actual prefixes might get changed during this process to avoid multiple prefix definitions for the same namespace URI or collisions, use the method `prefix(forNamespaceURI:)` of the document to get the actual prefix. On the other hand, an element with a colon in its orginal name whose literal prefix does not match a defined namespace prefix in its context then always keeps the full name and gets the prefix value `nil`. But such a literal prefix might cause the actual value of a namespace prefix to change during reading, so that in a serialization of the document the element does not acquire a different meaning.

When you add an element to a document with a `prefix` property for which a namespace URI is registered, you supposedly want to reference this namespace.

During serialization, every prefix value which is not `nil` is written as the prefix of the name (with a separating colon). Use the arguments `overwritingPrefixesForNamespaceURIs:` and `overwritingPrefixes:` of the serialization and output methods (each with an according map which has the prefixes for the serialization as values) to change prefixes in the serialization, where an empty String value means not outputting a prefix. Independently from those two arguments, use the argument `suppressDeclarationForNamespaceURIs:` to suppress the according namespace declarations in the output. Be careful with those settings as there is no check for consistency.

Some XML documents declare a namespace at the top of the document in the form `xmlns="..."` i.e. without a prefix to define the schema to be used for the document. When reading such a document with `namespaceAware: true`, consequently a prefix is created for this namespace and used for all according elements to conserve the affiliation to the namespace. Rules and the usual name based searches then have to take that prefix into account. If you want to avoid this, use the setting `silentEmptyRootPrefix: true` when parsing. The according namespace URI is then still registered at the document, but with prefix value `""`, and the according elements then have no prefix value set (their prefix value is `nil`), so no prefix value has to be considered in rules and searches. We then call this namespace a “silent” namespace. The method `prefix(forNamespaceURI:)` of the document returns `nil` for such a namespace, so you can use the prefix returned by this method for rules and searches regardless of the setting of `silentEmptyRootPrefix:` and also use this prefix in the construction of according elements. When adding an element without a prefix in the face of a silent namespace, the element is considerd to belong to the silent namespace.

When writing code that takes a possible prefix into account (i.e. the code should work regardless of whether `prefix` has a value or is `nil`), test your code with appropriate prefixes set, e.g. with the default `silentEmptyRootPrefix: false` and an according namespace definition in the source.

When moving elements between documents, missing namespaces with their prefixes are added to the target document, and prefixes of the moved elements are adjusted if necessary. For a removed or cloned element, the according namespace URI can still be found as long as the orginal document still exists and has not changed this value, so the element then behaves the same as being directly moved between documents.

Generally, there is no a need to change any prefix for a registered namespace during processing (there are also no tools added that would simplify this), just use the prefix returned by `prefix(forNamespaceURI:)` and, if necessary, define prefixes for a serialization.

Attributes can also have a prefix, set or get an attribute value via `element[prefix,name]`, where `prefix` might be `nil`. With regard to namespaces, the treatment of attributes corresponds to the treatment of elements, and independently of each other. The attributes that do not have an explicit namespace prefix set in the source do not get a namespace prefix during parsing, regardless of whether the corresponding element belongs to a namespace. So e.g. `myElement["id"]` also returns the according attribute value of an element that has a prefix, and `document.registeredAttributes("id")` finds all these attributes if `"id"` is a registered attribute name. Consequently, changing the prefix of an element does not change the prefixes of its attributes. For registering attributes with namespace prefixes or their values during parsing, namespace URIs must be given, and these provisions are translated into the according prefixes when the document has been parsed. When creating a document without parsing, to register attributes with prefixes or their values, the prefixes themselves must be specified.

Example:

```swift
let source = """
    <a>
        <math:math xmlns:math="http://www.w3.org/1998/Math/MathML"><math:mi>x</math:mi></math:math>
        <b xmlns:math2="http://www.w3.org/1998/Math/MathML">
            <math2:math><math2:mi>n</math2:mi>math2:mo>!</math2:mo></math2:math>
        </b>
    </a>
    """

let document = try parseXML(fromText: source, namespaceAware: true)

document.echo()
```

The resulting output is:

```xml
<a xmlns:math="http://www.w3.org/1998/Math/MathML">
    <math:math><math:mi>x</math:mi></math:math>
    <b>
        <math:math><math:mi>n</math:mi><math:mo>!</math:mo></math:math>
    </b>
</a>
```

When searching for elements with prefixes, those prefixes have to be used:

```swift
let mathMLPrefix = myDocument.prefix(forNamespaceURI: "http://www.w3.org/1998/Math/MathML")

for element in document.elements(prefix: mathMLPrefix, "math", "mo", "mi") {
    print("element \"\(element.name)\" with prefix \"\(element.prefix ?? "")\"")
}
```

The resulting output:

```text
element "math" with prefix "math"
element "mi" with prefix "math"
element "math" with prefix "math"
element "mi" with prefix "math"
element "mo" with prefix "math"
```

A rule for one of those elements then could be formulated as follows:

```swift
let mathMLPrefix = myDocument.prefix(forNamespaceURI: "http://www.w3.org/1998/Math/MathML")

let transformation = XTransformation {

    XRule(forPrefix: mathMLPrefix, "mo") { mo in
        ...
    }

    ...

}
```

In the examples above, if the namespace URI is not declared in the source (and no according prefixes set at the elements), then the method `prefix(forNamespaceURI:)` of the document returns `nil`, and the code is still valid.

### Using async/await

You can use `traverse` with closures using `await`. And you can use the `async` property of the [Swift Async Algorithms package](https://github.com/apple/swift-async-algorithms) (giving a `AsyncLazySequence`) to apply `map` etc. with closures using `await` (e.g. `element.children.async.map { await a.f($0) }`).

Currently the SwiftXML packages defined a `forEachAsync` method for closure arguments using `await`, but this method might be removed in future versions of the package if the Swift Async Algorithms package should define it for `AsyncLazySequence`.

### Convenience extensions

`XContent` has the following extensions that are very convenient when working with XML in a complex manner:

- `applying`: apply some changes to an instance and return the instance
- `pulling`: take the content and give something else back, e.g. “pulling” something out of it
- `fullfilling`: test a condition for an instance and return it the condition is true, else return `nil`
- `fullfills`: test a condition on an instance return its result

(`fullfilling` is, in principle, a variant of the `filter` method for just one item.)

It is difficult to show the convenience of those extension with simple examples, where is easy to formulate the code without them. But they come in handy if the situation gets more complex.

Example:

```swift
let element1 = XElement("a") {
    XElement("child-of-a") {
        XElement("more", ["special": "yes"])
    }
}

let element2 = XElement("b")

if let childOfA = element1.fullfilling({ $0.name == "a" })?.children.first,
   childOfA.children.first?.fullfills({ $0["special"] == "yes" && $0["moved"] != "yes"  }) == true {
    element2.add {
        childOfA.applying { $0["moved"] = "yes" }
    }
}

element2.echo()
```

Result:

```text
<b><child-of-a moved="yes"><more special="yes"/></child-of-a></b>
```

`applying` is also predefined for a content sequence or a element sequence where it is shorter than using the `map` method in the general case (where a `return` statement might have to be included) and you can directly use it to define content (without the `asContent` property decribed above):

```swift
let myElement = XElement("a") {
    XElement("b", ["inserted": "yes"]) {
        XElement("c", ["inserted": "yes"])
    }
}

print(Array(myElement.descendants.applying{ $0["inserted"] = "yes" }))
```

Result:

```text
[<b inserted="yes">, <c inserted="yes">]
```

## Tools

### `copyXStructure`

```swift
public func copyXStructure(from start: XContent, to end: XContent, upTo: XElement? = nil, correction: ((StructureCopyInfo) -> XContent)?) -> XContent?
```

Copies the structure from `start` to `end`, optionally up to the `upTo` value. `start` and `end` must have a common ancestor. Returns `nil` if there is no common ancestor. The returned element is a clone of the `upTo` value if a) it is not `nil` and b) `upTo` is an ancestor of the common ancestor or the ancestor itself. Else it is the clone of the common ancestor (but generally with a different content in both cases). The `correction` can do some corrections.

## Debugging

If one uses multiple instances of `XRule` bundled into a `XTRansformation` to transform a whole document, in can be useful to know which actions belonging to which rules "touched" an element. In debug builds all filenames and line numbers that are executed by a transformation during execution are recorded in the `encounteredActionsAt` property.

