import std/algorithm
import std/math
import std/random

import internal
import vec

type
  Mat*[N: static[int]] = object
    data*: Storage[N]
  Mat2* = Mat[4]
  Mat3* = Mat[9]
  Mat4* = Mat[16]
  MatrixInvertError* = object of ValueError

Mat2.genAccessors m00, m10, m01, m11
Mat3.genAccessors m00, m10, m20, m01, m11, m21, m02, m12, m22
Mat4.genAccessors m00, m10, m20, m30, m01, m11, m21, m31, m02, m12, m22, m32, m03, m13, m23, m33

proc `$`*(m: Mat): string =
  # NOTE: This assumes that a matrix is square. If we ever support non-square matrices, the R and C
  # constants need to be fixed.
  const R = sqrt(m.N.float).int
  const C = R
  result = "["
  for col in 0..C-1:
    var i = 0
    for row in countup(0, (C*R)-1, R):
      result &= m[row+col].fmt
      i.inc
      if i < R: result &= ", "
    if col < R-1: result &= "\n "
  result &= "]"

# Constructors

proc mat2*(): Mat2 {.inline.} = result.data.fill(0)
proc mat2*(n: float32): Mat2 {.inline.} =
  result.m00 = n
  result.m11 = n
proc mat2*(m: Mat): Mat2 {.inline.} =
  result.m00 = m.m00
  result.m10 = m.m10
  result.m01 = m.m01
  result.m11 = m.m11
proc mat2*(a, b: Vec2): Mat2 {.inline.} =
  result.m00 = a.x
  result.m10 = a.y
  result.m01 = b.x
  result.m11 = b.y
proc mat2*(a, b, c, d: float32): Mat2 {.inline.} = result.data = [a, b, c, d]
proc mat3*(): Mat3 {.inline.} = result.data.fill(0)
proc mat3*(n: float32): Mat3 {.inline.} =
  result.m00 = n
  result.m11 = n
  result.m22 = n
proc mat3*(m: Mat2): Mat3 {.inline.} =
  result.m00 = m.m00
  result.m10 = m.m10
  result.m01 = m.m01
  result.m11 = m.m11
  result.m22 = 1
proc mat3*(m: Mat3 or Mat4): Mat3 {.inline.} =
  result.m00 = m.m00
  result.m10 = m.m10
  result.m20 = m.m20
  result.m01 = m.m01
  result.m11 = m.m11
  result.m21 = m.m21
  result.m02 = m.m02
  result.m12 = m.m12
  result.m22 = m.m22
proc mat3*(a, b, c: Vec3): Mat3 {.inline.} =
  result.m00 = a.x
  result.m10 = a.y
  result.m20 = a.z
  result.m01 = b.x
  result.m11 = b.y
  result.m21 = b.z
  result.m02 = c.x
  result.m12 = c.y
  result.m22 = c.z
proc mat3*(a, b, c, d, e, f, g, h, i: float32): Mat3 {.inline.} =
  result.data = [a, b, c, d, e, f, g, h, i]
proc mat4*(): Mat4 {.inline.} = result.data.fill(0)
proc mat4*(n: float32): Mat4 {.inline.} =
  result.m00 = n
  result.m11 = n
  result.m22 = n
  result.m33 = n
proc mat4*(m: Mat4): Mat4 {.inline.} = m
proc mat4*(m: Mat2): Mat4 {.inline.} =
  result.m00 = m.m00
  result.m10 = m.m10
  result.m01 = m.m01
  result.m11 = m.m11
  result.m22 = 1
  result.m33 = 1
proc mat4*(m: Mat3): Mat4 {.inline.} =
  result.m00 = m.m00
  result.m10 = m.m10
  result.m20 = m.m20
  result.m01 = m.m01
  result.m11 = m.m11
  result.m21 = m.m21
  result.m02 = m.m02
  result.m12 = m.m12
  result.m22 = m.m22
  result.m33 = 1
proc mat4*(a, b, c, d: Vec4): Mat4 {.inline.} =
  result.m00 = a.x
  result.m10 = a.y
  result.m20 = a.z
  result.m30 = a.w
  result.m01 = b.x
  result.m11 = b.y
  result.m21 = b.z
  result.m31 = b.w
  result.m02 = c.x
  result.m12 = c.y
  result.m22 = c.z
  result.m32 = c.w
  result.m03 = d.x
  result.m13 = d.y
  result.m23 = d.z
  result.m33 = d.w
proc mat4*(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p: float32): Mat4 {.inline.} =
  result.data = [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p]

## Constants

const mat2_zero* = mat2()
const mat2_id* = mat2(1)
const mat3_zero* = mat3()
const mat3_id* = mat3(1)
const mat4_zero* = mat4()
const mat4_id* = mat4(1)

## Common operations

proc rand*[T: Mat](o: var T, range = 0f..1f): var T {.inline.} =
  for i, _ in o: o[i] = rand(range)
  result = o
proc rand*[T: Mat](t: typedesc[T], range = 0f..1f): T {.inline.} = result.rand(range)

proc zero*[T: Mat](o: var T): var T {.inline.} =
  o.data.fill(0)
  result = o

proc `~=`*(a, b: Mat, tolerance = 1e-5): bool {.inline.} =
  genComponentWiseBool(`~=`, a.data, b.data, tolerance)

