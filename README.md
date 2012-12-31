# Bend-over

A Turing Tarpit for the PLT Games, December 2012.

**Bend-over** is a *band*-based programming language, in that it operates on a band. This is like a Turing Machine tape, but it can be bent and folded over onto itself--indeed, to perform any sort of calculation, one is required to bend the band overtop of itself and flatten the values together!

It is suspected, but not currently known, that Bend-over is Turing-complete.

## Language

Bend-over has a band for data storage/manipulation, and a pointer. The band initially extends infinitely out to the right, and is anchored at the left end, called the *origin*. This is also where the pointer begins. As the band may take on multiple shapes and orientations during computation, when the pointer is moving towards the anchored end, it is moving *inwards*, and *outwards* when going in the opposite direction; as well, *above* is considered to the West if outwards is North, and *below* is East.

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

+ `<` and `>` move the point in and out, respectively, along the band.
+ `@` is the clone operator, which duplicates the current cell by inserting an identical cell in the tape, pushing the tape ahead of it outward (and preserving its bends).
+ `$` is the split operator, working as the clone operator, except, depending on the datatype, the two copies of the original cell are now...
    + Numeric: the negation and the reciprocal of the number.
    + String: the first character and the rest of the string.
    + State ε: two state ε items.
+ `/` is the snip or remove operator, which removes the pointed-to cell from the tape, pulling the tape ahead of it inward (and preserving its bends).
+ `c` is the convert operator, which casts numbers to strings and vice versa.
    + Strings are only converted to numbers if they begin with at least one decimal digit, otherwise they are cast to ε.
    + State ε is treated as `0` and not `""`, so it converts to `"0"`, i.e. the string containing only the zero character.
+ `+` and `x` are the sum and product flatteners. (see section '<a href="#Flatteners">Flatteners</a>') ((TODO -- add `p` permute values flattener?))
+ `L` and `R` bend the tape 90 degrees in the specified direction. (Left and right from the point of view of the pointer, where outwards is forwards, e.g. left is above-wards.)
    + The cell closest to the origin is on the bottom of the overlapping stack, should there be any overlaps; all bends technically fold overtop of the previous parts of the band.
    + The contents of the band will not be modified by crossing over until a flattener is used.
    + The anchored item at index 0 cannot be used as a pivot point for a bend.
+ `i` and `o` are the input and output pragmas, which allow for execution-time interaction with the user.
    + Input is taken line-by-line, with the program waiting until a newline is received from the user before continuing, and returning the value as a string, sans newline.
    + Output is a direct feed to stdout, with all newline usage controlled by the program and not the implementation.
+ `d` is the dump pragma, which forces the interpreter to output the current state of the tape in a human-readable fashion.
+ `e` is the exit pragma, which tells the interpreter to quit everything, returning the contents of the currently pointed-to cell.

```
USING @:
           ( 7 )-<-( 6 )-<-( 5 )                       ( 7 )-<-( 6 )-<-( 5 )
             v               ^                           v               ^
   ( 1 )->-(2\8)->-( 3 )->-( 4 )  ==>  ( 1 )->-( 2 )->-(3\8)->-( 4 )->-( 4 ) <<< cloned cell
             v              ^^^                          v      ^^^
           ( 9 )     pointer here                      ( 9 )   pointer here
```

The structure of the program itself is straightforward. The first line consists of the alphabet, and the rest of the program is the program instructions.

In the alphabet line, each new character that appears is added to the list of alphabet characters, and then this alphabet list is made into a string, and placed in the third cell on the tape. Repeated instances of characters do not result in repeats in the alphabet string. The newline character is always included.

In the instruction portion of the program, whitespace is ignored, and can be used for structuring the program. `#` is used for comments, which run to the end of the line. Otherwise, each instruction is read in turn and executed, affecting the tape or its contents as necessary. Any non-instruction character *not* commented out is ignored: it is good practice to comment out all non-instructions, however, lest you accidentally type in a `c`, `d`, `e`, `i`, or `o`. There is an implicit exit pragma at the end of every program, so the final result of the Bend-over computation is the contents of the cell on which the pointer rests.

Any program can be written without pragmas, which, though useful, are not strictly necessary. 

The file extension for Bend-over programs is `.bov`.

## Flatteners

