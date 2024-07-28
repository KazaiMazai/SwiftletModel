<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Docs/Resources/Logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="Docs/Resources/Logo.svg">
  <img src="Docs/Resources/Logo.svg">
</picture>

SwiftletModel provides a way to implement the rich domain model of your app in Swifty way.

- Entities as plain structs
- Bidirectional relations
- Normalized Storage
- Denormalize to any shape on the fly
- Incomplete data handling

It's almost like an ORM but without a database. 

## Why


Need a consistent domain model which is more complex than just a couple of entities?

Get all data from the backend anyway and have reasons to avoid a heavy duty local storage like CoreData/SwiftData/Realm/SQLite? 
 

SwiftletModel.


## Model Definitions

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

Then we implement EntityModel protocol requirements. 

They define how the model will be saved: 

```swift

/**
There are a few things to be done in save(...)
  - Current instance should ne inserted into context
  - Related entities should be saved. Depending on the relation type inverse 
  relation kaypath may be reqiured.
  
The method is throwing to allow some room for validations in case of need.
*/

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

deleted:
 

```swift    
/**
Delete method defines the detele strategy for the current entity 
- Current instance should be removed from context
- We may want to `delete(...)` related entities recursively to implement a cascade deletion. 
- We need to nullify relation with a `detach(...)` method

The method is throwing to allow to perfom some additional checks before deletion 
and throw an error if something has gone wrong.
*/
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

and normalized:

```swift
    
    /**
    All relations should be normalized explicitly.
    This method will be called when entity is saved to context.
    */
    mutating func normalize() {
        $author.normalize()
        $chat.normalize()
        $attachment.normalize()
        $replies.normalize()
        $replyTo.normalize()
        $viewedBy.normalize()
    }
}
```


## How to Save Entities

Let's create a chat instance and put some messages into it. 
In order to do it we need to create a context first:


```swift
var context = Context()
```

Now lets create a chat with some messages

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

Now let's save chat to the context


```swift

try chat.save(to: &context)

```

Just look at this. Instead of providing the full entities everywhere...We need to provide them at least somewhere!
In other cases we can just put ids and it will be enough to establish proper relations.

At this point our chat and the related entities will be saved to the context.

- All entities will be normalized so we don't have to care about duplication.
- Bidirectional links will be managed.


## How to Query Entities


Let's query something. For eg, User with the following nested models:

```yaml
User 
- chats 
  - messages 
    - replies 
        - authors 
        - ids of the replied message
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

*Wait but we've just saved a chat with users and messages, WTF?
Exactly. That's the point of bidirectional links and normalizaion.*

When `resolve()` is called all entities are pulled from the context storage 
and put in its place according the nested shape in denormalized form.


## Codable Conformance

Since models implemented as plain structs we get codable out of the box.


```swift

let encoder = JSONEncoder.prettyPrinting
encoder.relationEncodingStrategy = .plain
let userJSON = user.prettyDescription(with: encoder) ?? ""
print(userJSON)


```

<details><summary>Here is what we get</summary>
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

They are represented by the following propery wrappers:
- `@BelongsTo`
- `@HasOne`
- `@HasMany`


### HasOne

`@HasOne` is an optional to-one relation. 

```swift
/**
It can be either one way. One-way relation requires to provide a default value. 
Actually, the default value will be always nil. 
*/

@HasOne
var user: User? = nil


/**
It can be mutual. Mutual relation requires to provide a witness to ensure 
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
It can be mutual. Mutual relation requires to provide a witness to ensure that it is indeed mutual: direct and inverse key paths.
Inverse relation can be either to-one or to-many and must be mutual.
*/

@BelongsTo(\.chat, inverse: \.messages)
var chat: Chat?

```


If `BelongsTo` is a required relation, why is the property still optional? 
Relation properties are always optional becuase it's the way how SwiftletModel handles incomplete data. 

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
 
Basically, it's required because there is no reason for to-many relation to have an explicit nil. 


## Incomplete Date Handling


SwiftletModel provides a few strategies to handle incomplete data for the cases:

- Incomplete Entity Models
- Incomplete collections of to-many Relations
- Missing Data for to-one Relations


### Handling missing Data for to-one Relations

To-one relation can be either optional: `@HasOne` or required: `@BelongsTo`

Basically, data can be missing for at least 3 reasons:

1. The business logic of the app allows the related enitity to be missing. For example: message may not have an attachment.

2. Data is missing because we haven't loaded it yet. If the source is a backend or even a local storage there is almost certainly a case when app haven't received the data yet. 

3. The logic of obtaining the data implies that some of the data will be missing. For example: a tipical app flow where we obtain a list of chats from the backend. Then we get a list messages for the chat. Even though a message cannot exist without a chat, message model coming from the backend will hardly ever contain a chat model because it will make the shape of the data weird with a lot of duplication.


When we deal with missing data it's hard to figure out the reason why it's missing 
It can always be an explicit nil or maybe not.

That's why SwiftletModel's relations properties are always optional. 
It allows to implement patching update relations policy by default: when enitites with missing relations are saved to the storage they don't overwrite or nullify existing relations.


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
When message with an explicit nil 
is saved it **WILL OVERWRITE** existing relations to the attachment by nullifing them:
*/

let message = Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .relation(id: "1"),
    attachment: .null
)


try message.save(to: &context)

```