proc clamp*[T: Mat](o: var T, m: T, range = -Inf.float32 .. Inf.float32): var T {.inline.} =
  for i, _ in o: o[i] = m[i].clamp(range.a, range.b)
  result = o
proc clamp*[T: Mat](m: T, range = -Inf.float32 .. Inf.float32): T {.inline.} =
  result.clamp(m, range)

proc `+`*[T: Mat](o: var T, a, b: T): var T {.inline.} =
  for i, _ in o: o[i] = a[i] + b[i]
  result = o
proc `+`*[T: Mat](a, b: T): T {.inline.} = result.`+`(a, b)

proc `-`*[T: Mat](o: var T, a, b: T): var T {.inline.} =
  for i, _ in o: o[i] = a[i] - b[i]
  result = o
proc `-`*[T: Mat](a, b: T): T {.inline.} = result.`-`(a, b)

proc `-`*[T: Mat](o: var T): var T {.inline.} =
  for i, _ in o: o[i] = -o[i]
  result = o
proc `-`*[T: Mat](m: T): T {.inline.} =
  result = m
  discard -result

proc `*`*[T: Mat](a, b: T): T {.inline.} = result.`*`(a, b)

# 2x2 matrix operations

proc setId*[T: Mat2](o: var T): var T {.inline.} =
  o.data.fill(0)
  o.m00 = 1
  o.m11 = 1
  result = o

proc `*`*[T: Mat2](o: var T, a, b: Mat2): var T {.inline.} =
  let
    a = a
    b = b
  o.m00 = a.m00 * b.m00 + a.m01 * b.m10
  o.m10 = a.m10 * b.m00 + a.m11 * b.m10
  o.m01 = a.m00 * b.m01 + a.m01 * b.m11
  o.m11 = a.m10 * b.m01 + a.m11 * b.m11
  result = o

proc column*[T: Vec2](o: var T, m: Mat2, index: range[0..1]): var T {.inline.} =
  case index
  of 0: o[0..1] = m[0..1]
  of 1: o[0..1] = m[2..3]
  result = o
proc column*(m: Mat2, index: range[0..1]): Vec2 {.inline.} = result.column(m, index)

proc `column=`*[T: Mat2](o: var T, m: T, v: Vec2, index: range[0..1]): var T {.inline.} =
  o = m
  case index
  of 0: o[0..1] = v[0..1]
  of 1: o[2..3] = v[0..1]
  result = o
proc `column=`*(m: Mat2, v: Vec2, index: range[0..1]): Mat2 {.inline.} =
  result.`column=`(m, v, index)

proc rotation*[T: Vec2](o: var T, m: Mat2, axis: Axis2d): var T {.inline.} =
  case axis
  of Axis2d.X: o[0..1] = m[0..1]
  of Axis2d.Y: o[0..1] = m[2..3]
  result = o
proc rotation*(m: Mat2, axis: Axis2d): Vec2 {.inline.} = result.rotation(m, axis)

proc `rotation=`*[T: Mat2](o: var T, v: Vec2, axis: Axis2d): var T {.inline.} =
  case axis
  of Axis2d.X: o[0..1] = v[0..1]
  of Axis2d.Y: o[2..3] = v[0..1]
  result = o
proc `rotation=`*[T: Mat2](m: T, v: Vec2, axis: Axis2d): T {.inline.} =
  result = m
  discard result.`rotation=`(v, axis)

proc rotate*[T: Mat2](o: var T, m: T, angle: float32, space: Space = Space.local): var T {.inline.} =
  let
    s = angle.sin
    c = angle.cos
    t = mat2(c, s, -s, c)
  case space:
    of Space.local: o = m * t
    of Space.world: o = t * m
  result = o
proc rotate*(m: Mat2, angle: float32, space: Space = Space.local): Mat2 {.inline.} =
  result.rotate(m, angle, space)

proc transpose*[T: Mat2](o: var T, m: T): var T {.inline.} =
  o = m
  swap(o.m10, o.m01)
  result = o
proc transpose*(m: Mat2): Mat2 {.inline.} = result.transpose(m)

proc isOrthogonal*(m: Mat2): bool {.inline.} =
  m * m.transpose ~= mat2_id

proc trace*(m: Mat2): float32 {.inline.} = m.m00 + m.m11

proc isDiagonal*(m: Mat2): bool {.inline.} = m.m10 == 0 and m.m01 == 0 and m.m00 == m.m11

proc mainDiagonal*[T: Vec2](o: var T, m: Mat2): var T {.inline.} =
  o.x = m.m00
  o.y = m.m11
  result = o
proc mainDiagonal*(m: Mat2): Vec2 {.inline.} = result.mainDiagonal(m)

proc antiDiagonal*[T: Vec2](o: var T, m: Mat2): var T {.inline.} =
  o.x = m.m01
  o.y = m.m10
  result = o
proc antiDiagonal*(m: Mat2): Vec2 {.inline.} = result.antiDiagonal(m)

# 3x3 matrix operations

proc setId*[T: Mat3](o: var T): var T {.inline.} =
  o.data.fill(0)
  o.m00 = 1
  o.m11 = 1
  o.m22 = 1
  result = o

