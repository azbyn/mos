" Vim syntax file
" based on python.vim from neovim
" Language:	mos
" Maintainer:	Zvezdan Petkovic <zpetkovic@acm.org>
" Last Change:	2016 Feb 20
" Credits:	Neil Schemenauer <nas@python.ca>
"		Dmitry Vasiliev
"
"		This version is a major rewrite by Zvezdan Petkovic.
"
"		- introduced highlighting of doctesmos
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
"   let mos_no_builtin_highlight = 1
"   let mos_no_doctest_code_highlight = 1
"   let mos_no_doctest_highlight = 1
"   let mos_no_exception_highlight = 1
"   let mos_no_number_highlight = 1
"   let mos_space_error_highlight = 1
"
" All the options above can be switched on together.
"
"   let mos_highlight_all = 1
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

" Keep mos keywords in alphabetical order inside groups for easy
" comparison with the table in the 'mos Language Reference'
" https://docs.mos.org/2/reference/lexical_analysis.html#keywords,
" https://docs.mos.org/3/reference/lexical_analysis.html#keywords.
" Groups are in the order presented in NAMING CONVENTIONS in syntax.txt.
" Exceptions come last at the end of each group (class and def below).
"
" Keywords 'with' and 'as' are new in mos 2.6
" (use 'from __future__ import with_statement' in mos 2.5).
"
" Some compromises had to be made to support both mos 3 and 2.
" We include mos 3 features, but when a definition is duplicated,
" the last definition takes precedence.
"
" - 'False', 'None', and 'True' are keywords in mos 3 but they are
"   built-ins in 2 and will be highlighted as built-ins below.
" - 'exec' is a built-in in mos 3 and will be highlighted as
"   built-in below.
" - 'nonlocal' is a keyword in mos 3 and will be highlighted.
" - 'print' is a built-in in mos 3 and will be highlighted as
"   built-in below (use 'from __future__ import print_function' in 2)
" - async and await were added in mos 3.5 and are soft keywords.
"
syn keyword mosStatement	break continue return
"syn keyword mosStatement	lambda nonlocal pass print return with yield
"syn keyword mosStatement	class fun prop nextgroup=tsFunction skipwhite
syn keyword mosConditional	elif else if
syn keyword mosRepeat	for while
syn keyword mosOperator	in
"syn keyword mosException	except finally raise try
"syn keyword mosAsync		async await
syn keyword mosDeclaration fun prop struct module import this

hi def link     mosDeclaration       Keyword

syn match     mosFuncCall    "\w\(\w\)*("he=e-1,me=e-1
hi def link mosFuncCall      Function
hi def link mosStatement     Keyword

" Decorators (new in mos 2.4)
syn match   mosDecorator	"@" display nextgroup=mosFunction skipwhite
" The zero-length non-grouping match before the function name is
" extremely important in mosFunction.  Without it, everything is
" interpreted as a function inside the contained environment of
" doctesmos.
" A dot must be allowed because of @MyClass.myfunc decorators.
syn match   mosFunction
      \ "\%(\%(fun\s\|class\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contained

syn match   mosComment	"#.*$" contains=mosTodo,@Spell
syn keyword mosTodo		FIXME NOTE NOTES TODO XXX contained

syn region mosComment	matchgroup=cCommentStart start="<<<" end=">>>" contains=mosTodo,@Spell extend

" Triple-quoted strings can contain doctesmos.
syn region  mosString matchgroup=mosQuotes
      \ start=+[uU]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=mosEscape,@Spell
