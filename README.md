<img alt="Plys logo" src="/help_translator/autoit_11_210x72.jpg" align="right" float="left">

# Plys – AutoIt language superset

<p><strong>• file scope in AutoIt programs</strong></p>

<p><strong>• module-private functions and variables</strong></p>

<p><strong>• python-like import operator</strong></p>

## Light Your AutoIt Code!

This inconspicuous wrapper complements the AutoIt language with

1. preprocessor keyword **#import** "filename" loads only public functions and variables
1. Python-like code blocks by lines indentation (without *endfunc*, *wend* etc.)
1. **dim** and **const** outside of functions means *global* and *global const* respectively, inside of functions means *local* and *local const*
1. arguments of function are *const* by default, but with *dim* prefix it becomes variable
1. lighter [synonyms](synonyms.md) for functions, macros and operators as a rule using in large projects: for arrays, files and strings
1. no “$”-prefix in variable names
1. one-line anonymous functions
1. and each of this **is optional**


## Setup

**Requirements:** [AutoIt](https://www.autoitscript.com/site/autoit/downloads/) (minimum), [AutoIt Script Editor](https://www.autoitscript.com/site/autoit-script-editor/downloads/) (optionally).


1. Download and unpack archive from [latest release](https://github.com/NSUSpray/Plys/releases/latest).
1. Double click the “setup.aup.au3” file and follow to setup instructions.


## Extra options

You can use extra options for each file by typing in the script one of this:

```autoit
#plys dollarprefix  ; refuse to use variables without “$” prefix
#plys noconst  ; use default variable declarations behavior
#plys noindent  ; ignore indentation but obligue to use “endif/wend/etc”.
#plys noimport  ; refuse the import operator
#plys nosynonyms  ; refuse the function and macro synonyms
#plys nolambda  ; refuse the anonymous functions
```


## Environment

After installation Plys already integrated to Windows shell. If you want to run a script by command line use

```<AutoIt3.exe path> <AutoIt3exe folder>\Plys\plys.au3 [/Rapid] [/ErrorStdOut] [/NoStdio] <script path> [<arguments>]```

`/Rapid` means that if source files have not be modified since the previous run, they will not be re-translated. This option speeds up script execution startup.

The `/ErrorStdOut` switch allows the redirection of a fatal error to StdOut which can then be captured by an application.

Also you can turn off data exchange through standard input/output streams, then the shell process will not hang in memory, but then you will not be able to observe the output of your program in the output window of your development environment. You can do this by adding the `/NoStdio` option.

If you want to translate a script to pure AutoIt code use

```<AutoIt3.exe path> <AutoIt3exe folder>\Plys\plys.au3 [/Translate] <script path>```

Try [AutoIt Plys package](https://github.com/NSUSpray/AutoItPlysSublime) for [Sublime Text](https://www.sublimetext.com/) which including syntax highlighting, comments toggling, auto-completions, build systems for run and compile, context help, Tidy and Include Helper command for AutoIt and AutoIt Plys.

You can compile the script, specifying to the compiler the translating file *\*.aup.au3*.


## How it works

The *plys.aup.au3* file contains the code that will run immediately after the launch of your script. On setup this file will copy to AutoIt install dir (Program Files\AutoIt3\Plys\plys.aup.au3) and aup-files will associated with it. On the launch aup-files are automatically processed, after which the new AutoIt process interprets the already converted code, and the current process remains cycle to continue data exchange with the new process via standard streams. This handler replaces all *#import* with *#include*. The processed files get the extension *.aup.au3* and are placed in the folder of the original script with *hidden* attribute.


[Read more on the AutoIt forum](https://www.autoitscript.com/forum/topic/198342)