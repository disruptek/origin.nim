import std/algorithm
import std/math

import common

# Constructors

proc mat2*(): Mat2 {.inline.} =
  ## Initialize a 2x2 zero matrix.
  result.fill(0)

proc mat2*(n: float32): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix with each component all its main diagonal set to `n`.
  result[0] = n
  result[3] = n

proc mat2*(m: Mat2): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix from the components of another 2x2 matrix.
  m

proc mat2*(m: Mat3): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix from the upper 2x2 portion of the 3x3 matrix `m`.
  result[0..1] = m[0..1]
  result[2..3] = m[3..4]

proc mat2*(m: Mat4): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix from the upper 2x2 portion of the 4x4 matrix `m`.
  result[0..1] = m[0..1]
  result[2..3] = m[4..5]

proc mat2*(a, b: Vec2): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix from the 2D column vectors `a` and `b`.
  result[0..1] = a
  result[2..3] = b

proc mat2*(a, b, c, d: float32): Mat2 {.inline.} =
  ## Initialize a 2x2 matrix in column order from scalars.
  [a, b, c, d]

# Constants

const zero* = ## \
  ## A 2x2 zero matrix.
  mat2()

const id* = ## \
  # A 2x2 identity matrix.
  mat2(1)

# Operations

proc setId*(o: var Mat3) {.inline.} =
  ## Store a 2x2 identity matrix into the output matrix `o`.
  o.fill(0)
  o[0] = 1
  o[3] = 1

proc `*`*(m1, m2: Mat2): Mat2 =
  ## Multiply the 2x2 matrices `m1` by `m2`, storing the result in a new matrix.
  result[0] = m1[0]*m2[0] + m1[2]*m2[1]
  result[1] = m1[1]*m2[0] + m1[3]*m2[1]
  result[2] = m1[0]*m2[2] + m1[2]*m2[3]
  result[3] = m1[1]*m2[2] + m1[3]*m2[3]

proc `*=`*(o: var Mat2, m: Mat2) =
  ## Multiply the 2x2 matrices `o` by `m`, storing the result back into the output matrix `o`.
  o = o*m

proc column*(o: var Vec2, m: Mat2, index: range[0..1]) =
  ## Extract the 2D column vector at the given `index` from the 2x2 matrix `m`, storing the result
  ## in the output vector `o`.
  case index
  of 0: o[0..1] = m[0..1]
  of 1: o[0..1] = m[2..3]

proc column*(m: Mat2, index: range[0..1]): Vec2 =
  ## Extract the 2D column vector at the given `index` from the 2x2 matrix `m`, storing the result
  ## in a new vector.
  result.column(m, index)

proc `column=`*(o: var Mat2, m: Mat2, v: Vec2, index: range[0..1]) =
  ## Set the components of a column at the given `index` of the 2x2 matrix `m` from the vector `v`,
  ## storing the result in the output matrix `o`.
  o = m
  case index
  of 0: o[0..1] = v[0..1]
  of 1: o[2..3] = v[0..1]

proc `column=`*(m: Mat2, v: Vec2, index: range[0..1]): Mat2 =
  ## Set the components of a column at the given `index` of the 2x2 matrix `m` from the vector `v`,
  ## storing the result in a new matrix.
  result.`column=`(m, v, index)

proc rotationToVec2*(o: var Vec2, m: Mat2, axis: Axis2d) =
  ## Extract the 2D rotation along `axis` from the 2x2 matrix `m`, storing the result in the output
  ## vector `o`.
  case axis
  of Axis2d.X: o[0..1] = m[0..1]
  of Axis2d.Y: o[0..1] = m[2..3]

proc rotationToVec2*(m: Mat2, axis: Axis2d): Vec2 =
  ## Extract the 2D rotation along `axis` from the 2x2 matrix `m`, storing the result in a new
  ## vector.
  result.rotationToVec2(m, axis)

proc rotationFromVec2*(o: var Mat2, v: Vec2, axis: Axis2d) =
  ## Set the rotation components along `axis` of the 2x2 matrix `m` from the 2D vector `v`, storing
  ## the result in the output matrix `o`.
  case axis
  of Axis2d.X: o[0..1] = v[0..1]
  of Axis2d.Y: o[2..3] = v[0..1]

proc rotationFromVec2*(m: Mat2, v: Vec2, axis: Axis2d): Mat2 =
  ## Set the rotation components along `axis` of the 2x2 matrix `m` from the 2D vector `v`, storing
  ## the result in a new matrix.
  result = m
  result.rotationFromVec2(v, axis)

proc rotate*(o: var Mat2, m: Mat2, angle: float32, space: Space = Space.local) =
  ## Rotate the 2x2 matrix `m` by `angle`, storing the result in the output matrix `o`. `space` can
  ## be set to `Space.local` or `Space.world` to perform the rotation in local or world space.
  let
    s = angle.sin
    c = angle.cos
    t = mat2(c, -s, s, c)
  case space:
    of Space.local: o = o * t
    of Space.world: o = t * o

proc rotate*(m: Mat2, angle: float32, space: Space = Space.local): Mat2 =
  ## Rotate the 2x2 matrix `m` by 'angle`, storing the result in a new matrix. `space` can be set to
  ## `Space.local` or `Space.world` to perform the rotation in local or world space.
  result = m
  result.rotate(m, angle, space)

proc transpose*(o: var Mat2, m: Mat2) =
  ## Transpose the 2x2 matrix `m`, storing the result in the output matrix `o`.
  o = m
  swap(o[1], o[2])

proc transpose*(m: Mat2): Mat2 =
  ## Transpose the 3x3 matrix `m`, storing the result in a new matrix.
  result.transpose(m)

proc isOrthogonal*(m: Mat2): bool =
  ## Check if the 2x2 matrix `m` is orthogonal.
  m*m.transpose ~= id

proc trace*(m: Mat4): float32 =
  ## Calculate the trace of the 2x2 matrix `m`.
  m[0] + m[3]

proc isDiagonal*(m: Mat2): bool =
  ## Check if the 2x2 matrix `m` is a diagonal matrix.
  m[1] == 0 and m[2] == 0 and m[0] == m[3]

proc mainDiagonal*(o: var Vec2, m: Mat2) =
  ## Extract the main diagonal of the 2x2 matrix `m`, storing it in the 2D output vector `o`.
  o[0] = m[0]
  o[1] = m[3]

proc mainDiagonal*(m: Mat2): Vec2 =
  ## Extract the main diagonal of the 2x2 matrix `m`, storing it in a new 2D vector.
  result.mainDiagonal(m)

proc antiDiagonal*(o: var Vec2, m: Mat2) =
  ## Extract the anti-diagonal of the 2x2 matrix `m`, storing it in the 2D output vector `o`.
  o[0] = m[2]
  o[1] = m[1]

proc antiDiagonal*(m: Mat2): Vec2 =
  ## Extract the anti-diagonal of the 2x2 matrix `m`, storing it in a new 2D vector.
  result.antiDiagonal(m)

