import std/algorithm
import std/math

import common
import vec
import vec2
import mat2

# Constructors

proc mat3*(): Mat3 {.inline.} =
  ## Initialize a 3x3 zero matrix.
  result.fill(0)

proc mat3*(n: float32): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix with each component all its main diagonal set to `n`.
  result[0] = n
  result[4] = n
  result[8] = n

proc mat3*(m: Mat3): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix from the components of another 3x3 matrix.
  m

proc mat3*(m: Mat2): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix from the 2x2 matrix `m`. The upper 2x2 portion of the matrix is written
  ## from the components of `m`, and the remaining component along its main diagonal is set to 1.
  result[0..1] = m[0..1]
  result[3..4] = m[2..3]
  result[8] = 1

proc mat3*(m: Mat4): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix from the upper 3x3 portion of the 4x4 matrix `m`.
  result[0..2] = m[0..2]
  result[3..5] = m[4..6]
  result[6..8] = m[8..10]

proc mat3*(a, b, c: Vec3): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix from the 3D column vectors `a`, `b`, and `c`.
  result[0..2] = a
  result[3..5] = b
  result[6..8] = c

proc mat3*(a, b, c, d, e, f, g, h, i: float32): Mat3 {.inline.} =
  ## Initialize a 3x3 matrix in column order from scalars.
  [a, b, c, d, e, f, g, h, i]

# Constants

const zero* = ## \
  ## A 3x3 zero matrix.
  mat3()

const id* = ## \
  ## A 3x3 identity matrix.
  mat3(1)

# Operations

proc setId*(o: var Mat3) {.inline.} =
  ## Store a 3x3 identity matrix into the output matrix `o`.
  o.fill(0)
  o[0] = 1
  o[4] = 1
  o[8] = 1

proc `*`*(m1, m2: Mat3): Mat3 =
  ## Multiply the 3x3 matrices `m1` by `m2`, storing the result in a new matrix.
  result[0] = m1[0]*m2[0] + m1[3]*m2[1] + m1[6]*m2[2]
  result[1] = m1[1]*m2[0] + m1[4]*m2[1] + m1[7]*m2[2]
  result[2] = m1[2]*m2[0] + m1[5]*m2[1] + m1[8]*m2[2]
  result[3] = m1[0]*m2[3] + m1[3]*m2[4] + m1[6]*m2[5]
  result[4] = m1[1]*m2[3] + m1[4]*m2[4] + m1[7]*m2[5]
  result[5] = m1[2]*m2[3] + m1[5]*m2[4] + m1[8]*m2[5]
  result[6] = m1[0]*m2[6] + m1[3]*m2[7] + m1[6]*m2[8]
  result[7] = m1[1]*m2[6] + m1[4]*m2[7] + m1[7]*m2[8]
  result[8] = m1[2]*m2[6] + m1[5]*m2[7] + m1[8]*m2[8]

proc `*=`*(o: var Mat3, m: Mat3) =
  ## Multiply the 3x3 matrices `o` by `m`, storing the result back into the output matrix `o`.
  o = o*m

proc `*`*(o: var Vec3, m: Mat3, v: Vec3) =
  ## Multiply the 3x3 matrix `m` by the 3D vector `v`, storing the result in the output vector `o`.
  o[0] = m[0] * v[0] + m[3] * v[1] + m[6] * v[2]
  o[1] = m[1] * v[0] + m[4] * v[1] + m[7] * v[2]
  o[2] = m[2] * v[0] + m[5] * v[1] + m[8] * v[2]

proc `*`*(m: Mat3, v: Vec3): Vec3 =
  ## Multiply the 3x3 matrix `m` by the 3D vector `v`, storing the result in a new vector.
  result.`*`(m, v)

proc copyRotation*(o: var Mat3, m: Mat3) =
  ## Copy the 2x2 rotation portion of the 3x3 matrix `m` into the rotation portion of the 3x3 matrix
  ## `o`.
  o[0..1] = m[0..1]
  o[3..4] = m[2..3]

proc copyRotation*(m: Mat3): Mat3 =
  ## Copy the 2x2 rotation portion of the 3x3 matrix `m` into the rotation portion of a new 3x3
  ## matrix. The remaining component along its main diagonal is set to 1.
  result.copyRotation(m)
  result[8] = 1

proc rotationToMat2*(o: var Mat2, m: Mat3) =
  ## Copy the 2x2 rotation portion of the 3x3 matrix `m` into the 2x2 matrix `o`.
  o[0..1] = m[0..1]
  o[2..3] = m[3..4]

proc rotationToMat2*(m: Mat3): Mat2 =
  ## Copy the 2x2 rotation portion of the 3x3 matrix `m` into a new 2x2 matrix.
  result.rotationToMat2(m)

