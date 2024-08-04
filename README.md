<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Docs/Resources/Logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="Docs/Resources/Logo.svg">
  <img src="Docs/Resources/Logo.svg">
</picture>

# SwiftletModel

[![CI](https://github.com/KazaiMazai/SwiftletModel/workflows/Tests/badge.svg)](https://github.com/KazaiMazai/SwiftletModel/actions?query=workflow%3ATests)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKazaiMazai%2FSwiftletModel%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/KazaiMazai/SwiftletModel)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKazaiMazai%2FSwiftletModel%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/KazaiMazai/SwiftletModel)


SwiftletModel offers an easy and efficient way to implement complex domain models in your iOS applications.

- **Entities as Plain Structs**: Define your entities using simple Swift structs.
- **Bidirectional Relations**: Manage relationships between entities effortlessly with type safety.
- **Normalized In-Memory Storage**: Store your data in a normalized form to maintain consistency and efficiency.
- **On-the-Fly Denormalization**: Transform your data into any required shape instantly.
- **Incomplete Data Handling**: Seamlessly handle scenarios involving partial or missing data.
- **Codable Out of the Box**: Easily encode and decode your entities for persistence, response mapping, or other purposes.
 
## When and Why

SwiftletModel excels in the following scenarios:

- **Complex Domain Model**s: Ideal for apps with intricate domain models that require a robust and flexible solution.
- **Backend-Centric Applications**: Perfect for applications where the backend is the primary source of truth for data management.
- **Lightweight Local Storage**: Suitable when you want to avoid the development overhead of persistent storage solutions like CoreData, SwiftData, Realm, or SQLite.

SwiftletModel offers a streamlined, in-memory alternative to CoreData and SwiftData. It is designed for applications that need a straightforward local data management system without the complexity of a full-fledged database.

Although primarily in-memory, SwiftletModel’s data model is Codable, allowing for straightforward data persistence if required.

## Table of Contents

- [Getting Started](#getting-started)
  * [Model Definitions](#model-definitions)
  * [Save to context](#save-to-context)
  * [Delete from context](#delete-from-context)
  * [Normalization](#normalization)
- [How to Save Entities](#how-to-save-entities)
- [How to Query Entities](#how-to-query-entities)
  * [Query with nested models](#query-with-nested-models)
  * [Related models query](#related-models-query)
- [Codable Conformance](#codable-conformance)
- [Relation Types](#relation-types)
  * [HasOne](#hasone)
  * [BelongsTo](#belongsto)
  * [HasMany](#hasmany)
- [Establishing Relations](#establishing-relations)
  * [Setting to-one relations](#setting-to-one-relations)
  * [Setting to-many relations](#setting-to-many-relations)
  * [Saving Relations](#saving-relations)
  * [Removing Relations](#removing-relations)
- [Incomplete Data Handling](#incomplete-data-handling)
  * [Handling incomplete Entity data](#handling-incomplete-entity-data)
    + [Advanced Merge Strategies](#advanced-merge-strategies)
  * [Handling incomplete data for to-many Relations](#handling-incomplete-data-for-to-many-relations)
  * [Handling missing data for to-one Relations](#handling-missing-data-for-to-one-relations)
- [Type Safety](#type-safety)
- [Installation](#installation)
- [Licensing](#licensing)

## Getting Started

### Model Definitions

First, we define the model with all kinds of relations:

```swift

struct Message: EntityModel, Codable {
    let id: String
    let text: String
    
    @BelongsTo
    var author: User? = nil
    
    @BelongsTo(\.chat, inverse: \.messages)
    var chat: Chat?
    
    @HasOne(\.attachment, inverse: \.message)
    var attachment: Attachment?
    
    @HasMany(\.replies, inverse: \.replyTo)
    var replies: [Message]?
    
    @HasOne(\.replyTo, inverse: \.replies)
    var replyTo: Message?
    
    @HasMany
    var viewedBy: [User]? = nil
}

```

Now we need to implement EntityModel protocol requirements. 

### Save to context

The save method defines how the model will be saved: 
- Current instance should be inserted into context
- Related entities should be saved with their relations.

```swift

func save(to context: inout Context) throws {
    context.insert(self)
    try save(\.$author, to: &context)
    try save(\.$chat, inverse: \.$messages, to: &context)
    try save(\.$attachment, inverse: \.$message, to: &context)
    try save(\.$replies, inverse: \.$replyTo, to: &context)
    try save(\.$replyTo, inverse: \.$replies, to: &context)
    try save(\.$viewedBy, to: &context)
}
```
The method is throwing to have some room for validations in case of need.

### Delete from context

The delete method defines the delete strategy for the entity 
- Current instance should be removed from the context
- We may want to `delete(...)` related entities recursively to implement a cascade deletion. 
- We can nullify relations with a `detach(...)` method

```swift    
func delete(from context: inout Context) throws {
    context.remove(Message.self, id: id)
    detach(\.$author, in: &context)
    detach(\.$chat, inverse: \.$messages, in: &context)
    detach(\.$replies, inverse: \.$replyTo, in: &context)
    detach(\.$replyTo, inverse: \.$replies, in: &context)
    detach(\.$viewedBy, in: &context)
    try delete(\.$attachment, inverse: \.$message, from: &context)
}
```

The method is throwing to be able to perform some additional checks before deletion 
and throw an error if something has gone wrong.

### Normalization

All relations should be normalized in `normalize()`. The method will be called when the entity is saved to context.

```swift
mutating func normalize() {
    $author.normalize()
    $chat.normalize()
    $attachment.normalize()
    $replies.normalize()
    $replyTo.normalize()
    $viewedBy.normalize()
}
```

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
            author: .relation(id: "1")
        ),
        
        Message(
            id: "1",
            text: "Yes.",
            author: .relation(id: "2")
        )
    ]),
    admins: .relation(ids: ["1"])
)
```

Now let's save chat to the context.


```swift

try chat.save(to: &context)

```

Just look at this. Instead of providing the full entities everywhere...We need to provide them at least somewhere!
In other cases, we can just put ids and it will be enough to establish proper relations.

At this point, our chat and the related entities will be saved to the context.

- All entities will be normalized so we don't have to care about duplication.
- Bidirectional links will be managed.


## How to Query Entities

### Query with nested models

Let's query something. For example, a User with the following nested models:

```yaml
User 
- chats 
  - messages 
    - replies 
        - authorUser 
        - replyToMessageId
    - authorId
    - chatId
  - users
  - adminIds
  
```

It can be done with the following syntax:


```swift

let user = User
    .query("1", in: context)
    .with(\.$chats) {
        $0.with(\.$messages) {
            $0.with(\.$replies) {
                $0.with(\.$author)
                  .id(\.$replyTo)
            }
            .id(\.$author)
            .id(\.$chat)
        }
        .with(\.$users)
        .ids(\.$admins)
    }
    .resolve()
```

*Wait but we've just saved a chat with users and messages.
Now we are querying things from another end, WTF?*

*Exactly. That's the point of bidirectional links and normalization.*

When `resolve()` is called all entities are pulled from the context storage 
and put in its place according to the nested shape in denormalized form.

### Related models query

We can also query related items directly:

```swift

let userChats: [Chat] = User
    .query("1", in: context)
    .related(\.$chats)
    .resolve()
    
```

## Codable Conformance

Since models are implemented as plain structs we get codable out of the box.


```swift

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


## Relation Types


SwiftletModel supports the following types of relations:
- One way & Mutual
- To One & To Many
- Optional & Required

They are represented by the following property wrappers:
- `@BelongsTo`
- `@HasOne`
- `@HasMany`


### HasOne

`@HasOne` is an optional to-one relation. 

```swift
/**
It can be either one way. One-way relation requires providing a default value. 
Actually, the default value will be always nil. 
*/

@HasOne
var user: User? = nil


/**
It can be mutual. Mutual relation requires providing a witness to ensure 
that it is indeed mutual: direct and inverse key paths.
*/

@HasOne(\.attachment, inverse: \.message)
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
    author: .relation(id: "1"),
    attachment: .null
)


try message.save(to: &context)

```

### BelongsTo

`@BelongsTo` is a required to-one relation. 


```swift
/**
It can be either one way: 
*/

@BelongsTo
var author: User? = nil
    

/**
It can be mutual. Mutual relation requires providing a witness to ensure that it is indeed mutual: direct and inverse key paths.
Inverse relations can be either to-one or to-many and must be mutual.
*/

@BelongsTo(\.chat, inverse: \.messages)
var chat: Chat?

```


If `BelongsTo` is a required relation, why is the property still optional? 
Relation properties are always optional because it's the way how SwiftletModel handles incomplete data. 

Required relation means that it cannot be explicitly nullified.


### HasMany

`@HasMany` is a required to-many relation. 

```swift
/**
Like other relations it can be either one way:
*/

@HasMany
var viewedBy: [User]? = nil

 
/**
It can be mutual. Mutual relation requires to provide a witness 
to ensure that it is really mutual: direct and inverse key paths.
*/

@HasMany(\.replies, inverse: \.replyTo)
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
 
message.$author = .relation(id: user.id)
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
chat.$messages = .relation(ids: [message.id])
try chat.save(to: &context)
try message.save(to: &context)       
```

To-many relations support not only setting up new relations, 
but also appending new relations to the existing ones. It can be done via `slice(...)`

(See: [Handling incomplete data for to-many Relations](#Handling-incomplete-data-for-to-many-relations))
 
 
```swift

/**
New to-many relations can be appended to the existing ones when set as a slice:
*/
chat.$messages = .slice([message])
try chat.save(to: &context)

/**
An array of ids will also work, 
but all entities should be additionally saved to the context. 
*/
chat.$messages = .slice(ids: [message.id])
try chat.save(to: &context)
try message.save(to: &context)    

```

### Saving Relations

Saving an entity with all related ones is possible thanks to the Entity save method:

```swift

extension User {
    /**
    Save with relation KeyPaths will save both related entities and relations to them.
    */
    func save(to context: inout Context) throws {
        context.insert(self, options: User.patch())
        try save(\.$chats, inverse: \.$users, to: &context)
        try save(\.$adminOf, inverse: \.$admins, to: &context)
    }
}

```

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
- Incomplete collections of to-many Relations
- Missing Data for to-one Relations


### Handling incomplete Entity data

When the service gets more mature, models often become bulky.
We sometimes have to fetch them from different sources or deal with partial model data. 

SwiftletModel provides a reliable way to deal with incomplete model data via `MergeStrategy`.
MergeStrategy defines how new entities are merged with existing ones that we already have in the Context.

Let's define a user model with an optional Profile. 

```swift

extension User {
    /**
    Something heavy here is that the backend does not serve for all requests.
    */
    struct Profile: Codable { ... }
}
 
struct User: EntityModel, Codable {
    let id: String
    private(set) var name: String
    private(set) var avatar: Avatar
    private(set) var profile: Profile?
    
    @HasMany(\.chats, inverse: \.users)
    var chats: [Chat]?
    
    @HasMany(\.adminOf, inverse: \.admins)
    var adminOf: [Chat]?
}
```

Let's define a patch `MergeStrategy`:

```swift
extension User {
    /**
    This `MergeStrategy` will overwrite the existing users' profiles 
    only if the new users' profiles are not nil.
    */
    static func patch() -> MergeStrategy<User> {
        MergeStrategy(
            .patch(\.profile)
        )
    }
}

```

Now we can use the merge strategy in the User's save method:

```swift
extension User {
    /**
    The Default `MergeStrategy` for inserting entities into the Context is replaced.
    Here we provide a patch strategy that will be patching users' profiles.
    */
    func save(to context: inout Context) throws {
        context.insert(self, options: User.patch())
        try save(\.$chats, inverse: \.$users, to: &context)
        try save(\.$adminOf, inverse: \.$admins, to: &context)
    }
}

```

#### Advanced Merge Strategies

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

### Handling incomplete data for to-many Relations

We often have to deal with proportional data. 
If we have a collection of anything on the backend it will almost certainly be paginated.

SwiftletModel provides a convenient way to deal with incomplete collections for to-many relations.

When setting to-many relation it's possible to mark the collection as a slice. 
In that case, all the related entities will be appended to the existing.
 
```swift

/**
New to-many relations can be appended 
to the existing ones when we set them as a slice:
*/
chat.$messages = .slice([message])
try chat.save(to: &context)
 

```


### Handling missing data for to-one Relations

To-one relation can be either optional: `@HasOne` or required: `@BelongsTo`

Basically, data can be missing for at least 3 reasons:

1. The business logic of the app allows the related entity to be missing. For example: a message may not have an attachment.

2. Data is missing because we haven't loaded it yet. If the source is a backend or even a local storage there is almost certainly a case when the app haven't received the data yet. 

3. The logic of obtaining the data implies that some of the data will be missing. For example: a typical app flow where we obtain a list of chats from the backend. Then we get a list of messages for the chat. Even though a message cannot exist without a chat, a message model coming from the backend will hardly ever contain a chat model because it will make the shape of the data weird with a lot of duplication.


When we deal with missing data it's hard to figure out the reason why it's missing. 
It can always be an explicit nil or maybe not.

That's why SwiftletModel's relations properties are always optional. 
It allows to implement a patching update policy for relations by default: when entities with missing relations are saved to the storage they don't overwrite or nullify existing relations.


This allows to safely update models and merge it with the exising data:


```swift

/**
When this message is saved it **WILL NOT OVERWRITE** 
existing relations to attachments if there are any:
*/
let message = Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .relation(id: "1"),
)

try message.save(to: &context)

```

HasOne allows to set the relation as an explicit nil:  

```swift

/**
When a message with an explicit nil 
is saved it **WILL OVERWRITE** existing relations to the attachment by nullifying them:
*/
let message = Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .relation(id: "1"),
    attachment: .null
)


try message.save(to: &context)

```

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
 

##  Installation

You can add SwiftletModel to an Xcode project as an SPM package:

- From the File menu, select Add Package Dependencies...
- Enter "https://github.com/KazaiMazai/SwiftletModel.git" into the package repository URL text field
- Profit

## Licensing

SwiftletModel is licensed under MIT license.
