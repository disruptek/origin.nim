import std/algorithm
import std/math
import std/random

import internal
import vec

type
  Mat*[N: static[int]] = array[N*N, float32]
  SomeMat* = Mat2 or Mat3 or Mat4
  Mat2* = Mat[2]
  Mat3* = Mat[3]
  Mat4* = Mat[4]
  MatrixInvertError* = object of ValueError

proc `$`*[N: static[int]](m: Mat[N]): string =
  ## Prints a matrix readably.
  result = "["
  for col in 0..N-1:
    var i = 0
    for row in countup(0, (N*N)-1, N):
      result &= m[row+col].fmt
      i.inc
      if i < N: result &= ", "
    if col < N-1: result &= "\n "
  result &= "]"

# Component accessors

template m00*(m: SomeMat): float32 = m[0]
template m10*(m: SomeMat): float32 = m[1]
template m20*(m: Mat3 or Mat4): float32 = m[2]
template m30*(m: Mat4): float32 = m[3]
template m01*(m: Mat2): float32 = m[2]
template m01*(m: Mat3): float32 = m[3]
template m01*(m: Mat4): float32 = m[4]
template m11*(m: Mat2): float32 = m[3]
template m11*(m: Mat3): float32 = m[4]
template m11*(m: Mat4): float32 = m[5]
template m21*(m: Mat3): float32 = m[5]
template m21*(m: Mat4): float32 = m[6]
template m31*(m: Mat4): float32 = m[7]
template m02*(m: Mat3): float32 = m[6]
template m02*(m: Mat4): float32 = m[8]
template m12*(m: Mat3): float32 = m[7]
template m12*(m: Mat4): float32 = m[9]
template m22*(m: Mat3): float32 = m[8]
template m22*(m: Mat4): float32 = m[10]
template m32*(m: Mat4): float32 = m[11]
template m03*(m: Mat4): float32 = m[12]
template m13*(m: Mat4): float32 = m[13]
template m23*(m: Mat4): float32 = m[14]
template m33*(m: Mat4): float32 = m[15]
template `m00=`*(m: var SomeMat, n: float32) = m[0] = n
template `m10=`*(m: var SomeMat, n: float32) = m[1] = n
template `m20=`*(m: var Mat3 or Mat4, n: float32) = m[2] = n
template `m30=`*(m: var Mat4, n: float32) = m[3] = n
template `m01=`*(m: var Mat2, n: float32) = m[2] = n
template `m01=`*(m: var Mat3, n: float32) = m[3] = n
template `m01=`*(m: var Mat4, n: float32) = m[4] = n
template `m11=`*(m: var Mat2, n: float32) = m[3] = n
template `m11=`*(m: var Mat3, n: float32) = m[4] = n
template `m11=`*(m: var Mat4, n: float32) = m[5] = n
template `m21=`*(m: var Mat3, n: float32) = m[5] = n
template `m21=`*(m: var Mat4, n: float32) = m[6] = n
template `m31=`*(m: var Mat4, n: float32) = m[7] = n
template `m02=`*(m: var Mat3, n: float32) = m[6] = n
template `m02=`*(m: var Mat4, n: float32) = m[8] = n
template `m12=`*(m: var Mat3, n: float32) = m[7] = n
template `m12=`*(m: var Mat4, n: float32) = m[9] = n
template `m22=`*(m: var Mat3, n: float32) = m[8] = n
template `m22=`*(m: var Mat4, n: float32) = m[10] = n
template `m32=`*(m: var Mat4, n: float32) = m[11] = n
template `m03=`*(m: var Mat4, n: float32) = m[12] = n
template `m13=`*(m: var Mat4, n: float32) = m[13] = n
template `m23=`*(m: var Mat4, n: float32) = m[14] = n
template `m33=`*(m: var Mat4, n: float32) = m[15] = n

# Constructors

proc mat2*(): Mat2 {.inline.} =
  ## Initialize a 2x2 zero matrix.
  result.fill(0)

proc mat2*(n: float32): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix with each component all its main diagonal set to `n`.
  result.m00 = n
  result.m11 = n

proc mat2*(m: SomeMat): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix from the upper 2x2 portion of the matrix `m`.
  result.m00 = m.m00
  result.m10 = m.m10
  result.m01 = m.m01
  result.m11 = m.m11

proc mat2*(a, b: Vec2): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix from the 2D column vectors `a` and `b`.
  result.m00 = a.x
  result.m10 = a.y
  result.m01 = b.x
  result.m11 = b.y

proc mat2*(a, b, c, d: float32): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix in column order from scalars.
  [a, b, c, d]

proc mat3*(): Mat3 {.inline.} =
  ## Initialize a 3x3 zero matrix.
  result.fill(0)

proc mat3*(n: float32): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix with each component all its main diagonal set to `n`.
  result.m00 = n
  result.m11 = n
  result.m22 = n

proc mat3*(m: Mat2): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix from the 2x2 matrix `m`. The upper 2x2 portion of the matrix is written
  ## from the components of `m`, and the remaining component along its main diagonal is set to 1.
  result.m00 = m.m00
  result.m10 = m.m10
  result.m01 = m.m01
  result.m11 = m.m11
  result.m22 = 1

proc mat3*(m: Mat3 or Mat4): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix from the upper 3x3 portion of the 3x3 or 4x4 matrix `m`.
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
  ## Initialize a 3x3 matrix from the 3D column vectors `a`, `b`, and `c`.
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
  ## Initialize a 3x3 matrix in column order from scalars.
  [a, b, c, d, e, f, g, h, i]

proc mat4*(): Mat4 {.inline.} =
  ## Initialize a 4x4 zero matrix.
  result.fill(0)

