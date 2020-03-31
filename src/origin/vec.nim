import std/algorithm
import std/math
import std/random

import internal

type
  Vec*[N: static[int]] = array[N, float32]
  SomeVec* = Vec2 or Vec3 or Vec4
  Vec2* = Vec[2]
  Vec3* = Vec[3]
  Vec4* = Vec[4]

proc `$`*[N: static[int]](v: Vec[N]): string =
  ## Prints a vector readably.
  result = "["
  for i, c in v:
    result &= c.fmt
    if i < N-1: result &= ", "
  result &= "]"

# Component accessors

template x*(v: SomeVec): float32 = v[0]
template y*(v: SomeVec): float32 = v[1]
template z*(v: Vec3 or Vec4): float32 = v[2]
template w*(v: Vec4): float32 = v[3]
template `x=`*(v: var SomeVec, n: float32) = v[0] = n
template `y=`*(v: var SomeVec, n: float32) = v[1] = n
template `z=`*(v: var Vec3 or Vec4, n: float32) = v[2] = n
template `w=`*(v: var Vec4, n: float32) = v[3] = n

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
  let high = min(2, system.len(v)-1)
  result[0..high] = v[0..high]

proc vec3*(x, y: float32): Vec3 {.inline.} =
  ## Initialize a 3D vector from scalars `x` and `y`.
  result[0..1] = [x, y]

proc vec3*(x, y, z: float32): Vec3 {.inline.} =
  ## Initialize a 3D vector from scalars `x`, `y`, and `z`.
  result[0..2] = [x, y, z]

proc vec3*(xy: Vec2, z: float32): Vec3 {.inline.} =
  ## Initialize a 3D vector from 2D vector `xy` and scalar `z`.
  result[0..2] = [xy.x, xy.y, z]

proc vec3*(x: float32, yz: Vec2): Vec3 {.inline.} =
  ## Initialize a 3D vector from scalar `x` and 2D vector `yz`.
  result[0..2] = [x, yz.x, yz.y]

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
  let high = min(3, system.len(v)-1)
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
  result[0..2] = [xy.x, xy.y, z]

proc vec4*(x: float32, yz: Vec2): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalar `x` and 2D vector `yz`.
  result[0..2] = [x, yz.x, yz.y]

proc vec4*(xy, zw: Vec2): Vec4 {.inline.} =
  ## Initialize a 4D vector from 2D vectors `xy` and `zw`.
  [xy.x, xy.y, zw.x, zw.y]

proc vec4*(x: float32, yzw: Vec3): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalar `x` and 3D vector `yzw`.
  [x, yzw.x, yzw.y, yzw.z]