syn region  mosString matchgroup=mosTripleQuotes
      \ start=+[uU]\=\z('''\|"""\)+ skip=+\\["']+ end="\z1" keepend
      \ contains=mosEscape,mosSpaceError,mosDoctest,@Spell
syn region  mosRawString matchgroup=mosQuotes
      \ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=@Spell
syn region  mosRawString matchgroup=mosTripleQuotes
      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
      \ contains=mosSpaceError,mosDoctest,@Spell

syn match   mosEscape	+\\[abfnrtv'"\\]+ contained
syn match   mosEscape	"\\\o\{1,3}" contained
syn match   mosEscape	"\\x\x\{2}" contained
syn match   mosEscape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
" mos allows case-insensitive Unicode IDs: http://www.unicode.org/charts/
syn match   mosEscape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   mosEscape	"\\$"

if exists("mos_highlight_all")
  if exists("mos_no_builtin_highlight")
    unlet mos_no_builtin_highlight
  endif
  if exists("mos_no_doctest_code_highlight")
    unlet mos_no_doctest_code_highlight
  endif
  if exists("mos_no_doctest_highlight")
    unlet mos_no_doctest_highlight
  endif
  if exists("mos_no_exception_highlight")
    unlet mos_no_exception_highlight
  endif
  if exists("mos_no_number_highlight")
    unlet mos_no_number_highlight
  endif
  let mos_space_error_highlight = 1
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
" and so on, as specified in the 'mos Language Reference'.
" https://docs.mos.org/2/reference/lexical_analysis.html#numeric-literals
" https://docs.mos.org/3/reference/lexical_analysis.html#numeric-literals
if !exists("mos_no_number_highlight")
  " numbers (including longs and complex)
  syn match   mosNumber	"\<0[oO]\=\o\+[Ll]\=\>"
  syn match   mosNumber	"\<0[xX]\x\+[Ll]\=\>"
  syn match   mosNumber	"\<0[bB][01]\+[Ll]\=\>"
  syn match   mosNumber	"\<\%([1-9]\d*\|0\)[Ll]\=\>"
  syn match   mosNumber	"\<\d\+[jJ]\>"
  syn match   mosNumber	"\<\d\+[eE][+-]\=\d\+[jJ]\=\>"
  syn match   mosNumber
	\ "\<\d\+\.\%([eE][+-]\=\d\+\)\=[jJ]\=\%(\W\|$\)\@="
  syn match   mosNumber
	\ "\%(^\|\W\)\zs\d*\.\d\+\%([eE][+-]\=\d\+\)\=[jJ]\=\>"
endif

" Group the built-ins in the order in the 'mos Library Reference' for
" easier comparison.
" https://docs.mos.org/2/library/constants.html
" https://docs.mos.org/3/library/constants.html
" http://docs.mos.org/2/library/functions.html
" http://docs.mos.org/3/library/functions.html
" http://docs.mos.org/2/library/functions.html#non-essential-built-in-functions
" http://docs.mos.org/3/library/functions.html#non-essential-built-in-functions
" mos built-in functions are in alphabetical order.
if !exists("mos_no_builtin_highlight")
  " built-in constanmos
  " 'False', 'True', and 'None' are also reserved words in mos 3
  syn keyword mosConst	false true nil
  "syn keyword mosBuiltin	NotImplemented Ellipsis __debug__
  " built-in functions
  "syn keyword mosBuiltin	abs all any bin bool bytearray callable chr
  "syn keyword mosBuiltin	classmethod compile complex delattr dict dir
  "syn keyword mosBuiltin	divmod enumerate eval filter float format
  "syn keyword mosBuiltin	frozenset getattr globals hasattr hash
  "syn keyword mosBuiltin	help hex id input int isinstance
  "syn keyword mosBuiltin	issubclass iter len list locals map max
  "syn keyword mosBuiltin	memoryview min next object oct open ord pow
  "syn keyword mosBuiltin	print property range repr reversed round set
  "syn keyword mosBuiltin	setattr slice sorted staticmethod str
  "syn keyword mosBuiltin	sum super tuple type vars zip __import__
  " mos 2 only
  "syn keyword mosBuiltin	basestring cmp execfile file
  "syn keyword mosBuiltin	long raw_input reduce reload unichr
  "syn keyword mosBuiltin	unicode xrange
  " mos 3 only
  "syn keyword mosBuiltin	ascii bytes exec
  " non-essential built-in functions; mos 2 only
  "syn keyword mosBuiltin	apply buffer coerce intern
  " avoid highlighting attributes as builtins
  syn match   mosAttribute	/\.\h\w*/hs=s+1 contains=ALLBUT,mosBuiltin transparent
endif

" From the 'mos Library Reference' class hierarchy at the bottom.
" http://docs.mos.org/2/library/exceptions.html
" http://docs.mos.org/3/library/exceptions.html
if !exists("mos_no_exception_highlight")
  " builtin base exceptions (used mostly as base classes for other exceptions)
  syn keyword mosExceptions	BaseException Exception
  syn keyword mosExceptions	ArithmeticError BufferError
  syn keyword mosExceptions	LookupError
  " builtin base exceptions removed in mos 3
  syn keyword mosExceptions	EnvironmentError StandardError
  " builtin exceptions (actually raised)
  syn keyword mosExceptions	AssertionError AttributeError
  syn keyword mosExceptions	EOFError FloatingPointError GeneratorExit
  syn keyword mosExceptions	ImportError IndentationError
  syn keyword mosExceptions	IndexError KeyError KeyboardInterrupt
  syn keyword mosExceptions	MemoryError NameError NotImplementedError
  syn keyword mosExceptions	OSError OverflowError ReferenceError
  syn keyword mosExceptions	RuntimeError StopIteration SyntaxError
  syn keyword mosExceptions	SystemError SystemExit TabError TypeError
  syn keyword mosExceptions	UnboundLocalError UnicodeError
  syn keyword mosExceptions	UnicodeDecodeError UnicodeEncodeError
  syn keyword mosExceptions	UnicodeTranslateError ValueError
  syn keyword mosExceptions	ZeroDivisionError
  " builtin OS exceptions in mos 3
  syn keyword mosExceptions	BlockingIOError BrokenPipeError
  syn keyword mosExceptions	ChildProcessError ConnectionAbortedError
  syn keyword mosExceptions	ConnectionError ConnectionRefusedError
  syn keyword mosExceptions	ConnectionResetError FileExistsError
  syn keyword mosExceptions	FileNotFoundError InterruptedError
  syn keyword mosExceptions	IsADirectoryError NotADirectoryError
  syn keyword mosExceptions	PermissionError ProcessLookupError
  syn keyword mosExceptions	RecursionError StopAsyncIteration
  syn keyword mosExceptions	TimeoutError
  " builtin exceptions deprecated/removed in mos 3
  syn keyword mosExceptions	IOError VMSError WindowsError
  " builtin warnings
  syn keyword mosExceptions	BytesWarning DeprecationWarning FutureWarning
  syn keyword mosExceptions	ImportWarning PendingDeprecationWarning
  syn keyword mosExceptions	RuntimeWarning SyntaxWarning UnicodeWarning
  syn keyword mosExceptions	UserWarning Warning
  " builtin warnings in mos 3
  syn keyword mosExceptions	ResourceWarning
endif

if exists("mos_space_error_highlight")
  " trailing whitespace
  syn match   mosSpaceError	display excludenl "\s\+$"
  " mixed tabs and spaces
  syn match   mosSpaceError	display " \+\t"
  syn match   mosSpaceError	display "\t\+ "
endif

" Do not spell doctesmos inside strings.
" Notice that the end of a string, either ''', or """, will end the contained
" doctest too.  Thus, we do *not* need to have it as an end pattern.
if !exists("mos_no_doctest_highlight")
  if !exists("mos_no_doctest_code_highlight")
    syn region mosDoctest
	  \ start="^\s*>>>\s" end="^\s*$"
	  \ contained contains=ALLBUT,mosDoctest,@Spell
    syn region mosDoctestValue
	  \ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
	  \ contained
  else
    syn region mosDoctest
	  \ start="^\s*>>>" end="^\s*$"
	  \ contained contains=@NoSpell
  endif
endif

" Sync at the beginning of class, function, or method definition.
syn sync match mosSync grouphere NONE "^\s*\%(def\|class\)\s\+\h\w*\s*("

if version >= 508 || !exists("did_mos_syn_inits")
  if version <= 508
    let did_mos_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default highlight links.  Can be overridden later.
  HiLink mosStatement	Statement
  HiLink mosConditional	Conditional
  HiLink mosRepeat		Keyword
  HiLink mosOperator		Operator
  HiLink mosException	Exception
  HiLink mosInclude		Include
  HiLink mosAsync		Statement
  HiLink mosDecorator	Define
  HiLink mosFunction		Function
  HiLink mosComment		Comment
  HiLink mosTodo		Todo
  HiLink mosString		String
  HiLink mosRawString	String
  HiLink mosQuotes		String
  HiLink mosTripleQuotes	mosQuotes
  HiLink mosEscape		Special
  if !exists("mos_no_number_highlight")
    HiLink mosNumber		Number
  endif
  if !exists("mos_no_builtin_highlight")
    HiLink mosBuiltin	Function
    HiLink mosConst	Constant


  endif
  if !exists("mos_no_exception_highlight")
    HiLink mosExceptions	Structure
  endif
  if exists("mos_space_error_highlight")
    HiLink mosSpaceError	Error
  endif
  if !exists("mos_no_doctest_highlight")
    HiLink mosDoctest	Special
    HiLink mosDoctestValue	Define
  endif

  delcommand HiLink
endif

let b:current_syntax = "mos"

let &cpo = s:cpo_save
unlet s:cpo_save

set noexpandtab

syntax match mosLambda "\\" conceal cchar=λ
syntax match mosLambda "->" " conceal cchar=→
hi link mosLambda Operator
hi! link Conceal Operator
"setlocal conceallevel=2

"syn match ArrowHead contained ">" conceal cchar=▶
set conceallevel=1 concealcursor=nvic
"call vimlambdify#lambdify_match("Statement", "mosNiceStatement", "\\\\")
" vim:set sw=2 sts=2 ts=8 noet:
