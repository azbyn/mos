" Vim syntax file
" based on python.vim from neovim
" Language:	ts
" Maintainer:	Zvezdan Petkovic <zpetkovic@acm.org>
" Last Change:	2016 Feb 20
" Credits:	Neil Schemenauer <nas@ts.ca>
"		Dmitry Vasiliev
"
"		This version is a major rewrite by Zvezdan Petkovic.
"
"		- introduced highlighting of doctests
"		- updated keywords, built-ins, and exceptions
"		- corrected regular expressions for
"
"		  * functions
"		  * decorators
"		  * strings
"		  * escapes
"		  * numbers
"		  * space error
"
"		- corrected synchronization
"		- more highlighting is ON by default, except
"		- space error highlighting is OFF by default
"
" Optional highlighting can be controlled using these variables.
"
"   let ts_no_builtin_highlight = 1
"   let ts_no_doctest_code_highlight = 1
"   let ts_no_doctest_highlight = 1
"   let ts_no_exception_highlight = 1
"   let ts_no_number_highlight = 1
"   let ts_space_error_highlight = 1
"
" All the options above can be switched on together.
"
"   let ts_highlight_all = 1
"

" For version 5.x: Clear all syntax items.
" For version 6.x: Quit when a syntax file was already loaded.
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

" Keep ts keywords in alphabetical order inside groups for easy
" comparison with the table in the 'ts Language Reference'
" https://docs.ts.org/2/reference/lexical_analysis.html#keywords,
" https://docs.ts.org/3/reference/lexical_analysis.html#keywords.
" Groups are in the order presented in NAMING CONVENTIONS in syntax.txt.
" Exceptions come last at the end of each group (class and def below).
"
" Keywords 'with' and 'as' are new in ts 2.6
" (use 'from __future__ import with_statement' in ts 2.5).
"
" Some compromises had to be made to support both ts 3 and 2.
" We include ts 3 features, but when a definition is duplicated,
" the last definition takes precedence.
"
" - 'False', 'None', and 'True' are keywords in ts 3 but they are
"   built-ins in 2 and will be highlighted as built-ins below.
" - 'exec' is a built-in in ts 3 and will be highlighted as
"   built-in below.
" - 'nonlocal' is a keyword in ts 3 and will be highlighted.
" - 'print' is a built-in in ts 3 and will be highlighted as
"   built-in below (use 'from __future__ import print_function' in 2)
" - async and await were added in ts 3.5 and are soft keywords.
"
syn keyword tsStatement	break continue
"syn keyword tsStatement	lambda nonlocal pass print return with yield
"syn keyword tsStatement	class fun prop nextgroup=tsFunction skipwhite
syn keyword tsConditional	elif else if
syn keyword tsRepeat	for while
syn keyword tsOperator	and in is not or 
syn keyword tsException	except finally raise try
syn keyword tsInclude	from import
syn keyword tsAsync		async await
syn keyword tsDeclaration fun prop struct

hi def link     tsDeclaration       Keyword

syn match     tsFuncCall    "\w\(\w\)*("he=e-1,me=e-1
hi def link tsFuncCall      Function
hi def link tsStatement     Keyword

" Decorators (new in ts 2.4)
syn match   tsDecorator	"@" display nextgroup=tsFunction skipwhite
" The zero-length non-grouping match before the function name is
" extremely important in tsFunction.  Without it, everything is
" interpreted as a function inside the contained environment of
" doctests.
" A dot must be allowed because of @MyClass.myfunc decorators.
syn match   tsFunction
      \ "\%(\%(fun\s\|class\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contained

syn match   tsComment	"#.*$" contains=tsTodo,@Spell
syn keyword tsTodo		FIXME NOTE NOTES TODO XXX contained

" Triple-quoted strings can contain doctests.
syn region  tsString matchgroup=tsQuotes
      \ start=+[uU]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=tsEscape,@Spell