proc vec4*(xyz: Vec3, w: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from 3D vector `xyz` and scalar `w`.
  [xyz.x, xyz.y, xyz.z, w]

proc vec4*(xy: Vec2, z, w: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from 2D vector `xy` and scalars `z` and `w`.
  [xy.x, xy.y, z, w]

proc vec4*(x, y: float32, zw: Vec2): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalars `x` and `y` and 2D vector `zw`.
  [x, y, zw.x, zw.y]

proc vec4*(x: float32, yz: Vec2, w: float32): Vec4 {.inline.} =
  ## Initialize a 4D vector from scalar `x`, 2D vector `yz` and scalar `w`.
  [x, yz.x, yz.y, w]

# Constants

const vec2_zero* = ## \
  ## A 2D zero vector.
  vec2()

const vec3_zero* = ## \
  ## A 3D zero vector.
  vec3()

const vec4_zero* = ## \
  ## A 4D zero vector.
  vec4()

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

# Common operations

proc rand*[T: SomeVec](o: var T, range = 0f..1f): var T {.inline.} =
  ## Randomize the components of the vector `o` to be within the range `range`, storing the result
  ## in the output vector `o`.
  for i, _ in o: o[i] = rand(range)
  result = o

proc rand*[T: SomeVec](t: typedesc[T], range = 0f..1f): T {.inline.} =
  ## Initialize a new vector with its components randomized to be within the range `range`.
  result.rand(range)

proc zero*[T: SomeVec](o: var T): var T {.inline.} =
  ## Set all components of the vector `o` to zero.
  o.fill(0)
  result = o

proc `~=`*(a, b: SomeVec, tolerance = 1e-5): bool {.inline.} =
  ## Check if the vectors `a` and `b` are approximately equal.
  genComponentWiseBool(`~=`, a, b, tolerance)

proc clamp*[T: SomeVec](o: var T, v: T, range = -Inf.float32 .. Inf.float32): var T {.inline.} =
  ## Constrain each component of the vector `v` to lie within `range`, storing the result in the
  ## output vector `o`.
  for i, _ in o: o[i] = v[i].clamp(range.a, range.b)
  result = o

proc clamp*[T: SomeVec](v: T, range = -Inf.float32 .. Inf.float32): T {.inline.} =
  ## Constrain each component of the vector `v` to lie within `range`, storing the result in a
  ## new vector.
  result.clamp(v, range)

proc `+`*[T: SomeVec](o: var T, a, b: T): var T {.inline.} =
  ## Component-wise addition of the vectors `a` and `b`, storing the result in the output vector
  ## `o`.
  for i, _ in o: o[i] = a[i] + b[i]
  result = o

proc `+`*[T: SomeVec](a, b: T): T {.inline.} =
  ## Component-wise addition of the vectors `a` and `b`, storing the result in a new vector.
  result.`+`(a, b)

proc `-`*[T: SomeVec](o: var T, a, b: T): var T {.inline.} =
  ## Component-wise subtraction of the vectors `a` and `b`, storing the result in the output vector
  ## `o`.
  for i, _ in o: o[i] = a[i] - b[i]
  result = o

proc `-`*[T: SomeVec](a, b: T): T {.inline.} =
  ## Component-wise subtraction of the vectors `a` and `b`, storing the result in a new vector.
  result.`-`(a, b)

proc `-`*[T: SomeVec](o: var T): var T {.inline.} =
  ## Unary subtraction (negation) of the components of the vector `o`, storing the result in the
  ## output vector `o`.
  for i, _ in o: o[i] = -o[i]
  result = o

proc `-`*[T: SomeVec](v: T): T {.inline.} =
  ## Unary subtraction (negation) of the components of the vector `v`, storing the result in a new
  ## vector.
  result = v
  discard -result

proc `*`*[T: SomeVec](o: var T, a, b: T): var T {.inline.} =
  ## Calculate the Hadamard product (component-wise vector multiplication) of vectors `a` and `b`,
  ## storing the result in the output vector `o`.
  for i, _ in o: o[i] = a[i] * b[i]
  result = o

proc `*`*[T: SomeVec](a, b: T): T {.inline.} =
  ## Calculate the Hadamard product (component-wise vector multiplication) of vectors `a` and `b`,
  ## storing the result in a new vector.
  result.`*`(a, b)

proc `*`*[T: SomeVec](o: var T, v: T, scalar: float32): var T {.inline.} =
  ## Scale vector `v` by `scalar`, storing the result in the output vector `o`.
  for i, _ in o: o[i] = v[i] * scalar
  result = o

proc `*`*[T: SomeVec](v: T, scalar: float32): T {.inline.} =
  ## Scale vector `v` by `scalar`, storing the result in a new vector.
  result.`*`(v, scalar)

proc `/`*[T: SomeVec](o: var T, a, b: T): var T {.inline.} =
  ## Calculate the Hadamard quotient (component-wise vector division) of vectors `a` and `b`,
  ## storing the result in the output vector `o`.
  for i, _ in o: o[i] = if b[i] == 0: 0.0 else: a[i] / b[i]
  result = o

proc `/`*[T: SomeVec](a, b: T): T {.inline.} =
  ## Calculate the Hadamard quotient (component-wise vector division) of vectors `a` and `b`,
  ## storing the result in a new vector.
  result.`/`(a, b)

proc `/`*[T: SomeVec](o: var T, v: T, scalar: float32): var T {.inline.} =
  ## Scale vector `v` by the inverse of `scalar`, storing the result in the the output vector `o`.
  ##
  ## **Note**: If `scalar` is zero, the result will be zero rather than undefined.
  for i, _ in o: o[i] = if scalar == 0: 0.0 else: v[i] / scalar
  result = o

proc `/`*[T: SomeVec](v: T, scalar: float32): T {.inline.} =
  ## Scale vector `v` by the inverse of `scalar`, storing the result in a new vector.
  ##
  ## **Note**: If `scalar` is zero, the result will be zero rather than undefined.
  result.`/`(v, scalar)

proc `^`*[T: SomeVec](o: var T, v: T, power: float32): var T {.inline.} =
  ## Raise each component of vector `v` to the power of `power`, storing the result in the output
  ## vector `o`.
  for i, _ in o: o[i] = v[i].pow(power)
  result = o

proc `^`*[T: SomeVec](v: T, power: float32): T {.inline.} =
  ## Raise each component of vector `v` to the power of `power`, storing the result in a new vector.
  result.`^`(v, power)

proc `<`*(a, b: SomeVec): bool =
  ## Perform a component-wise less than comparison of the vectors `a` and `b`.
  ##
  ## **Note**: The system-defined template will allow `>` to be used as well.
  genComponentWiseBool(`<`, a, b)

proc `<=`*(a, b: SomeVec): bool {.inline.} =
  ## Perform a component-wise greater than comparison of the vectors `a` and `b`.
  ##
  ## **Note**: The system-defined template will allow `>=` to be used as well.
  genComponentWiseBool(`<=`, a, b)

proc sign*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Extract the sign of each component of vector `v`, storing the result in the output vector `o`.
  ##
  ## Each component becomes `-1` if it is less than zero, `0` if it is equal to zero, or `1` if it
  ## is greater than zero.
  for i, _ in o: o[i] = v[i].cmp(0).float
  result = o

proc sign*[T: SomeVec](v: T): T {.inline.} =
  ## Extract the sign of each component of vector `v`, storing the result in a new vector.
  ##
  ## Each component becomes `-1` if it is less than zero, `0` if it is equal to zero, or `1` if it
  ## is greater than zero.
  result.sign(v)

proc fract*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Compute the fractional part of each component of vector `v`, storing the result in the output
  ## vector `o`.
  for i, _ in o: o[i] = v[i] - v[i].floor
  result = o

proc fract*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the fractional part of each component of vector `v`, storing the result in a new vector.
  result.fract(v)

proc dot*(a, b: SomeVec): float32 {.inline.} =
  ## Calculate the dot product of vectors `a` and `b`.
  for i, _ in a: result += a[i] * b[i]

proc sqrt*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Calculate the square root of each component of vector `v`, storing the result in the output
  ## vector `o`.
  ##
  ## **Note**: If a component is negative, the result will be zero rather than undefined.
  for i, _ in o: o[i] = if v[i] < 0: 0.0 else: v[i].sqrt
  result = o

proc sqrt*[T: SomeVec](v: T): T {.inline.} =
  ## Calculate the square root of each component of vector `v`, storing the result in a new vector.
  ##
  ## **Note**: If a component is negative, the result will be zero rather than undefined.
  result.sqrt(v)

proc lenSq*(v: SomeVec): float32 {.inline.} =
  ## Calculate the squared magnitude of vector `v`.
  ##
  ## **Note**: This can sometimes be used instead of the more expensive square root version (`len`),
  ## for example when comparing relative distances.
  for c in v: result += c^2

proc len*(v: SomeVec): float32 {.inline.} =
  ## Calculate the magnitude of vector `v`.
  ##
  ## **Note**: This is more expensive than the squared version (`lenSq`) as it involves a square
  ## root calculation. In some cases, the less expensive `lenSq` method can be used instead, for
  ## example when comparing relative distances.
  v.lenSq.sqrt

proc distSq*(a, b: SomeVec): float32 {.inline.} =
  ## Calculate the squared distance between vectors `a` and `b`.
  lenSq(b-a)

proc dist*(a, b: SomeVec): float32 {.inline.} =
  ## Calculate the distance between vectors `a` and `b`.
  distSq(a, b).sqrt

proc normalize*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Calculate the unit vector in the same direction as vector `v`, storing the result in the output
  ## vector `o`.
  let len = v.len
  if len != 0:
    result = o.`*`(v, 1/len)
  else:
    result = o.zero

proc normalize*[T: SomeVec](v: T): T {.inline.} =
  ## Calculate the unit vector in the same direction as vector `v`, storing the result in a new
  ## vector.
  result.normalize(v)

proc round*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Round each component of vector `v` to the nearest integer, storing the result in the output
  ## vector `o`.
  for i, _ in o: o[i] = v[i].round
  result = o

proc round*[T: SomeVec](v: T): T {.inline.} =
  ## Round each component of vector `v` to the nearest integer, storing the result in a new vector.
  result.round(v)

proc floor*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Maps each component of vector `v` to the greatest integer that is less than or equal to itself,
  ## storing the result in the output vector `o`.
  for i, _ in o: o[i] = v[i].floor
  result = o

proc floor*[T: SomeVec](v: T): T {.inline.} =
  ## Maps each component of vector `v` to the greatest integer that is less than or equal to itself,
  ## storing the result in a new vector.
  result.floor(v)

proc ceil*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Maps each component of vector `v` to the least integer that is greater than or equal to itself,
  ## storing the result in the output vector `o`.
  for i, _ in o: o[i] = v[i].ceil
  result = o

proc ceil*[T: SomeVec](v: T): T {.inline.} =
  ## Maps each component of vector `v` to the least integer that is greater than or equal to itself,
  ## storing the result in a new vector.
  result.ceil(v)

proc abs*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Calculate the absolute value of each component of vector `v`, storing the result in the output
  ## vector `o`.
  for i, _ in o: o[i] = v[i].abs
  result = o

proc abs*[T: SomeVec](v: T): T {.inline.} =
  ## Calculate the absolute value of each component of vector `v`, storing the result in a new
  ## vector.
  result.abs(v)

proc min*[T: SomeVec](o: var T, a, b: T): var T {.inline.} =
  ## Retrieve the lesser of each component for vectors `a` and `b`, storing the result in the
  ## output vector `o`.
  for i, _ in o: o[i] = min(a[i], b[i])
  result = o

proc min*[T: SomeVec](a, b: T): T {.inline.} =
  ## Retrieve the lesser of each component for vectors `a` and `b`, storing the result in a new
  ## vector.
  result.min(a, b)

proc max*[T: SomeVec](o: var T, a, b: T): var T {.inline.} =
  ## Retrieve the greater of each component for vectors `a` and `b`, storing the result in the
  ## output vector `o`.
  for i, _ in o: o[i] = max(a[i], b[i])
  result = o

proc max*[T: SomeVec](a, b: T): T {.inline.} =
  ## Retrieve the greater of each component for vectors `a` and `b`, storing the result in a new
  ## vector.
  result.max(a, b)

proc `mod`*[T: SomeVec](o: var T, v: T, divisor: float32): var T {.inline.} =
  ## Compute the modulus of each component of vector `v` by `divisor`, storing the result in the
  ## output vector `o`.
  for i, _ in o: o[i] = floorMod(v[i], divisor)
  result = o

proc `mod`*[T: SomeVec](v: T, divisor: float32): T {.inline.} =
  ## Compute the modulus of each component of vector `v` by `divisor`, storing the result in a new
  ## vector.
  result.mod(v, divisor)

proc sin*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Compute the sine of each component of vector `v`, storing the result in the output vector `o`.
  for i, _ in o: o[i] = v[i].sin
  result = o

proc sin*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the sine of each component of vector `v`, storing the result in a new vector.
  result.sin(v)

proc cos*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Compute the cosine of each component of vector `v`, storing the result in the output vector
  ## `o`.
  for i, _ in o: o[i] = v[i].cos
  result = o

proc cos*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the cosine of each component of vector `v`, storing the result in a new vector.
  result.cos(v)

proc tan*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Compute the tangent of each component of vector `v`, storing the result in the output vector
  ## `o`.
  for i, _ in o: o[i] = v[i].tan
  result = o

proc tan*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the tangent of each component of vector `v`, storing the result in a new vector.
  result.tan(v)

proc asin*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Compute the arcsine of each component of vector `v`, storing the result in the output vector
  ## `o`.
  for i, _ in o: o[i] = v[i].arcsin
  result = o

proc asin*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the arcsine of each component of vector `v`, storing the result in a new vector.
  result.asin(v)

proc acos*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Compute the arccosine of each component of vector `v`, storing the result in the output vector
  ## `o`.
  for i, _ in o: o[i] = v[i].arccos
  result = o

proc acos*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the arccosine of each component of vector `v`, storing the result in a new vector.
  result.acos(v)

proc atan*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Compute the arctangent of each component of vector `v`, storing the result in the output vector
  ## `o`.
  for i, _ in o: o[i] = v[i].arctan
  result = o

proc atan*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the arctangent of each component of vector `v`, storing the result in a new vector.
  result.atan(v)

proc radians*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Convert each component of vector `v` from degrees to radians, storing the result in the output
  ## vector `o`.
  const degree = Pi/180
  for i, _ in o: o[i] = v[i] * degree
  result = o

proc radians*[T: SomeVec](v: T): T {.inline.} =
  ## Convert each component of vector `v` from degrees to radians, storing the result in a new
  ## vector.
  result.radians(v)

proc degrees*[T: SomeVec](o: var T, v: T): var T {.inline.} =
  ## Convert each component of vector `v` from radians to degrees, storing the result in the output
  ## vector `o`.
  const radian = 180/Pi
  for i, _ in o: o[i] = v[i] * radian
  result = o

proc degrees*[T: SomeVec](v: T): T {.inline.} =
  ## Convert each component of vector `v` from radians to degrees, storing the result in a new
  ## vector.
  result.degrees(v)

proc lerp*[T: SomeVec](o: var T, a, b: T, factor: float32): var T {.inline.} =
  ## Linearly interpolate between the values of each component in vectors `a` and `b` by `factor`,
  ## storing the result in the output vector `o`.
  for i, _ in o: o[i] = lerp(a[i], b[i], factor)
  result = o

proc lerp*[T: SomeVec](a, b: T, factor: float32): T {.inline.} =
  ## Linearly interpolate between the values of each component in vectors `a` and `b` by `factor`,
  ## storing the result in a new vector.
  result.lerp(a, b, factor)

# 2D and 3D vector operations

proc angle*(a, b: Vec2 or Vec3): float32 {.inline.} =
  ## Compute the angle in radians between vectors `a` and `b`.
  let m = a.len * b.len
  if m == 0: 0f else: arccos(dot(a, b) / m)

proc sameDirection*(a, b: Vec2 or Vec3, tolerance = 1e-5): bool {.inline.} =
  ## Check whether vectors `a` and `b` are the same direction within `tolerance`.
  dot(a.normalize, b.normalize) >= 1 - 1e-5

# 3D vector operations

proc cross*[T: Vec3](o: var T, a, b: T): var T {.inline.} =
  ## Calculate the cross product of 3D vectors `a` and `b`, storing the result in the output vector
  ## `o`.
  o.x = (a.y * b.z) - (a.z * b.y)
  o.y = (a.z * b.x) - (a.x * b.z)
  o.z = (a.x * b.y) - (a.y * b.x)
  result = o

proc cross*(a, b: Vec3): Vec3 {.inline.} =
  ## Calculate the cross product of 3D vectors `a` and `b`, storing the result in a new vector.
  result.cross(a, b)

proc box*(a, b, c: Vec3): float32 {.inline.} =
  ## Calculate the box product of 3D vectors `a`, `b`, and `c`.
  dot(cross(a, b), c)

proc isParallel*(a, b: Vec3): bool {.inline.} =
  ## Check whether the 3D vectors `a` and `b` are parallel to each other.
  cross(a, b) ~= vec3_zero
