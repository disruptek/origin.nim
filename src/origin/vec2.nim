import std/algorithm

import common

# Constructors

proc vec2*(): Vec2 {.inline.} =
  ## Initialize a 2D zero vector.
  result.fill(0)

proc vec2*(n: float32): Vec2 {.inline.} =
  ## Initialize a 2D vector with all components set to `n`.
  result.fill(n)

proc vec2*(v: Vec): Vec2 {.inline.} =
  ## Initialize a 2D vector from another vector `v`.
  ##
  ## `v` need not be the same length as the type of vector to initialize.
  ##
  ## In the case of unequal lengths, the standard OpenGL GLSL rule applies:
  ## if `v` has less components than the type to initialize, any remaining
  ## components are set to zero. If `v` has more components than the type to
  ## initialize, the extras are dropped from the result.
  result[0..1] = v[0..1]

proc vec2*(x, y: float32): Vec2 {.inline.} =
  ## Initialize a 2D vector from scalars `x` and `y`.
  [x, y]

# Constants

const zero* = ## \
  ## A 2D zero vector.
  vec2()
