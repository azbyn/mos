Ddoc

$(P Phobos is the standard runtime library that comes with the D language
compiler.)

$(P Generally, the $(D stdd) namespace is used for the main modules in the
Phobos standard library. The $(D etc) namespace is used for external C/C++
library bindings. The $(D core) namespace is used for low-level D runtime
functions.)

$(P The following table is a quick reference guide for which Phobos modules to
use for a given category of functionality. Note that some modules may appear in
more than one category, as some Phobos modules are quite generic and can be
applied in a variety of situations.)

$(BOOKTABLE ,
    $(TR
        $(TH Modules)
        $(TH Description)
    )
    $(LEADINGROW Algorithms &amp; ranges)
    $(TR
        $(TDNW
            $(LINK2 std_algorithm.html, stdd.algorithm)$(BR)
            $(LINK2 std_range.html, stdd.range)$(BR)
            $(LINK2 std_range_primitives.html, stdd.range.primitives)$(BR)
            $(LINK2 std_range_interfaces.html, stdd.range.interfaces)$(BR)
        )
        $(TD Generic algorithms that work with $(LINK2 std_range.html, ranges)
            of any type, including strings, arrays, and other kinds of
            sequentially-accessed data. Algorithms include searching,
            comparison, iteration, sorting, set operations, and mutation.
        )
    )
    $(TR
        $(TDNW $(LINK2 std_experimental_ndslice.html, stdd.experimental.ndslice))
        $(TD Multidimensional random access ranges and arrays.)
    )
    $(LEADINGROW Array manipulation)
    $(TR
        $(TDNW
            $(LINK2 std_array.html, stdd.array)$(BR)
            $(LINK2 std_algorithm.html, stdd.algorithm)$(BR)
        )
        $(TD Convenient operations commonly used with built-in arrays.
            Note that many common array operations are subsets of more generic
            algorithms that work with arbitrary ranges, so they are found in
            $(D stdd.algorithm).
        )
    )
    $(LEADINGROW Containers)
    $(TR
        $(TDNW
            $(LINK2 std_container_array.html, stdd.container.array)$(BR)
            $(LINK2 std_container_binaryheap.html, stdd.container.binaryheap)$(BR)
            $(LINK2 std_container_dlist.html, stdd.container.dlist)$(BR)
            $(LINK2 std_container_rbtree.html, stdd.container.rbtree)$(BR)
            $(LINK2 std_container_slist.html, stdd.container.slist)$(BR)
        )
        $(TD See $(LINK2 std_container.html, stdd.container.*) for an
            overview.
        )
    )
    $(LEADINGROW Data formats)
    $(TR
        $(TDNW $(LINK2 std_base64.html, stdd.base64))
        $(TD Encoding / decoding Base64 format.)
    )
    $(TR
        $(TDNW $(LINK2 std_csv.html, stdd.csv))
        $(TD Read Comma Separated Values and its variants from an input range of $(CODE dchar).)
    )
    $(TR
        $(TDNW $(LINK2 std_json.html, stdd.json))
        $(TD Read/write data in JSON format.)
    )
    $(TR
        $(TDNW $(LINK2 std_xml.html, stdd.xml))
        $(TD Read/write data in XML format.)
    )
    $(TR
        $(TDNW $(LINK2 std_zip.html, stdd.zip))
        $(TD Read/write data in the ZIP archive format.)
    )
    $(TR
        $(TDNW $(LINK2 std_zlib.html, stdd.zlib))
        $(TD Compress/decompress data using the zlib library.)
    )
    $(LEADINGROW Data integrity)
    $(TR
        $(TDNW $(LINK2 std_digest_crc.html, stdd.digest.crc))
        $(TD Cyclic Redundancy Check (32-bit) implementation.)
    )
    $(TR
        $(TDNW $(LINK2 std_digest_digest.html, stdd.digest.digest))
        $(TD Compute digests such as md5, sha1 and crc32.)
    )
    $(TR
        $(TDNW $(LINK2 std_digest_hmac.html, stdd.digest.hmac))
        $(TD Compute HMAC digests of arbitrary data.)
    )
    $(TR
        $(TDNW $(LINK2 std_digest_md.html, stdd.digest.md))
        $(TD Compute MD5 hash of arbitrary data.)
    )
    $(TR
        $(TDNW $(LINK2 std_digest_murmurhash.html, stdd.digest.murmurhash))
        $(TD Compute MurmurHash of arbitrary data.)
    )
    $(TR
        $(TDNW $(LINK2 std_digest_ripemd.html, stdd.digest.ripemd))
        $(TD Compute RIPEMD-160 hash of arbitrary data.)
    )
    $(TR
        $(TDNW $(LINK2 std_digest_sha.html, stdd.digest.sha))
        $(TD Compute SHA1 and SHA2 hashes of arbitrary data.)
    )
    $(LEADINGROW Date &amp; time)
    $(TR
        $(TDNW $(LINK2 std_datetime.html, stdd.datetime))
        $(TD Provides convenient access to date and time representations.)
    )
    $(TR
        $(TDNW $(LINK2 core_time.html, core.time))
        $(TD Implements low-level time primitives.)
    )
    $(LEADINGROW Exception handling)
    $(TR
        $(TDNW $(LINK2 std_exception.html, stdd.exception))
        $(TD Implements routines related to exceptions.)
    )
    $(TR
        $(TDNW $(LINK2 core_exception.html, core.exception))
        $(TD Defines built-in exception types and low-level
            language hooks required by the compiler.)
    )
    $(LEADINGROW External library bindings)
    $(TR
        $(TDNW $(LINK2 etc_c_curl.html, etc.c.curl))
        $(TD Interface to libcurl C library.)
    )
    $(TR
        $(TDNW $(LINK2 etc_c_odbc_sql.html, etc.c.odbc.sql))
        $(TD Interface to ODBC C library.)
    )
    $(TR
        $(TDNW $(LINK2 etc_c_odbc_sqlext.html, etc.c.odbc.sqlext))
    )
    $(TR
        $(TDNW $(LINK2 etc_c_odbc_sqltypes.html, etc.c.odbc.sqltypes))
    )
    $(TR
        $(TDNW $(LINK2 etc_c_odbc_sqlucode.html, etc.c.odbc.sqlucode))
    )
    $(TR
        $(TDNW $(LINK2 etc_c_sqlite3.html, etc.c.sqlite3))
        $(TD Interface to SQLite C library.)
    )
    $(TR
        $(TDNW $(LINK2 etc_c_zlib.html, etc.c.zlib))
        $(TD Interface to zlib C library.)
    )
    $(LEADINGROW I/O &amp; File system)
    $(TR
        $(TDNW $(LINK2 std_file.html, stdd.file))
        $(TD Manipulate files and directories.)
    )
    $(TR
        $(TDNW $(LINK2 std_path.html, stdd.path))
        $(TD Manipulate strings that represent filesystem paths.)
    )
    $(TR
        $(TDNW $(LINK2 std_stdio.html, stdd.stdio))
        $(TD Perform buffered I/O.)
    )
    $(LEADINGROW Interoperability)
    $(TR
        $(TDNW
            $(LINK2 core_stdc_complex.html, core.stdc.complex)$(BR)
            $(LINK2 core_stdc_ctype.html, core.stdc.ctype)$(BR)
            $(LINK2 core_stdc_errno.html, core.stdc.errno)$(BR)
            $(LINK2 core_stdc_fenv.html, core.stdc.fenv)$(BR)
            $(LINK2 core_stdc_float_.html, core.stdc.float_)$(BR)
            $(LINK2 core_stdc_inttypes.html, core.stdc.inttypes)$(BR)
            $(LINK2 core_stdc_limits.html, core.stdc.limits)$(BR)
            $(LINK2 core_stdc_locale.html, core.stdc.locale)$(BR)
            $(LINK2 core_stdc_math.html, core.stdc.math)$(BR)
            $(LINK2 core_stdc_signal.html, core.stdc.signal)$(BR)
            $(LINK2 core_stdc_stdarg.html, core.stdc.stdarg)$(BR)
            $(LINK2 core_stdc_stddef.html, core.stdc.stddef)$(BR)
            $(LINK2 core_stdc_stdint.html, core.stdc.stdint)$(BR)
            $(LINK2 core_stdc_stdio.html, core.stdc.stdio)$(BR)
            $(LINK2 core_stdc_stdlib.html, core.stdc.stdlib)$(BR)
            $(LINK2 core_stdc_string.html, core.stdc.string)$(BR)
            $(LINK2 core_stdc_tgmath.html, core.stdc.tgmath)$(BR)
            $(LINK2 core_stdc_time.html, core.stdc.time)$(BR)
            $(LINK2 core_stdc_wchar_.html, core.stdc.wchar_)$(BR)
            $(LINK2 core_stdc_wctype.html, core.stdc.wctype)$(BR)
        )
        $(TD
            D bindings for standard C headers.$(BR)$(BR)
            These are mostly undocumented, as documentation
            for the functions these declarations provide
            bindings to can be found on external resources.
        )
    )
    $(LEADINGROW Memory management)
    $(TR
        $(TDNW $(LINK2 core_memory.html, core.memory))
        $(TD Control the built-in garbage collector.)
    )
    $(TR
        $(TDNW $(LINK2 std_typecons.html, stdd.typecons))
        $(TD Build scoped variables and reference-counted types.)
    )
    $(LEADINGROW Metaprogramming)
    $(TR
        $(TDNW $(LINK2 core_attribute.html, core.attribute))
        $(TD Definitions of special attributes recognized by the compiler.)
    )
    $(TR
        $(TDNW $(LINK2 core_demangle.html, core.demangle))
        $(TD Convert $(I mangled) D symbol identifiers to source representation.)
    )
    $(TR
        $(TDNW $(LINK2 std_demangle.html, stdd.demangle))
        $(TD A simple wrapper around core.demangle.)
    )
    $(TR
        $(TDNW $(LINK2 std_meta.html, stdd.meta))
        $(TD Construct and manipulate template argument lists (aka type lists).)
    )
    $(TR
        $(TDNW $(LINK2 std_traits.html, stdd.traits))
        $(TD Extract information about types and symbols at compile time.)
    )
    $(TR
        $(TDNW $(LINK2 std_typecons.html, stdd.typecons))
        $(TD Construct new, useful general purpose types.)
    )
    $(LEADINGROW Multitasking)
    $(TR
        $(TDNW $(LINK2 std_concurrency.html, stdd.concurrency))
        $(TD Low level messaging API for threads.)
    )
    $(TR
        $(TDNW $(LINK2 std_parallelism.html, stdd.parallelism))
        $(TD High level primitives for SMP parallelism.)
    )
    $(TR
        $(TDNW $(LINK2 std_process.html, stdd.process))
        $(TD Starting and manipulating processes.)
    )
    $(TR
        $(TDNW $(LINK2 core_atomic.html, core.atomic))
        $(TD Basic support for lock-free concurrent programming.)
    )
    $(TR
        $(TDNW $(LINK2 core_sync_barrier.html, core.sync.barrier))
        $(TD Synchronize the progress of a group of threads.)
    )
    $(TR
        $(TDNW $(LINK2 core_sync_condition.html, core.sync.condition))
        $(TD Synchronized condition checking.)
    )
    $(TR
        $(TDNW $(LINK2 core_sync_exception.html, core.sync.exception))
        $(TD Base class for synchronization exceptions.)
    )
    $(TR
        $(TDNW $(LINK2 core_sync_mutex.html, core.sync.mutex))
        $(TD Mutex for mutually exclusive access.)
    )
    $(TR
        $(TDNW $(LINK2 core_sync_rwmutex.html, core.sync.rwmutex))
        $(TD Shared read access and mutually exclusive write access.)
    )
    $(TR
        $(TDNW $(LINK2 core_sync_semaphore.html, core.sync.semaphore))
        $(TD General use synchronization semaphore.)
    )
    $(TR
        $(TDNW $(LINK2 core_thread.html, core.thread))
        $(TD Thread creation and management.)
    )
    $(LEADINGROW Networking)
    $(TR
        $(TDNW $(LINK2 std_socket.html, stdd.socket))
        $(TD Socket primitives.)
    )
    $(TR
        $(TDNW $(LINK2 std_net_curl.html, stdd.net.curl))
        $(TD Networking client functionality as provided by libcurl.)
    )
    $(TR
        $(TDNW $(LINK2 std_net_isemail.html, stdd.net.isemail))
        $(TD Validates an email address according to RFCs 5321, 5322 and others.)
    )
    $(TR
        $(TDNW $(LINK2 std_uri.html, stdd.uri))
        $(TD Encode and decode Uniform Resource Identifiers (URIs).)
    )
    $(TR
        $(TDNW $(LINK2 std_uuid.html, stdd.uuid))
        $(TD Universally-unique identifiers for resources in distributed
        systems.)
    )
    $(LEADINGROW Numeric)
    $(TR
        $(TDNW $(LINK2 std_bigint.html, stdd.bigint))
        $(TD An arbitrary-precision integer type.)
    )
    $(TR
        $(TDNW $(LINK2 std_complex.html, stdd.complex))
        $(TD A complex number type.)
    )
    $(TR
        $(TDNW $(LINK2 std_math.html, stdd.math))
        $(TD Elementary mathematical functions (powers, roots, trigonometry).)
    )
    $(TR
        $(TDNW $(LINK2 std_mathspecial.html, stdd.mathspecial))
        $(TD Families of transcendental functions.)
    )
    $(TR
        $(TDNW $(LINK2 std_experimental_ndslice.html, stdd.experimental.ndslice))
        $(TD Multidimensional random access ranges and arrays.)
    )
    $(TR
        $(TDNW $(LINK2 std_numeric.html, stdd.numeric))
        $(TD Floating point numerics functions.)
    )
    $(TR
        $(TDNW $(LINK2 std_random.html, stdd.random))
        $(TD Pseudo-random number generators.)
    )
    $(TR
        $(TDNW $(LINK2 core_checkedint.html, core.checkedint))
        $(TD Range-checking integral arithmetic primitives.)
    )
    $(TR
        $(TDNW $(LINK2 core_math.html, core.math))
        $(TD Built-in mathematical intrinsics.)
    )
    $(LEADINGROW Paradigms)
    $(TR
        $(TDNW $(LINK2 std_functional.html, stdd.functional))
        $(TD Functions that manipulate other functions.)
    )
    $(TR
        $(TDNW $(LINK2 std_algorithm.html, stdd.algorithm))
        $(TD Generic algorithms for processing sequences.)
    )
    $(TR
        $(TDNW $(LINK2 std_signals.html, stdd.signals))
        $(TD Signal-and-slots framework for event-driven programming.)
    )
    $(LEADINGROW Runtime utilities)
    $(TR
        $(TDNW $(LINK2 object.html, object))
        $(TD Core language definitions. Automatically imported.)
    )
    $(TR
        $(TDNW $(LINK2 std_getopt.html, stdd.getopt))
        $(TD Parsing of command-line arguments.)
    )
    $(TR
        $(TDNW $(LINK2 std_compiler.html, stdd.compiler))
        $(TD Host compiler vendor string and language version.)
    )
    $(TR
        $(TDNW $(LINK2 std_system.html, stdd.system))
        $(TD Runtime environment, such as OS type and endianness.)
    )
    $(TR
        $(TDNW $(LINK2 core_cpuid.html, core.cpuid))
        $(TD Capabilities of the CPU the program is running on.)
    )
    $(TR
        $(TDNW $(LINK2 core_memory.html, core.memory))
        $(TD Control the built-in garbage collector.)
    )
    $(TR
        $(TDNW $(LINK2 core_runtime.html, core.runtime))
        $(TD Control and configure the D runtime.)
    )
    $(LEADINGROW String manipulation)
    $(TR
        $(TDNW $(LINK2 std_string.html, stdd.string))
        $(TD Algorithms that work specifically with strings.)
    )
    $(TR
        $(TDNW $(LINK2 std_array.html, stdd.array))
        $(TD Manipulate builtin arrays.)
    )
    $(TR
        $(TDNW $(LINK2 std_algorithm.html, stdd.algorithm))
        $(TD Generic algorithms for processing sequences.)
    )
    $(TR
        $(TDNW $(LINK2 std_uni.html, stdd.uni))
        $(TD Fundamental Unicode algorithms and data structures.)
    )
    $(TR
        $(TDNW $(LINK2 std_utf.html, stdd.utf))
        $(TD Encode and decode UTF-8, UTF-16 and UTF-32 strings.)
    )
    $(TR
        $(TDNW $(LINK2 std_format.html, stdd.format))
        $(TD Format data into strings.)
    )
    $(TR
        $(TDNW $(LINK2 std_path.html, stdd.path))
        $(TD Manipulate strings that represent filesystem paths.)
    )
    $(TR
        $(TDNW $(LINK2 std_regex.html, stdd.regex))
        $(TD Regular expressions.)
    )
    $(TR
        $(TDNW $(LINK2 std_ascii.html, stdd.ascii))
        $(TD Routines specific to the ASCII subset of Unicode.)
    )
    $(TR
        $(TDNW $(LINK2 std_encoding.html, stdd.encoding))
        $(TD Handle and transcode between various text encodings.)
    )
    $(TR
        $(TDNW $(LINK2 std_windows_charset.html, stdd.windows.charset))
        $(TD Windows specific character set support.)
    )
    $(TR
        $(TDNW $(LINK2 std_outbuffer.html, stdd.outbuffer))
        $(TD Serialize data to $(CODE ubyte) arrays.)
    )
    $(LEADINGROW Type manipulations)
    $(TR
        $(TDNW $(LINK2 std_conv.html, stdd.conv))
        $(TD Convert types from one type to another.)
    )
    $(TR
        $(TDNW $(LINK2 std_typecons.html, stdd.typecons))
        $(TD Type constructors for scoped variables, ref counted types, etc.)
    )
    $(TR
        $(TDNW $(LINK2 std_bitmanip.html, stdd.bitmanip))
        $(TD High level bit level manipulation, bit arrays, bit fields.)
    )
    $(TR
        $(TDNW $(LINK2 std_variant.html, stdd.variant))
        $(TD Discriminated unions and algebraic types.)
    )
    $(TR
        $(TDNW $(LINK2 core_bitop.html, core.bitop))
        $(TD Low level bit manipulation.)
    )
    $(LEADINGROW Vector programming)
    $(TR
        $(TDNW $(LINK2 core_simd.html, core.simd))
        $(TD SIMD intrinsics)
    )

$(COMMENT
    $(LEADINGROW Undocumented modules (intentionally omitted).)
    $(TR
        $(TDNW
            $(LINK2 core_sync_config.html, core.sync.config)$(BR)
            $(LINK2 std_concurrencybase.html, stdd.concurrencybase)$(BR)
            $(LINK2 std_container_util.html, stdd.container.util)$(BR)
            $(LINK2 std_regex_internal_backtracking.html, stdd.regex.internal.backtracking)$(BR)
            $(LINK2 std_regex_internal_generator.html, stdd.regex.internal.generator)$(BR)
            $(LINK2 std_regex_internal_ir.html, stdd.regex.internal.ir)$(BR)
            $(LINK2 std_regex_internal_kickstart.html, stdd.regex.internal.kickstart)$(BR)
            $(LINK2 std_regex_internal_parser.html, stdd.regex.internal.parser)$(BR)
            $(LINK2 std_regex_internal_tests.html, stdd.regex.internal.tests)$(BR)
            $(LINK2 std_regex_internal_thompson.html, stdd.regex.internal.thompson)$(BR)
            $(LINK2 std_stdiobase.html, stdd.stdiobase)$(BR)
        )
        $(TD
             Internal modules.
        )
    )
    $(TR
        $(TDNW
            $(LINK2 core_vararg.html, core.vararg)$(BR)
            $(LINK2 std_c_fenv.html, stdd.c.fenv)$(BR)
            $(LINK2 std_c_linux_linux.html, stdd.c.linux_linux)$(BR)
            $(LINK2 std_c_linux_socket.html, stdd.c.linux_socket)$(BR)
            $(LINK2 std_c_locale.html, stdd.c.locale)$(BR)
            $(LINK2 std_c_math.html, stdd.c.math)$(BR)
            $(LINK2 std_c_process.html, stdd.c.process)$(BR)
            $(LINK2 std_c_stdarg.html, stdd.c.stdarg)$(BR)
            $(LINK2 std_c_stddef.html, stdd.c.stddef)$(BR)
            $(LINK2 std_c_stdio.html, stdd.c.stdio)$(BR)
            $(LINK2 std_c_stdlib.html, stdd.c.stdlib)$(BR)
            $(LINK2 std_c_string.html, stdd.c.string)$(BR)
            $(LINK2 std_c_time.html, stdd.c.time)$(BR)
            $(LINK2 std_c_wcharh.html, stdd.c.wcharh)$(BR)
            $(LINK2 std_stdint.html, stdd.stdint)$(BR)
        )
        $(TDN
             Redirect modules.
        )
    )
    $(TR
        $(TDNW
            $(LINK2 std_mmfile.html, stdd.mmfile)$(BR)
            $(LINK2 std_typetuple.html, stdd.typetuple)$(BR)
        )
        $(TD
             Deprecated modules.
        )
    )
    $(TR
        $(TDNW
            $(LINK2 std_experimental_logger.html, stdd.experimental.logger)$(BR)
            $(LINK2 std_experimental_logger_core.html, stdd.experimental.logger.core)$(BR)
            $(LINK2 std_experimental_logger_filelogger.html, stdd.experimental.logger.filelogger)$(BR)
            $(LINK2 std_experimental_logger_multilogger.html, stdd.experimental.logger.multilogger)$(BR)
            $(LINK2 std_experimental_logger_nulllogger.html, stdd.experimental.logger.nulllogger)$(BR)
        )
        $(TD
             Experimental modules.
        )
    )
)
)

Macros:
        TITLE=Phobos Runtime Library
        DDOC_BLANKLINE=
        _=
