//
//  Fetch.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 04/12/2025.
//

import SwiftletModel
import SwiftUI
import Crocodil
import SwiftletModelUIMacros
import Combine

@EntityModel
struct User: Codable, Sendable {
    @Unique<Self>(\.username, collisions: .upsert) static var uniqueUsername
    @Unique<Self>(\.email, collisions: .throw) static var uniqueEmail
   
    let id: String
    private(set) var name: String?
    private(set) var avatar: Avatar?
    private(set) var profile: Profile?
    private(set) var username: String
    private(set) var email: String

    var isCurrent: Bool = false
    
    var fullname: String? { name }
    
    init(id: String, name: String? = nil, avatar: Avatar? = nil, profile: Profile? = nil, username: String, email: String, isCurrent: Bool) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.profile = profile
        self.username = username
        self.email = email
        self.isCurrent = isCurrent
    }
 
}

struct Profile: Codable {
    let bio: String?
    let url: String?
}

struct Avatar: Codable {
    let small: URL?
    let medium: URL?
    let large: URL?
}

@propertyWrapper
struct FetchQuery<Value> {
    var wrappedValue: Value
    
    private var cancellables = Set<AnyCancellable>()
     
    init<Entity>(_ query: QueryList<Entity>) where Value == Array<Entity>, Entity: EntityModelProtocol {
        wrappedValue = query.resolve(in: Dependency[\.observableContext].mainContext)
        
        Dependency[\.observableContext]
            .$mainContext
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.global(qos: .userInteractive))
            .map { query.resolve(in: $0) }
            .sink {
                wrappedValue = $0
                Task {
                    let value = await Dependency[\.observableContext].read {
                        query.resolve(in: $0)
                    }
                    wrappedValue = value
                }
                
            }
            .store(in: &cancellables)
    }
    
    init<Entity>(_ query: Query<Entity>) where  Value == Optional<Entity>, Entity: EntityModelProtocol {
        wrappedValue = query.resolve(in: Dependency[\.observableContext].mainContext)
        
        Dependency[\.observableContext]
            .$mainContext
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.global(qos: .userInteractive))
            .map { query.resolve(in: $0) }
            .sink { wrappedValue = $0 }
            .store(in: &cancellables)
    }
}


struct SomeView: View {
    #Fetch(User
        .filter(\.isCurrent == true)
        .sorted(by: \.username)
    )
    var users: [User]
    
    #Fetch(User
        .filter(\.isCurrent == true)
        .sorted(by: \.username)
        .first()
    )
    var user: User?
    
    
    @Environment(\.updateContext) var updateContext
    
    var body: some View {
        Text("Hello, World!").onAppear {
            updateContext { context in
                try User(id: "1", username: "", email: "", isCurrent: false)
                    .save(to: &context)
            }
        }
    }
}

struct SomeView2: View {
    
    var users: [User]
    
//    #Fetched(
//        User
//        .filter(\.isCurrent == true)
//        .sorted(by: \.username)
//    )
//    #FetchedOne(
//        User.filter(\.isCurrent == true)
//        .sorted(by: \.username)
//        .first()
//    )
//    var user: User?
    
    
    @Environment(\.updateContext) var updateContext
    
    var body: some View {
        Text("Hello, World!").onAppear {
            updateContext { context in
                try User(id: "1", username: "", email: "", isCurrent: false)
                    .save(to: &context)
                
                
            }
        }
    }
}

func foo() {
    #Fetch(
        User
        .filter(\.isCurrent == true)
        .sorted(by: \.username)
    )
}

extension View {
    func contextContainer() -> some View {
        environmentObject(Dependencies[\.observableContext])
    }
}

final class ObservableContext: ObservableObject {
    @Published var mainContext: Context
    private let backgroundContext: ActorOf<Context>
    
    init(_ context: Context = Context()) {
        self.mainContext = context
        self.backgroundContext = ActorOf(context)
    }
    
    func update(_ operation: @escaping (inout Context) throws -> Void) {
        Task { @MainActor in
            mainContext = try await backgroundContext.write(operation)
        }
    }
    
    func read<T>(_ operation: @escaping (Context) -> T) async -> T {
        await backgroundContext.read(operation)
    }
}

typealias UpdateContext = ((inout Context) throws -> Void)

extension Dependencies {
    @DependencyEntry var observableContext: ObservableContext = ObservableContext(Context())

    @DependencyEntry var updateContext: (@escaping UpdateContext) -> Void = { operation in
        Dependencies[\.observableContext].update(operation)
    }
    
    
}

 
extension EnvironmentValues {
    @Entry var updateContext: (@escaping UpdateContext) -> Void = Dependency[\.updateContext]
}
  

actor ActorOf<Value> {
   private var value: Value
   
   init(_ value: Value) {
       self.value = value
   }
   
   func write(_ operation: (inout Value) throws -> Void) rethrows -> Value {
       try operation(&value)
       return value
   }
   
   func read<T>(_ operation: (Value) -> T) -> T {
       operation(value)
   }
}

 
final class ObservableQuery<Value, QueryType, Entity: EntityModelProtocol>: ObservableObject {
    private let query: QueryType
    @Published var value: Value
    
    init(_ query: Query<Entity>) where QueryType == Query<Entity>, Value == Optional<Entity> {
        self.query = query
        self.value = query.resolve(in: Dependency[\.observableContext].mainContext)
    }
    
    init(_ query: QueryList<Entity>) where Value == Array<Entity>, QueryType == QueryList<Entity>  {
        self.query = query
        self.value = query.resolve(in: Dependency[\.observableContext].mainContext)
    }
}
 
