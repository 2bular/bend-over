# bend-over

A prison-based Turing Tarpit for the PLT Games, December 2012.

Ordinary stack- and register-based languages allow the machine to write and modify the tape of data arbitrarily, and that power is much too expensive to have in a state penitentiary. So, what can you do? Just *bend over* and take it!

Bend-over is a *band*-based programming language, in that it operates on a band. This is like a Turing Machine tape, but it can be bent and folded over onto itself--indeed, to perform any sort of calculation, one is required to bend the band overtop of itself and flatten the values together!

## Language

Bend-over has a band for data storage/manipulation, and a pointer. The band initially extends infinitely out to the right, and is anchored at the left end. As the band may take on multiple shapes and orientations during computation, when the pointer is moving towards the anchored end it is moving inwards, and outwards when going in the opposite direction along the band. Although indexing is entirely unnecessary, one indexes from zero in Bend-over, with the anchored space considered as having index 0. The band is initially empty, except for items 1 and 2, containing the number `1` and an alphabet string (see section 'Practical Programming'), respectively.

There are two datatypes in Bend-over: numeric and string. Numeric-type data are typically arbitrary-precision rational numbers, but are implementation-dependent and can also be arbitrary-precision integers and double-precision floating-point numbers. String-type data are holistic units: no distinction is made between a character and a string of length one. When a portion of the band is empty--e.g. as it is upon initialization--it is considered to be filled with state ε, which is simultaneously a numeric and string type; more specifically, the state is a merger of the number `0` and the empty string `""`. In Bend-over, both are considered equal and interchangeable, and have the same internal representation.

Bend-over has a few major instructions for band manipulation.

+ `>` and `<` move the point out and in, respectively, along the band.
+ `@` is the clone operator, which duplicates the current cell by inserting an identical cell in the tape, pushing the tape ahead of it outward (and preserving its bends).
+ `$` is the split operator, working as the clone operator, except, depending on the datatype, the two copies of the original cell are now...
    + Numeric: the negation and the reciprocal of the number.
    + String: the first character and the rest of the string.
    + State ε: two state ε items.
+ `/` is the snip or remove operator, which removes the pointed-to cell from the tape, pulling the tape ahead of it inward (and preserving its bends).
+ `c` is the convert operator, which casts numbers to strings and vice versa.
    + Strings are only converted to numbers if they begin with at least one decimal digit, otherwise they are cast to ε.
    + State ε is treated as `0` and not `""`, so it converts to `"0"`, i.e. the string containing only the zero character.
+ `+` and `x` are the sum and product flatteners. (see section 'Flatteners')
+ `L` and `R` bend the tape 90 degrees in the specified direction.
    + As the key goal for performing meaningful computation is to cross the bands over and flatten, crossing the band is not only acceptable but also encouraged.
    + The contents of the band will not be modified by crossing over until a flattener is used.
    + The anchored item at index 0 cannot be used as a pivot point for a bend.
+ `i` and `o` are the input and output pragmas, which allow for execution-time interaction with the user.
    + Input is taken line-by-line, with the program waiting until a newline is received from the user before continuing.
    + Output is a direct feed to stdout, with all linebreak usage controlled by the program and not the implementation.
+ `d` is the dump pragma, which forces the interpreter to output the current state of the tape in a human-readable fashion, truncted three spaces after the last non-ε datum.
    + State ε data may be represented as `0`, `""`, `ε` or `e`; the choice is implementation-dependent.
    + This pragma is only avbailable in debug mode.

The structure of the program itself is straightforward. The first line consists of the debug flag and the alphabet, and the rest of the program is the program instructions.

In the alphabet line, each new character that appears is added to the list of alphabet characters, and then this alphabet list is made into a string, and placed in the third cell on the tape. Repeated instances of characters do not result in repeats in the alphabet string. The newline character is always included. If the first character in the line is a lowercase 'd' (`d`, ASCII codepoint 100), then the debug flag is triggered, and the alphabet-string-parsing only begins on the following character, and *will not* exclude any additional 'd' characters encountered.

In the instruction portion of the program, whitespace is ignored, and can be used for structuring the program. `#` is used for comments, which run to the end of the line.