proc `*`*[T: Mat3](o: var T, a, b: T): var T {.inline.} =
  let
    a = a
    b = b
  o.m00 = a.m00 * b.m00 + a.m01 * b.m10 + a.m02 * b.m20
  o.m10 = a.m10 * b.m00 + a.m11 * b.m10 + a.m12 * b.m20
  o.m20 = a.m20 * b.m00 + a.m21 * b.m10 + a.m22 * b.m20
  o.m01 = a.m00 * b.m01 + a.m01 * b.m11 + a.m02 * b.m21
  o.m11 = a.m10 * b.m01 + a.m11 * b.m11 + a.m12 * b.m21
  o.m21 = a.m20 * b.m01 + a.m21 * b.m11 + a.m22 * b.m21
  o.m02 = a.m00 * b.m02 + a.m01 * b.m12 + a.m02 * b.m22
  o.m12 = a.m10 * b.m02 + a.m11 * b.m12 + a.m12 * b.m22
  o.m22 = a.m20 * b.m02 + a.m21 * b.m12 + a.m22 * b.m22
  result = o

proc `*`*[T: Vec3](o: var T, m: Mat3, v: T): var T {.inline.} =
  o.x = m.m00 * v.x + m.m01 * v.y + m.m02 * v.z
  o.y = m.m10 * v.x + m.m11 * v.y + m.m12 * v.z
  o.z = m.m20 * v.x + m.m21 * v.y + m.m22 * v.z
  result = o
proc `*`*(m: Mat3, v: Vec3): Vec3 {.inline.} = result.`*`(m, v)

proc column*[T: Vec3](o: var T, m: Mat3, index: range[0..2]): var T {.inline.} =
  case index
  of 0: o[0..2] = m[0..2]
  of 1: o[0..2] = m[3..5]
  of 2: o[0..2] = m[6..8]
  result = o
proc column*(m: Mat3, index: range[0..2]): Vec3 {.inline.} = result.column(m, index)

proc `column=`*[T: Mat3](o: var T, m: T, v: Vec3, index: range[0..2]): var T {.inline.} =
  o = m
  case index
  of 0: o[0..2] = v[0..2]
  of 1: o[3..5] = v[0..2]
  of 2: o[6..8] = v[0..2]
  result = o
proc `column=`*(m: Mat3, v: Vec3, index: range[0..2]): Mat3 {.inline.} =
  result.`column=`(m, v, index)

proc copyRotation*[T: Mat3](o: var T, m: T): var T {.inline.} =
  o.m00 = m.m00
  o.m10 = m.m10
  o.m01 = m.m01
  o.m11 = m.m11
  result = o
proc copyRotation*(m: Mat3): Mat3 {.inline.} =
  discard result.copyRotation(m)
  result.m22 = 1

proc rotation*[T: Mat2](o: var T, m: Mat3): var T {.inline.} =
  o.m00 = m.m00
  o.m10 = m.m10
  o.m01 = m.m01
  o.m11 = m.m11
  result = o
proc rotation*(m: Mat3): Mat2 {.inline.} = result.rotation(m)

proc rotation*[T: Vec2](o: var T, m: Mat3, axis: Axis2d): var T {.inline.} =
  case axis
  of Axis2d.X: o[0..1] = m[0..1]
  of Axis2d.Y: o[0..1] = m[3..4]
  result = o
proc rotation*(m: Mat3, axis: Axis2d): Vec2 {.inline.} = result.rotation(m, axis)

proc `rotation=`*[T: Mat3](o: var T, m: Mat2): var T {.inline.} =
  o.m00 = m.m00
  o.m10 = m.m10
  o.m01 = m.m01
  o.m11 = m.m11
  result = o
proc `rotation=`*(m: Mat2): Mat3 {.inline.} = result.rotation = m

proc `rotation=`*[T: Mat3](o: var T, v: Vec2, axis: Axis2d): var T {.inline.} =
  case axis
  of Axis2d.X: o[0..1] = v[0..1]
  of Axis2d.Y: o[3..4] = v[0..1]
  result = o
proc `rotation=`*[T: Mat3](m: T, v: Vec2, axis: Axis2d): T {.inline.} =
  result = m
  discard result.`rotation=`(v, axis)

proc rotate*[T: Mat3](o: var T, m: T, angle: float32, space: Space = Space.local): var T =
  let
    s = angle.sin
    c = angle.cos
    t = mat2(c, s, -s, c)
  var outMat2 = o.rotation
  case space:
    of Space.local: outMat2 = outMat2 * t
    of Space.world: outMat2 = t * outMat2
  o = m
  o.`rotation=`(outMat2)
proc rotate*(m: Mat3, angle: float32, space: Space = Space.local): Mat3 {.inline.} =
  result = m
  discard result.rotate(m, angle, space)

proc normalizeRotation*[T: Mat3](o: var T, m: T): var T {.inline.} =
  var
    x = vec2(m.m00, m.m10).normalize
    y = vec2(m.m01, m.m11).normalize
  o.m00 = x.x
  o.m10 = x.y
  o.m01 = y.x
  o.m11 = y.y
  result = o
proc normalizeRotation*(m: Mat3): Mat3 {.inline.} =
  result = m
  discard result.normalizeRotation(m)

proc translation*[T: Vec2](o: var T, m: Mat3): var T {.inline.} =
  o.x = m.m02
  o.y = m.m12
  result = o
proc translation*(m: Mat3): Vec2 {.inline.} = result.translation(m)

proc `translation=`*[T: Mat3](o: var T, m: T, v: Vec2): var T {.inline.} =
  discard o.copyRotation(m)
  o.m02 = v.x
  o.m12 = v.y
  o.m22 = m.m22
  result = o