proc mat4*(n: float32): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix with each component all its main diagonal set to `n`.
  result.m00 = n
  result.m11 = n
  result.m22 = n
  result.m33 = n

proc mat4*(m: Mat4): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix from the components of another 4x4 matrix.
  m

proc mat4*(m: Mat2): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix from the 2x2 matrix `m`. The upper 2x2 portion of the matrix is written
  ## from the components of `m`, and the remaining components along its main diagonal are set to 1.
  result.m00 = m.m00
  result.m10 = m.m10
  result.m01 = m.m01
  result.m11 = m.m11
  result.m22 = 1
  result.m33 = 1

proc mat4*(m: Mat3): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix from the 3x3 matrix `m`. The upper 3x3 portion of the matrix is written
  ## from the components of `m`, and the remaining component along its main diagonal is set to 1.
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
  ## Initialize a 4x4 matrix from the 4D column vectors `a`, `b`, `c`, and `d`.
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
  ## Initialize a 4x4 matrix in column order from scalars.
  [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p]

# Constants

const mat2_zero* = ## \
  ## A 2x2 zero matrix.
  mat2()

const mat2_id* = ## \
  # A 2x2 identity matrix.
  mat2(1)

const mat3_zero* = ## \
  ## A 3x3 zero matrix.
  mat3()

const mat3_id* = ## \
  ## A 3x3 identity matrix.
  mat3(1)

const mat4_zero* = ## \
  ## A 4x4 zero matrix.
  mat4()

const mat4_id* = ## \
  ## A 4x4 identity matrix.
  mat4(1)

# Common operations

proc rand*(o: var SomeMat, range = 0f..1f) {.inline.} =
  ## Randomize the components of the matrix `o` to be within the range `range`, storing the result
  ## in the output matrix `o`.
  for i, _ in o: o[i] = rand(range)

proc rand*[T: SomeMat](t: typedesc[T], range = 0f..1f): T {.inline.} =
  ## Initialize a new matrix with its components randomized to be within the range `range`.
  result.rand(range)

proc zero*(o: var SomeMat) {.inline.} =
  ## Set all components of the matrix `o` to zero.
  o.fill(0)

proc `~=`*(a, b: SomeMat, tolerance = 1e-5): bool {.inline.} =
  ## Check if the matrices `a` and `b` are approximately equal.
  genComponentWiseBool(`~=`, a, b, tolerance)

proc clamp*[T: SomeMat](o: var T, m: T, range = -Inf.float32 .. Inf.float32) {.inline.} =
  ## Constrain each component of the matrix `m` to lie within `range`, storing the result in the
  ## output matrix `o`.
  for i, _ in o: o[i] = m[i].clamp(range.a, range.b)

proc clamp*[T: SomeMat](m: T, range = -Inf.float32 .. Inf.float32): T {.inline.} =
  ## Constrain each component of the matrix `m` to lie within `range`, storing the result in a new
  ## matrix.
  result.clamp(m, range)

proc `+`*[T: SomeMat](o: var T, a, b: T) {.inline.} =
  ## Component-wise addition of the matrices `a` and `b`, storing the result in the output matrix
  ## `o`.
  for i, _ in o: o[i] = a[i] + b[i]

proc `+`*[T: SomeMat](a, b: T): T {.inline.} =
  ## Component-wise addition of the matrices `a` and `b`, storing the result in a new matrix.
  result.`+`(a, b)

proc `-`*[T: SomeMat](o: var T, a, b: T) {.inline.} =
  ## Component-wise subtraction of the matrices `a` and `b`, storing the result in the output matrix
  ## `o`.
  for i, _ in o: o[i] = a[i] - b[i]

proc `-`*[T: SomeMat](a, b: T): T {.inline.} =
  ## Component-wise subtraction of the matrices `a` and `b`, storing the result in a new matrix.
  result.`-`(a, b)

proc `-`*(o: var SomeMat) {.inline.} =
  ## Unary subtraction (negation) of the components of the matrix `o`, storing the result in the
  ## output matrix `o`.
  for i, _ in o: o[i] = -o[i]

proc `-`*[T: SomeMat](m: T): T {.inline.} =
  ## Unary subtraction (negation) of the components of the matrix `m`, storing the result in a new
  ## matrix.
  result = m
  result.`-`

proc `*`*[T: SomeMat](a, b: T): T {.inline.} =
  # Multiply the matrices `a` and `b`, storing the result in a new matrix.
  result.`*`(a, b)

# 2x2 matrix operations

proc setId*(o: var Mat2) {.inline.} =
  ## Store a 2x2 identity matrix into the output matrix `o`.
  o.fill(0)
  o.m00 = 1
  o.m11 = 1

proc `*`*(o: var Mat2, a, b: Mat2) {.inline.} =
  ## Multiply the 2x2 matrices `a` and `b`, storing the result in the output matrix `o`.
  let
    a = a
    b = b
  o.m00 = a.m00 * b.m00 + a.m01 * b.m10
  o.m10 = a.m10 * b.m00 + a.m11 * b.m10
  o.m01 = a.m00 * b.m01 + a.m01 * b.m11
  o.m11 = a.m10 * b.m01 + a.m11 * b.m11

proc column*(o: var Vec2, m: Mat2, index: range[0..1]) {.inline.} =
  ## Extract the 2D column vector at the given `index` from the 2x2 matrix `m`, storing the result
  ## in the output vector `o`.
  case index
  of 0: o[0..1] = m[0..1]
  of 1: o[0..1] = m[2..3]

proc column*(m: Mat2, index: range[0..1]): Vec2 {.inline.} =
  ## Extract the 2D column vector at the given `index` from the 2x2 matrix `m`, storing the result
  ## in a new vector.
  result.column(m, index)

