# C++ Notes

Chapter 4 of **C++ Crash Course - No Starch Press (2019)**

- [Object Life Cycle](#object-life-cycle)
  - [Object's Storage Duration](#objects-storage-duration)
    - [Automatic Storage Duration](#automatic-storage-duration)
    - [Static Storage Duration](#static-storage-duration)
    - [Thread-local Storage Duration](#thread-local-storage-duration)
    - [Dynamic Storage Duration](#dynamic-storage-duration)
  - [Exceptions](#exceptions)
    - [Standard Exception Classes](#standard-exception-classes)
    - [Handling Exceptions](#handling-exceptions)
    - [`noexcept` keyword](#noexcept-keyword)
    - [Call stacks](#call-stacks)
    - [Throwing in destructor](#throwing-in-destructor)
    - [Exceptions and Performance](#exceptions-and-performance)
  - [Copy Semantics](#copy-semantics)
    - [Copy Constructor](#copy-constructor)
    - [Copy Assignment](#copy-assignment)
    - [Default Copy](#default-copy)
  - [Move Semantics](#move-semantics)
    - [Value Categories](#value-categories)
    - [*lvalue* and *rvalue* References](#lvalue-and-rvalue-references)
    - [The `std::move` function](#the-stdmove-function)
    - [Move Construction](#move-construction)
    - [Move Assignment](#move-assignment)
    - [Compiler-Generated Methods](#compiler-generated-methods)

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
- If destructor throws during call stacks unwinding -> C++ runtime will call `std::terminate()` to abort the program.

#### Exceptions and Performance

Kurt Guntheroth, the author of Optimized C++, puts it well:
> “use of exception handling leads to programs that are faster
> when they execute normally, and better behaved when they fail.”

When a C++ program executes normally (without exceptions being thrown), there is no runtime overhead associated with checking exceptions. It’s only when an exception is thrown that you pay overhead.

Exceptions are elegant because of how they fit in with RAII objects. When destructors are responsible for cleaning up resources, stack unwinding is a direct and effective way to guarantee against resource leakages.

### Copy Semantics

Rules for making copies of objects: after x is copied into y, they’re *equivalent* and *independent*. That is, `x == y` is true after a copy (equivalence), and a modification to x doesn’t cause a modification of y (independence).

#### Copy Constructor

Is used when an object is constructed and intialized with values of another object of the same class.

Signature
```cpp
SomeClass( const SomeClass& other );
```
Usage:
```cpp
void foo(SomeClass sc)
{
    ...
}

{
    SomeClass a;
    SomeClass b{ a };   // copy-ctor is invoked

    foo( a );           // copy-ctor is used when passing object by-value to function
}
```

#### Copy Assignment

Major difference from copy constructor is that in `b = a`, b might already have a value. You must clean up b's resource before copying a.

*Warning:*
> The default copy assignment operator for simple types just copies the members from the source object to the destination object. In the case of SimpleString, this is very dangerous for two reasons.
> * First, the original SimpleString class’s buffer gets rewritten without freeing the dynamically allocated char array.
> * Second, now two SimpleString classes own the same buffer, which can cause dangling pointers and double frees.
>
> You must implement a copy assignment operator that performs a clean hand-off.

Signature:
```cpp
SomeClass& operator=( const SomeClass& other )
{
    if ( this != &other ) {
        // clean up this and copy other here
    }
    return *this;
}
```

#### Default Copy

Note:
> Any time a class manages a resource, you must be extremely careful with default copy semantics; they're likely to be wrong.
> 
> If you accept the default copy ctor and assignment by the compiler, you should explicitly declare that using `default` keyword:
> ```cpp
> SomeClass( const SomeClass& ) = default;
> SomeClass& operator=( const SomeClass& ) = default;
> ```
> If you want to disable default copy because your class simply cannot or should not be copied - for example, if your class manages a file or if it represents a mutual exclusion lock for concurrent programming - you can use `delete` keyword:
> ```cpp
> UnCopiable( const UnCopiable& ) = delete;
> UnCopiable& operator( const UnCopiable& ) = delete;
> ```

### Move Semantics

Often, you just want to *transfer ownership* of resources from one object to another. You could make a copy and destroy the original, but this is often inefficient. Instead, you can *move*.

After an object y is *moved into* an object x, x is equivalent to the former value of y. After the move, y is in a special state called the *moved-from* state. You can perform only two operations on moved-from objects: (re)assign them or destruct them. Note that moving an object y into an object x isn’t just a renaming: these are separate objects with separate storage and potentially separate lifetimes.

#### Value Categories

Every expression has two important characteristics: its *type* and its *value category*. A value category describes what kinds of operations are valid for the expression.

An *lvalue* is any value that has a name, and an *rvalue* is anything that isn’t an lvalue.

Reference: [Understanding lvalues, rvalues and their references](https://www.fluentcpp.com/2018/02/06/understanding-lvalues-rvalues-and-their-references/)

#### *lvalue* and *rvalue* References

```cpp
someFunc( type& l );    // lvalue reference
someFunc( type&& r );   // rvalue reference
```

For example:
```cpp
void refType( int& x ) {
    std::cout << "lvalue ref = " << x << std::endl;
}

void refType( int&& x ) {
    std::cout << "rvalue ref = " << x << std::endl;
}

int main()
{
    auto x = 1;
    refType( x );       // invoke refType(int&) because x is a lvalue (has a name)
    refType( 2 );       // invoke refType(int&&) because value 2 is an integer literal
    refType( x + 2 );   // invoke refType(int&&) because value x+2 is not bound to a name
    return 0;
}
```

#### The `std::move` function

This function is to *cast* an lvalue reference to an rvalue reference.

> The C++ committee probably should have named std::move as std::rvalue, but it’s the name we’re stuck with. The std:move function doesn’t actually move anything— it casts.

```cpp
#include <utility>
...
int main()
{
    auto x = 1;
    refType( x );       // invoke refType(int&) because x is a lvalue (has a name)
    refType( std::move(x) );    // invoke refType(int&&)
    refType( 2 );       // invoke refType(int&&) because value 2 is an integer literal
    refType( x + 2 );   // invoke refType(int&&) because value x+2 is not bound to a name
    return 0;
}
```

#### Move Construction

Signature:
```cpp
SomeClass( SomeClass&& other ) noexcept
{
    // shallow copy fields of other
    // clear out all fields of other
}
```

Because `other` is an rvalue ref, you're allowed to destroy it. You can copy all fields of `other` into this and then zero out the fields of `other`. The latter step is important because it puts `other` in a *moved-from* state.

```cpp
SimpleString( SimpleString&& other ) noexcept
    : maxSize_{ other.maxSize_ }
    , data_{ other.data_ }
    , length_{ other.length_ }
{
    other.maxSize_ = 0;
    other.data_ = nullptr;
    other.length_ = 0;
}
```

Move construction is a lot less expensive than copy construction when class needs to allocate big amount of data.

The move ctor is designed to *not* throw an exception. Your preference should be to use `noexcept` move ctors.

#### Move Assignment

Signature:
```cpp
SomeClass& operator=( SomeClass&& other ) noexcept
{
    if ( this != &other ) {
        // *move* other to this
    }
    return *this;
}
```

Example:
```cpp
  SimpleString& operator=( SimpleString&& other ) noexcept
  {
    if ( this != &other ) {
      delete [] data_;
      maxSize_ = other.maxSize_;
      data_ = other.data_;
      length_ = other.length_;

      other.maxSize_ = 0;
      other.data_ = nullptr;
      other.length_ = 0;
    }
  }
  ...

  SimpleString a{ 50 };
  a.appendLine( "Hello!" );

  SimpleString b{ 50 };
  b.appendLine( "How ddya!" );

  b = std::move( a );   // b now owns a's data and a cannot be used
```

#### Compiler-Generated Methods

Five methods govern move and copy behavior:
* The destructor
* The copy constructor
* The move constructor
* The copy assignment operator
* The move assignment operator

Rule of five:
![Rule of five](https://i.stack.imgur.com/CVtPu.jpg)

If you provide nothing, the compiler will generate all fives dtor/copy/move functions. This is the *rule of zero*.

If you explicitly define any of dtor/copy_ctor/copy_assign then you'll get all three. Copies are used in place of moves.

Finally, if you provide only move semantics for your class, the compiler will not automatically generate anything except a destructor.