The arguably most important operations of Bend-over are the flatteners. Whenever a flattener is activated, any and all cells on the band which are overlapping other cells have their contents put together w.r.t. the downwards direction--flattened--with the result being put into the bottom-most cell (the one closest to the origin). The remaining cells that have overlapped others are filled with state ε. All cells that do not overlap anything, or are not overlapped by anything, are left untouched when there is a flattening.

Flatteners are global, and affect all overlapping entries. When a flattener is called, the order of operation is as follows:

1. The first (innermost) cell on top of another cell is found. It is treated as the right operand, and the item beneath it the left operand.
2. The result is placed in the bottom and an ε-state is left in the top.
3. The next cell on top of another is found. If it is the third or higher in a stack, the operation is performed with the bottommost as the left operand and the found cell as the right.
4. This is continued until all overlaps have been flattened.

There are two flatteners: *sum* and *product*, also referred to as addition and multiplication.

The **sum flattener**, `+`, adds the contents of overlapping cells together.

+ For two numbers, this is a simple sum.
+ For two strings, this is the concatenation of the first string and the second.
+ An ε-state added to anything leaves that thing unchanged, regardless of order. (This also applies to two ε-states added together, which results in another ε.)
+ For a number added to a string or vice versa, the result is the string formed if the original string's characters' bytes are increased in value by the number. If the number is not an integer, then it is rounded down towards negative infinity. For instance, "`7*Z`" + 3 would result in "`:-]`".

The **product flattener**, `x`, not only multiplies the contents of overlapping cells together, but also performs other useful duties.

+ For two numbers, this is their mathematical product. If one number or both are ε-states, the result is another ε-state.
+ For two strings, this tests if the bottom is greater than the top. It returns 1 if they are, and an ε-state otherwise.
+ For a string and a number, or a string and an ε-state, this evaluates the contents of the string as program instructions, the number of times this is done dictated by the number. The result is the original string. See below.

### Product Flattener Execution

Also known as simply 'executing'. When you multiply a string by a number, the contents of the string are executed as a Bend-over subroutine, with the number of times looped specified by the number. If the number is not an integer, it is rounded down towards negative infinity. If the number is ε, no execution is performed. If the number is negative, its absolute value represents the number of nested subroutines to break out of. The rest of the original program or subroutine continues its execution when the subroutine finishes.

The "return result" of such a multiplication is technically the string used as the program. However, since the actual execution can modify the band and any value on it, including the string of the program that was just product-flattened, the "return value" *after the subroutine runs* can be whatever the subroutine leaves at that cell.

Modifying the program string will not change the commands that the pointer will follow mid-execution. However, you can remove or change the values of any pending multiplication, as well as set up new ones, provided they would occur further along the tape than the site of the current multiplication. The behaviour of multi-level stacks modified in the middle of a multiplication flattening is undefined and should not be relied upon.

Because of the built-in ability for Bend-over to execute its own code, no conditional statements or other explicit looping mechanisms are provided. For any sort of looping or recursion, Bend-over takes the same stance as Muriel and Smurf: get acquainted with quines and pseudoquines.

The exact mechanism of the multiplication is as follows. When a number `n` is multiplied by a string `s`...

+ The string is placed in the bottommost cell of the stack.
+ If `n` is not an integer, it is rounded down to negative infinity.
+ If `n` equals `ε`, the evaluation ends.
+ If `n` is positive,
    + Concatenate `n` copies of `s` internally (`ss`).
    + Evaluate the contents of `ss` as a Bend-over program.
    + The evaluation ends.
+ If `n` is negative, 
    + Break out of `n` nested subroutines.
    + If the main execution routine is broken out of, treat it as though an exit pragma `e` is encountered.
    + The evaluation ends.

## Practical Programming

Because Bend-over is so minimal, this section details some common design patterns.

### Concepts