proc `column=`*(o: var Mat2, m: Mat2, v: Vec2, index: range[0..1]) {.inline.} =
  ## Set the components of a column at the given `index` of the 2x2 matrix `m` from the vector `v`,
  ## storing the result in the output matrix `o`.
  o = m
  case index
  of 0: o[0..1] = v[0..1]
  of 1: o[2..3] = v[0..1]

proc `column=`*(m: Mat2, v: Vec2, index: range[0..1]): Mat2 {.inline.} =
  ## Set the components of a column at the given `index` of the 2x2 matrix `m` from the vector `v`,
  ## storing the result in a new matrix.
  result.`column=`(m, v, index)

proc rotation*(o: var Vec2, m: Mat2, axis: Axis2d) {.inline.} =
  ## Extract the 2D rotation along `axis` from the 2x2 matrix `m`, storing the result in the output
  ## vector `o`.
  case axis
  of Axis2d.X: o[0..1] = m[0..1]
  of Axis2d.Y: o[0..1] = m[2..3]

proc rotation*(m: Mat2, axis: Axis2d): Vec2 {.inline.} =
  ## Extract the 2D rotation along `axis` from the 2x2 matrix `m`, storing the result in a new
  ## vector.
  result.rotation(m, axis)

proc `rotation=`*(o: var Mat2, v: Vec2, axis: Axis2d) {.inline.} =
  ## Set the rotation components along `axis` of the 2x2 matrix `m` from the 2D vector `v`, storing
  ## the result in the output matrix `o`.
  case axis
  of Axis2d.X: o[0..1] = v[0..1]
  of Axis2d.Y: o[2..3] = v[0..1]

proc `rotation=`*(m: Mat2, v: Vec2, axis: Axis2d): Mat2 {.inline.} =
  ## Set the rotation components along `axis` of the 2x2 matrix `m` from the 2D vector `v`, storing
  ## the result in a new matrix.
  result = m
  result.`rotation=`(v, axis)

proc rotate*(o: var Mat2, m: Mat2, angle: float32, space: Space = Space.local) {.inline.} =
  ## Rotate the 2x2 matrix `m` by `angle`, storing the result in the output matrix `o`. `space` can
  ## be set to `Space.local` or `Space.world` to perform the rotation in local or world space.
  let
    s = angle.sin
    c = angle.cos
    t = mat2(c, s, -s, c)
  case space:
    of Space.local: o = o * t
    of Space.world: o = t * o

proc rotate*(m: Mat2, angle: float32, space: Space = Space.local): Mat2 {.inline.} =
  ## Rotate the 2x2 matrix `m` by 'angle`, storing the result in a new matrix. `space` can be set to
  ## `Space.local` or `Space.world` to perform the rotation in local or world space.
  result = m
  result.rotate(m, angle, space)

proc transpose*(o: var Mat2, m: Mat2) {.inline.} =
  ## Transpose the 2x2 matrix `m`, storing the result in the output matrix `o`.
  o = m
  swap(o.m10, o.m01)

proc transpose*(m: Mat2): Mat2 {.inline.} =
  ## Transpose the 3x3 matrix `m`, storing the result in a new matrix.
  result.transpose(m)

proc isOrthogonal*(m: Mat2): bool {.inline.} =
  ## Check if the 2x2 matrix `m` is orthogonal.
  m * m.transpose ~= mat2_id

proc trace*(m: Mat2): float32 {.inline.} =
  ## Calculate the trace of the 2x2 matrix `m`.
  m.m00 + m.m11

proc isDiagonal*(m: Mat2): bool {.inline.} =
  ## Check if the 2x2 matrix `m` is a diagonal matrix.
  m.m10 == 0 and m.m01 == 0 and m.m00 == m.m11

proc mainDiagonal*(o: var Vec2, m: Mat2) {.inline.} =
  ## Extract the main diagonal of the 2x2 matrix `m`, storing it in the 2D output vector `o`.
  o.x = m.m00
  o.y = m.m11

proc mainDiagonal*(m: Mat2): Vec2 {.inline.} =
  ## Extract the main diagonal of the 2x2 matrix `m`, storing it in a new 2D vector.
  result.mainDiagonal(m)

proc antiDiagonal*(o: var Vec2, m: Mat2) {.inline.} =
  ## Extract the anti-diagonal of the 2x2 matrix `m`, storing it in the 2D output vector `o`.
  o.x = m.m01
  o.y = m.m10

proc antiDiagonal*(m: Mat2): Vec2 {.inline.} =
  ## Extract the anti-diagonal of the 2x2 matrix `m`, storing it in a new 2D vector.
  result.antiDiagonal(m)

# 3x3 matrix operations

proc setId*(o: var Mat3) {.inline.} =
  ## Store a 3x3 identity matrix into the output matrix `o`.
  o.fill(0)
  o.m00 = 1
  o.m11 = 1
  o.m22 = 1

proc `*`*(o: var Mat3, a, b: Mat3) {.inline.} =
  ## Multiply the 3x3 matrices `a` and `b`, storing the result in the output matrix `o`.
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

proc `*`*(o: var Vec3, m: Mat3, v: Vec3) {.inline.} =
  ## Multiply the 3x3 matrix `m` by the 3D vector `v`, storing the result in the output vector `o`.
  o.x = m.m00 * v.x + m.m01 * v.y + m.m02 * v.z
  o.y = m.m10 * v.x + m.m11 * v.y + m.m12 * v.z
  o.z = m.m20 * v.x + m.m21 * v.y + m.m22 * v.z

proc `*`*(m: Mat3, v: Vec3): Vec3 {.inline.} =
  ## Multiply the 3x3 matrix `m` by the 3D vector `v`, storing the result in a new vector.
  result.`*`(m, v)

