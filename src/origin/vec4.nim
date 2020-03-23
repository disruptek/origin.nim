import std/algorithm

import common

# Constructors

proc vec4*(): Vec4 {.inline.} =
  ## Initialize a 4D zero vector.
  result.fill(0)

proc vec4*(n: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector with all components set to `n`.
  result.fill(n)

proc vec4*(v: Vec): Vec4 {.inline.} =
  ## Initialize a 4D vector from another vector `v`.
  ##
  ## `v` need not be the same length as the type of vector to initialize.
  ##
  ## In the case of unequal lengths, the standard OpenGL GLSL rule applies:
  ## if `v` has less components than the type to initialize, any remaining
  ## components are set to zero. If `v` has more components than the type to
  ## initialize, the extras are dropped from the result.
  const high = min(4, v.len)-1
  result[0..high] = v[0..high]

proc vec4*(x, y: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalars `x` and `y`.
  result[0..1] = [x, y]

proc vec4*(x, y, z: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalars `x`, `y`, and `z`.
  result[0..2] = [x, y, z]

proc vec4*(x, y, z, w: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from 4 scalars, `x`, `y`, `z`, and `w`.
  [x, y, z, w]

proc vec4*(xy: Vec2, z: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from 2D vector `xy` and scalar `z`.
  result[0..2] = [xy[0], xy[1], z]

proc vec4*(x: float32, yz: Vec2): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalar `x` and 2D vector `yz`.
  result[0..2] = [x, yz[0], yz[1]]

proc vec4*(xy, zw: Vec2): Vec4 {.inline.} =
  ## Initialize a 4D vector from 2D vectors `xy` and `zw`.
  [xy[0], xy[1], zw[0], zw[1]]

proc vec4*(x: float32, yzw: Vec3): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalar `x` and 3D vector `yzw`.
  [x, yzw[0], yzw[1], yzw[2]]

proc vec4*(xyz: Vec3, w: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from 3D vector `xyz` and scalar `w`.
  [xyz[0], xyz[1], xyz[2], w]

proc vec4*(xy: Vec2, z, w: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from 2D vector `xy` and scalars `z` and `w`.
  [xy[0], xy[1], z, w]

proc vec4*(x, y: float32, zw: Vec2): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalars `x` and `y` and 2D vector `zw`.
  [x, y, zw[0], zw[1]]

proc vec4*(x: float32, yz: Vec2, w: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalar `x`, 2D vector `yz` and scalar `w`.
  [x, yz[0], yz[1], w]

# Constants

const zero* = ## \
  ## A 4D zero vector.
  vec4()

