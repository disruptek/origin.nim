# Origin

An opinionated linear algebra and general mathematics library useful for game
development.

A few notes:
This software is of alpha-quality, although all math has been scrutinized for
correctness and all unit tests currently pass. This is the author's first Nim
library that was developed in the process of learning the language, and all code
was ported from their existing [Common Lisp
implementation](https://github.com/mfiano/origin). As such, it may not
be very idiomatic or in the best of styles, and it is certainly lacking in the
macrology department in an effort to be readable like it would be in a math
text, and understandable to newcomers to the language without a lot of "magic"
or code generation.

# Overview

Origin is a pure Nim library providing support for common math functions related
to game development. The following constructs are supported:

* 2, 3, and 4-dimensional vectors
* 2x2, 3x3 and 4x4 square matrices
* Quaternions
* Non-linear interpolation of scalars, such as "easing" functions.
* General linear algebra utility functions (point-plane intersection tests,
  etc).
* There is planned support for dual quaternions, collision detection and physics
  simulation algorithms, and more in the future.

Most functions have an API for both freshly allocating new constructs in
addition to in-place modification.

This library is currently lacking good offline documentation, as the code is
still being fleshed out. However, you can consult the unit tests or generate the
HTML from the documentation comments with nim doc to get a clearer idea on how
to use it.

# Matrix format
Until good documentation is present, it should be noted that matrices represent
a set of column-vectors that are stored in column-major order. This should be
familiar to anyone already familiar with OpenGL, but it's important to make note
of, as it differs from many computer graphics math code.

With column-vectors, this means that matrix application (matrix/vector
multiplication), it is done in pre-multiplication order (the matrix appears on
the left; the vector on the right).

Column-major refers to the actual memory layout of the data; it is stored as a
contiguous array one column at a time (as opposed to one row at a time as with
row-major ordering).