proc `translation=`*(m: Mat3, v: Vec2): Mat3 {.inline.} = result.`translation=`(m, v)

proc translate*[T: Mat3](o: var T, m: T, v: Vec2): var T {.inline.} =
  o.m00 = m.m00 + m.m20 * v.x
  o.m10 = m.m10 + m.m20 * v.y
  o.m20 = m.m20
  o.m01 = m.m01 + m.m21 * v.x
  o.m11 = m.m11 + m.m21 * v.y
  o.m21 = m.m21
  o.m02 = m.m02 + m.m22 * v.x
  o.m12 = m.m12 + m.m22 * v.y
  o.m22 = m.m22
  result = o
proc translate*(m: Mat3, v: Vec2): Mat3 {.inline.} = result.translate(m, v)

proc scale*[T: Vec2](o: var T, m: Mat3): var T {.inline.} =
  o.x = m.rotation(Axis2d.X).len
  o.y = m.rotation(Axis2d.Y).len
  result = o
proc scale*(m: Mat3): Vec2 {.inline.} = result.scale(m)

proc `scale=`*[T: Mat3](o: var T, m: T, v: Vec2): var T {.inline.} =
  o = m
  o.m00 = v.x
  o.m11 = v.y
  result = o
proc `scale=`*(m: Mat3, v: Vec2): Mat3 {.inline.} = result.`scale=`(m, v)

proc scale*[T: Mat3](o: var T, m: T, v: Vec2): var T {.inline.} =
  o.m00 = m.m00 * v.x
  o.m10 = m.m10 * v.y
  o.m20 = m.m20
  o.m01 = m.m01 * v.x
  o.m11 = m.m11 * v.y
  o.m21 = m.m21
  o.m02 = m.m02 * v.x
  o.m12 = m.m12 * v.y
  o.m22 = m.m22
  result = o
proc scale*(m: Mat3, v: Vec2): Mat3 {.inline.} = result.scale(m, v)

proc transpose*[T: Mat3](o: var T, m: T): var T {.inline.} =
  o = m
  swap(o.m10, o.m01)
  swap(o.m20, o.m02)
  swap(o.m21, o.m12)
  result = o
proc transpose*(m: Mat3): Mat3 {.inline.} = result.transpose(m)

proc isOrthogonal*(m: Mat3): bool {.inline.} = m * m.transpose ~= mat3_id

proc trace*(m: Mat3): float32 {.inline.} = m.m00 + m.m11 + m.m22

proc isDiagonal*(m: Mat3): bool {.inline.} =
  m.m10 == 0 and m.m20 == 0 and m.m01 == 0 and
  m.m21 == 0 and m.m02 == 0 and m.m12 == 0 and
  m.m00 == m.m11 and m.m11 == m.m22

proc mainDiagonal*[T: Vec3](o: var T, m: Mat3): var T {.inline.} =
  o.x = m.m00
  o.y = m.m11
  o.z = m.m22
  result = o
proc mainDiagonal*(m: Mat3): Vec3 {.inline.} = result.mainDiagonal(m)

proc antiDiagonal*[T: Vec3](o: var T, m: Mat3): var T {.inline.} =
  o.x = m.m02
  o.y = m.m11
  o.z = m.m20
  result = o
proc antiDiagonal*(m: Mat3): Vec3 {.inline.} = result.antiDiagonal(m)

# 4x4 matrix operations

proc setId*[T: Mat4](o: var T): var T {.inline.} =
  o.data.fill(0)
  o.m00 = 1
  o.m11 = 1
  o.m22 = 1
  o.m33 = 1
  result = o

proc `*`*[T: Mat4](o: var T, a, b: T): var T {.inline.} =
  let
    a = a
    b = b
  o.m00 = a.m00 * b.m00 + a.m01 * b.m10 + a.m02 * b.m20 + a.m03 * b.m30
  o.m10 = a.m10 * b.m00 + a.m11 * b.m10 + a.m12 * b.m20 + a.m13 * b.m30
  o.m20 = a.m20 * b.m00 + a.m21 * b.m10 + a.m22 * b.m20 + a.m23 * b.m30
  o.m30 = a.m30 * b.m00 + a.m31 * b.m10 + a.m32 * b.m20 + a.m33 * b.m30
  o.m01 = a.m00 * b.m01 + a.m01 * b.m11 + a.m02 * b.m21 + a.m03 * b.m31
  o.m11 = a.m10 * b.m01 + a.m11 * b.m11 + a.m12 * b.m21 + a.m13 * b.m31
  o.m21 = a.m20 * b.m01 + a.m21 * b.m11 + a.m22 * b.m21 + a.m23 * b.m31
  o.m31 = a.m30 * b.m01 + a.m31 * b.m11 + a.m32 * b.m21 + a.m33 * b.m31
  o.m02 = a.m00 * b.m02 + a.m01 * b.m12 + a.m02 * b.m22 + a.m03 * b.m32
  o.m12 = a.m10 * b.m02 + a.m11 * b.m12 + a.m12 * b.m22 + a.m13 * b.m32
  o.m22 = a.m20 * b.m02 + a.m21 * b.m12 + a.m22 * b.m22 + a.m23 * b.m32
  o.m32 = a.m30 * b.m02 + a.m31 * b.m12 + a.m32 * b.m22 + a.m33 * b.m32
  o.m03 = a.m00 * b.m03 + a.m01 * b.m13 + a.m02 * b.m23 + a.m03 * b.m33
  o.m13 = a.m10 * b.m03 + a.m11 * b.m13 + a.m12 * b.m23 + a.m13 * b.m33
  o.m23 = a.m20 * b.m03 + a.m21 * b.m13 + a.m22 * b.m23 + a.m23 * b.m33
  o.m33 = a.m30 * b.m03 + a.m31 * b.m13 + a.m32 * b.m23 + a.m33 * b.m33
  result = o