+ The tape can be bent into a loop, having a run of cells on top of another, and can even be "folded" backwards overtop of itself or zippered up by having tall stacks of repeatedly folded over data. This can be utilized to zip lists of values together, or to manipulate sequences together, but watch your bends.
+ Obviously, subtraction and division are lacking from Bend-over. To perform either, use the split operator `$` on the subtrahend/divisor to negate/invert it, and then add/multiply the two values together to get the result. Note that this means a division by zero is equal to zero, i.e. ε.
+ To normalize a non-ε number to 1, multiply it by its reciprocal.  This can be done by cloning it and splitting the outward clone--or splitting it twice--then multiplying it by its reciprocal. Use the value in the middle as a way to extend the band to accomodate the multiplication, you can always delete it all afterwards. Attempting to normalize an ε-state results in another ε.
+ The typical convention for "boolean" data types is 1 for True and ε (i.e. zero) for False, as there is no builtin boolean datatype. String comparison (string-by-string multiplication) follows this, and the sum and product flatteners become logical operators AND and OR, respectively. (The result of OR needs to be normalized to one, but if you're performing multiple logical operations in a row before using the boolean elsewhere, the normalization can wait until after you finish.) The negation operation for this would be a numerical negation (through `$`) plus 1, but only if the number is normalized to 1/ε.
+ There is no operator for numeric equality! Subtract one number from the other, and normalize the result: you will have an ε-state if they are equal, and a `1` otherwise. Subtract this value from one to swap it.
+ There is also no conditional execution operator! Use the multiplication flattener on a string and a "boolean" to dictate whether or not something should be executed. An else could be constructed by simultaneously multiplying the logical negation by the else clause.
+ You can consider negative values for executions as break statements. Remember that it will go right back to continuing the multiplication flattening where it left off.
+ Quines? Good luck and godspeed, you brave, brave soul. You cannot simply add whatever strings you please, because they can only be inserted through the alphabet and reconstruction. An elegant solution may arise from egregious band-bending, and the string transposition (summing a string and a number) may aid you, but don't count on it.
    + The way to handle any and all subroutines without quining would be to build the all subroutines explicitly at the beginning of the program, and call them by folding integers (usually 1) over them.
    + Fairly sure quines are next-to impossible. I invite any and all willing to try and do so. (ascii, for reference: @ 64, $ 36, / 47, c 99, L 76, R 82, + 43, x 120, > 62, < 60, # 35, \n 13)
+ To loop something a certain number of times, but also have a piece of code run the first time only, use a comment at the end of the program: since comments are parsed from the comment character to the next newline, and the string is exactly concatenated the number of times to make that number of loops, you can achieve a once only effect using code like `<once>\n<body>#`. If it was looped, it would be equivalent to the following program executing: (notice how the comments block out bits of code)
```
<once>
<body>#<once>
<body>#<once>
...
<body>#<once>
<body>#
```

### Snippets

+ Insert an ε before an arbitrary item (like `@` but first item is an ε-state, not the original item): `@c$$/>>/<$$/>>@RR>R+R<//<`
    + How it works:
        + On a string that coverts to a number: Clone, convert, and split twice. The tape will now be 'number, negative reciprocal, reciprocal'. The number and the reciprocal are both deleted, leaving the negative reciprocal, which is split twice more, making 'negative reciprocal, number, negation'. The negative reciprocal is deleted, and the number and its negation are added together.
        + On a string that coverts to ε: Clone, convert to ε, split twice, so the tape is now 'ε, ε, ε'. Delete first and third ε-states, split twice more, the tape is 'ε, ε, ε' again. Delete the first ε, add the remaining ε's together, then clean up the residue.
        + On a number or ε: Clone, convert to string, split twice, tape is now 'head, ε, tail'. Delete the head and tail elements, and split the ε twice, leaving 'ε, ε, ε'. Continues as above.
    + This works because, if you split a number twice, the last two elements are the negations of each other. And since splitting a single character string results in the same character followed by an ε, the program acts by normalizing the conversions of numbers, ε-states, and non-numeric strings to ε, and then adding the last two elements of a double split together, which accomodates the conversions of numeric strings, i.e. numbers.
    + Relies on the rest of the tape after the item not crossing over any of the band above it that is sum-flattenable.

### Implementations

Implementations, in general...

+ SHOULD provide the numeric type as exact rationals, but MAY also implement them as floats of *at least* double-precision.
+ MAY return the coordinates and/or the index of the final cell when an exit pragma is called or the end of the program is reached.
+ MUST perform flattening calculations from bottom to top, and from in to out, as specified in the '<a href="#Flatteners">Flatteners</a>' section.
+ MAY have undefined behaviour when modifying "stacks" of levels greater than two when using the product flattener for evaluation, but SHOULD be internally consistent.
+ SHOULD end a dump two to four spaces after the last non-empty cell.
+ SHOULD represent ε-states in a dump as `0`, `""`, `ε` or `e`.
+ MAY choose not to implement the `d` pragma :P