proc rotationFromMat2*(o: var Mat3, m: Mat2) =
  ## Copy the components of the 2x2 matrix `m` into the rotation portion of the 3x3 matrix `o`.
  o[0..1] = m[0..1]
  o[3..4] = m[2..3]

proc rotationFromMat2*(m: Mat2): Mat3 =
  ## Copy the components of the 2x2 matrix `m` into the rotation portion of a new 3x3 matrix.
  result.rotationFromMat2(m)

proc normalizeRotation*(o: var Mat3, m: Mat3) =
  ## Normalize the columns of the 2x2 rotation portion of the 3x3 matrix `m`, storing the result in
  ## the 3x3 output matrix `o`.
  var
    x = vec2(m[0], m[1]).normalize
    y = vec2(m[2], m[3]).normalize
  o[0..1] = x[0..1]
  o[2..3] = y[0..1]

proc normalizeRotation*(m: Mat3): Mat3 =
  ## Normalize the rotation portion of the 3x3 matrix `m`, storing the result in a new matrix.
  result = m
  result.normalizeRotation(m)

proc column*(o: var Vec3, m: Mat3, index: range[0..2]) =
  ## Extract the 3D column vector at the given `index` from the 3x3 matrix `m`, storing the result
  ## in the output vector `o`.
  case index
  of 0: o[0..2] = m[0..2]
  of 1: o[0..2] = m[3..5]
  of 2: o[0..2] = m[6..8]

proc column*(m: Mat3, index: range[0..2]): Vec3 =
  ## Extract the 3D column vector at the given `index` from the 3x3 matrix `m`, storing the result
  ## in a new vector.
  result.column(m, index)

proc `column=`*(o: var Mat3, m: Mat3, v: Vec3, index: range[0..2]) =
  ## Set the components of a column at the given `index` of the 3x3 matrix `m` from the vector `v`,
  ## storing the result in the output matrix `o`.
  o = m
  case index
  of 0: o[0..2] = v[0..2]
  of 1: o[3..5] = v[0..2]
  of 2: o[6..8] = v[0..2]

proc `column=`*(m: Mat3, v: Vec3, index: range[0..2]): Mat3 =
  ## Set the components of a column at the given `index` of the 3x3 matrix `m` from the vector `v`,
  ## storing the result in a new matrix.
  result.`column=`(m, v, index)

proc translation*(o: var Vec2, m: Mat3) =
  ## Extract the 2D translation vector from the 3x3 matrix `m`, storing the result in the output
  ## vector `o`.
  o[0..1] = m[6..7]

proc translation*(m: Mat3): Vec2 =
  ## Extract the 2D translation vector from the 3x3 matrix `m`, storing the result in a new vector.
  result.translation(m)

proc `translation=`*(o: var Mat3, m: Mat3, v: Vec2) =
  ## Set the translation components of the 3x3 matrix `m` from the vector `v`, storing the result in
  ## the output matrix `o`
  o.copyRotation(m)
  o[6..7] = v[0..1]
  o[8] = m[8]

proc `translation=`*(m: Mat3, v: Vec2): Mat3 =
  ## Set the translation components of the 3x3 matrix `m` from the vector `v`, storing the result in
  ## a new matrix.
  result.`translation=`(m, v)

proc translate*(o: var Mat3, m: Mat3, v: Vec2) =
  ## Translate the 3x3 matrix `m` by the 2D translation vector `v`, storing the result in the output
  ## matrix `o`.
  o[0] = m[0] + m[2] * v[0]
  o[1] = m[1] + m[2] * v[1]
  o[2] = m[2]
  o[3] = m[3] + m[5] * v[0]
  o[4] = m[4] + m[5] * v[1]
  o[5] = m[5]
  o[6] = m[6] + m[8] * v[0]
  o[7] = m[7] + m[8] * v[1]
  o[8] = m[8]

proc translate*(m: Mat3, v: Vec2): Mat3 =
  ## Translate the 3x3 matrix `m` by the 2D translation vector `v`, storing the result in a new
  ## matrix.
  result.translate(m, v)

proc rotationToVec2*(o: var Vec2, m: Mat3, axis: Axis2d) =
  ## Extract the 2D rotation along `axis` from the 3x3 matrix `m`, storing the result in the output
  ## vector `o`.
  case axis
  of Axis2d.X: o[0..1] = m[0..1]
  of Axis2d.Y: o[0..1] = m[3..4]

proc rotationToVec2*(m: Mat3, axis: Axis2d): Vec2 =
  ## Extract the 2D rotation along `axis` from the 3x3 matrix `m`, storing the result in a new
  ## vector.
  result.rotationToVec2(m, axis)

proc rotationFromVec2*(o: var Mat3, v: Vec2, axis: Axis2d) =
  ## Set the rotation components along `axis` of the 3x3 matrix `m` from the 2D vector `v`, storing
  ## the result in the output matrix `o`.
  case axis
  of Axis2d.X: o[0..1] = v[0..1]
  of Axis2d.Y: o[3..4] = v[0..1]

