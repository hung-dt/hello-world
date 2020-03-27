# C++ Notes
Chapter 4 of **C++ Crash Course - No Starch Press (2019)**
## Object Life Cycle

### Object's Storage Duration

#### Automatic Storage Duration
- an automatic object is allocated at the beginning of a scope and deallocated at the end of the scope.
- function parameters are also automatic

#### Static Storage Duration
- A static object is declared using `static` or `extern` keyword.
  - At global scope (or namespace scope) --> allocated when program starts and deallocated when program exits.
  - At function scope --> called `local static variable` starts lifetime when function is first called and ends when program exits.
  - At class scope --> called `static member` has static storage duration (same as global)
  
#### Thread-local Storage Duration
- You can make code thread-safe by specifying that an static object has `thread storage duration` by adding `thread_local` keyword to the `static` or `extern`.
- By specifying `thread_local` each thread will have its own copy of the variable. Mofications to one thread_local will not affect other threads.

```cpp
void powerUpRatThing(int nuclearIsotopes)
{
  static thread_local int ratThingsPower = 200;
  ...
}
```

#### Dynamic Storage Duration
- Dynamic objects are allocated and deallocated on request. You have total control over the lifetime of these objects.

### Exceptions
Exceptions are types that communicate an error condition.
```cpp
#include <stdexcept>

throw std::runtime_error{ "Runtime error happened!" };
```
#### Standard Exception Classes
![stdexcept](https://people.eecs.ku.edu/~jrmiller/Courses/268/Materials/Exceptions/C++ExceptionHierarchy.png)

#### Handling Exceptions
- Rules are based on class inheritance. Catch exceptions if thrown type:
  - Matches catch type
  - Sub-class of catch type

#### `noexcept` keyword
- Mark a function that never throw exception with `noexcept` keyword.
```cpp
bool isOdd( const int x ) noexcept
{
  return x % 2 != 0;
}
```
- If your code throws an exception inside a function marked noexcept, the C++ runtime will call `std::terminate()` to abort the program.
- Marking a function noexcept enables some code optimizations that rely on the function’s not being able to throw an exception. Essentially, the compiler is liberated to use move semantics, which may be faster.

#### Call stacks
The runtime seeks the closest exception handler to a thrown exception. If there is a matching exception handler in the current stack frame, it will handle the exception. If no matching handler is found, the runtime will unwind the call stack until it finds a suitable handler.

#### Throwing in destructor
- Destructor should not throw -> treat destructors as if they were noexcept.
- Destructor must catch and handle exceptions.
- If desctructor throws during call stacks unwinding -> C++ runtime will call std::terminate() to abort the program.

#### Exceptions and Performance

Kurt Guntheroth, the author of Optimized C++, puts it well:
> “use of exception handling leads to programs that are faster
> when they execute normally, and better behaved when they fail.”

When a C++ program executes normally (without exceptions being thrown), there is no runtime overhead associated with checking exceptions. It’s only when an exception is thrown that you pay overhead.

Exceptions are elegant because of how they fit in with RAII objects. When destructors are responsible for cleaning up resources, stack unwinding is a direct and effective way to guarantee against resource leakages.

### Copy Semantics
