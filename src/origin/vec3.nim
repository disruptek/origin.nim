import std/algorithm

import common
import vec

# Constructors

proc vec3*(): Vec3 {.inline.} =
  ## Initialize a 3D zero vector.
  result.fill(0)

proc vec3*(n: float32): Vec3 {.inline.} =
  ## Initialize a 3D vector with all components set to `n`.
  result.fill(n)

proc vec3*(v: Vec): Vec3 {.inline.} =
  ## Initialize a 2D vector from another vector `v`.
  ##
  ## `v` need not be the same length as the type of vector to initialize.
  ##
  ## In the case of unequal lengths, the standard OpenGL GLSL rule applies:
  ## if `v` has less components than the type to initialize, any remaining
  ## components are set to zero. If `v` has more components than the type to
  ## initialize, the extras are dropped from the result.
  const high = min(3, v.len)-1
  result[0..high] = v[0..high]

proc vec3*(x, y: float32): Vec3 {.inline.} =
  ## Initialize a 3D vector from scalars `x` and `y`.
  result[0..1] = [x, y]

proc vec3*(x, y, z: float32): Vec3 {.inline.} =
  ## Initialize a 3D vector from scalars `x`, `y`, and `z`.
  result[0..2] = [x, y, z]

proc vec3*(xy: Vec2, z: float32): Vec3 {.inline.} =
  ## Initialize a 3D vector from 2D vector `xy` and scalar `z`.
  result[0..2] = [xy[0], xy[1], z]

proc vec3*(x: float32, yz: Vec2): Vec3 {.inline.} =
  ## Initialize a 3D vector from scalar `x` and 2D vector `yz`.
  result[0..2] = [x, yz[0], yz[1]]

# Constants

const zero* = ## \
  ## A 3D zero vector.
  vec3()

const up* = ## \
  ## A 3D vector representing the positive Y / up direction.
  vec3(0, 1, 0)

const down* = ## \
  ## A 3D vector representing the negative Y / down direction.
  vec3(0, -1, 0)

const left* = ## \
  ## A 3D vector representing the negative X / left direction.
  vec3(-1, 0, 0)

const right* = ## \
  ## A 3D vector representing the positive X / right direction.
  vec3(1, 0, 0)

const forward* = ## \
  ## A 3D vector representing the positive Z / forward direction.
  vec3(0, 0, 1)

const backward* = ## \
  ## A 3D vector representing the negative Z / backward direction.
  vec3(0, 0, -1)

# Operations

proc cross*(o: var Vec3, v1, v2: Vec3) {.inline.} =
  ## Calculate the cross product of 3D vectors `v1` and `v2`, storing the result in the output
  ## vector `o`.
  o[0] = (v1[1]*v2[2]) - (v1[2]*v2[1])
  o[1] = (v1[2]*v2[0]) - (v1[0]*v2[2])
  o[2] = (v1[0]*v2[1]) - (v1[1]*v2[0])

proc cross*(v1, v2: Vec3): Vec3 {.inline.} =
  ## Calculate the cross product of 3D vectors `v1` and `v2`, storing the result in a new vector.
  result.cross(v1, v2)

proc box*(v1, v2, v3: Vec3): float32 {.inline.} =
  ## Calculate the box product of 3D vectors `v1`, `v2`, and `v3`.
  dot(cross(v1, v2), v3)

proc isParallel*(v1, v2: Vec3): bool {.inline.} =
  ## Check whether the 3D vectors `v1` and `v2` are parallel to each other.
  cross(v1, v2) ~= zero