proc column*(o: var Vec3, m: Mat3, index: range[0..2]) {.inline.} =
  ## Extract the 3D column vector at the given `index` from the 3x3 matrix `m`, storing the result
  ## in the output vector `o`.
  case index
  of 0: o[0..2] = m[0..2]
  of 1: o[0..2] = m[3..5]
  of 2: o[0..2] = m[6..8]

proc column*(m: Mat3, index: range[0..2]): Vec3 {.inline.} =
  ## Extract the 3D column vector at the given `index` from the 3x3 matrix `m`, storing the result
  ## in a new vector.
  result.column(m, index)

proc `column=`*(o: var Mat3, m: Mat3, v: Vec3, index: range[0..2]) {.inline.} =
  ## Set the components of a column at the given `index` of the 3x3 matrix `m` from the vector `v`,
  ## storing the result in the output matrix `o`.
  o = m
  case index
  of 0: o[0..2] = v[0..2]
  of 1: o[3..5] = v[0..2]
  of 2: o[6..8] = v[0..2]

proc `column=`*(m: Mat3, v: Vec3, index: range[0..2]): Mat3 {.inline.} =
  ## Set the components of a column at the given `index` of the 3x3 matrix `m` from the vector `v`,
  ## storing the result in a new matrix.
  result.`column=`(m, v, index)

proc copyRotation*(o: var Mat3, m: Mat3) {.inline.} =
  ## Copy the 2x2 rotation portion of the 3x3 matrix `m` into the rotation portion of the 3x3 matrix
  ## `o`.
  o.m00 = m.m00
  o.m10 = m.m10
  o.m01 = m.m01
  o.m11 = m.m11

proc copyRotation*(m: Mat3): Mat3 {.inline.} =
  ## Copy the 2x2 rotation portion of the 3x3 matrix `m` into the rotation portion of a new 3x3
  ## matrix. The remaining component along its main diagonal is set to 1.
  result.copyRotation(m)
  result.m22 = 1

proc rotation*(o: var Mat2, m: Mat3) {.inline.} =
  ## Copy the 2x2 rotation portion of the 3x3 matrix `m` into the 2x2 matrix `o`.
  o.m00 = m.m00
  o.m10 = m.m10
  o.m01 = m.m01
  o.m11 = m.m11

proc rotation*(m: Mat3): Mat2 {.inline.} =
  ## Copy the 2x2 rotation portion of the 3x3 matrix `m` into a new 2x2 matrix.
  result.rotation(m)

proc rotation*(o: var Vec2, m: Mat3, axis: Axis2d) {.inline.} =
  ## Extract the 2D rotation along `axis` from the 3x3 matrix `m`, storing the result in the output
  ## vector `o`.
  case axis
  of Axis2d.X: o[0..1] = m[0..1]
  of Axis2d.Y: o[0..1] = m[3..4]

proc rotation*(m: Mat3, axis: Axis2d): Vec2 {.inline.} =
  ## Extract the 2D rotation along `axis` from the 3x3 matrix `m`, storing the result in a new
  ## vector.
  result.rotation(m, axis)

proc `rotation=`*(o: var Mat3, m: Mat2) {.inline.} =
  ## Copy the components of the 2x2 matrix `m` into the rotation portion of the 3x3 matrix `o`.
  o.m00 = m.m00
  o.m10 = m.m10
  o.m01 = m.m01
  o.m11 = m.m11

proc `rotation=`*(m: Mat2): Mat3 {.inline.} =
  ## Copy the components of the 2x2 matrix `m` into the rotation portion of a new 3x3 matrix.
  result.rotation = m

proc `rotation=`*(o: var Mat3, v: Vec2, axis: Axis2d) {.inline.} =
  ## Set the rotation components along `axis` of the 3x3 matrix `m` from the 2D vector `v`, storing
  ## the result in the output matrix `o`.
  case axis
  of Axis2d.X: o[0..1] = v[0..1]
  of Axis2d.Y: o[3..4] = v[0..1]

proc `rotation=`*(m: Mat3, v: Vec2, axis: Axis2d): Mat3 {.inline.} =
  ## Set the rotation components along `axis` of the 3x3 matrix `m` from the 2D vector `v`, storing
  ## the result in a new matrix.
  result = m
  result.`rotation=`(v, axis)

proc rotate*(o: var Mat3, m: Mat3, angle: float32, space: Space = Space.local) =
  ## Rotate the 3x3 matrix `m` by `angle`, storing the result in the output matrix `o`. `space` can
  ## be set to `Space.local` or `Space.world` to perform the rotation in local or world space.
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
  ## Rotate the 3x3 matrix `m` by 'angle`, storing the result in a new matrix. `space` can be set to
  ## `Space.local` or `Space.world` to perform the rotation in local or world space.
  result = m
  result.rotate(m, angle, space)

proc normalizeRotation*(o: var Mat3, m: Mat3) {.inline.} =
  ## Normalize the columns of the 2x2 rotation portion of the 3x3 matrix `m`, storing the result in
  ## the 3x3 output matrix `o`.
  var
    x = vec2(m.m00, m.m10).normalize
    y = vec2(m.m01, m.m11).normalize
  o.m00 = x.x
  o.m10 = x.y
  o.m01 = y.x
  o.m11 = y.y

proc normalizeRotation*(m: Mat3): Mat3 {.inline.} =
  ## Normalize the rotation portion of the 3x3 matrix `m`, storing the result in a new matrix.
  result = m
  result.normalizeRotation(m)

proc translation*(o: var Vec2, m: Mat3) {.inline.} =
  ## Extract the 2D translation vector from the 3x3 matrix `m`, storing the result in the output
  ## vector `o`.
  o.x = m.m02
  o.y = m.m12