syn region  tsString matchgroup=tsTripleQuotes
      \ start=+[uU]\=\z('''\|"""\)+ skip=+\\["']+ end="\z1" keepend
      \ contains=tsEscape,tsSpaceError,tsDoctest,@Spell
syn region  tsRawString matchgroup=tsQuotes
      \ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=@Spell
syn region  tsRawString matchgroup=tsTripleQuotes
      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
      \ contains=tsSpaceError,tsDoctest,@Spell

syn match   tsEscape	+\\[abfnrtv'"\\]+ contained
syn match   tsEscape	"\\\o\{1,3}" contained
syn match   tsEscape	"\\x\x\{2}" contained
syn match   tsEscape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
" ts allows case-insensitive Unicode IDs: http://www.unicode.org/charts/
syn match   tsEscape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   tsEscape	"\\$"

if exists("ts_highlight_all")
  if exists("ts_no_builtin_highlight")
    unlet ts_no_builtin_highlight
  endif
  if exists("ts_no_doctest_code_highlight")
    unlet ts_no_doctest_code_highlight
  endif
  if exists("ts_no_doctest_highlight")
    unlet ts_no_doctest_highlight
  endif
  if exists("ts_no_exception_highlight")
    unlet ts_no_exception_highlight
  endif
  if exists("ts_no_number_highlight")
    unlet ts_no_number_highlight
  endif
  let ts_space_error_highlight = 1
endif

" It is very important to understand all details before changing the
" regular expressions below or their order.
" The word boundaries are *not* the floating-point number boundaries
" because of a possible leading or trailing decimal point.
" The expressions below ensure that all valid number literals are
" highlighted, and invalid number literals are not.  For example,
"
" - a decimal point in '4.' at the end of a line is highlighted,
" - a second dot in 1.0.0 is not highlighted,
" - 08 is not highlighted,
" - 08e0 or 08j are highlighted,
"
" and so on, as specified in the 'ts Language Reference'.
" https://docs.ts.org/2/reference/lexical_analysis.html#numeric-literals
" https://docs.ts.org/3/reference/lexical_analysis.html#numeric-literals
if !exists("ts_no_number_highlight")
  " numbers (including longs and complex)
  syn match   tsNumber	"\<0[oO]\=\o\+[Ll]\=\>"
  syn match   tsNumber	"\<0[xX]\x\+[Ll]\=\>"
  syn match   tsNumber	"\<0[bB][01]\+[Ll]\=\>"
  syn match   tsNumber	"\<\%([1-9]\d*\|0\)[Ll]\=\>"
  syn match   tsNumber	"\<\d\+[jJ]\>"
  syn match   tsNumber	"\<\d\+[eE][+-]\=\d\+[jJ]\=\>"
  syn match   tsNumber
	\ "\<\d\+\.\%([eE][+-]\=\d\+\)\=[jJ]\=\%(\W\|$\)\@="
  syn match   tsNumber
	\ "\%(^\|\W\)\zs\d*\.\d\+\%([eE][+-]\=\d\+\)\=[jJ]\=\>"
endif

" Group the built-ins in the order in the 'ts Library Reference' for
" easier comparison.
" https://docs.ts.org/2/library/constants.html
" https://docs.ts.org/3/library/constants.html
" http://docs.ts.org/2/library/functions.html
" http://docs.ts.org/3/library/functions.html
" http://docs.ts.org/2/library/functions.html#non-essential-built-in-functions
" http://docs.ts.org/3/library/functions.html#non-essential-built-in-functions
" ts built-in functions are in alphabetical order.
if !exists("ts_no_builtin_highlight")
  " built-in constants
  " 'False', 'True', and 'None' are also reserved words in ts 3
  syn keyword tsConst	false true nil
  "syn keyword tsBuiltin	NotImplemented Ellipsis __debug__
  " built-in functions
  "syn keyword tsBuiltin	abs all any bin bool bytearray callable chr
  "syn keyword tsBuiltin	classmethod compile complex delattr dict dir
  "syn keyword tsBuiltin	divmod enumerate eval filter float format
  "syn keyword tsBuiltin	frozenset getattr globals hasattr hash
  "syn keyword tsBuiltin	help hex id input int isinstance
  "syn keyword tsBuiltin	issubclass iter len list locals map max
  "syn keyword tsBuiltin	memoryview min next object oct open ord pow
  "syn keyword tsBuiltin	print property range repr reversed round set
  "syn keyword tsBuiltin	setattr slice sorted staticmethod str
  "syn keyword tsBuiltin	sum super tuple type vars zip __import__
  " ts 2 only
  "syn keyword tsBuiltin	basestring cmp execfile file
  "syn keyword tsBuiltin	long raw_input reduce reload unichr
  "syn keyword tsBuiltin	unicode xrange
  " ts 3 only
  "syn keyword tsBuiltin	ascii bytes exec
  " non-essential built-in functions; ts 2 only
  "syn keyword tsBuiltin	apply buffer coerce intern
  " avoid highlighting attributes as builtins
  syn match   tsAttribute	/\.\h\w*/hs=s+1 contains=ALLBUT,tsBuiltin transparent
endif

" From the 'ts Library Reference' class hierarchy at the bottom.
" http://docs.ts.org/2/library/exceptions.html
" http://docs.ts.org/3/library/exceptions.html
if !exists("ts_no_exception_highlight")
  " builtin base exceptions (used mostly as base classes for other exceptions)
  syn keyword tsExceptions	BaseException Exception
  syn keyword tsExceptions	ArithmeticError BufferError
  syn keyword tsExceptions	LookupError
  " builtin base exceptions removed in ts 3
  syn keyword tsExceptions	EnvironmentError StandardError
  " builtin exceptions (actually raised)
  syn keyword tsExceptions	AssertionError AttributeError
  syn keyword tsExceptions	EOFError FloatingPointError GeneratorExit
  syn keyword tsExceptions	ImportError IndentationError
  syn keyword tsExceptions	IndexError KeyError KeyboardInterrupt
  syn keyword tsExceptions	MemoryError NameError NotImplementedError
  syn keyword tsExceptions	OSError OverflowError ReferenceError
  syn keyword tsExceptions	RuntimeError StopIteration SyntaxError
  syn keyword tsExceptions	SystemError SystemExit TabError TypeError
  syn keyword tsExceptions	UnboundLocalError UnicodeError
  syn keyword tsExceptions	UnicodeDecodeError UnicodeEncodeError
  syn keyword tsExceptions	UnicodeTranslateError ValueError
  syn keyword tsExceptions	ZeroDivisionError
  " builtin OS exceptions in ts 3
  syn keyword tsExceptions	BlockingIOError BrokenPipeError
  syn keyword tsExceptions	ChildProcessError ConnectionAbortedError
  syn keyword tsExceptions	ConnectionError ConnectionRefusedError
  syn keyword tsExceptions	ConnectionResetError FileExistsError
  syn keyword tsExceptions	FileNotFoundError InterruptedError
  syn keyword tsExceptions	IsADirectoryError NotADirectoryError
  syn keyword tsExceptions	PermissionError ProcessLookupError
  syn keyword tsExceptions	RecursionError StopAsyncIteration
  syn keyword tsExceptions	TimeoutError
  " builtin exceptions deprecated/removed in ts 3
  syn keyword tsExceptions	IOError VMSError WindowsError
  " builtin warnings
  syn keyword tsExceptions	BytesWarning DeprecationWarning FutureWarning
  syn keyword tsExceptions	ImportWarning PendingDeprecationWarning
  syn keyword tsExceptions	RuntimeWarning SyntaxWarning UnicodeWarning
  syn keyword tsExceptions	UserWarning Warning
  " builtin warnings in ts 3
  syn keyword tsExceptions	ResourceWarning
endif

if exists("ts_space_error_highlight")
  " trailing whitespace
  syn match   tsSpaceError	display excludenl "\s\+$"
  " mixed tabs and spaces
  syn match   tsSpaceError	display " \+\t"
  syn match   tsSpaceError	display "\t\+ "
endif

" Do not spell doctests inside strings.
" Notice that the end of a string, either ''', or """, will end the contained
" doctest too.  Thus, we do *not* need to have it as an end pattern.
if !exists("ts_no_doctest_highlight")
  if !exists("ts_no_doctest_code_highlight")
    syn region tsDoctest
	  \ start="^\s*>>>\s" end="^\s*$"
	  \ contained contains=ALLBUT,tsDoctest,@Spell
    syn region tsDoctestValue
	  \ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
	  \ contained
  else
    syn region tsDoctest
	  \ start="^\s*>>>" end="^\s*$"
	  \ contained contains=@NoSpell
  endif
endif

" Sync at the beginning of class, function, or method definition.
syn sync match tsSync grouphere NONE "^\s*\%(def\|class\)\s\+\h\w*\s*("

if version >= 508 || !exists("did_ts_syn_inits")
  if version <= 508
    let did_ts_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default highlight links.  Can be overridden later.
  HiLink tsStatement	Statement
  HiLink tsConditional	Conditional
  HiLink tsRepeat		Keyword
  HiLink tsOperator		Operator
  HiLink tsException	Exception
  HiLink tsInclude		Include
  HiLink tsAsync		Statement
  HiLink tsDecorator	Define
  HiLink tsFunction		Function
  HiLink tsComment		Comment
  HiLink tsTodo		Todo
  HiLink tsString		String
  HiLink tsRawString	String
  HiLink tsQuotes		String
  HiLink tsTripleQuotes	tsQuotes
  HiLink tsEscape		Special
  if !exists("ts_no_number_highlight")
    HiLink tsNumber		Number
  endif
  if !exists("ts_no_builtin_highlight")
    HiLink tsBuiltin	Function
    HiLink tsConst	Constant


  endif
  if !exists("ts_no_exception_highlight")
    HiLink tsExceptions	Structure
  endif
  if exists("ts_space_error_highlight")
    HiLink tsSpaceError	Error
  endif
  if !exists("ts_no_doctest_highlight")
    HiLink tsDoctest	Special
    HiLink tsDoctestValue	Define
  endif

  delcommand HiLink
endif

let b:current_syntax = "ts"

let &cpo = s:cpo_save
unlet s:cpo_save

set noexpandtab

syntax match tsLambda "\\" conceal cchar=λ
syntax match tsLambda "->" " conceal cchar=→
hi link tsLambda Operator
hi! link Conceal Operator
"setlocal conceallevel=2

"syn match ArrowHead contained ">" conceal cchar=▶
set conceallevel=1 concealcursor=nvic
"call vimlambdify#lambdify_match("Statement", "tsNiceStatement", "\\\\")
" vim:set sw=2 sts=2 ts=8 noet:
