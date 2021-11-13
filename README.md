<div align="center">
<h3>Light Your AutoIt Code!</h3>
<br>

<table>
<tr><th>AutoIt</th><th>AutoIt Plys</th></tr>
<tr align="left"><td><sub>

```autoit
; −−−−−−−−−−−−−−−−−−−− lib1.au3 −−−−−−−−−−−−−−−−−−−− ;

#include <StringConstants.au3>

Func __Lib1_Merge(Const $a, Const $b, Const $c, $d="")
  If $d = "" Then
    Local Const $t = $a($b, $c)
    $d = $a(@CRLF & $b & @CRLF & $t & @CRLF, $t)
  Else
    $d &= $a($c & @CRLF & $b, $d)
  EndIf
  Return _
    StringRegExpReplace _
      ($d, "(" & $b & ")" & $b, "$1" & $c) & _
    UBound(StringRegExp _
      ($d, $c, $STR_REGEXPARRAYGLOBALFULLMATCH))
EndFunc


; −−−−−−−−−−−−−−−−−−−− lib2.au3 −−−−−−−−−−−−−−−−−−−− ;

#include "lib1.au3"

Func __Lib2_Xyx(Const $x, Const $y)
  Return $x & $y & $x
EndFunc

Global $r = __Lib1_Merge(__Lib2_Xyx, "S", "T")
For $i = 1 To 5
  $r = "<" & $r & ">"
  ConsoleWrite("$r = " & $r & @CRLF)
Next
```

</sub></td><td><sub>

```autoit
; −−−−−−−−−−−−−−−−−−−− lib1.aup −−−−−−−−−−−−−−−−−−−− ;

func merge*(a, b, c, dim d="")
  if d = "" then
    const t = a(b, c)
    d = a(@ . b . @ . t . @, t)
  else
    d .= a(c . @ . b, d)
  return _
    ReReplace(d, "(" . b . ")" . b, "$1" . c) . _
    UBound(ReFind(d, c, @ReArrayGlobalFull))


; −−−−−−−−−−−−−−−−−−−− lib2.aup −−−−−−−−−−−−−−−−−−−− ;

#import "lib1.aup"

dim r = lib1:merge({x, y: x . y . x}, "S", "T")
for i = 1 to 5
  r = "<" . r . ">"
  Echo("r = " . r . @)













```

</sub></td></tr>
</table>
</div>

# Plys – AutoIt language superset

<p><strong>• file scope in AutoIt programs</strong></p>

<p><strong>• module-private functions and variables</strong></p>

<p><strong>• python-like import operator</strong></p>


This inconspicuous wrapper complements the AutoIt language with

1. preprocessor keyword **#import** in addition to *#include* similar to [*import* in Python](https://en.wikibooks.org/wiki/Python_Programming/Modules#Importing_a_Module)
1. Python-like blocking by lines indentation (without *endfunc*, *wend* etc.)
1. **dim** and **const** outside of functions means *global* and *global const* respectively, inside of functions means *local* and *local const*
1. arguments of function are *const* by default, but with *dim* prefix it becomes variable
1. lighter [synonyms](synonyms.md) for functions, macros and operators as a rule using in large projects: for arrays, files and strings
1. no “$”-prefix in variable names
1. one-line anonymous functions
1. and **each of this is optional**


## Overview

```autoit
; file “mylib.aup”

dim foo*, bar

func baz*()
    foo = quux()

func quux(dim arg="one/two/three")
    bar = Sort(Split(arg, "/", @NoCount))
    return "begin" . @ . bar[0] . @ . "end"
```

```autoit
; file “main.aup”

#import "mylib.aup"
...
```

In this example variable *bar* and function *quux()* are private for module *mylib.aup* (names at declaration ends with an asterisk) and not visible in *main.aup*. Variable *foo* and function *baz()* will be visible with the “mylib:” prefix:

```autoit
; file “main.aup”

#import "mylib.aup"

foo = baz()  ; error: no foo and baz() in this scope
mylib:foo = mylib:baz()  ; OK: foo and baz() are public in “mylib” scope
mylib:bar = mylib:quux()  ; error: bar and quux() are private in “mylib” scope
```