proc translation*(m: Mat3): Vec2 {.inline.} =
  ## Extract the 2D translation vector from the 3x3 matrix `m`, storing the result in a new vector.
  result.translation(m)

proc `translation=`*(o: var Mat3, m: Mat3, v: Vec2) {.inline.} =
  ## Set the translation components of the 3x3 matrix `m` from the vector `v`, storing the result in
  ## the output matrix `o`.
  o.copyRotation(m)
  o.m02 = v.x
  o.m12 = v.y
  o.m22 = m.m22

proc `translation=`*(m: Mat3, v: Vec2): Mat3 {.inline.} =
  ## Set the translation components of the 3x3 matrix `m` from the vector `v`, storing the result in
  ## a new matrix.
  result.`translation=`(m, v)

proc translate*(o: var Mat3, m: Mat3, v: Vec2) {.inline.} =
  ## Translate the 3x3 matrix `m` by the 2D translation vector `v`, storing the result in the output
  ## matrix `o`.
  o.m00 = m.m00 + m.m20 * v.x
  o.m10 = m.m10 + m.m20 * v.y
  o.m20 = m.m20
  o.m01 = m.m01 + m.m21 * v.x
  o.m11 = m.m11 + m.m21 * v.y
  o.m21 = m.m21
  o.m02 = m.m02 + m.m22 * v.x
  o.m12 = m.m12 + m.m22 * v.y
  o.m22 = m.m22

proc translate*(m: Mat3, v: Vec2): Mat3 {.inline.} =
  ## Translate the 3x3 matrix `m` by the 2D translation vector `v`, storing the result in a new
  ## matrix.
  result.translate(m, v)

proc scale*(o: var Vec2, m: Mat3) {.inline.} =
  ## Extract the 2D scale vector from the 3x3 matrix `m`, storing the result in the output
  ## vector `o`.
  o.x = m.rotation(Axis2d.X).len
  o.y = m.rotation(Axis2d.Y).len

proc scale*(m: Mat3): Vec2 {.inline.} =
  ## Extract the 2D scale vector from the 3x3 matrix `m`, storing the result in a new vector.
  result.scale(m)

proc `scale=`*(o: var Mat3, m: Mat3, v: Vec2) {.inline.} =
  ## Set the scale of the 3x3 matrix `m` from the 2D vector `v`, storing the result in the output
  ## matrix `o`.
  o = m
  o.m00 = v.x
  o.m11 = v.y

proc `scale=`*(m: Mat3, v: Vec2): Mat3 {.inline.} =
  ## Set the scale of the 3x3 matrix `m` from the 2D vector `v`, storing the result in a new matrix.
  result.`scale=`(m, v)

proc scale*(o: var Mat3, m: Mat3, v: Vec2) {.inline.} =
  ## Scale the 3x3 matrix `m` by the 2D vector `v`, storing the result in the output matrix `o`.
  o.m00 = m.m00 * v.x
  o.m10 = m.m10 * v.y
  o.m20 = m.m20
  o.m01 = m.m01 * v.x
  o.m11 = m.m11 * v.y
  o.m21 = m.m21
  o.m02 = m.m02 * v.x
  o.m12 = m.m12 * v.y
  o.m22 = m.m22

proc scale*(m: Mat3, v: Vec2): Mat3 {.inline.} =
  ## Scale the 3x3 matrix `m` by the 2D vector `v`, storing the result in a new matrix.
  result.scale(m, v)

proc transpose*(o: var Mat3, m: Mat3) {.inline.} =
  ## Transpose the 3x3 matrix `m`, storing the result in the output matrix `o`.
  o = m
  swap(o.m10, o.m01)
  swap(o.m20, o.m02)
  swap(o.m21, o.m12)

proc transpose*(m: Mat3): Mat3 {.inline.} =
  ## Transpose the 3x3 matrix `m`, storing the result in a new matrix.
  result.transpose(m)

proc isOrthogonal*(m: Mat3): bool {.inline.} =
  ## Check if the 3x3 matrix `m` is orthogonal.
  m * m.transpose ~= mat3_id

proc trace*(m: Mat3): float32 {.inline.} =
  ## Calculate the trace of the 3x3 matrix `m`.
  m.m00 + m.m11 + m.m22

proc isDiagonal*(m: Mat3): bool {.inline.} =
  ## Check if the 3x3 matrix `m` is a diagonal matrix.
  m.m10 == 0 and m.m20 == 0 and m.m01 == 0 and
  m.m21 == 0 and m.m02 == 0 and m.m12 == 0 and
  m.m00 == m.m11 and m.m11 == m.m22

proc mainDiagonal*(o: var Vec3, m: Mat3) {.inline.} =
  ## Extract the main diagonal of the 3x3 matrix `m`, storing it in the 3D output vector `o`.
  o.x = m.m00
  o.y = m.m11
  o.z = m.m22

proc mainDiagonal*(m: Mat3): Vec3 {.inline.} =
  ## Extract the main diagonal of the 3x3 matrix `m`, storing it in a new 3D vector.
  result.mainDiagonal(m)

proc antiDiagonal*(o: var Vec3, m: Mat3) {.inline.} =
  ## Extract the anti-diagonal of the 3x3 matrix `m`, storing it in the 3D output vector `o`.
  o.x = m.m02
  o.y = m.m11
  o.z = m.m20

proc antiDiagonal*(m: Mat3): Vec3 {.inline.} =
  ## Extract the anti-diagonal of the 3x3 matrix `m`, storing it in a new 3D vector.
  result.antiDiagonal(m)

# 4x4 matrix operations

proc setId*(o: var Mat4) {.inline.} =
  ## Store a 4x4 identity matrix into the output matrix `o`.
  o.fill(0)
  o.m00 = 1
  o.m11 = 1
  o.m22 = 1
  o.m33 = 1

