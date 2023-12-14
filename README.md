### MoveMockMacros

**Overview**

MoveMockMacros is a Swift macro library designed to facilitate the creation of mock implementations for Swift protocols. It provides a set of macros that automatically generate mock classes based on a given protocol, allowing developers to focus on testing their code without the need to manually create mock implementations.

**Features**

* @Mock Macro: Apply the `@Mock` attribute to a protocol declaration to generate a corresponding mock class with all required methods and properties.

**Installation**

1. Include the `SwiftSyntaxMacros` and `MoveMockMacros` libraries in your Swift project.
2. Ensure that the SwiftSyntax framework is also included.
3. Apply the `@Mock` attribute to your protocol declarations.

**Usage**

* Basic Example

```swift
@Mock
protocol MyProtocol {
    func doSomething()
    var value: Int { get set }
}
```

* This will generate a MyProtocolMock class with mock implementations for the methods and properties defined in MyProtocol.

**Expending the Macro**
* Right click on the @Mock annotation in your protocol class
* Click expand macro
* View the macro expansion

**How to Run Tests**

* Open your project in Xcode.
* Navigate to the test directory of your project.
* Create an instance of the Mock class you created and use it in tests.
  
  ```swift
  let myProtocolMock = MyProtocolMock()
  ```
* Run the tests to ensure proper functionality.
