# bend-over

A band-based Turing Tarpit for the PLT Games, December 2012.

Ordinary stack- and register-based languages allow the machine to write and modify the tape of data arbitrarily, and that power is much too expensive to have in a state penitentiary. So, what can you do? Just *bend over* and take it!

Bend-over is a *band*-based programming language, in that it operates on a band. This is like a Turing Machine tape, but it can be bent and folded over onto itself--indeed, to perform any sort of calculation, one is required to bend the band overtop of itself and flatten the values together!

## Language

Bend-over has a band for data storage/manipulation, and a pointer. The band initially extends infinitely out to the right, and is anchored at the left end, called the origin. This is also where the pointer begins at. As the band may take on multiple shapes and orientations during computation, when the pointer is moving towards the anchored end, it is moving *inwards*, and *outwards* when going in the opposite direction; as well, *above* is considered to the West if outwards is North, and *below* is East.

```
# if 'o' is a cell
# and 'P' is the pointer location
# and 'X' is the anchored cell

            ABOVE
              |
  IN -- X o o P o o … -- OUT
              |
            BELOW


             OUT
              |
              o
     ABOVE -- P -- BELOW
              o
  IN -- X o o o
              |
           also IN

```

Although indexing is entirely unnecessary, you index from zero in Bend-over, with the anchored space considered as having the zeroth index. The band is initially empty, except for items 1 and 2, containing the number `1` and an alphabet string (see below), respectively.

There are two datatypes in Bend-over: numeric and string. Numeric-type data are typically and canonically arbitrary-precision rational numbers, but can also be implemented as arbitrary-precision integers or double-precision floating-point numbers. String-type data are of arbitrary length and any encoding. Strings are considered holistic units: no distinction is made between a character and a string of length one. When a portion of the band is empty--e.g. as it is upon initialization--it is considered to be filled with state ε, which is simultaneously a numeric and string type; more specifically, the state is a merger of the number `0` and the empty string `""`. In Bend-over, both are considered equal and interchangeable, and have the same internal representation.

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
    + The cell closest to the origin is on the bottom, so all bends technically fold overtop of the previous parts of the band.
    + The contents of the band will not be modified by crossing over until a flattener is used.
    + The anchored item at index 0 cannot be used as a pivot point for a bend.
+ `i` and `o` are the input and output pragmas, which allow for execution-time interaction with the user.
    + Input is taken line-by-line, with the program waiting until a newline is received from the user before continuing, and returning the value as a string.
    + Output is a direct feed to stdout, with all linebreak usage controlled by the program and not the implementation.
+ `d` is the dump pragma, which forces the interpreter to output the current state of the tape in a human-readable fashion, truncated three spaces after the last non-ε datum.
    + State ε data may be represented as `0`, `""`, `ε` or `e`; the choice is implementation-dependent.
+ `e` is the exit pragma, which tells the interpreter to quit everything, returning the contents of the currently pointed-to cell.
    + 

The structure of the program itself is straightforward. The first line consists of the debug flag and the alphabet, and the rest of the program is the program instructions.

In the alphabet line, each new character that appears is added to the list of alphabet characters, and then this alphabet list is made into a string, and placed in the third cell on the tape. Repeated instances of characters do not result in repeats in the alphabet string. The newline character is always included. If the first character in the line is a lowercase 'd' (`d`, ASCII codepoint 100), then the debug flag is triggered, and the alphabet-string-parsing only begins on the following character, and *will not* exclude any additional 'd' characters encountered.

In the instruction portion of the program, whitespace is ignored, and can be used for structuring the program. `#` is used for comments, which run to the end of the line. Otherwise, each instruction is read in turn and executed, affecting the tape or its contents as necessary. There is an implicit exit pragma at the end of every program, so the final result of the Bend-over computation is the contents of the cell on which the pointer rests.

The file extension for Bend-over programs is `.bov`.

## Flatteners

The arguably most important operations of Bend-over are the flatteners. Whenever a flattener is activated, any and all cells on the band which are overlapping other cells have their contents put together w.r.t. the downwards direction--flattened--with the result being put into the bottom-most cell (the one closest to the origin). The remaining cells that have overlapped others are filled with state ε. All cells that do not overlap anything, or are not overlapped by anything, are left untouched.

Flatteners are global, and affect all overlapping entries. When a flattener is called, the order of operation is as follows:
1. The first (innermost) cell on top of another cell is found. It is treated as the right operand, and the item beneath it the left operand.
2. The result is placed in the bottom and an ε-state is left in the top.
3. The next cell on top of another is found. If it is the third or higher in a stack, the operation is performed with the bottommost as the left operand and the found cell as the right.
4. This is continued until all overlaps have been flattened.

There are two flatteners: *sum* and *product*, also referred to as addition and multiplication.

The sum flattener, `+`, adds the contents of overlapping cells together.
+ For two numbers, this is a simple sum. Subtraction may be defined by splitting (`$`) the right operand first and deleting the reciprocal.
+ For two strings, this is the concatenation of the first string and the second.
+ An ε-state added to anything leaves that thing unchanged, regardless of order. (This also applies to two ε-states added together, which results in another ε.)
+ For a number added to a string or vice versa, ((XXX -- this is currently undefined)).

The product flattener, `x`, not only multiplies the contents of overlapping cells together, but also performs other useful duties.
+ For two numbers, this is their mathematical product. Division can be performed by splitting the right operand first and deleting the negation.
+ For two strings, this tests if they are equal

## Practical Programming

Because Bend-over is so minimal, this section details some common design patterns.

### Concepts

### Snippets

+ Insert an ε before an arbitrary item (like `@` but first item is an ε and not the original): `@c$$/>>/<$$/>>@RR>R+R<//<`
    + How it works:
        + On a string that coverts to a number: Clone, convert, and split twice. The tape will now be 'number, negative reciprocal, reciprocal'. The number and the reciprocal are both deleted, leaving the negative reciprocal, which is split twice more, making 'negative reciprocal, number, negation'. The negative reciprocal is deleted, and the number and its negation are added together.
        + On a string that coverts to ε: Clone, convert to ε, split twice, so the tape is now 'ε, ε, ε'. Delete first and third ε-states, split twice more, the tape is 'ε, ε, ε' again. Delete the first ε, add the remaining ε's together, then clean up the residue.
        + On a number or ε: Clone, convert to string, split twice, tape is now 'head, ε, tail'. Delete the head and tail elements, and split the ε twice, leaving 'ε, ε, ε'. Continues as above.
    + Holistically, this works because, if you split a number twice, the last two elements are the negations of each other. And since splitting a single character string results in the same character followed by an ε, the program acts by normalizing the conversions of numbers, ε-states, and non-numeric strings to ε, and then adding the last two elements of a double split together, which accomodates the conversions of numeric strings, i.e. numbers.
    + Relies on the rest of the tape after the item not crossing over any of the band above it that is sum-flattenable.

### Implementations

Implementations...
+ SHOULD provide the numeric type as exact rationals, but MAY also implement them as floats of *at least* double-precision.
+ MAY return the coordinates and/or the index of the final cell when an exit pragma is called or the end of the program is reached.
+ MUST perform flattening calculations from bottom to top, and from in to out, as specified in the 'Flatteners' section.