proc `*`*(o: var Mat4, a, b: Mat4) {.inline.} =
  ## Multiply the 4x4 matrices `a` and `b`, storing the result in the output matrix `o`.
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

proc `*`*(o: var Vec4, m: Mat4, v: Vec4) {.inline.} =
  ## Multiply the 4x4 matrix `m` by the 4D vector `v`, storing the result in the output vector `o`.
  o.x = m.m00 * v.x + m.m01 * v.y + m.m02 * v.z + m.m03 * v.w
  o.y = m.m10 * v.x + m.m11 * v.y + m.m12 * v.z + m.m13 * v.w
  o.z = m.m20 * v.x + m.m21 * v.y + m.m22 * v.z + m.m23 * v.w
  o.w = m.m30 * v.x + m.m31 * v.y + m.m32 * v.z + m.m33 * v.w

proc `*`*(m: Mat4, v: Vec4): Vec4 {.inline.} =
  ## Multiply the 4x4 matrix `m` by the 4D vector `v`, storing the result in a new vector.
  result.`*`(m, v)

proc column*(o: var Vec4, m: Mat4, index: range[0..3]) {.inline.} =
  ## Extract the 4D column vector at the given `index` from the 4x4 matrix `m`, storing the result
  ## in the output vector `o`.
  case index
  of 0: o[0..3] = m[0..3]
  of 1: o[0..3] = m[4..7]
  of 2: o[0..3] = m[8..11]
  of 3: o[0..3] = m[12..15]

proc column*(m: Mat4, index: range[0..3]): Vec4 {.inline.} =
  ## Extract the 4D column vector at the given `index` from the 4x4 matrix `m`, storing the result
  ## in a new vector.
  result.column(m, index)

proc `column=`*(o: var Mat4, m: Mat4, v: Vec4, index: range[0..3]) {.inline.} =
  ## Set the components of a column at the given `index` of the 4x4 matrix `m` from the vector `v`,
  ## storing the result in the output matrix `o`.
  o = m
  case index
  of 0: o[0..3] = v[0..3]
  of 1: o[4..7] = v[0..3]
  of 2: o[8..11] = v[0..3]
  of 3: o[12..15] = v[0..3]

proc `column=`*(m: Mat4, v: Vec4, index: range[0..3]): Mat4 {.inline.} =
  ## Set the components of a column at the given `index` of the 4x4 matrix `m` from the vector `v`,
  ## storing the result in a new matrix.
  result.`column=`(m, v, index)

proc copyRotation*(o: var Mat4, m: Mat4) {.inline.} =
  ## Copy the 3x3 rotation portion of the 4x4 matrix `m` into the rotation portion of the 4x4 matrix
  ## `o`.
  o.m00 = m.m00
  o.m10 = m.m10
  o.m20 = m.m20
  o.m01 = m.m01
  o.m11 = m.m11
  o.m21 = m.m21
  o.m02 = m.m02
  o.m12 = m.m12
  o.m22 = m.m22

proc copyRotation*(m: Mat4): Mat4 {.inline.} =
  ## Copy the 3x3 rotation portion of the 4x4 matrix `m` into the rotation portion of a new 4x4
  ## matrix. The remaining component along its main diagonal is set to 1.
  result.copyRotation(m)
  result.m33 = 1

proc rotation*(o: var Mat3, m: Mat4) {.inline.} =
  ## Copy the 3x3 rotation portion of the 4x4 matrix `m` into the 3x3 matrix `o`.
  o.m00 = m.m00
  o.m10 = m.m10
  o.m20 = m.m20
  o.m01 = m.m01
  o.m11 = m.m11
  o.m21 = m.m21
  o.m02 = m.m02
  o.m12 = m.m12
  o.m22 = m.m22

proc rotation*(m: Mat4): Mat3 {.inline.} =
  ## Copy the 3x3 rotation portion of the 4x4 matrix `m` into a new 3x3 matrix.
  result.rotation(m)

proc rotation*(o: var Vec3, m: Mat4, axis: Axis3d) {.inline.} =
  ## Extract the 3D rotation along `axis` from the 4x4 matrix `m`, storing the result in the output
  ## vector `o`.
  case axis
  of Axis3d.X: o[0..2] = m[0..2]
  of Axis3d.Y: o[0..2] = m[4..6]
  of Axis3d.Z: o[0..2] = m[8..10]

proc rotation*(m: Mat4, axis: Axis3d): Vec3 {.inline.} =
  ## Extract the 3D rotation along `axis` from the 4x4 matrix `m`, storing the result in a new
  ## vector.
  result.rotation(m, axis)

proc `rotation=`*(o: var Mat4, m: (Mat3 or Mat4)) {.inline.} =
  ## Copy the components of the 3x3 matrix `m` into the rotation portion of the 4x4 matrix `o`.
  o.m00 = m.m00
  o.m10 = m.m10
  o.m20 = m.m20
  o.m01 = m.m01
  o.m11 = m.m11
  o.m21 = m.m21
  o.m02 = m.m02
  o.m12 = m.m12
  o.m22 = m.m22

proc `rotation=`*(m: Mat3): Mat4 {.inline.} =
  ## Copy the components of the 3x3 matrix `m` into the rotation portion of a new 4x4 matrix.
  result.rotation = m

proc `rotation=`*(o: var Mat4, v: Vec3, axis: Axis3d) {.inline.} =
  ## Set the rotation components along `axis` of the 4x4 matrix `m` from the 3D vector `v`, storing
  ## the result in the output matrix `o`.
  case axis
  of Axis3d.X: o[0..2] = v[0..2]
  of Axis3d.Y: o[4..6] = v[0..2]
  of Axis3d.Z: o[8..10] = v[0..2]

