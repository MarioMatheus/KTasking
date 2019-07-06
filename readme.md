# KTasking Sample Project - Kitura: Swift Server Side

## Overview
KTasking is a Restful API implemented using Kitura.
Kitura is a framework and web server for web services written in Swift. For more informations, visit [Kitura](www.kitura.io).

The project uses features such as Codable routing, URL parameters, Postgres database using SwiftKueryORM, a TypeSafeMiddleware with JWT auth to access some resources.
KTasking also uses api swagger to generate the documentation, which can be accessed on the `/openapi/ui` route, for api consumption.

## How to run
Open project folder in terminal
 - Docker Compose
   ```bash
    $ docker-compose up
   ```
 - Swift CLI
   ```bash
    $ swift build
    $ swift run
   ```
    Note: Running by swift cli, you need to have installed [PostgreSQL](https://www.postgresql.org/) with a 'postgres' user, and 'ktasking' database.

## Project Topics (<i>to show somethings about project and Kitura</i>)
Much of the things covered below you can find more in the Kitura [Documentation](https://www.kitura.io/learn.html).
The server contains three models: Goal, Task and User. A User contains many Goals that contains many Tasks. Goals and Tasks operations requires authentication.

### Codable Routing
A good Kitura feature, <i>Codable Routing</i> automatically converts body data from HTTP requests and responses in app's structs and classes. We can define handler methods with the parameters: the body struct or class and a completion function to send the http response, enabling Kitura itself performs data validation for you.
```swift
app.router.post("/goals", handler: addGoal)
```
```swift
func addGoal(goal: Goal, completion: @escaping (Goal?, RequestError?) -> Void) {
    var newGoal = goal
    newGoal.id = UUID().uuidString
    newGoal.createdAt = Date()
    // auth and insertion operations here
    completion(newGoal, nil)
}
```
Sample `/goals` post request:
```json
{ "name": "testando conexao do container" }
```
Response:
```json
{
    "user": "jamilesilva",
    "id": "6BC59721-F15E-419C-8E5E-8FE46F96ACA2",
    "name": "testando conexao do container",
    "created_at": 584136687.80758595
}
```

### SwiftKueryORM
An ORM (Object Relational Mapping) library built for Swift. Using it allows you to simplify persistence of models. With SwiftKueryORM you just have to implement the `Model` protocol in your models and in these perform operations in database.
 -   Establishing connection (<i> sample code </i>)
 ```swift
 let pool: SwiftKuery.ConnectionPool = {
     return PostgreSQLConnection.createPool(
         host: ProcessInfo.processInfo.environment["DBHOST"] ?? "localhost",
	     port: 5432,
	     options: [
	         .databaseName("ktasking"),
	         .userName(ProcessInfo.processInfo.environment["DBUSER"] ?? "postgres"),
	         .password(ProcessInfo.processInfo.environment["DBPASSWORD"] ?? "nil"),
	     ],
	     poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 50, timeout: 10000))
}()
		
func setUp() {
    Database.default = Database(pool)
    try? User.createTableSync()
    try? Goal.createTableSync()
    try? Task.createTableSync()
}
 ```

`Model` protocol provides completion handlers with signature that matches with the completion handler used by Codable Routing, so, we can pass route completion handler to completion parameter of `Model` operations.

```swift
func getGoals(params: GoalParams?, completion: @escaping ([Goal]?, RequestError?) -> Void) {
    // auth operation here
    Goal.findAll(matching: params, completion)
}
```
Note: You can define URL parameters making a struct that implements `QueryParams` protocol.

### JWT Authentication
KTasking uses SwiftJWT library to enable authentication based in Json Web Tokens.  SwiftJWT is very cool, with a JWTSigner and JWTVerifier you can implements login and register operations in a simple way.
```swift
// Using a Hashed Message Authentication Code (HMAC)
let jwtKey = "kitura-jwt-test-key"
let jwtSigner = JWTSigner.hs256(key: Data(jwtKey.utf8))
let jwtVerifier = JWTVerifier.hs256(key: Data(jwtKey.utf8))

func sendToken(by userCredentials: UserCredentials, statusCode: RequestError?,_ completion: @escaping(TokenResponse?, RequestError?) -> Void) {
    do {
        let claims = ClaimsStandardJWT(iss: jwtKey, sub: userCredentials.username, exp: Date(timeIntervalSinceNow: 3600))
	var jwt = JWT(claims: claims)
	let token = try jwt.sign(using: jwtSigner)
	completion(TokenResponse(token: token), statusCode)
    } catch _ {
        completion(nil, .internalServerError)
    }
}
```
Now, you can create a TypeSafeMiddleware and add it as a parameter in a route to perform the authentication of a user.
```swift
struct TypeSafeJWT<C: Claims>: TypeSafeMiddleware {
    let jwt: JWT<C>

    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (TypeSafeJWT?, RequestError?) -> Void) {
        let authHeader = request.headers["Authorization"]
	guard let authComponents = authHeader?.components(separatedBy: " "), 
	    authComponents.count == 2, 
	    authComponents[0] == "Bearer",
	    let jwt = try? JWT<C>(jwtString: authComponents[1], verifier: App.jwtVerifier)
	    else {
	        return completion(nil, .unauthorized)
	    }
	    completion(TypeSafeJWT(jwt: jwt), **nil**)
	}
}
```

```swift
func getGoals(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, params: GoalParams?, completion: @escaping ([Goal]?, RequestError?) -> Void) {
    guard let userName = typeSafeJWT.jwt.claims.sub else {
        return completion(nil, .unauthorized)
    }
    let goalParams = UserGoalsParams(user: userName, goalName: params?.name)
    Worker.queue.execute {
        Goal.findAll(matching: goalParams, completion)
    }
}
```

## License

The project does not need a license :)
