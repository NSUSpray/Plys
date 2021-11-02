<p><strong>- file scope in AutoIt programs</strong></p>

<p><strong>- module-private functions and variables</strong></p>

<p><strong>- python-like import operator</strong></p>

# Light Your AutoIt Code

This inconspicuous wrapper complements the AutoIt language with

1. preprocessor keyword **#import** in addition to *#include* similar to [*import* in Python](https://en.wikibooks.org/wiki/Python_Programming/Modules#Importing_a_Module)
1. Python-like blocking by lines indentation (without *endfunc*, *wend* etc.)
1. **dim** and **const** outside of functions means *global* and *global const* respectively, inside of functions means *local* and *local const*
1. arguments of function are *const* by default, but with *dim* prefix it becomes variable
1. short synonyms for functions as a rule using in large projects: for arrays, files and strings
1. no “$”-prefix in variable names

```autoit
; file “mylib.aup”

dim bar, _bar

func foo()
    bar = _foo()

func _foo(dim str="word/number/space")
    _bar = Sort(Split(str, "/", @NoCount))
```

```autoit
; file “main.aup”

#import "mylib.aup"
```

In this example variable *_bar* and function *_foo()* are private for module *mylib.aup* (names begin with an underscore) and not visible in *main.aup*. Variable *bar* and function *foo()* will be visible with the “mylib:” prefix:

```autoit
; file “main.aup”

#import "mylib.aup"

bar = foo()                 ; error: no bar and foo() in this scope
mylib:bar = mylib:foo()     ; OK: bar and foo() are public in “mylib” scope
mylib:_bar = mylib:_foo()       ; error: _bar and _foo() are private in “mylib” scope
```

*Sort* is synonym for _ArraySort, *Split* is synonym for StringSplit, *@NoCount* is synonym for $STR_NOCOUNT.


## How to use this wrapper

1. Place the “plys.au3” file in the “Include” folder (*C:\Program Files (x86)\AutoIt3\Include\*).
1. Make in your project folder au3-file with this content
    ```autoit
    #include <plys.au3>
    #plys "MainFileOfMyProject.aup"
    
    ; run me!
    ```
1. Then, if you have the files *module1.aup* and *module2.au3* with the same names
    ```autoit
    ; module1.aup
    
    dim bar, _bar
    
    func foo()
        ; instructions
    ```
    ```autoit
    ; module2.au3
    
    global $bar
    
    func foo()
        ; instructions
    endfunc
    
    func _foo()
        ; instructions
    endfunc
    ```
    you can write in your program like this
    ```autoit
    ; MainFileOfMyProject.aup
    
    #import "module1.aup"
    #import "module2.au3"
    
    module1:bar = module2:foo()
    ;module1:_bar = module2:_foo()      ; error because _bar and _foo() are private (with underscore prefix)
    
    #import "module2.au3"       ; re-importing files without "#include-once" will not lead to errors
    ```

You can turn off data exchange through standard input/output streams, then the shell process will not hang in memory, but then you will not be able to observe the output of your program in the output window of your development environment. You can do this by adding a line to the main file of your program
```autoit
#plys nostdio
```

You can disable autorun of your program altogether, keeping only the generation of executable files, for example, for further compilation, adding the line to the main file of your program
```autoit
#plys norun
```

Then you can compile the program, specifying to the compiler the resulting file *main.aup.au3*, if the main file of your program is called *main.aup*.

File processing is pretty dumb, so bugs are possible.


## How it works

The *plys.au3* file contains the code that is run immediately after the launch of your program: files are automatically processed, after which the new AutoIt process interprets the already converted code, and the current process remains cycle to continue data exchange with the new process via standard streams. This handler replaces all *#import* with *#include*. The processed files get the extension *.aup.au3* and are placed in the folder of the original script with *hidden* attribute.


## TODO

* #import **from** "*filename.aup*"
    ```autoit
    #import from "mylib.aup"
    
    bar = foo()     ; bar and foo will be taken from the "mylib.aup"
    ```

* #import "*filename.aup*" as **alias**
    ```autoit
    #import "mylib.aup" as ml
    
    ml:bar = ml:foo()       ; bar and foo will be taken from the "mylib.aup"
    ```

* Optimize translation speed