proc `rotation=`*(m: Mat4, v: Vec3, axis: Axis3d): Mat4 {.inline.} =
  ## Set the rotation components along `axis` of the 4x4 matrix `m` from the 3D vector `v`, storing
  ## the result in a new matrix.
  result = m
  result.`rotation=`(v, axis)

proc rotate*(o: var Mat4, m: Mat4, v: Vec3, space: Space = Space.local) =
  ## Rotate the 4x4 matrix `m` by the vector of Euler angles `v`, storing the result in the output
  ## matrix `o`. `space` can be set to `Space.local` or `Space.world` to perform the rotation in
  ## local or world space.
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
  t = [1f, 0, 0, 0, c.x, s.x, 0, -s.x, c.x]
  rotateAxis(outMat3, t, space)
  t = [c.y, 0, -s.y, 0, 1, 0, s.y, 0, c.y]
  rotateAxis(outMat3, t, space)
  o.`rotation=`(outMat3)

proc rotate*(m: Mat4, v: Vec3, space: Space = Space.local): Mat4 {.inline.} =
  ## Rotate the matrix `m` by the vector of Euler angles `v`, storing the result in a new matrix.
  ## `space` can be set to `Space.local` or `Space.world` to perform the rotation in local or world
  ## space.
  result = m
  result.rotate(m, v, space)

proc normalizeRotation*(o: var Mat4, m: Mat4) {.inline.} =
  ## Normalize the columns of the 3x3 rotation portion of the 4x4 matrix `m`, storing the result in
  ## the 4x4 output matrix `o`.
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

proc normalizeRotation*(m: Mat4): Mat4 {.inline.} =
  ## Normalize the rotation portion of the 4x4 matrix `m`, storing the result in a new matrix.
  result = m
  result.normalizeRotation(m)

proc translation*(o: var Vec3, m: Mat4) {.inline.} =
  ## Extract the 3D translation vector from the 4x4 matrix `m`, storing the result in the output
  ## vector `o`.
  o.x = m.m03
  o.y = m.m13
  o.z = m.m23

proc translation*(m: Mat4): Vec3 {.inline.} =
  ## Extract the 3D translation vector from the 4x4 matrix `m`, storing the result in a new vector.
  result.translation(m)

proc `translation=`*(o: var Mat4, m: Mat4, v: Vec3) {.inline.} =
  ## Set the translation components of the 4x4 matrix `m` from the vector `v`, storing the result in
  ## the output matrix `o`.
  o.copyRotation(m)
  o.m03 = v.x
  o.m13 = v.y
  o.m23 = v.z
  o.m33 = m.m33

proc `translation=`*(m: Mat4, v: Vec3): Mat4 {.inline.} =
  ## Set the translation components of the 4x4 matrix `m` from the vector `v`, storing the result in
  ## a new matrix.
  result.`translation=`(m, v)

proc translate*(o: var Mat4, m: Mat4, v: Vec3) {.inline.} =
  ## Translate the 4x4 matrix `m` by the 3D translation vector `v`, storing the result in the output
  ## matrix `o`.
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

proc translate*(m: Mat4, v: Vec3): Mat4 {.inline.} =
  ## Translate the 4x4 matrix `m` by the 3D translation vector `v`, storing the result in a new
  ## matrix.
  result.translate(m, v)

proc scale*(o: var Vec3, m: Mat4) {.inline.} =
  ## Extract the 3D scale vector from the 4x4 matrix `m`, storing the result in the output vector
  ## `o`.
  o.x = m.rotation(Axis3d.X).len
  o.y = m.rotation(Axis3d.Y).len
  o.z = m.rotation(Axis3d.Z).len

proc scale*(m: Mat4): Vec3 {.inline.} =
  ## Extract the 3D scale vector from the 4x4 matrix `m`, storing the result in a new vector.
  result.scale(m)

proc `scale=`*(o: var Mat4, m: Mat4, v: Vec3) {.inline.} =
  ## Set the scale of the 4x4 matrix `m` from the 3D vector `v`, storing the result in the output
  ## matrix `o`.
  o = m
  o.m00 = v.x
  o.m11 = v.y
  o.m22 = v.z

proc `scale=`*(m: Mat4, v: Vec3): Mat4 {.inline.} =
  ## Set the scale of the 4x4 matrix `m` from the 3D vector `v`, storing the result in a new matrix.
  result.`scale=`(m, v)

proc scale*(o: var Mat4, m: Mat4, v: Vec3) {.inline.} =
  ## Scale the 4x4 matrix `m` by the 3D vector `v`, storing the result in the output matrix `o`.
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

proc scale*(m: Mat4, v: Vec3): Mat4 {.inline.} =
  ## Scale the 4x4 matrix `m` by the 3D vector `v`, storing the result in a new matrix.
  result.scale(m, v)

proc transpose*(o: var Mat4, m: Mat4) {.inline.} =
  ## Transpose the 4x4 matrix `m`, storing the result in the output matrix `o`.
  o = m
  swap(o.m10, o.m01)
  swap(o.m20, o.m02)
  swap(o.m30, o.m03)
  swap(o.m21, o.m12)
  swap(o.m31, o.m13)
  swap(o.m32, o.m23)

proc transpose*(m: Mat4): Mat4 {.inline.} =
  ## Transpose the 4x4 matrix `m`, storing the result in a new matrix.
  result.transpose(m)

proc isOrthogonal*(m: Mat4): bool {.inline.} =
  ## Check if the 4x4 matrix `m` is orthogonal.
  m * m.transpose ~= mat4_id

