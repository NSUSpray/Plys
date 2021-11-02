#include-once
#include "Array.au3"
#include "StringConstants.au3"
#include "TrayConstants.au3"

enum $COMMENT_TYPE, $DIRECTIVE_TYPE, $STRING_TYPE, $MAIN_TYPE

TraySetIcon ("stop")
TraySetState ($TRAY_ICONSTATE_FLASH)
plys ()
exit


;#############################################################################
func plys ()
;#############################################################################
	
	#cs ======================================================================
	#		Configuration
	#ce ======================================================================
	
	local $run = True
	local $stdioExchange = True
	
	; features
	local $noDollarPrefix = True
	global $_CONSTBYDEFAULT = True
	local $closeBlockByIndent = True
		;TODO: local $tab = "\t"
	global $_IMPORTKEYWORD = True
		local const $modulePrivatePrefix = "_"
		local const $newSuffixLen = 2
		local const $nameDelim = ":"		; regular expression
	local $synonyms = True

	; get project settings
	local $Text = FileRead (@ScriptFullPath)
	$run = $run and _
		not StringRegExp ($Text, "(?m)^\#plys norun")
	$stdioExchange = $stdioExchange and _
		not StringRegExp ($Text, "(?m)^\#plys nostdio")
	$noDollarPrefix = $noDollarPrefix and _
		not StringRegExp ($Text, "(?m)^\#plys dollarprefix")
	$_CONSTBYDEFAULT = $_CONSTBYDEFAULT and _
		not StringRegExp ($Text, "(?m)^\#plys noconst")
	$closeBlockByIndent = $closeBlockByIndent and _
		not StringRegExp ($Text, "(?m)^\#plys noindent")
	$_IMPORTKEYWORD = $_IMPORTKEYWORD and _
		not StringRegExp ($Text, "(?m)^\#plys noimport")
	$synonyms = $synonyms and _
		not StringRegExp ($Text, "(?m)^\#plys nosynonyms")
	
	
	#cs ======================================================================
	#		Prepare
	#ce ======================================================================
	
	#cs	$DepTable [n+1][n+1]
	#			$DepTable [0][0] = n				number of files
	#			$DepTable [1-n][0]					relative path to file “n”
	#			$DepTable [0][1-n]					names array of file “n”
	#			$DepTable [i][j] = $include		file “i” includes file “j”
	#ce
	local $DepTable [1][1] = [[0]]
	local const $rel_path = StringRegExp _
		($Text, '(?m)^\#plys\s+"(.+?)"', $STR_REGEXPARRAYMATCH) [0]
	GetDeps ($DepTable, $rel_path)
	local $targetPaths [0]
	
	if $_IMPORTKEYWORD then
		local $ThruTable = $DepTable
		enum $include = 2, $mir_include = 1.5, $import = 1
		local const $directives [] = [$import, $include, $mir_include]
		
		; capture dependencies throught
		local $changed
		do
			$changed = False
			for $row = 1 to $ThruTable [0][0]
				for $col = 1 to $ThruTable [0][0]
					switch $ThruTable [$row][$col]
						case $include ; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
							; “mirror” rule
							if $ThruTable [$col][$row] <= $import then
								$ThruTable [$col][$row] = $mir_include
								$changed = True
							endif
							; “chain” rule for column
							for $y = 1 to $ThruTable [0][0]
								if $y <> $col and _
									$ThruTable [$y][$row] > $ThruTable [$y][$col] _
								then
									$ThruTable [$y][$col] = $ThruTable [$y][$row]
									$changed = True
								endif
							next
						case $import ; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
							; “chain” rule for column
							for $y = 1 to $ThruTable [0][0]
								if $y <> $col and _
									$ThruTable [$y][$row] > $import _
								and _
									$ThruTable [$y][$col] = "" _
								then
									$ThruTable [$y][$col] = $import
									$changed = True
								endif
							next
					endswitch
				next
			next
		until not $changed
		
		; make suffixes
		local const $abc = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", _
			"K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", _
			"X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
		local const $abcLen = UBound ($abc)
		local $suffixes [$DepTable [0][0] + 1]
		local $suffix
		$suffixes [0] = $DepTable [0][0]
		for $module = 1 to $suffixes [0]
			do
				$suffix = ""
				for $i = 1 to $newSuffixLen
					$suffix &= $abc [Random (0, $abcLen - 1, 1)]
				next
			until _ArraySearch ($suffixes, $suffix) = -1
			$suffixes [$module] = $suffix
		next
		
	endif
	
	
	#cs ======================================================================
	#		Process Files
	#ce ======================================================================
	
	local $sourcePath, $targetPath, $isPlysFile
	local $i, $comments, $indentSize, $prevIndentSize, $statement, _
		$j, $split, $sttmnt, $closer, $indent
	local $funcDeclares, $newFuncDeclare, $args
	local $rel_dirSlash, $relrel_dep, $foundInPrev
	local $names, $prefix, $filename, $varPrefix
	
	for $module = 1 to $DepTable [0][0]
		$sourcePath = @ScriptDir & "\" & $DepTable [$module][0]
		$isPlysFile = (PathPart ($sourcePath, "ext") = ".aup")
		$Text = FileRead ($sourcePath)
		
		; Close block by indent
		; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
		if $closeBlockByIndent and $isPlysFile then
			$Text = StringSplit _
				($Text & @CRLF, @CRLF, $STR_ENTIRESPLIT + $STR_NOCOUNT)
			
			$i = -1
			$comments = False
			$prevIndentSize = 0
			local $stack [0]
			while $i + 1 <= UBound ($Text) - 1
				$i += 1
				
				; skip comments and directives (and empty lines)
				if StringRegExp ($Text [$i], "^\s*;") then continueloop
				if $comments then
					if StringRegExp ($Text [$i], _
							"(?i)^\s*(\#ce|\#comments-end)") then _
						$comments = False
					continueloop
				endif
				if StringRegExp _
						($Text [$i], "(?i)^\s*(\#cs|\#comments-start)") then
					$comments = True
					continueloop
				endif
				if StringRegExp ($Text [$i], "^\s*\#") then continueloop
				
				if Mod ($i + 1, 5) = 0 and _
						not StringRegExp ($Text [$i], "^\s*$") then _
					$Text [$i] &= @TAB & @TAB & "; #" & ($i + 1)
				
				$indentSize = StringLen _
					(StringRegExpReplace ($Text [$i], "^(\t*).*", "$1"))
				$statement = _
					StringRegExpReplace ($Text [$i], "^\t*(\w*).*", "$1")
				if StringRegExp ($statement, "(?i)^(else)?if$") then
					$j = $i
					while True
						$split = SplitStatements ($Text [$j])
						if reFindInMain ($split, "(?i)\sthen(\s|$)") then _		; with “then”
							exitloop
						$j += 1
					wend
					if reFindInMain ($split, "(?i)\sthen\h.*?\S") then _		; has “then” expression
						$statement = ""
				endif
				if $indentSize < $prevIndentSize then
					$sttmnt = $statement
					for $is = $indentSize to $prevIndentSize - 1
						if $is > UBound ($stack) - 1 then exitloop
						switch $stack [$is]
							case "if"
								if StringRegExp _
										($sttmnt, "(?i)^else(if)?$") then
									$sttmnt = ""
									continueloop
								endif
								$closer = "endif"
							case "elseif"
								if StringRegExp _
										($sttmnt, "(?i)^else(if)?$") then _
									continueloop
								$closer = "endif"
							case "else"
								$closer = "endif"
							case "select", "switch", "with", "func"
								$closer = "end" & $stack [$is]
							case "for"
								$closer = "next"
							case "while"
								$closer = "wend"
							case else
								continueloop
						endswitch
						$indent = ""
						for $k = 1 to $is
							$indent &= @TAB
						next
						$Text [$i] = $indent & $closer & @CRLF & $Text [$i]
					next
					redim $stack [$indentSize]
				endif
				switch $statement
					case "if", "elseif"
						$i = $j
						continuecase
					case "else", "select", "switch", _
							"for", "while", "with", "func"
						redim $stack [$indentSize + 1]
						$stack [$indentSize] = $statement
				endswitch
				$prevIndentSize = $indentSize
			wend
			$Text = StringTrimRight (_ArrayToString ($Text, @CRLF), 2)
		endif
		
		; No dollar prefix
		; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
		if $noDollarPrefix and $isPlysFile then
			$Text = SplitStatements ($Text)
			$names = $DepTable [0][$module]
			if IsArray ($names) then
				$names = _ArrayToString ($names)
				$names = StringRegExpReplace ($names, "\|\$\w+", "")  ; funcs only
				$names = StringRegExpReplace ($names, "\$\w+\|", "")  ; funcs only
				if $names <> "" then $names = "|" & $names
			else
				$names = ""
			endif
			reReplaceInMain ($Text, "(?i)(?(?=\b(" & _
				"byref|const|continuecase|continueloop|default|dim|do|" & _
				"until|enum|exit|exitloop|false|for|to|step|next|for|in|" & _
				"func|return|endfunc|global|if|then|elseif|else|endif|" & _
				"local|null|redim|select|case|endselect|static|switch|" & _
				"endswitch|true|volatile|with|endwith|while|wend|and|or|" & _
				"not|_" & $names & _
				")\b) |(?<![\w@$])[A-Za-z_]\w*(?!\w*(\s*\(|:|\s*_\W)))", "\$$0")
			$Text = _ArrayToString ($Text, "", -1, -1, "", 0, 0)
		endif

		; Const by default
		; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
		if $_CONSTBYDEFAULT and $isPlysFile then
			$Text = StringRegExpReplace _
				($Text, "(?im)^(const|enum|static)\s+\$", "global $0")
			$Text = StringRegExpReplace _
				($Text, "(?im)^(\s+)((?:const|enum|static)\s+\$)", "$1local $2")
			$Text = StringRegExpReplace _
				($Text, "(?im)^dim(\s+\$)", "global$1")
			$Text = StringRegExpReplace _
				($Text, "(?im)^(\s+)dim(\s+\$)", "$1local$2")
			$funcDeclares = StringRegExp _
				($Text, "(?im)^\s*func\s+.*$", $STR_REGEXPARRAYGLOBALMATCH)
			if IsArray ($funcDeclares) then
				for $funcDeclare in $funcDeclares
					$newFuncDeclare = $funcDeclare
					$args = StringRegExpReplace _
						($funcDeclare, "(?i)\s*func\s+.*?\(\s*(.*)\s*\).*", "$1")
					if $args = "" then continueloop
					$args = StringSplit ($args, ",", $STR_NOCOUNT)
					for $arg in $args		; insert “const”
						if not StringRegExp ($arg, "\b(const|dim)\b") then _
							$newFuncDeclare = StringReplace _
								($newFuncDeclare, $arg, " const " & $arg)
					next
					$newFuncDeclare = StringRegExpReplace _
						($newFuncDeclare, "\bdim\s+", "")		; delete “dim”
					$Text = _
						StringReplace ($Text, $funcDeclare, $newFuncDeclare)
				next
			endif
		endif
		
		; Import
		; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
		if $_IMPORTKEYWORD then
			if $isPlysFile then
				; comment #import if module including or importing alredy been
				for $dep = 1 to $DepTable [0][0]
					if $DepTable [$module][$dep] <> $import then continueloop
					$rel_dirSlash = PathPart ($DepTable [$module][0], "dir")
					$relrel_dep = $DepTable [$dep][0]
					if $rel_dirSlash <> "" then $relrel_dep = _
							StringReplace ($relrel_dep, $rel_dirSlash, "")
					$relrel_dep = StringRegExpReplace _
						($relrel_dep, "[\\\.\^\$\[\(\{\+\#]", "\\$0")
					$Text = StringRegExpReplace _
						($Text, '(?m)^\#(include|import)\s+[<"]' & _
						$relrel_dep & '[>"]', ";PLYS $0")
					$foundInPrev = False
					for $prev = 1 to $module - 1
						if $DepTable [$prev][$dep] then
							$foundInPrev = True
							exitloop
						endif
					next
					if not $foundInPrev then		; uncomment first
						$Text = StringRegExpReplace _
							($Text, '(?m)^;PLYS (\#(include|import)\s+[<"]' & _
							$relrel_dep & '[>"])', "$1", 1)
					endif
				next
			endif
					
			; replace “#include/#import "path\name.ext"”
			; with “#include "path\%target_prefix%name.ext.au3"”
			$Text = StringRegExpReplace ($Text, _
				'(?m)^\#(include' & ($isPlysFile ? "|import" : "") & _
				')\s+"(.*\\)?(.*?)"(.*)$', _
				'#include "$2$3\.au3"$4')
			
			$Text = SplitStatements ($Text)
			
			; replace own names
			$names = $DepTable [0][$module]
			if IsArray ($names) then
				; purified filename
				$prefix = PathPart ($DepTable [$module][0], "dir", "name")
				$prefix = StringRegExpReplace ($prefix, "[^\w]", "_")
				; TODO: загнать имена в шаблон (имя|имя|…) и заменить одним махом
				for $name in $names
					if StringLeft ($name, 1) = "$" then		; is variable
						reReplaceInMain ($Text, _
							"(?im)([^\w""'" & $nameDelim & "]|^)\$(" & _
								StringTrimLeft ($name, 1) & ")([^\w""'])", _
							"$1\$" & $prefix & "_$2__" & $suffixes [$module] & "$3")
					else		; is function
						reReplaceInMain ($Text, _
							"(?im)([^\w""'\$" & $nameDelim & "]|^)(" & $name & ")([^\w""'])", _
							"$1" & $prefix & "_$2__" & $suffixes [$module] & "$3")
					endif
				next
			endif
			
			; replace names from $ThruTable [0][$dep] in $module file
			for $directive in $directives		; import (1), include (2), mir_include (1.5)
				for $dep = 1 to $DepTable [0][0]
					if $ThruTable [$module][$dep] <> $directive then _
						continueloop
					$names = $DepTable [0][$dep]
					if IsArray ($names) then
						; purified filename
						$filename = PathPart ($DepTable [$dep][0], "name")
						$filename = StringRegExpReplace ($filename, "[^\w]", "_")
						$prefix = PathPart ($DepTable [$dep][0], "dir")
						$prefix = StringRegExpReplace ($prefix, "[^\w]", "_")
						$prefix &= $filename
						for $name in $names
							if StringLeft ($name, 1) = "$" then		; is variable
								$name = StringTrimLeft ($name, 1)
								$varPrefix = "\$"
							else
								$varPrefix = ""
							endif
							if $ThruTable [$module][$dep] <> $import then
								reReplaceInMain ($Text, _
									"(?im)([^\w""']|^)" & $varPrefix & $name & "([^\w""'])", _
									"$1" & $varPrefix & $prefix & "_" & $name & "__" & $suffixes [$dep] & "$2")
							elseif StringLeft ($name, 1) <> $modulePrivatePrefix then
								reReplaceInMain ($Text, _
									"(?im)([^\w""']|^)" & $filename & $nameDelim & $varPrefix & $name & "([^\w""'])", _
									"$1" & $varPrefix & $prefix & "_" & $name & "__" & $suffixes [$dep] & "$2")
							endif
						next
					endif
				next
			next
			
			$Text = _ArrayToString ($Text, "", -1, -1, "", 0, 0)
			
		endif
		
		; Synonyms
		; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
		if $synonyms and $isPlysFile then
			$Text = SplitStatements ($Text)
			;
			reReplaceInMain ($Text, "(?i)\bPrint\b", "ConsoleWrite")
			; DllStruct −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
			reReplaceInMain ($Text, "(?i)\bStruct\b", "DllStructCreate")
			reReplaceInMain ($Text, "(?i)\bStructGet\b", "DllStructGetData")
			reReplaceInMain ($Text, "(?i)\bStructGetSize\b", "DllStructGetSize")
			reReplaceInMain ($Text, "(?i)\bStructGetPtr\b", "DllStructGetPtr")
			reReplaceInMain ($Text, "(?i)\bStructSet\b", "DllStructSetData")
			; File −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
			reReplaceInMain ($Text, "(?i)\b(" & _
				"ChangeDir|Copy|CreateShortcut|Flush|GetAttrib|" & _
				"GetEncoding|GetLongName|GetShortcut|GetShortName|" & _
				"GetSize|GetTime|GetVersion|Open|OpenDialog|Read|" & _
				"ReadLine|ReadToArray|Recycle|RecycleEmpty|SaveDialog|" & _
				"SelectFolder|SetAttrib|SetEnd|SetPos|SetTime|Write|" & _
				"WriteLine" & _
				")\b", "File$1")
			reReplaceInMain ($Text, "(?i)\bCreateLink\b", "FileCreateNTFSLink")
			reReplaceInMain ($Text, "(?i)\bFirstFile\b", "FileFindFirstFile")
			reReplaceInMain ($Text, "(?i)\bNextFile\b", "FileFindNextFile")
			; **Close|**Delete|**Exists|**GetPos|Install|**Move
			; String −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
			reReplaceInMain ($Text, "(?i)\b(" & _
				"AddCR|Format|InStr|IsAlNum|IsAlpha|IsASCII|IsDigit|" & _
				"IsLower|IsSpace|IsUpper|IsXDigit|Left|Len|Lower|Mid|" & _
				"Replace|Right|Split|StripCR|StripWS|TrimLeft|TrimRight|" & _
				"Upper" & _
				")\b", "String$1")
			reReplaceInMain ($Text, "(?i)\breFind\b", "StringRegExp")
			reReplaceInMain ($Text, "(?i)\breRepl\b", "StringRegExpReplace")
			; Compare|FromASCIIArray|*IsFloat|*IsInt|**Reverse|ToASCIIArray
			; Win −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
			reReplaceInMain ($Text, "(?i)\b(" & _
				"Activate|Active|Flash|GetCaretPos|GetClassList|" & _
				"GetClientSize|GetProcess|GetTitle|Kill|List|" & _
				"MenuSelectItem|MinimizeAll|MinimizeAllUndo|SetOnTop|" & _
				"SetTitle|SetTrans|Wait|WaitActive|WaitClose|" & _
				"WaitNotActive" & _
				")\b", "Win$1")
			; **Close|**Exists|*GetHandle|**GetPos|*GetState|*GetText|**Move|*SetState
			; Macros −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
			reReplaceInMain ($Text, "(?i)(@)(" & _
				"NoCaseSense|CaseSense|NoCaseSenseBasic|StripLeading|" & _
				"StripTrailing|StripSpaces|StripAll|ChrSplit|EntireSplit|" & _
				"NoCount|EndNotStart|UTF16|UCS2" & _
				")\b", "$Str_$2")
			reReplaceInMain ($Text, "(?i)(@re)(" & _
				"Array|ArrayFull|ArrayGlobal|ArrayGlobalFull"& _
				")\b", "$Str_RegExp$2Match")
			reReplaceInMain ($Text, "(?i)@reMatch\b", "$STR_REGEXPMATCH")
			reReplaceInMain ($Text, "(?i)@ActiveWin\b", 'WinGetHandle("[ACTIVE]")')
			; _Array −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
			reReplaceInMain ($Text, "(?i)\b(" & _
				"Add|ColDelete|ColInsert|Combinations|Display|Extract|" & _
				"FindAll|Insert|Max|MaxIndex|Min|MinIndex|Permute|Pop|" & _
				"Push|Search|Shuffle|Sort|Swap|ToClip|Transpose|Trim|" & _
				"Unique" & _
				")\b", "_Array$1")
			reReplaceInMain ($Text, "(?i)\bToHist\b", "_Array1DToHistogram")
			reReplaceInMain ($Text, "(?i)\bBinSearch\b", "_ArrayBinarySearch")
			reReplaceInMain ($Text, "(?i)\bConcat\b", "_ArrayConcatenate")
			; **Delete|**Reverse|*ToString
			; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
			$Text = _ArrayToString ($Text, "", -1, -1, "", 0, 0) & @CRLF & _
				"#include <StringConstants.au3>" & @CRLF & _
				"#include <Array.au3>"
		endif
		
		$targetPath = PathPart ($sourcePath, "drive", "ext") & ".au3"
		if FileExists ($targetPath) then
			if FileGetTime ($sourcePath, 0, 1) > _
					FileGetTime ($targetPath, 0, 1) or True then
				FileDelete ($targetPath)
				FileWrite ($targetPath, $Text)
				if $run then
					FileSetAttrib ($targetPath, "+H")
					_ArrayAdd ($targetPaths, $targetPath)
				endif
			endif
		else
			FileWrite ($targetPath, $Text)
			if $run then
				FileSetAttrib ($targetPath, "+H")
				_ArrayAdd ($targetPaths, $targetPath)
			endif
		endif
	next
	$Text = ""
	$DepTable = 0
	if $_IMPORTKEYWORD then $ThruTable = 0
	
	
	if $run then
		local const $pid = Run ( _
			@AutoItExe & ' "' & @ScriptDir & "\" & _
			PathPart ($rel_path, "name", "ext") & '.au3" ' & _
			_ArrayToString ($CmdLine, " ", 1), _
			"", default, $STDIN_CHILD + $STDERR_CHILD + $STDOUT_CHILD)
		Opt ("TrayIconHide", 1)
		if $stdioExchange then
			local $timer = TimerInit ()
			while True
				StdinWrite ($pid, ConsoleRead ())
				ConsoleWriteError (StderrRead ($pid))
				ConsoleWrite (StdoutRead ($pid))
				if TimerDiff ($timer) > 1000 then
					if not ProcessExists ($pid) then exitloop
					$timer = TimerInit ()
				endif
				GUIGetMsg ()
			wend
			StdioClose ($pid)
		endif
		;for $targetPath in $targetPaths
		;	FileDelete ($targetPath)
		;next
	endif
	
