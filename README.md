# AwesomeSwiftSocks

A library to handle sockets in Swift.

AwesomeSwiftSocks is devided into two layer of abstraction.

###  1. Sockets

Sockets are wrappers arounds C-style sockets. You can connect to a remote server, send and receive messages.
For exemple, to get a website:

```swift
// Create the socket
let socket = ClientSocket(url: "www.moraybaruh.com", port: 80)
// Connect to the host
guard socket.connect() else
{
	print("Connection Failed")
	return
}
// Send a simple HTTP GET request
socket.send("GET / HTTP/1.1\r\n")
socket.send("host: www.moraybaruh.com\r\n\r\n")
let received = NSMutableData()
// Retreive all the data sent by the server
while let data = socket.read(1)
{
	received.appendData(data)
}
print(String(data: received, encoding: NSUTF8StringEncoding)!)
// Connection is closed when the socket is destroyed
```

Another use of sockets is to handle a server. This can be done in the following way:

```swift
// Create the socket
let socket = ServerSocket(port: 4242)
// Start listening for incomming connections
guard socket.listen() else
{
	print("Couldn't start server")
	return true
}
// Accept and handle all incomming connections.
socket.acceptAll
{
	clientSocket in
	clientSocket.send("Hello AwesomeSwiftSocks")
}
```

### 2. Connections and servers

Connections are the abstraction of the `ClientSocket` class. It manages a connection to a remote host
without blocking your current thread. It is similar to `NSURLConnection` but offers more flexibility.
To handle a connection, you need to implement the `SocketConnectionDelegate` protocol:

```swift
/**
 *  Defines methods to properly handle socket
 *  connections.
 */
public protocol SocketConnectionDelegate : class
{
  /// Called when the connection has been estabished with success.
  func socketConnectionDidConnect(socketConnection : SocketConnection)
  /// Called when the connection couldn't be established.
  func socketConnectionDidFailToConnect(socketConnection : SocketConnection)
  /// Called when the connection has ended.
  func socketConnectionDidDisconnect(socketConnection : SocketConnection)
  /// Called when the connection has received some data.
  func socketConnection(socketConnection : SocketConnection, didReciveData data : NSData)
}
```

This way, you will be notified of any event occuring within the connection. These methods are
always called on the main thread. You can start a conection the following way:

```swift
let connection = SocketConnection(url: myURL, port: myPort)
connection.delegate = myDelegate
connection.startConnection()
```

Servers are the abstraction of the `ServerSocket` class. The handling of a server is very similar to
connections'. To get started with server, just implement the `SocketServerDelegate`:


```
/**
 *  Defines methods to properly handle events on a `SocketServer`.
 */
public protocol SocketServerDelegate : class
{
  /// Called when the server has been started successfully.
  func socketServerDidStart(socketServer : SocketServer)
  /// Called when the server has failed to start.
  func socketServerDidFailToStart(socketServer : SocketServer)
  /// Called when the server has accepted a client.
  func socketServer(socketServer : SocketServer, didAcceptClient clientSocket : ClientSocket)
  /// Called when the server has stopped.
  func socketServerDidStop(socketServer : SocketServer)
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AwesomeSwiftSocks is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AwesomeSwiftSocks"
```

## Author

Moray Baruh, contact@moraybaruh.com

## License

AwesomeSwiftSocks is available under the MIT license. See the LICENSE file for more info.
