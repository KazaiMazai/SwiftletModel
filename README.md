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

It's kind of ORM but without a database. 

## Why


Need a consistent domain model which is more complex than just a couple of entities?
Get all data from the backend anyway and have reasons to avoid a heavy duty local storage like CoreData/SwiftData/Realm/SQLite? 
 

SwiftletModel.


## Models Definition

Define your model with all kinds of relations:

```swift

struct Message: Codable {
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

Implement EntityModel protocol requirements.
They define how you model will be normalized, saved and deleted:

```swift

extension Message: EntityModel {
    mutating func normalize() {
        $author.normalize()
        $chat.normalize()
        $attachment.normalize()
        $replies.normalize()
        $replyTo.normalize()
        $viewedBy.normalize()
    }
    
    func save(to context: inout Context) throws {
        context.insert(self)
        try save(\.$author, to: &context)
        try save(\.$chat, inverse: \.$messages, to: &context)
        try save(\.$attachment, inverse: \.$message, to: &context)
        try save(\.$replies, inverse: \.$replyTo, to: &context)
        try save(\.$replyTo, inverse: \.$replies, to: &context)
        try save(\.$viewedBy, to: &context)
    }
    
    func delete(from context: inout Context) throws {
        try delete(\.$attachment, inverse: \.$message, from: &context)
        context.remove(Message.self, id: id)
        detach(\.$author, in: &context)
        detach(\.$chat, inverse: \.$messages, in: &context)
        detach(\.$replies, inverse: \.$replyTo, in: &context)
        detach(\.$replyTo, inverse: \.$replies, in: &context)
        detach(\.$viewedBy, in: &context)
    }
}
```


## Save Entities

Let's create a chat instance and put some messages into it. 

In order to do it we first need to create a context:

```swift
var context = Context()

```

Now lets create a chat with some messages and save it.


```swift

var context = Context()

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

try chat.save(to: &context)


```

Instead of providing the full entities everywhere we need to do it at least once. 
In other cases we can just put ids and it will be enough.

At this point our chat and the related entities will be saved to the context.

- All entities will be normalized so we don't have to care about duplication.
- Bidirectional links will be managed.


## Query Entities


Now let's query a user his chat, messages and replies.

Wait but we've just saved a chat with users and messages

Exactly. That's the point of bidirectional links.

```
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

When `resolve()` is called all entities are pulled from the context storage 
and put in its place according the nested shape in denormalized form.


## Codable

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


## Relations


SwiftletModel supports the following types of relations:
- One way & Mutual
- To One & To Many
- Optional & Required

They are represented by the following propery wrappers:
- @BelongsTo
- @HasOne
- @HasMany


### HasOne

HasOne is an optional to-one relation. 

It can be either one way:

```swift
@HasOne
var user: User? = nil
    
```
One-way relation requires to provide a default value which is always nil. 


Or mutual: 

```
@HasOne(\.attachment, inverse: \.message)
var attachment: Attachment?

```
Mutual relation requires to provide a witness to ensure that it is indeed mutual: direct and inverse key paths.



The optionality of the Relation means that it can be explicitly nullified:

```swift
Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .relation(id: "1"),
    attachment: .null
),
```

When this message is saved, it will nillify the existing relation in the context.


### BelongsTo

`BelongsTo` is a required to-one relation. 

It can be either one way:

```swift
@BelongsTo
var author: User? = nil
    
```


Or mutual: 

```swift
@BelongsTo(\.chat, inverse: \.messages)
var chat: Chat?

```

Mutual relation requires to provide a witness to ensure that it is indeed mutual: direct and inverse key paths.



If `BelongsTo` is a required relation, why is the property still optional? 
Relation properties are always optional becuase it's the way how SwiftletModel handles incomplete data. 

Required relation means that it cannot be explicitly nullified.


### HasMany

Like other relations it can be either one way:

```swift
@HasMany
var viewedBy: [User]? = nil

```

Or mutual. 

```swift
@HasMany(\.replies, inverse: \.replyTo)
var replies: [Message]?
  
```

Mutual relation requires to provide a witness to ensure that it is really mutual: direct and inverse key paths.



## How incomplete data is handled


SwiftletModel provides a few strategies to handle incomplete data cases:

- Incomplete Entity Models
- Incomplete collections of to-many Relations
- Missing Data for to-one Relations


## Handling missing Data for to-one Relations

To-one relation can be either optional: `@HasOne` or required: `@BelongsTo`

Basically, data can be missing for at least 3 reasons:

1. The business logic of the app implies that the relation can be missing.

For example: message may not have an attachment.

2. Data is missing because we haven't loaded it yet. 

The source can be a backend or even a local storage, it doesn't matter. There is almost certainly a state when app haven't received the
data for technical reasons yet.


3. The logic of obtaining the data implies that some of the data will be missing.

For example.

A tipical app flow implies that we obtain a list of chats from the backend. 
Then we get a list messages for the chat. 
Even though message cannot do without chat, message model will hardly ever contain a chat model because it will make the shape of the data weird.


When we deal with missing data it's hard to figure out wether its missing for reason and it is an explicit nil. Or it's missing because we haven't obtainer it yet.

That's why SwiftletModel's relations properties are always optional. 
It allows to implement PATCH relations policy: when enitites with missing data about relations are saved to the storage they don't overwrite or nullify existing relations.


This allows to safely update models and merge it with the exising data:

When this message is saved it **will NOT overwrite** existing relations to attachments if there are any:
```swift
Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .relation(id: "1"),
)

```


HasOne allows to set the relation as an explicit nil:  

```swift
Message(
    id: "1",
    text: "Any thoughts on SwiftletModel?",
    author: .relation(id: "1"),
    attachment: .null
)
```

This IS a destructive operation becuase when this message is saved it **will overwrite**  existing relations to the attachment by nullifing them
 
