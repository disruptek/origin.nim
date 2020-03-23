import fenv
import macros
import math
import random

randomize()

# Types

type
  Vec*[N: static[int]] = array[N, float32]
  Mat*[N: static[int]] = array[N*N, float32]
  SomeVec* = Vec2 or Vec3 or Vec4
  SomeMat* = Mat2 or Mat3 or Mat4
  SomeType* = SomeVec or SomeMat
  Vec2* = Vec[2]
  Vec3* = Vec[3]
  Vec4* = Vec[4]
  Mat2* = Mat[2]
  Mat3* = Mat[3]
  Mat4* = Mat[4]

type Axis2d* {.pure.} = enum
  X, Y

type Axis3d* {.pure.} = enum
  X, Y, Z

type Space* {.pure.} = enum
  local, world

type MatrixInvertError* = object of Exception

# Constants

const radian* = 180/PI
const degree* = PI/180

# Utilities

macro genComponentWiseBool*[N: static[int]](op; v1, v2: Vec[N]; args: varargs[untyped]): bool =
  for i in countdown(N-1, 0):
    var check = nnkCall.newTree(
      op,
      nnkBracketExpr.newTree(v1, newLit(i)),
      nnkBracketExpr.newTree(v2, newLit(i)))
    for arg in args:
      check.add arg
    if result.kind == nnkEmpty:
      result = check
    else:
      result = nnkInfix.newTree(ident("and"), check, result)

proc `~=`*(x, y: float32; tolerance = 1e-5): bool =
  if x == y:
    return true
  let
    ax = abs(x)
    ay = abs(y)
    diff = abs(x-y)
    cmb = ax+ay
    min = float32.minimumPositiveValue
    max = float32.maximumPositiveValue
  if x == 0 or y == 0 or (cmb < min):
    return diff < (tolerance * min)
  result = diff / min(cmb, max) < tolerance

proc lerp*(a, b, v: float32): float32 =
  a * (1 - v) + b * v

# Common operations

proc zero*(o: var SomeType) {.inline.} =
  ## Set all components of the vector, matrix, or quaternion `o` to zero.
  o.fill(0)

proc rand*(o: var SomeType; range = 0f..1f) {.inline.} =
  ## Randomize the components of the vector, matrix, or quaternion `o` within
  ## the range `range`, storing the result back into `o`.
  for i, _ in o: o[i] = rand(range)

proc rand*[T: SomeType](t: typedesc[T]; range = 0f..1f): T {.inline.} =
  ## Initialize a new vector, matrix, or quaternion with its components
  ## randomized within the range `range`.
  result.rand(range)

proc `~=`*(a1, a2: SomeType; tolerance = 1e-5): bool {.inline.} =
  ## Check if the vectors, matrices, or quaternions `a1` and `a2` are approximately equal.
  genComponentWiseBool(`~=`, a1, a2, tolerance)

proc clamp*[T: SomeType](o: var T; a: T; range = -Inf..Inf) {.inline.} =
  ## Constrain each component of the vector, matrix, or quaternion `a` to lie within `range`,
  ## storing the result in the output `o`.
  for i, _ in o: o[i] = a[i].clamp(range.a, range.b)

proc clamp*[T: SomeType](a: T; range = -Inf..Inf): T {.inline.} =
  ## Constrain each component of the vector, matrix, or quaternion `a` to lie within `range`,
  ## storing the result in a new object.
  result.clamp(a, range)

proc `+`*[T: SomeType](a1, a2: T): T {.inline.} =
  ## Component-wise addition of the vectors, matrices, or quaternions `a1` and `a2`, storing the
  ## result in a new object.
  for i, _ in a1: result[i] = a1[i] + a2[i]

proc `+=`*[T: SomeType](o: var T; a: T) {.inline.} =
  ## Component-wise addition of the vectors, matrices, or quaternions `a1` and `a2`, storing the
  ## result in the output object `o`.
  for i, _ in o: o[i] += a[i]

proc `-`*[T: SomeType](a1, a2: T): T {.inline.} =
  ## Component-wise subtraction of the vectors, matrices, or quaternions `a1` from `a2`, storing the
  ## result in a new object.
  for i, _ in a1: result[i] = a1[i] - a2[i]

proc `-=`*[T: SomeType](o: var T; a: T) {.inline.} =
  ## Component-wise subtraction of the vectors, matrices, or quaternions `a1` from `a2`, storing the
  ## result in the output object `o`.
  for i, _ in a: o[i] -= a[i]

proc `-`*[T: SomeType](a: T): T {.inline.} =
  ## Unary subtraction (negation) of the components of the vectors, matrices, or quaternions `a1`
  ## from `a2`, storing the result in a new object.
  for i, _ in a: result[i] = -a[i]
