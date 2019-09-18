# Introduction

This repository consists of programming exercises written in Hack to solve the "Term Frequency" problem from [Exercises in Programming Style](https://www.amazon.com/Exercises-Programming-Style-Cristina-Videira/dp/1482227371/) book.

The book is written by UCI professor [Cristina Videira Lopes](https://www.ics.uci.edu/~lopes/) from the materials developed in her [INF 212 Analysis of Programming Languages](https://www.ics.uci.edu/~lopes/teaching/inf212W15/index.html) class. It gets the inspiration from [Amazon\.com: Exercises in Style](https://www.amazon.com/Exercises-Style-Raymond-Queneau/dp/0811207897/), a literature book written in 1940's where the author tells the same story in 99 different literature styles. 

Similarly EiPS solves the same problem, the [Term Frequency](https://en.wikipedia.org/wiki/Tf%E2%80%93idf#Term_frequency) (TF) problem, which is about counting the occurrence frequency of the words of a given text. (The example text used in the book is "Pride and Prejudice" by Jane Austen). The requirement of the exercises is to print out 25 most frequent words (excluding "stopping words" such as "the", "in", "a" etc.) and their counts in a descending order. A simple problem is chosen to keep the algorithm design out of the discussion and to focus only on programming paradigms and structuring the code.

This repo is my attempt to translate and reproduce the styles used in the book to [Hack Programming Language](https://hacklang.org/). I don't think that I implemented the styles in the most idiomatic way for Hack. Please give me feedback if certain style could be formulized in Hack in a better, different way.

# Styles implemented in Hack

The book uses non-conventional names for the styles it discusses. Following is the list of styles the way they named in the book and more widely recognized names for them:

1. Good Old Times: No variable names, no functions, limited memory. Assuming the text won't fit to the memory and disk usage is needed.
1. Go Forth: Stack Machine. Paradigm of [Forth (programming language) - Wikipedia](https://en.wikipedia.org/wiki/Forth_(programming_language))
1. Monolith: No abstractions. No functions, classes. One giant block of statements.
1. Cookbook: Procedural. Code split into functions manipulating a global state.
1. Pipeline: Functional / Pipeline. Code split into functions without side effects that are chained.
1. Code Golf: Shortest lines of code.
1. Infinite Mirror: Recursion
1. Kick Forward: Continuation-passing. Giving to function to be called on the return value, to the function itself.
1. The One: Monadic Identity / Imperative Functional. One entity that wraps and binds all no-side-effect functions.
1. Things: Objects. As in Object Oriented Programming.
1. Letterbox: Messaging. Instead of having public methods, object communicate with each other with messages that tells the directive and parameters.
1. Closed Maps: Prototype. JavaScript style objects.
1. Abstract Things: Abstract Data Types. Abstract classes with partial implementations that are meant to be fully implemented in concrete classes inheriting them.
1. Hollywood: Callback Hell / Inversion of Control. Objects are not directly called by their methods but their handles are registered callback functions. 
1. Bulletin Board: Publisher/Subscriber. Objects are neither call or be called directly. They publish or read messages to/from domains/categories to which they subscribed.
1. Introspective: Introspective. Programming entities have access to meta-level information about the program's execution (such as list of local variables or content of local scope stack)
1. Reflective: Program entities can add or modify other entities in run-time. (I failed at implementing this in Hack.)
1. Aspects: Aspect-Oriented. Ability to add/modify functionality of certain entities without editing their code. (My attempt to implement this was to imitate Decorator pattern in Hack as much as possible.)
1. Plugins: Dynamically Loadable Modules. Such as DLL files in Windows and SO files in Unix. (My attempt to implement this was to use different implements of the same function chosen in a configuration file. AFAIK HHVM does not have dynamically loaded modules, even though the virtual machine can be extended with statically loaded modules.)
1. Constructivist: Constructive. Checking sanity of input arguments and falling back to meaningful defaults instead of stopping execution.
1. Tantrum: Design by contract. Stopping execution by throwing exception for everything unexpected.
1. Passive Aggressive: Exceptions. Jumping out of the function and letting higher-order functions to deal with catching exceptions and dealing with them.
1. Declared Intentions: Type Checking (in run-time). Hack already comes with a static type-checker. Here I attempted to not use Hack types in function declarations but check inputs via a decorator pattern.
1. Quarantine: Monadic IO, lazy evaluation. Similar to "The One". But distinguishes wrapped functionalities between the ones that have side-effects and that don't. Lazily evaluates side effects at the last moment.
1. Persistent Tables: Relational Database. Call SQL from Hack (via SQLite).
1. Spreadsheet: Spreadsheet, active data. Entities that represent columns in an Excel-like spreadsheet where data and formula can be entered and an `update` call will compute the values to display when data fields change.
1. Lazy rivers: generators, data stream. Input, processing and output are streams. Allows processing of infinitely big, online inputs. My favorite style for this problem. Implemented using `yield`.
1. Actors: multi-threaded messaging. (I failed at implementing this in Hack.)
1. Dataspaces: multi-thread shared memory, data intensive parallelism. (I failed at implementing this in Hack.)
1. Map-Reduce: Map-Reduce. Splitting input into workers that can run in parallel for map phase. Their results are collected and processed by a single reduce worker. (My implementation does not use multi-processes.)
1. Double Map-Reduce: Hadoop. Google style map-reduce where reduce phase can be parallelized too. (My implementation does not use multi-processes.)
1. Trinity: Model-View-Controller. Abstracting the functionalities into 3 components, one to represent the data (model), one to implement how that will be displayed (view) and one to bring that data and invoke viewing (controller).
1. RESTful: splitting application between client and a server that communicate via a request/respond protocal, where servers don't keep state of the app state, and client have to indicate the state at each request. (I did not implemented this yet. Because it does not makes sense for CLI mode. Maybe in the future I'll write a server for this.)

# Setup

* Install HHVM: https://docs.hhvm.com/hhvm/installation/linux
* Install Composer: https://getcomposer.org/ (requires PHP)
* Using composer, install dependencies: `php composer.phar install`
* Get Pride and Prejudice `wget https://raw.githubusercontent.com/crista/exercises-in-programming-style/master/pride-and-prejudice.txt`

# Run a Style Exercise

```
hhvm bin/run_exercise.hh EXERCISE INPUT
```

For example, run following command from project folder.

```
hhvm bin/run_exercise.hh src/05_cookbook.hack src/small_input.txt
```

it outputs

```
live - 2
mostly - 2
white - 1
tigers - 1
india - 1
wild - 1
lions - 1
africa - 1
```