proc `*`*[T: Vec4](o: var T, m: Mat4, v: T): var T {.inline.} =
  o.x = m.m00 * v.x + m.m01 * v.y + m.m02 * v.z + m.m03 * v.w
  o.y = m.m10 * v.x + m.m11 * v.y + m.m12 * v.z + m.m13 * v.w
  o.z = m.m20 * v.x + m.m21 * v.y + m.m22 * v.z + m.m23 * v.w
  o.w = m.m30 * v.x + m.m31 * v.y + m.m32 * v.z + m.m33 * v.w
  result = o
proc `*`*(m: Mat4, v: Vec4): Vec4 {.inline.} = result.`*`(m, v)

proc column*[T: Vec4](o: var T, m: Mat4, index: range[0..3]): var T {.inline.} =
  case index
  of 0: o[0..3] = m[0..3]
  of 1: o[0..3] = m[4..7]
  of 2: o[0..3] = m[8..11]
  of 3: o[0..3] = m[12..15]
  result = o
proc column*(m: Mat4, index: range[0..3]): Vec4 {.inline.} = result.column(m, index)

proc `column=`*[T: Mat4](o: var T, m: T, v: Vec4, index: range[0..3]): var T {.inline.} =
  o = m
  case index
  of 0: o[0..3] = v[0..3]
  of 1: o[4..7] = v[0..3]
  of 2: o[8..11] = v[0..3]
  of 3: o[12..15] = v[0..3]
  result = o
proc `column=`*(m: Mat4, v: Vec4, index: range[0..3]): Mat4 {.inline.} =
  result.`column=`(m, v, index)

proc copyRotation*[T: Mat4](o: var T, m: T): var T {.inline.} =
  o.m00 = m.m00
  o.m10 = m.m10
  o.m20 = m.m20
  o.m01 = m.m01
  o.m11 = m.m11
  o.m21 = m.m21
  o.m02 = m.m02
  o.m12 = m.m12
  o.m22 = m.m22
  result = o
proc copyRotation*(m: Mat4): Mat4 {.inline.} =
  discard result.copyRotation(m)
  result.m33 = 1

proc rotation*[T: Mat3](o: var T, m: Mat4): var T {.inline.} =
  o.m00 = m.m00
  o.m10 = m.m10
  o.m20 = m.m20
  o.m01 = m.m01
  o.m11 = m.m11
  o.m21 = m.m21
  o.m02 = m.m02
  o.m12 = m.m12
  o.m22 = m.m22
  result = o
proc rotation*(m: Mat4): Mat3 {.inline.} = result.rotation(m)

proc rotation*[T: Vec3](o: var T, m: Mat4, axis: Axis3d): var T {.inline.} =
  case axis
  of Axis3d.X: o[0..2] = m[0..2]
  of Axis3d.Y: o[0..2] = m[4..6]
  of Axis3d.Z: o[0..2] = m[8..10]
  result = o
proc rotation*(m: Mat4, axis: Axis3d): Vec3 {.inline.} = result.rotation(m, axis)

proc `rotation=`*[T: Mat4](o: var T, m: (Mat3 or Mat4)): var T {.inline.} =
  o.m00 = m.m00
  o.m10 = m.m10
  o.m20 = m.m20
  o.m01 = m.m01
  o.m11 = m.m11
  o.m21 = m.m21
  o.m02 = m.m02
  o.m12 = m.m12
  o.m22 = m.m22
  result = o
proc `rotation=`*[T: Mat3](m: T): T {.inline.} = result.rotation = m

proc `rotation=`*[T: Mat4](o: var T, v: Vec3, axis: Axis3d): var T {.inline.} =
  case axis
  of Axis3d.X: o[0..2] = v[0..2]
  of Axis3d.Y: o[4..6] = v[0..2]
  of Axis3d.Z: o[8..10] = v[0..2]
  result = o
proc `rotation=`*[T: Mat4](m: T, v: Vec3, axis: Axis3d): T {.inline.} =
  result = m
  discard result.`rotation=`(v, axis)

proc rotate*[T: Mat4](o: var T, m: T, v: Vec3, space: Space = Space.local): var T =
  proc rotateAxis(o: var Mat3, m: Mat3, space: Space) =
    case space:
      of Space.local: o = o * m
      of Space.world: o = m * o
  var
    t = mat3(1)
    outMat3 = o.rotation
  let
    s = v.sin
    c = v.cos
  o = m
  t.m00 = c.z
  t.m10 = s.z
  t.m01 = -s.z
  t.m11 = c.z
  rotateAxis(outMat3, t, space)
  t.data = [1f, 0, 0, 0, c.x, s.x, 0, -s.x, c.x]
  rotateAxis(outMat3, t, space)
  t.data = [c.y, 0, -s.y, 0, 1, 0, s.y, 0, c.y]
  rotateAxis(outMat3, t, space)
  o.`rotation=`(outMat3)
