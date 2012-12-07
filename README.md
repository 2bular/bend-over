# bend-over

A prison-based Turing Tarpit for the PLT Games.

Ordinary stack- and register-based languages allow the machine to write and modify the tape of data arbitrarily, and that power is much too expensive to have in a state penitentiary. So, what can you do?

Bend-over is a *band*-based programming language, in that it operates on a stack. This is like a Turing Machine tape, but it can be bent and folded over onto itself--indeed, to perform any sort of calculation, one is required to bend the band overtop of itself and flatten the values together!

## Language

Bend-over has a band for data storage/manipulation, and a pointer. The band initially extends infinitely out to the right, and is anchored at the leftward end. As the band may take on multiple shapes during computation, when the pointer is moving towards the anchored end it is moving inwards, and outwards when going in the opposite direction along the band. The band is initially empty, except for the second and third items, containing `1` and an alphabet string (see section 'Practical Programming').

There are two datatypes in Bend-over: numeric and string. Numeric types are . When the band is empty, it is considered to be filled with state `ε`. This is the name of the state is a merger of the number `0` and the empty string `""`, and thus both are considered equal.

Bend-over has a few major instructions for band manipulation.

+ `>` and `<` move the point out and in, respectively, along the band.
+ `!` is the clone operator, which duplicates the current cell, pushing the tape ahead of it outward.
+ `$` is the split operator, as the clone except the two copies of the original cell are now...
    + The negation and the reciprocal of the number, or
    + The first character of and the rest of the string.
+ `@` is the convert operator, which casts numbers to strings and vice versa.
    + Strings that do no begin with a number, and thereby would not be cast to any number, are cast to `ε`.
    + State `ε` here is treated as `0`, so it converts to `"0"`, i.e. the string containing only the zero character.
+ `/` is the snip or remove operator, which removes the pointed-to cell from the tape, pulling the tape ahead of it inward.
+ `+` and `x` are the sum and product flatteners.
+ `L` and `R` bend the tape 90 degrees in the specified direction.
    + As the key goal for performing meaningful computation is to cross the bands over and flatten, crossing the band is not only acceptable but also encouraged.
    + The contents of the band will not be modified by crossing over until a flattener is used.

The structure of the program itself is straightforward. The first line consists of the debug flag and the alphabet, and the rest of the program is the instructions. In the alphabet line, each character that appears is added to the list of alphabet characters, and then this alphabet list is made into a string, and placed in the third cell on the tape. Whitespace in the instruction portion of the program is ignored, and can be used for structure.