proc rotationFromVec2*(m: Mat3, v: Vec2, axis: Axis2d): Mat3 =
  ## Set the rotation components along `axis` of the 3x3 matrix `m` from the 2D vector `v`, storing
  ## the result in a new matrix.
  result = m
  result.rotationFromVec2(v, axis)

proc rotate*(o: var Mat3, m: Mat3, angle: float32, space: Space = Space.local) =
  ## Rotate the 3x3 matrix `m` by `angle`, storing the result in the output matrix `o`. `space` can
  ## be set to `Space.local` or `Space.world` to perform the rotation in local or world space.
  let
    s = angle.sin
    c = angle.cos
    t = mat2(c, -s, s, c)
  var outMat2 = o.rotationToMat2
  case space:
    of Space.local: outMat2 = outMat2 * t
    of Space.world: outMat2 = t * outMat2
  o = m
  o.rotationFromMat2(outMat2)

proc rotate*(m: Mat3, angle: float32, space: Space = Space.local): Mat3 =
  ## Rotate the 3x3 matrix `m` by 'angle`, storing the result in a new matrix. `space` can be set to
  ## `Space.local` or `Space.world` to perform the rotation in local or world space.
  result = m
  result.rotate(m, angle, space)

proc scale*(o: var Vec2, m: Mat3) =
  ## Extract the 2D scale vector from the 3x3 matrix `m`, storing the result in the output
  ## vector `o`.
  o[0] = m.rotationToVec2(Axis2d.X).len
  o[1] = m.rotationToVec2(Axis2d.Y).len

proc scale*(m: Mat3): Vec2 =
  ## Extract the 2D scale vector from the 3x3 matrix `m`, storing the result in a new vector.
  result.scale(m)

proc `scale=`*(o: var Mat3, m: Mat3, v: Vec2) =
  ## Set the scale of the 3x3 matrix `m` from the 2D vector `v`, storing the result in the output
  ## matrix `o`.
  o = m
  o[0] = v[0]
  o[4] = v[1]

proc `scale=`*(m: Mat3, v: Vec2): Mat3 =
  ## Set the scale of the 3x3 matrix `m` from the 2D vector `v`, storing the result in a new matrix.
  result.`scale=`(m, v)

proc scale*(o: var Mat3, m: Mat3, v: Vec2) =
  ## Scale the 3x3 matrix `m` by the 2D vector `v`, storing the result in the output matrix `o`.
  o[0] = m[0] * v[0]
  o[1] = m[1] * v[1]
  o[2] = m[2]
  o[3] = m[3] * v[0]
  o[4] = m[4] * v[1]
  o[5] = m[5]
  o[6] = m[6] * v[0]
  o[7] = m[7] * v[1]
  o[8] = m[8]

proc scale*(m: Mat3, v: Vec2): Mat3 =
  ## Scale the 3x3 matrix `m` by the 2D vector `v`, storing the result in a new matrix.
  result.scale(m, v)

proc transpose*(o: var Mat3, m: Mat3) =
  ## Transpose the 3x3 matrix `m`, storing the result in the output matrix `o`.
  o = m
  swap(o[1], o[3])
  swap(o[2], o[6])
  swap(o[5], o[7])

proc transpose*(m: Mat3): Mat3 =
  ## Transpose the 3x3 matrix `m`, storing the result in a new matrix.
  result.transpose(m)

proc isOrthogonal*(m: Mat3): bool =
  ## Check if the 3x3 matrix `m` is orthogonal.
  m*m.transpose ~= id

proc trace*(m: Mat3): float32 =
  ## Calculate the trace of the 3x3 matrix `m`.
  m[0] + m[4] + m[8]

proc isDiagonal*(m: Mat3): bool =
  ## Check if the 3x3 matrix `m` is a diagonal matrix.
  let x = default(array[3, float32])
  m[1..3] == x and m[5..7] == x and m[0] == m[4] and m[4] == m[8]

proc mainDiagonal*(o: var Vec3, m: Mat3) =
  ## Extract the main diagonal of the 3x3 matrix `m`, storing it in the 3D output vector `o`.
  o[0] = m[0]
  o[1] = m[4]
  o[2] = m[8]

proc mainDiagonal*(m: Mat3): Vec3 =
  ## Extract the main diagonal of the 3x3 matrix `m`, storing it in a new 3D vector.
  result.mainDiagonal(m)

proc antiDiagonal*(o: var Vec3, m: Mat3) =
  ## Extract the anti-diagonal of the 3x3 matrix `m`, storing it in the 3D output vector `o`.
  o[0] = m[6]
  o[1] = m[4]
  o[2] = m[2]

proc antiDiagonal*(m: Mat3): Vec3 =
  ## Extract the anti-diagonal of the 3x3 matrix `m`, storing it in a new 3D vector.
  result.antiDiagonal(m)