proc rotate*(m: Mat4, v: Vec3, space: Space = Space.local): Mat4 {.inline.} =
  result = m
  discard result.rotate(m, v, space)

proc normalizeRotation*[T: Mat4](o: var T, m: T): var T {.inline.} =
  var
    x = vec3(m.m00, m.m10, m.m20).normalize
    y = vec3(m.m01, m.m11, m.m21).normalize
    z = vec3(m.m02, m.m12, m.m22).normalize
  o.m00 = x.x
  o.m10 = x.y
  o.m20 = x.z
  o.m01 = y.x
  o.m11 = y.y
  o.m21 = y.z
  o.m02 = z.x
  o.m12 = z.y
  o.m22 = z.z
  result = o
proc normalizeRotation*(m: Mat4): Mat4 {.inline.} =
  result = m
  discard result.normalizeRotation(m)

proc translation*[T: Vec3](o: var T, m: Mat4): var T {.inline.} =
  o.x = m.m03
  o.y = m.m13
  o.z = m.m23
  result = o
proc translation*(m: Mat4): Vec3 {.inline.} = result.translation(m)

proc `translation=`*[T: Mat4](o: var T, m: T, v: Vec3): var T {.inline.} =
  discard o.copyRotation(m)
  o.m03 = v.x
  o.m13 = v.y
  o.m23 = v.z
  o.m33 = m.m33
  result = o
proc `translation=`*(m: Mat4, v: Vec3): Mat4 {.inline.} = result.`translation=`(m, v)

proc translate*[T: Mat4](o: var T, m: T, v: Vec3): var T {.inline.} =
  o.m00 = m.m00 + m.m30 * v.x
  o.m10 = m.m10 + m.m30 * v.y
  o.m20 = m.m20 + m.m30 * v.z
  o.m30 = m.m30
  o.m01 = m.m01 + m.m31 * v.x
  o.m11 = m.m11 + m.m31 * v.y
  o.m21 = m.m21 + m.m31 * v.z
  o.m31 = m.m31
  o.m02 = m.m02 + m.m32 * v.x
  o.m12 = m.m12 + m.m32 * v.y
  o.m22 = m.m22 + m.m32 * v.z
  o.m32 = m.m32
  o.m03 = m.m03 + m.m33 * v.x
  o.m13 = m.m13 + m.m33 * v.y
  o.m23 = m.m23 + m.m33 * v.z
  o.m33 = m.m33
  result = o
proc translate*(m: Mat4, v: Vec3): Mat4 {.inline.} = result.translate(m, v)

proc scale*[T: Vec3](o: var T, m: Mat4): var T {.inline.} =
  o.x = m.rotation(Axis3d.X).len
  o.y = m.rotation(Axis3d.Y).len
  o.z = m.rotation(Axis3d.Z).len
  result = o
proc scale*(m: Mat4): Vec3 {.inline.} = result.scale(m)

proc `scale=`*[T: Mat4](o: var T, m: T, v: Vec3): var T {.inline.} =
  o = m
  o.m00 = v.x
  o.m11 = v.y
  o.m22 = v.z
  result = o
proc `scale=`*(m: Mat4, v: Vec3): Mat4 {.inline.} = result.`scale=`(m, v)

proc scale*[T: Mat4](o: var T, m: T, v: Vec3): var T {.inline.} =
  o.m00 = m.m00 * v.x
  o.m10 = m.m10 * v.y
  o.m20 = m.m20 * v.z
  o.m30 = m.m30
  o.m01 = m.m01 * v.x
  o.m11 = m.m11 * v.y
  o.m21 = m.m21 * v.z
  o.m31 = m.m31
  o.m02 = m.m02 * v.x
  o.m12 = m.m12 * v.y
  o.m22 = m.m22 * v.z
  o.m32 = m.m32
  o.m03 = m.m03 * v.x
  o.m13 = m.m13 * v.y
  o.m23 = m.m23 * v.z
  o.m33 = m.m33
  result = o
proc scale*(m: Mat4, v: Vec3): Mat4 {.inline.} = result.scale(m, v)

proc transpose*[T: Mat4](o: var T, m: T): var T {.inline.} =
  o = m
  swap(o.m10, o.m01)
  swap(o.m20, o.m02)
  swap(o.m30, o.m03)
  swap(o.m21, o.m12)
  swap(o.m31, o.m13)
  swap(o.m32, o.m23)
  result = o
proc transpose*(m: Mat4): Mat4 {.inline.} = result.transpose(m)

proc isOrthogonal*(m: Mat4): bool {.inline.} = m * m.transpose ~= mat4_id

proc orthoNormalize*[T: Mat4](o: var T, m: T): var T =
  var
    x = m.rotation(Axis3d.X).normalize
    y = m.rotation(Axis3d.Y)
    z = m.rotation(Axis3d.Z)
  discard y.normalize(y - x * dot(y, x))
  discard z.cross(x, y)
  discard o.`rotation=`(x, Axis3d.X)
  discard o.`rotation=`(y, Axis3d.Y)
  discard o.`rotation=`(z, Axis3d.Z)
  result = o
proc orthoNormalize*(m: Mat4): Mat4 {.inline.} =
  result = mat4_id
  discard result.orthoNormalize(m)

proc trace*(m: Mat4): float32 {.inline.} = m.m00 + m.m11 + m.m22 + m.m33