*Sort* is synonym for \_ArraySort, *Split* is synonym for StringSplit, *@NoCount* is synonym for $STR_NOCOUNT, “*@*” is synonym for @CRLF, “*.*” is synonym for “&” operator. See [full list](synonyms.md).


## Setup

**Requirements:** [AutoIt](https://www.autoitscript.com/site/autoit/downloads/) (minimum), [AutoIt Script Editor](https://www.autoitscript.com/site/autoit-script-editor/downloads/) (optionally).


1. Download and unpack archive from [latest release](https://github.com/NSUSpray/Plys/releases/latest).
1. Double click the “setup.au3” file and follow to setup instructions.


## First steps

1. Right-click in the any folder and select `New > AutoIt Plys Script`.
1. Right-click on the created file again and select `Edit Script`.
1. At the bottom of the file type the following:

    ```autoit
    #include <MsgBoxConstants.au3>
    dim msg = ""
    for i = 1 to 10
        msg .= "Hello World!" . @
    msg = TrimRight(msg, 1)
    MsgBox(MB_OK, "My First Plys Script", msg)
    ```

1. Save the script and double-click the file for run (or right-click the file and select `Run Script`).


## Extra options

You can use extra options by typing in the script one of this:

```autoit
#plys dollarprefix  ; refuse to use variables without “$” prefix
#plys noconst  ; use default variable declarations behavior
#plys noindent  ; ignore indentation but obligue to use “endif/wend/etc”.
#plys noimport  ; refuse the import operator
#plys nosynonyms  ; refuse the function and macro synonyms
#plys lambda  ; enable anonymous functions (beta)
```

Also you can turn off data exchange through standard input/output streams, then the shell process will not hang in memory, but then you will not be able to observe the output of your program in the output window of your development environment. You can do this by adding a line to the main file of your program

```autoit
#plys nostdio
```


## Environment

After installation Plys already integrated to Windows shell. If you want to run a script by command line use

```<AutoIt3.exe path> <AutoIt3exe folder>\Plys\plys.au3 [/ErrorStdOut] <script path> [<arguments>]```

If you want to translate a script to pure AutoIt code use

```<AutoIt3.exe path> <AutoIt3exe folder>\Plys\plys.au3 [/Translate] <script path>```

Try [AutoIt Plys package](https://github.com/NSUSpray/AutoItPlysSublime) for [Sublime Text](https://www.sublimetext.com/) which including syntax highlighting, comments toggling, auto-completions, build systems for run and compile, context help, Tidy and Include Helper command for AutoIt and AutoIt Plys.

You can compile the script, specifying to the compiler the translating file *\*.aup.au3*.


## How it works

The *setup.au3* file contains the code that will run immediately after the launch of your script. On setup this file will copy to AutoIt install dir (as Plys\plys.au3) and aup-files will associated with it. On the launch aup-files are automatically processed, after which the new AutoIt process interprets the already converted code, and the current process remains cycle to continue data exchange with the new process via standard streams. This handler replaces all *#import* with *#include*. The processed files get the extension *.aup.au3* and are placed in the folder of the original script with *hidden* attribute.


## Future

* \#import "*filename.aup*" **noprefix**

    ```autoit
    #import "mylib.aup" noprefix
    bar = foo()
    ; bar and foo will be taken from the “mylib.aup” without “mylib:” prefix
    ```

* \#import "*filename.aup*" as **alias**

    ```autoit
    #import "mylib.aup" as ml
    ml:bar = ml:foo()  ; bar and foo will be taken from the “mylib.aup”
    ```

* function scope functions

    ```autoit
    func GlobalFunc()
        dim var1 = "body"
        func LocalFunc(var2)
            return "begin" . @ . var2 . @ . "end"
        return LocalFunc(LocalFunc(var1))

    MsgBox(MB_OK, "begin/body/end", GlobalFunc())
    ```

* array values in place

    ```autoit
    Display([1, 2, 3])
    ```