endfunc


;=============================================================================
func GetDeps (byref $DepTable, const $rel_path)
; Search all #include and #import paths in $rel_path file, add module numbers
; into $DepTable and recursively process this dependencies.
; $rel_* - relative to @ScriptDir, $relrel_* - relative to $rel_path
;=============================================================================
	local $text = FileRead (@ScriptDir & "\" & $rel_path)
	local const $relrel_includes = StringRegExp _
		($text, '(?m)^\#include\s+"(.+?)"', $STR_REGEXPARRAYGLOBALMATCH)
	local const $importEnabled = _
		$_IMPORTKEYWORD and PathPart ($rel_path, "ext") = ".aup"
	if $importEnabled then
		local const $relrel_imports = StringRegExp _
			($text, '(?m)^\#import\s+"(.+?)"', $STR_REGEXPARRAYGLOBALMATCH)
	endif
	local $names = StringRegExp ($text, _
		"(?im)^\s*func\s+(\w*)", _
		$STR_REGEXPARRAYGLOBALMATCH)
	if not IsArray ($names) then local $names [0]
	if $_CONSTBYDEFAULT then
		local $varsDeclares = StringRegExp _
			($text, "(?im)^(?:global|dim|const|enum)\s+(.*)", _
			$STR_REGEXPARRAYGLOBALMATCH)
	else
		local $varsDeclares = StringRegExp _
			($text, "(?im)^global\s+(.*)", $STR_REGEXPARRAYGLOBALMATCH)
	endif
	$text = ""
	if IsArray ($varsDeclares) then
		; FIXME: "const $bar = foo (1, 2)" → ["$bar = foo (1", " 2)"]
		local $newNames
		for $varsDeclare in $varsDeclares
			for $varDeclare in StringSplit ($varsDeclare, ",", $STR_NOCOUNT)
				;$newNames = StringRegExp _
				;	($varDeclare, "(\$\w*)", $STR_REGEXPARRAYGLOBALMATCH)
				;if IsArray ($newNames) then _ArrayAdd ($names, $newNames [0])
				$newNames = StringRegExp _
					($varDeclare, "(\$?[A-Za-z_]\w*)", $STR_REGEXPARRAYGLOBALMATCH)
				if IsArray ($newNames) then _ArrayAdd ($names, _
					StringRegExpReplace ($newNames [0], "^\w", "\$$0", 1))
			next
		next
	endif
	$varsDeclares = ""
	
	; append and init new module cells
	local const $module = $DepTable [0][0] + 1
	redim $DepTable [$module + 1][$module + 1]
	$DepTable [0][0] = $module
	$DepTable [$module][0] = $rel_path
	$DepTable [0][$module] = $names
	$names = ""
	
	enum $include = 2, $import = 1
	local const $directives [] = [$include, $import]
	local $relrel_deps, $rel_dep, $dep
	local const $rel_dirSlash = PathPart ($rel_path, "dir")		; current_file\directory\
	for $directive in $directives
		if $directive = $include then
			$relrel_deps = $relrel_includes
		elseif $importEnabled then
			$relrel_deps = $relrel_imports
		else
			continueloop
		endif
		if not IsArray ($relrel_deps) then continueloop
		
		for $relrel_dep in $relrel_deps
			$rel_dep = $rel_dirSlash & $relrel_dep
			$dep = _ArraySearch ($DepTable, $rel_dep, 1, default, _
				default, default, default, 0)
				; from 1 element in col 0
			if $dep = -1 then		; new path
				GetDeps ($DepTable, $rel_dep)
				$dep = _ArraySearch ($DepTable, $rel_dep, 1, default, _
					default, default, default, 0)
					; from 1 element in col 0
			endif
			$DepTable [$module][$dep] = $directive
		next
		
	next
endfunc


func PathPart (const $path, $start="path", $finish="")
	local const $components = ["path", "drive", "dir", "name", "ext"]
	$start = _ArraySearch ($components, $start)
	if @error then $start = 0
	$finish = _ArraySearch ($components, $finish)
	if @error then $finish = $start
	
	; from _PathSplit (File.au3)
	local const $arraymatch = 1
	local $split = StringRegExp ($path, _
		"^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?" & _
		"((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $arraymatch)
	if @error then ; This error should never happen.
		redim $split [5]
		$split [0] = $path
	endif
	$split [2] = StringRegExpReplace ($split [2], "\h*[\/\\]+\h*", _
		(StringLeft ($split [2], 1) == "/") ? "\/" : "\\")
	
	local $result = ""
	for $i = $start to $finish
		$result &= $split [$i]
	next
	return $result
endfunc


;−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
func SplitStatements (const byref $text)
;−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
	local $split [1][2], $i = 0
	local $result
	local $patterns [4], $type = $MAIN_TYPE
	$patterns [$COMMENT_TYPE] = _
		"(?is)((;.*?|(\#cs|\#comments-start).*?(\#ce|\#comments-end).*?)(\R|\z))"
	$patterns [$DIRECTIVE_TYPE] = "\#.*"
	$patterns [$STRING_TYPE] = "((""|').*?\2)"
	$patterns [$MAIN_TYPE] = "(?s).*?(?=[;""'\#]|\z)"
	local $offset = 1
	local const $len = StringLen ($text)
	while True
		;redim $split [$i + 1][2]		; optimized below
		if $i > UBound ($split) - 1 then redim $split [UBound ($split) * 2][2]
		$result = StringRegExp _
			($text, $patterns [$type], $STR_REGEXPARRAYFULLMATCH, $offset) [0]
		if @error then exitloop
		$split [$i][0] = $result
		$split [$i][1] = $type
		$offset = @extended
		if $offset > $len then exitloop
		switch StringMid ($text, $offset, 1)
			case ";"
				$type = $COMMENT_TYPE
			case "#"
				$type = (StringLeft ($text, 3) = "#cs") ? _
					$COMMENT_TYPE : $DIRECTIVE_TYPE
			case """", "'"
				$type = $STRING_TYPE
			case else
				$type = $MAIN_TYPE
		endswitch
		$i += 1
	wend
	return $split
endfunc


func reFindInMain (const byref $split, const $pattern, const $flag=0)
	local $match, $result [0]
	for $i = 0 to UBound ($split) - 1
		if $split [$i][1] <> $MAIN_TYPE then _
			continueloop
		switch $flag
			case $STR_REGEXPMATCH
				if StringRegExp ($split [$i][0], $pattern, $flag) then return 1
				if @error then return SetError (@error, @extended)
			case $STR_REGEXPARRAYGLOBALMATCH
				$match = StringRegExp _
					($split [$i][0], $pattern, $flag)
				switch @error
					case 2
						return SetError (@error, @extended)
					case 0
						_ArrayConcatenate ($result, $match)
				endswitch
		endswitch
	next
	switch $flag
		case $STR_REGEXPMATCH
			return 0
		case $STR_REGEXPARRAYGLOBALMATCH
			return (UBound ($result) = 0) ? SetError (1) : $result
	endswitch
endfunc


func reReplaceInMain (byref $split, const $pattern, const $replace, const $count=0)
	local $performed = 0, $remainder = $count
	for $i = 0 to UBound ($split) - 1
		if $split [$i][1] <> $MAIN_TYPE then _
			continueloop
		$split [$i][0] = StringRegExpReplace _
			($split [$i][0], $pattern, $replace, $remainder)
		if @error then return SetError (@error, @extended)
		$performed += @extended
		if $count <> 0 then
			$remainder -= @extended
			if $remainder = 0 then exitloop
		endif
	next
	return $performed
endfunc


func ReplaceInMain _
		(byref $split, const $subString, const $replaceString)
	local $performed = 0
	for $i = 0 to UBound ($split) - 1
		if $split [$i][1] <> $MAIN_TYPE then _
			continueloop
		$split [$i][0] = _
			StringReplace ($split [$i][0], $subString, $replaceString)
		if @error then return SetError (@error, 0, "")
		$performed += @extended
	next
	return $performed
endfunc