proc isDiagonal*(m: Mat4): bool {.inline.} =
  m.m10 == 0 and m.m20 == 0 and m.m30 == 0 and m.m01 == 0 and
  m.m21 == 0 and m.m31 == 0 and m.m02 == 0 and m.m12 == 0 and
  m.m32 == 0 and m.m03 == 0 and m.m13 == 0 and m.m23 == 0 and
  m.m00 == m.m11 and m.m11 == m.m22 and m.m22 == m.m33

proc mainDiagonal*[T: Vec4](o: var T, m: Mat4): var T {.inline.} =
  o.x = m.m00
  o.y = m.m11
  o.z = m.m22
  o.w = m.m33
  result = o
proc mainDiagonal*(m: Mat4): Vec4 {.inline.} = result.mainDiagonal(m)

proc antiDiagonal*[T: Vec4](o: var T, m: Mat4): var T {.inline.} =
  o.x = m.m03
  o.y = m.m12
  o.z = m.m21
  o.w = m.m30
  result = o
proc antiDiagonal*(m: Mat4): Vec4 {.inline.} = result.antiDiagonal(m)

proc determinant*(m: Mat4): float32 =
  m.m00 * m.m11 * m.m22 * m.m33 + m.m00 * m.m12 * m.m23 * m.m31 +
  m.m00 * m.m13 * m.m21 * m.m32 + m.m01 * m.m10 * m.m23 * m.m32 +
  m.m01 * m.m12 * m.m20 * m.m33 + m.m01 * m.m13 * m.m22 * m.m30 +
  m.m02 * m.m10 * m.m21 * m.m33 + m.m02 * m.m11 * m.m23 * m.m30 +
  m.m02 * m.m13 * m.m20 * m.m31 + m.m03 * m.m10 * m.m22 * m.m31 +
  m.m03 * m.m11 * m.m20 * m.m32 + m.m03 * m.m12 * m.m21 * m.m30 -
  m.m00 * m.m11 * m.m23 * m.m32 - m.m00 * m.m12 * m.m21 * m.m33 -
  m.m00 * m.m13 * m.m22 * m.m31 - m.m01 * m.m10 * m.m22 * m.m33 -
  m.m01 * m.m12 * m.m23 * m.m30 - m.m01 * m.m13 * m.m20 * m.m32 -
  m.m02 * m.m10 * m.m23 * m.m31 - m.m02 * m.m11 * m.m20 * m.m33 -
  m.m02 * m.m13 * m.m21 * m.m30 - m.m03 * m.m10 * m.m21 * m.m32 -
  m.m03 * m.m11 * m.m22 * m.m30 - m.m03 * m.m12 * m.m20 * m.m31

proc invertOrthogonal*[T: Mat4](o: var T, m: T): var T {.inline.} =
  o = m
  swap(o.m10, o.m01)
  swap(o.m20, o.m02)
  swap(o.m21, o.m12)
  o.m03 = o.m00 * -o.m03 + o.m01 * -o.m13 + o.m02 * -o.m23
  o.m13 = o.m10 * -o.m03 + o.m11 * -o.m13 + o.m12 * -o.m23
  o.m23 = o.m20 * -o.m03 + o.m21 * -o.m13 + o.m22 * -o.m23
  result = o
proc invertOrthogonal*(m: Mat4): Mat4 {.inline.} = result.invertOrthogonal(m)

