<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/KazaiMazai/SwiftletModel/blob/main/Docs/Resources/Logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/KazaiMazai/SwiftletModel/blob/main/Docs/Resources/Logo.svg">
  <img src="https://github.com/KazaiMazai/SwiftletModel/blob/main/Docs/Resources/Logo.svg">
</picture>

[![CI](https://github.com/KazaiMazai/SwiftletModel/workflows/Tests/badge.svg)](https://github.com/KazaiMazai/SwiftletModel/actions?query=workflow%3ATests)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKazaiMazai%2FSwiftletModel%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/KazaiMazai/SwiftletModel)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKazaiMazai%2FSwiftletModel%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/KazaiMazai/SwiftletModel)


SwiftletModel offers an easy and efficient way to implement complex domain model graph in your iOS applications.

- **Entities as Plain Structs**: Define your entities using simple Swift structs.
- **Bidirectional Relations**: Manage relationships between entities effortlessly with type safety.
- **Normalized In-Memory Storage**: Store your data in a normalized form to maintain consistency and efficiency.
- **On-the-Fly Denormalization**: Transform your data into any required shape instantly.
- **Incomplete Data Handling**: Seamlessly handle scenarios involving partial or missing data.
- **Indexing**: Sort and filter data efficiently, enforce unique constraints, and perform full-text search with B-tree, Unique, and Full-Text indexes.
- **Codable Out of the Box**: Easily encode and decode your entities for persistence, response mapping, or other purposes.
 
## Why

SwiftletModel excels in the following scenarios:

- **Complex Domain Models**: Ideal for apps with intricate domain models with multiple interconnected entity types.
- **Lightweight Local Storage**: Suitable when you want to avoid the development overhead of persistent storage solutions like CoreData, SwiftData, Realm, or SQLite.
- **Backend-Centric Applications**: Perfect for applications where the backend is the primary source of truth for data management and fully fledged local db is not needed.

SwiftletModel offers a streamlined, in-memory alternative to CoreData and SwiftData. It is designed for applications that need a straightforward local data management system without the complexity of a full-fledged database.
 

Although primarily in-memory, SwiftletModel’s data model is Codable, allowing for straightforward data persistence if required.

## Table of Contents

- [Getting Started](#getting-started)
  * [Model Definitions](#model-definitions)
- [How to Save Entities](#how-to-save-entities)
- [How to Delete Entities](#how-to-delete-entities)
  * [Relationship DeleteRule](#relationship-deleterule)
- [How to Query Entities](#how-to-query-entities)
  * [Query with nested models](#query-with-nested-models)
  * [Bulk nested models query](#Bulk-nested-models-query)
  * [Combining bulk nested models with nested models query](#combining-bulk-nested-models-with-nested-models-query)
  * [Related models query](#related-models-query)
- [How to use Sort Queries](#how-to-use-sort-queries)
  * [Basic Sorting](#basic-sorting)
    + [Single Property Sorting](#single-property-sorting)
    + [Multi-Property Sorting](#multi-property-sorting)
  * [Using Indexes for Sorting](#using-indexes-for-sorting)
    + [Single Property Index](#single-property-index)
    + [Compound Index](#compound-index)
    + [Combining Sort and Filter](#combining-sort-and-filter)
    + [Best Practises and Performance Considerations](#best-practises-and-performance-considerations)
- [How to use Filter Queries](#how-to-use-filter-queries)
  * [Basic Filtering](#basic-filtering)
    + [Equality Filters](#equality-filters)
    + [Comparison Filters](#comparison-filters)
  * [Complex Filters](#complex-filters)
    + [Logical Operators](#logical-operators)
  * [Text Filtering](#text-filtering)
    + [String Operations](#string-operations)
    + [Full-Text Search](#full-text-search)
  * [Performance Optimization](#performance-optimization)
    + [Index Usage](#index-usage)
  * [Filters Best Practices](#filters-best-practices)
  * [Filter Method Reference](#filter-method-reference)
- [Codable Conformance](#codable-conformance)
- [Relationship Types](#relationship-types)
  * [Optional to-one Relationship](#optional-to-one-relationship)
  * [Required to-one Relationship](#required-to-one-relationship)
  * [To-many Relationship](#to-many-relationship)
- [Establishing Relations](#establishing-relations)
  * [Setting to-one relations](#setting-to-one-relations)
  * [Setting to-many relations](#setting-to-many-relations)
  * [Saving Relations](#saving-relations)
  * [Removing Relations](#removing-relations)
- [Incomplete Data Handling](#incomplete-data-handling)
  * [Handling incomplete Entity Models](#handling-incomplete-entity-models)
    + [Default Merge Strategy](#default-merge-strategy)
    + [Fragment Merge Strategy](#fragment-merge-strategy)
    + [Advanced Merge Strategies](#advanced-merge-strategies)
  * [Handling incomplete Related Entity Models](#handling-incomplete-related-entity-models)
  * [Handling incomplete data for to-many Relations](#handling-incomplete-data-for-to-many-relations)
  * [Handling missing data for to-one Relations](#handling-missing-data-for-to-one-relations)
- [Indexing](#indexing)
  * [Index](#index)
  * [Unique](#unique)
  * [Index Performance Considerations](#index-performance-considerations)
- [Type Safety](#type-safety)
- [Installation](#installation)
- [Documentation](#documentation)
- [Licensing](#licensing)


## Getting Started

### Model Definitions

First, we define the model with all kinds of relations:

```swift

@EntityModel
struct Message {
    let id: String
    let text: String
    
    @Relationship(.required)
    var author: User?
    
    @Relationship(.required, inverse: \.messages)
    var chat: Chat?
    
    @Relationship(inverse: \.message)
    var attachment: Attachment?
    
    @Relationship(inverse: \.replyTo)
    var replies: [Message]?
    
    @Relationship(inverse: \.replies)
    var replyTo: Message?
    
    @Relationship
    var viewedBy: [User]? = nil
}

```

That's pretty much it. EntityModel macro will generate all the necessary stuff to
make our model conform to `EntityModelProtocol` requirements.

<details><summary>EntityModelProtocol definitions</summary>
<p>

```swift
public protocol EntityModelProtocol {
    associatedtype ID: Hashable, LosslessStringConvertible

    var id: ID { get }
   
    mutating func normalize()
    
    mutating func willSave(to context: inout Context) throws

    func didSave(to context: inout Context) throws
    
    func save(to context: inout Context, options: MergeStrategy<Self>) throws
    
    func willDelete(from context: inout Context) throws

    func didDelete(from context: inout Context) throws
  
    func delete(from context: inout Context) throws
    
    func asDeleted(in context: Context) -> Deleted<Self>?
    
    func saveMetadata(to context: inout Context) throws
    
    func removeMetadata(from context: inout Context) throws

    static var defaultMergeStrategy: MergeStrategy<Self> { get }

    static var fragmentMergeStrategy: MergeStrategy<Self> { get }

    static var patch: MergeStrategy<Self> { get }
    
    static func queryAll(with nested: Nested..., in context: Context) -> QueryList<Self>
         
    static func nestedQueryModifier(_ query: Query<Self>, in context: Context, nested: [Nested]) -> Query<Self>
}
}
```

</p>
</details>


## How to Save Entities

Now let's create a chat instance and put some messages into it. 
To do it we need to create a context first:



```swift
var context = Context()
```

Now let's create a chat with some messages.

```swift
let chat = Chat(
    id: "1",
    users: .relation([
        User(id: "1", name: "Bob"),
        User(id: "2", name: "Alice")
    ]),
    messages: .relation([
        Message(
            id: "1",
            text: "Any thoughts on SwiftletModel?",
            author: .id( "1")
        ),
        
        Message(
            id: "1",
            text: "Yes.",
            author: .id( "2")
        )
    ]),
    admins: .ids(["1"])
)
```

Now let's save chat to the context.


```swift

try chat.save(to: &context)

```


Just look at this. 

Instead of providing the full entities everywhere...We need to provide them at least somewhere!
In other cases, we can just put ids and it will be enough to establish proper relations.

At this point, our chat and the related entities will be saved to the context.

- All entities will be normalized so we don't have to care about duplication.
- Bidirectional links will be managed.


If your model has optional fields and contains incomplete data, you can save it as a fragment:

```swift

try chat.save(to: &context, options: .fragment)
```

It will patch the existing model. Read more about fragment data handling: [Handling incomplete Entity data](#handling-incomplete-entity-data)


## How to Delete Entities 

The delete method is generated via EntityModel macro making deletion as simple as:

```swift

let chat = Chat("1")
chat.delete(from: &context)

```

Calling `delete(...)` will 
- remove the current instance from the context
- it will nullify all relations or cascade delete depending on `DeleteRule` attribute
- call `willDelete(...)` and `didDelete(...)` callbacks when needed.

### Relationship DeleteRule

DeleteRule allows to specify how the related entities would be treated when current entity is deleted:
- nullify (the default option)
- cascade 

```swift

@Relationship(deleteRule: .cascade, inverse: \.message)
var attachment: Attachment?

```


## How to Query Entities

### Query with nested models

Let's query something. For example, a User with the following nested models:

It can be done with the following syntax:


```swift

let user = User
    .query("1", in: context)
    .with(\.$chats) { chat in
        chat.with(\.$messages) { message in
            message.with(\.$replies) { reply in
                reply.with(\.$author)
                     .id(\.$replyTo)
            }
            .id(\.$author)
            .id(\.$chat)
        }
        .with(\.$users)
        .id(\.$admins)
    }
    .resolve()
```

*Wait but we've just saved a chat with users and messages.
Now we are querying things from another end, WTF?*

*Exactly. That's the point of bidirectional links and normalization.*

When `resolve()` is called all entities are pulled from the context storage 
and put in its place according to the nested shape in denormalized form.

### Bulk nested models query

Bulk nested models query is s quick way to fetch related models graph up to a certain depth.
It's possible to query entity with all nested related models at once in a single line: 

```swift
let user = User
    .query("1", in: context)
    .with(.entities)
    .resolve()
```

It's also possible to query all nested models of the graph recursively up to a certain depth and specify, how do we want to resolve them at a certain depth: as a complete entity, as a fragment or only ids:

```swift
let user = User
    .query("1", in: context)
    .with(.entities, .fragments, .ids)
    .resolve()
```

### Combining bulk nested models with nested models query

Bulk nested queries can be combined with other queries to include all related models only for certain parts of the model graph

*In the example below, user would be resovled with all chats and while each chat would include all related models.*

```swift
let user = User
    .query("1", in: context)
    .with(\.$chats) { chat in
        chat.with(.entities)
    }
    .resolve()
```

### Related models query

We can also query related items directly:

```swift

let userChats: [Chat] = User
    .query("1", in: context)
    .related(\.$chats)
    .resolve()
    
```

## How to use Sort Queries

SwiftletModel provides a flexible sorting system that can leverage indexes for improved performance. 
The sorting API supports both single and multi-property sorting, with options for ascending and descending order.

### Basic Sorting
#### Single Property Sorting

```swift
// Ascending sort (default)
let users = User.query(in: context)
    .sorted(by: \.age)
    .resolve()

// Descending sort
let users = User.query(in: context)
    .sorted(by: \.age.desc)
    .resolve()
```
#### Multi-Property Sorting

```swift
// Sort by multiple properties
let users = User.query(in: context)
    .sorted(by: \.lastName, \.firstName)
    .resolve()

// Mixed ascending/descending
let users = User.query(in: context)
    .sorted(by: \.age.desc, \.lastName)
    .resolve()
```

### Using Indexes for Sorting
#### Single Property Index

```swift
@EntityModel
struct User {
    @Index<Self>(\.age) private static var ageIndex
    
    let id: String
    let age: Int
    let name: String
}

// This sort will use the index
let sortedUsers = User.query(in: context)
    .sorted(by: \.age)
    .resolve()
    
// Not indexed property sort
let sortedUsers = User.query(in: context)
    .sorted(by: \.name)
    .resolve()
```
#### Compound Index

```swift
@EntityModel
struct User {
    @Index<Self>(\.lastName, \.firstName) private static var nameIndex
    
    let id: String
    let firstName: String
    let lastName: String
    let age: Int
}

// This sort will use the compound index
let sortedUsers = User.query(in: context)
    .sorted(by: \.lastName, \.firstName)
    .resolve()
    
// Not indexed property sort. Compound index won't be used:
let sortedUsers = User.query(in: context)
    .sorted(by: \.lastName)
    .resolve()
    
// Not indexed property sort. Compound index won't be used:
let sortedUsers = User.query(in: context)
    .sorted(by: \.lastName, \.age)
    .resolve()    
    
```

#### Combining Sort and Filter
```swift
// Efficient when using indexes
let results = User.query(in: context)
    .filter(\.age > 18)
    .sorted(by: \.lastName, \.firstName)
    .resolve()

// Complex sorting with filters
let results = User.query(in: context)
    .filter(\.status == .active)
    .sorted(by: \.age.desc, \.lastName)
    .resolve()

```

#### Best Practises and Performance Considerations

| Operation | Indexed | Not Indexed | Notes |
|-----------|---------|-------------|--------|
| Single Property Sort | O(n) | O(n log n) | Indexed uses pre-sorted data |
| Multi-Property Sort | O(n) | O(n log n) | With compound index |
| Sort + Filter | O(m) | O(n log n) | m = filtered result size |
| Descending Sort | O(n) | O(n log n) | Same complexity as ascending |

Important to note: `Desc` sort indexing performance is lower than plain ascending. 


1. Index Selection:
- Add indexes for frequently sorted properties
- Use compound indexes for common sort combinations
- Consider memory usage, index build performance vs. performance trade-offs
2. Sort Order:
- Choose appropriate sort direction (ascending/descending)
- Consider default sorting needs
- Use compound sorts when necessary
3. Performance Optimization:
- Leverage indexes for better performance
- Filter before sorting may be beneficial
Consider result set size
4. Memory Considerations:
- Indexes increase memory usage
- Each compound index requires additional storage
- Balance between query performance and resource usage


## How to use Filter Queries

SwiftletModel provides a powerful and flexible filtering system that supports both indexed and non-indexed queries. 
The filtering API offers various comparison methods and can leverage indexes for improved performance.

### Basic Filtering

#### Equality Filters

```swift
// Single property equality
let users = User
        .filter(\.age == 25, in: context)
        .resolve()
        
// Multiple property equality chain.
let results = User
    .filter(\.age == 25, in: context)
    .filter(\.status == .active)
    .resolve()
```

#### Comparison Filters

```swift
// Greater than
let adults = User
    .filter(\.age > 18, in: context)
    .resolve()  

// Less than or equal
let juniors = User
        .filter(\.age <= 21, in: context)
        .resolve()

// Range combination
let youngAdults = User
    .filter(\.age >= 18, in: context)
    .filter(\.age < 30)
    .resolve()
```

### Complex Filters

#### Logical Operators

```swift
// OR operation
let results = User.filter(\.age == 25, in: context)
    .or(.filter(\.age == 30, in: context))
    .resolve()

// AND operation
let results = User.filter(\.age > 18, in: context)
    .and(\.status == .active)
    .resolve()

// Complex combinations
let results = User.filter(\.age == 25, in: context)
    .or(.filter(\.status == .active, in: context))
    .or(.filter(\.age > 30, in: context).and(\.level <= 4))
    .resolve()
```
### Text Filtering
#### String Operations

```swift
// Contains
let results = Message
    .filter(.string(\.text, contains: "hello"), in: context)
    .resolve()
    
// Prefix/Suffix
let results = Message
    .filter(.string(\.text, hasPrefix: "Re:"), in: context)
    .resolve()
    
let results = Message
    .filter(.string(\.text, hasSuffix: "regards"), in: context)
    .resolve()

// Case sensitivity
let results = Message
    .filter(.string(\.text, contains: "Hello", caseSensitive: true), in: context)
    .resolve()


```

#### Full-Text Search
When using FullTextIndex, you can perform more sophisticated fuzzy mathc text searches:

```swift
// Fuzzy matching
let results = Article.filter(.string(\.content, matches: "search terms"), in: context)
    .resolve()
// Multiple field search
let results = Article
    .filter(.string(\.title, \.content, matches: "search terms"), in: context)
    .resolve()

```

### Performance Optimization

#### Index Usage
The filtering system automatically utilizes available indexes when possible:

```swift
@EntityModel
struct User {
    @Index<Self>(\.age) private static var ageIndex
    @Index<Self>(\.status) private static var statusLevelIndex
    
    let id: String
    let age: Int
    let status: UserStatus
    let level: Int
}

// This query will use the age index
let results = User
    .filter(\.age > 18, in: context)
    .resolve()

// This query will use both the age and status indexes 
let results = User
    .filter(\.status == .active, in: context)
    .filter(\.level == 3)
```

Non Indexed queries are significantly slower because they require full collection scan. 
Indexed property queries are insanely fast. 
 
| Operation Type | Value Type | Indexed | Not Indexed | Notes |
|---------------|------------|----------|-------------|--------|
| Equality (==) | Hashable | O(1) | O(n) | Uses hash-based lookup for indexed values |
| Equality (==) | Comparable | O(log n) | O(n) | Uses B-tree for indexed comparable values |
| Comparison (>, <, >=, <=) | Hashable | O(n) | O(n) | Hash indexes don't help with range queries |
| Comparison (>, <, >=, <=) | Comparable | O(log n) | O(n) | B-tree enables efficient range queries |

### Filters Best Practices
1. Index Selection:
- Add indexes for frequently filtered properties
- Balance between query performance and memory usage
- Balance between read query and index update performance
2. Query Optimization:
- Place indexed property or most selective filters first
3. Text Search:
- Use FullTextIndex for better text search performance
- Consider case sensitivity requirements
- Test search relevance with representative data


### Filter Method Reference
```swift
// Comparison Methods
// == : Equal to
// != : Not equal to
// > : Greater than
// >= : Greater than or equal to
// < : Less than
// <= : Less than or equal to

// String Methods
// contains: Substring matching
// hasPrefix: Starts with
// hasSuffix: Ends with
// matches: Full-text fuzzy search matching

// Logical Operators
// and: Combines filters with AND logic
// or: Combines filters with OR logic 
 
// Complex filter combining multiple conditions
let results = User
    .filter(\.age >= 18, in: context)
    .and(\.status == .active)
    .or(.filter(\.role == .admin, in: context))
    .and(\.lastLogin > oneWeekAgo)
    .resolve()

// Text search with multiple fields
let articles = Article
    .filter(.string(\.title, \.content, matches: "swift database"), in: context)
    .filter(\.status == .published)
    .resolve()
```

## Codable Conformance

Since models are implemented as plain structs we can get `Codable` out of the box:

```swift

extension User: Codable { }

extension Chat: Codable { }

extension Message: Codable { }

/** 
And then use it for our codable purposes:
*/

let encoder = JSONEncoder.prettyPrinting
encoder.relationEncodingStrategy = .plain
let userJSON = user.prettyDescription(with: encoder) ?? ""
print(userJSON)

```

<details><summary>Here is the JSON string that we will get</summary>
<p>

```
{
  "adminOf" : null,
  "chats" : [
    {
      "admins" : [
        {
          "id" : "1"
        }
      ],
      "id" : "1",
      "messages" : [
        {
          "attachment" : null,
          "author" : {
            "id" : "1"
          },
          "chat" : {
            "id" : "1"
          },
          "id" : "1",
          "replies" : [
            {
              "attachment" : null,
              "author" : {
                "adminOf" : null,
                "chats" : null,
                "id" : "2",
                "name" : "Alice"
              },
              "chat" : null,
              "id" : "2",
              "replies" : null,
              "replyTo" : {
                "id" : "1"
              },
              "text" : "Yes.",
              "viewedBy" : null
            }
          ],
          "replyTo" : null,
          "text" : "Any thoughts on SwiftletModel?",
          "viewedBy" : null
        },
        {
          "attachment" : null,
          "author" : {
            "id" : "2"
          },
          "chat" : {
            "id" : "1"
          },
          "id" : "2",
          "replies" : [

          ],
          "replyTo" : null,
          "text" : "Yes.",
          "viewedBy" : null
        }
      ],
      "users" : [
        {
          "adminOf" : null,
          "chats" : null,
          "id" : "1",
          "name" : "Bob"
        },
        {
          "adminOf" : null,
          "chats" : null,
          "id" : "2",
          "name" : "Alice"
        }
      ]
    }
  ],
  "id" : "1",
  "name" : "Bob"
}
```


</p>
</details>


## Relationship Types


SwiftletModel supports the following types of relations:
- One way & Mutual
- To One & To Many
- Optional & Required

All of them are represented by a single property wrapper: `@Relationship`
 
### Optional to-one Relationship

Here is a way to define an optional relation. 

```swift
/**
It can be either one way. 
*/

@Relationship
var user: User? = nil


/**
Or can be mutual. Mutual relation requires providing an inverse key pathsa as a witness to ensure 
that it is indeed mutual
*/

@Relationship(inverse: \.message)
var attachment: Attachment?

```

The optionality of the Relation means that it can be explicitly nullified. 
(See: [Handling missing Data for to-one Relations](#handling-missing-data-for-to-one-relations))

```swift
/**
When this message is saved, it **will nullify**
the existing message-attachment relation in the context.
*/

let message = Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .id( "1"),
    attachment: .null
)


try message.save(to: &context)

```

### Required to-one Relationship

There is a way to define an required relation. 


```swift
/**
It can be either one way: 
*/

@Relationship(.required)
var author: User?
    

/**
It can be mutual. Mutual relation requires providing a witness to ensure that it is indeed mutual: direct and inverse key paths.
Inverse relations can be either to-one or to-many and must be mutual.
*/

@Relationship(.required, inverse: \.messages)
var chat: Chat?

```


If it is a required relation, why is the property still optional? 
Relation properties are always optional because it's the way how SwiftletModel handles incomplete data. 

Required relation only means that it cannot be explicitly nullified.


### To-many Relationship

To-many relationships can be defined the following way:

```swift
/**
It can be either one way:
*/

@Relationship
var viewedBy: [User]? = nil

 
/**
It can also be mutual. Mutual relation requires to provide an inverse key path as a witness 
to ensure that it is really mutual.
*/

@Relationship(inverse: \.replyTo)
var replies: [Message]?

```
 
Basically, it's required because there is no reason for to-many relations to have an explicit nil. 

## Establishing Relations

The properties themselves are read-only. 
However, relations can be set up through the property wrapper's projected values.

### Setting to-one relations

```swift

var message = Message(
    id: "1",
    text: "Howdy!"
)

/**
For to-one relations, we can attach by directly setting the relation:
*/
message.$author = .relation(user)
try message.save(to: &context)

/**
We can also attach by id. In that case 
we need to make sure that both entities exist in the context
*/
 
message.$author = .id( user.id)
try message.save(to: &context)
try user.save(to: &context)

/**
If the relation is optional we can nullify it by setting it to explicit nil. 
In that case, the existing relation will be destroyed on save. 
However, if there was some related entity it will not be deleted. 
*/
 
message.$attachment = .null
try message.save(to: &context)


/**
Setting the relation to `none` will not have any effect on the stored data. 
This happens automatically during normalization when you save an entity:
*/
 
message.$attachment = .none
try message.save(to: &context)


```

### Setting to-many relations

To-many relations can be set up exactly the same way:

```swift

/**
To-many relations can be set directly by providing an array of entities.
*/
chat.$messages = .relation([message])
try chat.save(to: &context)

/**
An array of ids will also work, but all entities should be additionally saved to the context. 
*/
chat.$messages = .ids([message.id])
try chat.save(to: &context)
try message.save(to: &context)       
```

To-many relations support not only setting up new relations, 
but also appending new relations to the existing ones. It can be done via `appending(...)`

(See: [Handling incomplete data for to-many Relations](#Handling-incomplete-data-for-to-many-relations))
 
 
```swift

/**
New to-many relations can be appended to the existing ones when set as an appending slice:
*/
chat.$messages = .appending(relation: [message])
try chat.save(to: &context)

/**
An array of ids will also work, 
but all entities should be additionally saved to the context. 
*/
chat.$messages = .appending(ids: [message.id])
try chat.save(to: &context)
try message.save(to: &context)    

```

### Saving Relations

Saving an entity with all related ones is possible thanks to the Entity save method and is done automatically.


### Removing Relations

There are several options to remove relations.

```swift
/**
We can detach entities. This will only destroy the relation between them while keeping entities in storage.
*/
detach(\.$chats, inverse: \.$users, in: &context)


/**
We can delete related entities. It only destroys the relationship between them.  The related entities will be also removed from storage with their `delete(...)` method.
*/
try delete(\.$attachment, inverse: \.$message, from: &context)


/**
We can explicitly nullify the relation. This is an equivalent of `detach(...)`
*/
message.$attachment = .null
try message.save(to: &context)

```


## Incomplete Data Handling

SwiftletModel provides a few strategies to handle incomplete data for the cases:

- Incomplete Entity Models
- Incomplete Related Entity Models
- Incomplete collections of to-many Relations
- Missing Data for to-one Relations


### Handling incomplete Entity Models

When the service gets more mature, models often become bulky.
We sometimes have to fetch them partially from different sources or deal with partial model data. 

Let's define a user model with an optional Profile. 

```swift

extension User {
    /**
    Something heavy here is that the backend does not serve for all requests.
    */
    struct Profile: Codable { ... }
}
 
@EntityModel 
struct User: Codable {
    let id: String
    private(set) var name: String
    private(set) var avatar: Avatar
    private(set) var profile: Profile?
    
    @Relationship(inverse: \.users)
    var chats: [Chat]?
    
    @Relationship(inverse: \.admins)
    var adminOf: [Chat]?
}
 

```

In SwiftletModel partial entity models are called fragments. SwiftletModel provides a reliable way 
to deal with fragments via `MergeStrategy` without corrupting existing data.

MergeStrategy defines how new entities are merged with existing ones that we already have in the Context.


```swift

/**
To handle that `EntityModelProtocol` has a default and fragment merge strategies:
*/

public extension EntityModelProtocol {
    static var defaultMergeStrategy: MergeStrategy<Self> { .replace }
    
    static var fragmentMergeStrategy: MergeStrategy<Self> { Self.patch }
}
```

#### Default Merge Strategy

When saving entities to context, you can omit the `options`
since the defaultMergeStrategy is used. 

The default merge Strategy replaces existing models in the context upon saving:

```swift
var context = Context()

/**
This is a complete user entity having all properties set:
*/
let user = User(
    id: "1", 
    name: "Bob", 
    avatar: Avatar(...), 
    profile: User.Profile(...)
)

try user.save(to: &context)

```


#### Fragment Merge Strategy

Fragment merge strategy patches existing models in the context. 
In other words, it updates only non-nil values. 
It's automatically generated via macro so you don't have to do anything.


```swift
var context = Context()

/**
This is a fragment. It doesn't a profile. 
Probably for a reason, we don't know, but we have to deal with it.
*/
let user = User(
    id: "1", 
    name: "Bob", 
    avatar: Avatar(...)
)

try user.save(to: &context, options: .fragment)


``` 

#### Advanced Merge Strategies


Both default and fragment merge strategies can be overridden for any entity:
 
```swift
extension User {
    /**
    This will make patching as the default behavior:
    */
    static var defaultMergeStrategy: MergeStrategy<Self> {
        User.patch
    }
    
    /**
    This is what the `User.patch` strategy for the user 
    with an optional `profile` actually looks like: 
    */
    static var fragmentMergeStrategy: MergeStrategy<Self> { 
        MergeStrategy(
            .patch(\.profile)
        )
     }
}

```

Merge strategy may include several properties.

```swift

MergeStrategy(
    .patch(\.name),
    .patch(\.profile),
    .patch(\.avatar)
)

```
Merge strategy can be applied to arrays. 

```swift

MergeStrategy(
    .append(\.arrayOfSomething)
)
```

You can write your own merge strategy for any type:

```swift
extension MergeStrategy {
    /**
    This is what the property patch MergeStrategy looks like.
    */
    static func patch<Entity, Value>(_ keyPath: WritableKeyPath<Entity, Optional<Value>>) -> MergeStrategy<Entity>   {
        MergeStrategy<Entity> { old, new in
            var new = new
            new[keyPath: keyPath] = new[keyPath: keyPath] ?? old[keyPath: keyPath]
            return new
        }
    }
}

```

### Handling incomplete Related Entity Models

When assigning related nested entities, we can mark them as fragments to utilise fragment merging strategy:

```swift

var chat = Chat(id: "1")
chat.$users = .fragment([.bob, .alice, .john])
try chat.save(to: &context)

```


### Handling incomplete data for to-many Relations

We often have to deal with portions of data. 
If we have a collection of anything on the backend it will almost certainly be paginated.

SwiftletModel provides a convenient way to deal with incomplete collections for to-many relations.

When setting to-many relation it's possible to mark the collection as a appending slice. 
In that case, all the related entities will be appended to the existing ones.
 
```swift

/**
New to-many relations can be appended 
to the existing ones when we set them as a appending entities:
*/
chat.$messages = .appending(relation: [message])
try chat.save(to: &context)

/**
or appending ids:
*/
chat.$messages = .appending(ids: [message])
try chat.save(to: &context)

/**
or appending fragments to ulitise fragment merging strategy:
*/ 
chat.$messages = .appending(fragment: [message])
try chat.save(to: &context)

```


### Handling missing data for to-one Relations

To-one relation can be either optional or required.

Basically, data can be missing for at least 3 reasons:

1. The business logic of the app allows the related entity to be missing. For example: a message may not have an attachment.

2. Data is missing because we haven't loaded it yet. If the source is a backend or even a local storage there is almost certainly a case when the app hasn't received the data yet. 

3. The logic of obtaining the data implies that some of the data will be missing. For example: a typical app flow where we obtain a list of chats from the backend. Then we get a list of messages for the chat. Even though a message cannot exist without a chat, a message model coming from the backend will hardly ever contain a chat model because it will make the shape of the data weird with a lot of duplication.


When we deal with missing data it's hard to figure out the reason why it's missing. 
It can always be an explicit nil or maybe not.

That's why SwiftletModel's relations properties are always optional. 
It allows to implement a patching update policy for relations by default: when entities with missing relations are saved to the storage they don't overwrite or nullify existing relations.


This allows to safely update models and merge them with the exising data:


```swift

/**
When this message is saved it **WILL NOT OVERWRITE** 
existing relations to attachments if there are any:
*/
let message = Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .id( "1"),
)

try message.save(to: &context)

```

Optional relation allows to set the relation to an explicit nil:  

```swift

/**
When a message with an explicit nil 
is saved it **WILL OVERWRITE** existing relations to the attachment by nullifying them:
*/
let message = Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .id( "1"),
    attachment: .null
)


try message.save(to: &context)

```

## Indexing
SwiftletModel provides three types of indexes to optimize data access and enforce uniqueness constraints: `Index`, `Unique`, and `FullTextIndex`. Each serves a different purpose and offers specific functionality.

### Index
The Index property wrapper enables efficient querying and sorting of entity properties.

```swift
@Index<Entity>(\.propertyName)
private static var propertyIndex
```

Features:
- Supports both Comparable and Hashable types
- Allows compound indexes up to 4 properties
- Maintains sorted order for Comparable types
- Enables fast lookups for Hashable types

Example:

```swift
@EntityModel
struct User {
    @Index<Self>(\.age) private static var ageIndex
    @Index<Self>(\.lastName, \.firstName) private static var nameIndex
    
    let id: String
    let firstName: String
    let lastName: String
    let age: Int
}
```
### Unique
The Unique property wrapper enforces uniqueness constraints on entity properties.

```swift
@Unique<Entity>(\.propertyName, collisions: .throw)
private static var uniqueIndex
```

Features:
- Enforces uniqueness constraints
- Supports compound unique constraints up to 4 properties
- Configurable collision handling:
    - throw: Throws error on violation
    - upsert: Replaces existing entity
    - custom collision handling
- Works with both Comparable and Hashable types


Example:

```swift
@EntityModel
struct User {
    // Unique username with upsert on collision
    @Unique<Self>(\.username, collisions: .upsert) 
    private static var uniqueUsername
    
    // Unique email that throws on collision
    @Unique<Self>(\.email, collisions: .throw) 
    private static var uniqueEmail
    
    // Custom collision handling for current user
    @Unique<Self>(\.isCurrent, collisions: .updateCurrentUser) 
    private static var currentUserIndex
    
    let id: String
    let username: String
    let email: String
    var isCurrent: Bool
}

// Custom collision resolver implementation
extension CollisionResolver where Entity == User {
    static var updateCurrentUser: Self {
        CollisionResolver { existingId, _, _, context in
            guard var user = Query<Entity>(context: context, id: existingId).resolve(),
                user.isCurrent
            else {
                return
            }
               
            user.isCurrent = false
            try user.save(to: &context)
        }
    }
}
```

This example demonstrates three different collision handling strategies:
1. `.upsert` - Automatically replaces existing entity when username conflicts
2. `.throw` - Throws an error when email conflicts
3. `.updateCurrentUser` - Custom logic to handle "current user" status:
   - When a new user is marked as current, automatically updates the existing current user not being current anymore
   - Ensures only one user can be marked as current at a time


### FullTextIndex

The FullTextIndex property wrapper implements full-text search capabilities using the BM25 ranking algorithm.

```swift
@FullTextIndex<Entity>(\.propertyName)
private static var searchIndex
```

Features:
- Full-text search with relevance ranking
- BM25 scoring algorithm for better search results
- Token frequency tracking & Document length normalization
- Supports multiple text fields
- Automatic tokenization and indexing
- Optimized for search performance
- Used for `match`, `contains`, `prefix`, `suffix` text search queries

Example:

```swift
@EntityModel
struct Article {
    @FullTextIndex<Self>(\.title, \.content) private static var contentIndex
    
    let id: String
    let title: String
    let content: String
}

// Usage
let articles = Article
    .query(in: context)
    .filter(.string(\.title, \.content, matches: "search terms"))
    .resolve()
```

### Index Performance Considerations
1. Index Selection:
    - Use Index for general querying and sorting
    - Use Unique when uniqueness must be enforced
    - Use FullTextIndex for text search functionality
2. Compound Indexes:
    - Limited to 4 properties for performance reasons
    - Consider the order of properties in compound indexes
    - More indexes increase write overhead
3. Memory Usage:
    - Each index type maintains its own data structures
    - Full-text indexes require more memory for token storage
    - Consider the trade-off between query performance and memory usage
4. Performance
    - Each index requires time to build and update that is executed when model is saved
    - Consider the trade-off between query read performance and index update performance

Best Practices
1. Index Sparingly:
- Only index properties that need to be queried or sorted
- Avoid redundant indexes
- Consider query patterns when designing indexes
2. Collision Handling:
    - Use .throw for strict uniqueness enforcement
    - Use .upsert when replacing existing records is acceptable
    - Use collistion resolver for custom replacement logic
3. Full-Text Search:
    - Index only text fields that need to be searched
    -  Consider the length of indexed content
    -  Test search relevance with representative data

## Type Safety

Relations rely heavily on principles of Type-Driven design under the hood.
They are implemented so that there is very little chance of misuse. 

```swift
struct Relation<Entity, Directionality, Cardinality, Constraints> { ... }
```

All you can do with relation is defined by its Directionality, Cardinality, and Constraint types.

Any mistake will be spotted at compile time:

- You cannot accidentally set an explicit nil to the required relation
- You cannot establish a wrong relation by making it mutual on one side and one-way on another
- You can't save relation in a wrong way
- You cannot ever confuse to-one and to-many relations 


This also means that you cannot accidentally break it.

If you want to learn more about type-driven design [here](https://swiftology.io/collections/type-driven-design/)
is a wonderful series of articles about it.
 

## Installation

You can add SwiftletModel to an Xcode project as an SPM package:

- From the File menu, select Add Package Dependencies...
- Enter "https://github.com/KazaiMazai/SwiftletModel.git" into the package repository URL text field
- Profit

## Documentation

Full project documentation can be found [here](https://swiftpackageindex.com/KazaiMazai/SwiftletModel/0.4.3/documentation/swiftletmodel)

## Licensing

SwiftletModel is licensed under MIT license.