proc orthoNormalize*(o: var Mat4, m: Mat4) =
  ## Orthonormalize the 4x4 matrix `m` using the Gram-Schmidt process, storing the result in the
  ## output matrix `o`.
  var
    x = m.rotation(Axis3d.X)
    y = m.rotation(Axis3d.Y)
    z = m.rotation(Axis3d.Z)
  x.normalize(x)
  y.normalize(y - x * dot(y, x))
  z.cross(x, y)
  o.`rotation=`(x, Axis3d.X)
  o.`rotation=`(y, Axis3d.Y)
  o.`rotation=`(z, Axis3d.Z)

proc orthoNormalize*(m: Mat4): Mat4 {.inline.} =
  ## Orthonormalize the 4x4 matrix `m` using the Gram-Schmidt process, storing the result in a new
  ## matrix.
  result = mat4_id
  result.orthoNormalize(m)

proc trace*(m: Mat4): float32 {.inline.} =
  ## Calculate the trace of the 4x4 matrix `m`.
  m.m00 + m.m11 + m.m22 + m.m33

proc isDiagonal*(m: Mat4): bool {.inline.} =
  ## Check if the 4x4 matrix `m` is a diagonal matrix.
  m.m10 == 0 and m.m20 == 0 and m.m30 == 0 and m.m01 == 0 and
  m.m21 == 0 and m.m31 == 0 and m.m02 == 0 and m.m12 == 0 and
  m.m32 == 0 and m.m03 == 0 and m.m13 == 0 and m.m23 == 0 and
  m.m00 == m.m11 and m.m11 == m.m22 and m.m22 == m.m33

proc mainDiagonal*(o: var Vec4, m: Mat4) {.inline.} =
  ## Extract the main diagonal of the 4x4 matrix `m`, storing it in the 4D output vector `o`.
  o.x = m.m00
  o.y = m.m11
  o.z = m.m22
  o.w = m.m33

proc mainDiagonal*(m: Mat4): Vec4 {.inline.} =
  ## Extract the main diagonal of the 4x4 matrix `m`, storing it in a new 4D vector.
  result.mainDiagonal(m)

proc antiDiagonal*(o: var Vec4, m: Mat4) {.inline.} =
  ## Extract the anti-diagonal of the 4x4 matrix `m`, storing it in the 4D output vector `o`.
  o.x = m.m03
  o.y = m.m12
  o.z = m.m21
  o.w = m.m30

proc antiDiagonal*(m: Mat4): Vec4 {.inline.} =
  ## Extract the anti-diagonal of the 4x4 matrix `m`, storing it in a new 4D vector.
  result.antiDiagonal(m)

proc determinant*(m: Mat4): float32 =
  ## Calculate the determinant of the 4x4 matrix `m`.
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

proc invertOrthogonal*(o: var Mat4, m: Mat4) {.inline.} =
  ## Invert the orthogonal 4x4 matrix `m`, storing the result in the output matrix `o`.
  ##
  ## **Note**: This is a less expensive invert method that can be used if is known that a matrix is
  ## orthogonal.
  o = m
  swap(o.m10, o.m01)
  swap(o.m20, o.m02)
  swap(o.m21, o.m12)
  o.m03 = o.m00 * -o.m03 + o.m01 * -o.m13 + o.m02 * -o.m23
  o.m13 = o.m10 * -o.m03 + o.m11 * -o.m13 + o.m12 * -o.m23
  o.m23 = o.m20 * -o.m03 + o.m21 * -o.m13 + o.m22 * -o.m23

proc invertOrthogonal*(m: Mat4): Mat4 {.inline.} =
  ## Invert the orthogonal 4x4 matrix `m`, storing the result in a new matrix.
  ##
  ## **Note**: This is a less expensive invert method that can be used if is known that a matrix is
  ## orthogonal.
  result.invertOrthogonal(m)

proc invert*(o: var Mat4, m: Mat4) =
  ## Invert the 4x4 matrix `m`, storing the result in the output matrix `o`.
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

proc invert*(m: Mat4): Mat4 {.inline.} =
  ## Invert the 4x4 m.m00trix `m`, storing the result in a new matrix.
  result.invert(m)

proc lookAt*(o: var Mat4, eye, target, up: Vec3) =
  ## Construct a 4x4 view matrix, storing the result in the output matrix `o`.
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

proc lookAt*(eye, target, up: Vec3): Mat4 {.inline.} =
  ## Construct a 4x4 view matrix, storing the result in a new matrix.
  result.setId
  result.lookAt(eye, target, up)

proc ortho*(o: var Mat4, left, right, bottom, top, near, far: float32) =
  ## Construct a 4x4 orthographic projection matrix, storing the result in the output matrix `o`.
  let
    x = right - left
    y = top - bottom
    z = far - near
  o.setId
  o.m00 = 2 / x
  o.m11 = 2 / y
  o.m22 = -2 / z
  o.m03 = (right + left) / -x
  o.m13 = (top + bottom) / -y
  o.m23 = (far + near) / -z

proc ortho*(left, right, bottom, top, near, far: float32): Mat4 {.inline.} =
  ## Construct a 4x4 orthographic projection matrix, storing the result in a new matrix.
  result.ortho(left, right, bottom, top, near, far)

proc perspective*(o: var Mat4, fovY, aspect, near, far: float32) =
  ## Construct a 4x4 perspective projection matrix, storing the result in the output matrix `o`.
  let
    f = 1 / tan(fovY / 2)
    z = near - far
  o.m00 = f * (1 / aspect)
  o.m11 = f
  o.m22 = (near + far) / z
  o.m32 = -1
  o.m23 = (near * far * 2) / z

proc perspective*(fovY, aspect, near, far: float32): Mat4 {.inline.} =
  ## Construct a 4x4 perspective projection matrix, storing the result in a new matrix.
  result.perspective(fovY, aspect, near, far)