proc invert*[T: Mat4](o: var T, m: T): var T =
  let
    det = m.determinant
  if det.abs < 1e-5:
    raise newException(MatrixInvertError, "Matrix cannot be inverted.")
  o.m00 = (m.m11 * m.m22 * m.m33 + m.m12 * m.m23 * m.m31 + m.m13 * m.m21 * m.m02 -
           m.m11 * m.m23 * m.m02 - m.m12 * m.m21 * m.m33 - m.m13 * m.m22 * m.m31) / det
  o.m10 = (m.m10 * m.m23 * m.m02 + m.m12 * m.m20 * m.m33 + m.m13 * m.m22 * m.m30 -
           m.m10 * m.m22 * m.m33 - m.m12 * m.m23 * m.m30 - m.m13 * m.m20 * m.m02) / det
  o.m20 = (m.m10 * m.m21 * m.m33 + m.m11 * m.m23 * m.m30 + m.m13 * m.m20 * m.m31 -
           m.m10 * m.m23 * m.m31 - m.m11 * m.m20 * m.m33 - m.m13 * m.m21 * m.m30) / det
  o.m30 = (m.m10 * m.m22 * m.m31 + m.m11 * m.m20 * m.m02 + m.m12 * m.m21 * m.m30 -
           m.m10 * m.m21 * m.m02 - m.m11 * m.m22 * m.m30 - m.m12 * m.m20 * m.m31) / det
  o.m01 = (m.m01 * m.m23 * m.m02 + m.m02 * m.m21 * m.m33 + m.m03 * m.m22 * m.m31 -
           m.m01 * m.m22 * m.m33 - m.m02 * m.m23 * m.m31 - m.m03 * m.m21 * m.m02) / det
  o.m11 = (m.m00 * m.m22 * m.m33 + m.m02 * m.m23 * m.m30 + m.m03 * m.m20 * m.m02 -
           m.m00 * m.m23 * m.m02 - m.m02 * m.m20 * m.m33 - m.m03 * m.m22 * m.m30) / det
  o.m21 = (m.m00 * m.m23 * m.m31 + m.m01 * m.m20 * m.m33 + m.m03 * m.m21 * m.m30 -
           m.m00 * m.m21 * m.m33 - m.m01 * m.m23 * m.m30 - m.m03 * m.m20 * m.m31) / det
  o.m31 = (m.m00 * m.m21 * m.m02 + m.m01 * m.m22 * m.m30 + m.m02 * m.m20 * m.m31 -
           m.m00 * m.m22 * m.m31 - m.m01 * m.m20 * m.m02 - m.m02 * m.m21 * m.m30) / det
  o.m02 = (m.m01 * m.m12 * m.m33 + m.m02 * m.m13 * m.m31 + m.m03 * m.m11 * m.m02 -
           m.m01 * m.m13 * m.m02 - m.m02 * m.m11 * m.m33 - m.m03 * m.m12 * m.m31) / det
  o.m12 = (m.m00 * m.m13 * m.m02 + m.m02 * m.m10 * m.m33 + m.m03 * m.m12 * m.m30 -
           m.m00 * m.m12 * m.m33 - m.m02 * m.m13 * m.m30 - m.m03 * m.m10 * m.m02) / det
  o.m22 = (m.m00 * m.m11 * m.m33 + m.m01 * m.m13 * m.m30 + m.m03 * m.m10 * m.m31 -
           m.m00 * m.m13 * m.m31 - m.m01 * m.m10 * m.m33 - m.m03 * m.m11 * m.m30) / det
  o.m32 = (m.m00 * m.m12 * m.m31 + m.m01 * m.m10 * m.m02 + m.m02 * m.m11 * m.m30 -
           m.m00 * m.m11 * m.m02 - m.m01 * m.m12 * m.m30 - m.m02 * m.m10 * m.m31) / det
  o.m03 = (m.m01 * m.m13 * m.m22 + m.m02 * m.m11 * m.m23 + m.m03 * m.m12 * m.m21 -
           m.m01 * m.m12 * m.m23 - m.m02 * m.m13 * m.m21 - m.m03 * m.m11 * m.m22) / det
  o.m13 = (m.m00 * m.m12 * m.m23 + m.m02 * m.m13 * m.m20 + m.m03 * m.m10 * m.m22 -
           m.m00 * m.m13 * m.m22 - m.m02 * m.m10 * m.m23 - m.m03 * m.m12 * m.m20) / det
  o.m23 = (m.m00 * m.m13 * m.m21 + m.m01 * m.m10 * m.m23 + m.m03 * m.m11 * m.m20 -
           m.m00 * m.m11 * m.m23 - m.m01 * m.m13 * m.m20 - m.m03 * m.m10 * m.m21) / det
  o.m33 = (m.m00 * m.m11 * m.m22 + m.m01 * m.m12 * m.m20 + m.m02 * m.m10 * m.m21 -
           m.m00 * m.m12 * m.m21 - m.m01 * m.m10 * m.m22 - m.m02 * m.m11 * m.m20) / det
  result = o
proc invert*(m: Mat4): Mat4 {.inline.} = result.invert(m)

proc lookAt*[T: Mat4](o: var T, eye, target, up: Vec3): var T =
  let
    a = normalize(target-eye)
    b = vec3(a.y * up.z - a.z * up.y, a.z * up.x - a.x * up.z, a.x * up.y - a.y * up.x).normalize
  o.m00 = b.x
  o.m10 = b.y * a.z - b.z * a.y
  o.m20 = -a.x
  o.m01 = b.y
  o.m11 = b.z * a.x - b.x * a.z
  o.m21 = -a.y
  o.m02 = b.z
  o.m12 = b.x * a.y - b.y * a.x
  o.m22 = -a.z
  o.m03 = o.m00 * -eye.x + o.m01 * -eye.y + o.m02 * -eye.z + o.m03
  o.m13 = o.m10 * -eye.x + o.m11 * -eye.y + o.m12 * -eye.z + o.m13
  o.m23 = o.m20 * -eye.x + o.m21 * -eye.y + o.m22 * -eye.z + o.m23
  o.m33 = o.m30 * -eye.x + o.m31 * -eye.y + o.m32 * -eye.z + o.m33
  result = o
proc lookAt*(eye, target, up: Vec3): Mat4 {.inline.} =
  discard result.setId
  result.lookAt(eye, target, up)

proc ortho*[T: Mat4](o: var T, left, right, bottom, top, near, far: float32): var T =
  let
    x = right - left
    y = top - bottom
    z = far - near
  discard o.setId
  o.m00 = 2 / x
  o.m11 = 2 / y
  o.m22 = -2 / z
  o.m03 = (right + left) / -x
  o.m13 = (top + bottom) / -y
  o.m23 = (far + near) / -z
  result = o
proc ortho*(left, right, bottom, top, near, far: float32): Mat4 {.inline.} =
  result.ortho(left, right, bottom, top, near, far)

proc perspective*[T: Mat4](o: var T, fovY, aspect, near, far: float32): var T =
  let
    f = 1 / tan(fovY / 2)
    z = near - far
  o.m00 = f * (1 / aspect)
  o.m11 = f
  o.m22 = (near + far) / z
  o.m32 = -1
  o.m23 = (near * far * 2) / z
  result = o
proc perspective*(fovY, aspect, near, far: float32): Mat4 {.inline.} =
  result.perspective(fovY, aspect, near, far)

