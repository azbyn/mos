// Written in the D programming language.

/// Helper functions for std.algorithm package.
module stdd.algorithm.internal;


// Same as std.string.format, but "self-importing".
// Helps reduce code and imports, particularly in static asserts.
// Also helps with missing imports errors.
package template algoFormat()
{
    import stdd.format : format;
    alias algoFormat = format;
}

// Internal random array generators

package(stdd) T* addressOf(T)(ref T val) { return &val; }
