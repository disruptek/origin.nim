import std/algorithm
import std/math

import common
import vec
import vec3
import mat3

# Constructors

proc mat4*(): Mat4 {.inline.} =
  ## Initialize a 4x4 zero matrix.
  result.fill(0)

proc mat4*(n: float32): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix with each component all its main diagonal set to `n`.
  result[0] = n
  result[5] = n
  result[10] = n
  result[15] = n

proc mat4*(m: Mat4): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix from the components of another 4x4 matrix.
  m

proc mat4*(m: Mat2): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix from the 2x2 matrix `m`. The upper 2x2 portion of the matrix is written
  ## from the components of `m`, and the remaining components along its main diagonal are set to 1.
  result[0..1] = m[0..1]
  result[4..5] = m[2..3]
  result[10] = 1
  result[15] = 1

proc mat4*(m: Mat3): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix from the 3x3 matrix `m`. The upper 3x3 portion of the matrix is written
  ## from the components of `m`, and the remaining component along its main diagonal is set to 1.
  result[0..2] = m[0..2]
  result[4..6] = m[3..5]
  result[8..10] = m[6..8]
  result[15] = 1

proc mat4*(a, b, c, d: Vec4): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix from the 4D column vectors `a`, `b`, `c`, and `d`.
  result[0..3] = a
  result[4..7] = b
  result[8..11] = c
  result[12..15] = d

proc mat4*(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p: float32): Mat4 {.inline.} =
  ## Initialize a 4x4 matrix in column order from scalars.
  [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p]

# Constants

const zero* = ## \
  ## A 4x4 zero matrix.
  mat4()

const id* = ## \
  ## A 4x4 identity matrix.
  mat4(1)

# Operations

proc setId*(o: var Mat4) {.inline.} =
  ## Store a 4x4 identity matrix into the output matrix `o`.
  o.fill(0)
  o[0] = 1
  o[5] = 1
  o[10] = 1
  o[15] = 1

proc `*`*(m1, m2: Mat4): Mat4 =
  ## Multiply the 4x4 matrices `m1` by `m2`, storing the result in a new matrix.
  result[0] = m1[0]*m2[0] + m1[4]*m2[1] + m1[8]*m2[2] + m1[12]*m2[3]
  result[1] = m1[1]*m2[0] + m1[5]*m2[1] + m1[9]*m2[2] + m1[13]*m2[3]
  result[2] = m1[2]*m2[0] + m1[6]*m2[1] + m1[10]*m2[2] + m1[14]*m2[3]
  result[3] = m1[3]*m2[0] + m1[7]*m2[1] + m1[11]*m2[2] + m1[15]*m2[3]
  result[4] = m1[0]*m2[4] + m1[4]*m2[5] + m1[8]*m2[6] + m1[12]*m2[7]
  result[5] = m1[1]*m2[4] + m1[5]*m2[5] + m1[9]*m2[6] + m1[13]*m2[7]
  result[6] = m1[2]*m2[4] + m1[6]*m2[5] + m1[10]*m2[6] + m1[14]*m2[7]
  result[7] = m1[3]*m2[4] + m1[7]*m2[5] + m1[11]*m2[6] + m1[15]*m2[7]
  result[8] = m1[0]*m2[8] + m1[4]*m2[9] + m1[8]*m2[10] + m1[12]*m2[11]
  result[9] = m1[1]*m2[8] + m1[5]*m2[9] + m1[9]*m2[10] + m1[13]*m2[11]
  result[10] = m1[2]*m2[8] + m1[6]*m2[9] + m1[10]*m2[10] + m1[14]*m2[11]
  result[11] = m1[3]*m2[8] + m1[7]*m2[9] + m1[11]*m2[10] + m1[15]*m2[11]
  result[12] = m1[0]*m2[12] + m1[4]*m2[13] + m1[8]*m2[14] + m1[12]*m2[15]
  result[13] = m1[1]*m2[12] + m1[5]*m2[13] + m1[9]*m2[14] + m1[13]*m2[15]
  result[14] = m1[2]*m2[12] + m1[6]*m2[13] + m1[10]*m2[14] + m1[14]*m2[15]
  result[15] = m1[3]*m2[12] + m1[7]*m2[13] + m1[11]*m2[14] + m1[15]*m2[15]

proc `*=`*(o: var Mat4, m: Mat4) =
  ## Multiply the 4x4 matrices `o` by `m`, storing the result back into the output matrix `o`.
  o = o*m

proc `*`*(o: var Vec4, m: Mat4, v: Vec4) =
  ## Multiply the 4x4 matrix `m` by the 4D vector `v`, storing the result in the output vector `o`.
  o[0] = m[0] * v[0] + m[4] * v[1] + m[8] * v[2] + m[12] * v[3]
  o[1] = m[1] * v[0] + m[5] * v[1] + m[9] * v[2] + m[13] * v[3]
  o[2] = m[2] * v[0] + m[6] * v[1] + m[10] * v[2] + m[14] * v[3]
  o[3] = m[3] * v[0] + m[7] * v[1] + m[11] * v[2] + m[15] * v[3]

proc `*`*(m: Mat4, v: Vec4): Vec4 =
  ## Multiply the 4x4 matrix `m` by the 4D vector `v`, storing the result in a new vector.
  result.`*`(m, v)

proc copyRotation*(o: var Mat4, m: Mat4) =
  ## Copy the 3x3 rotation portion of the 4x4 matrix `m` into the rotation portion of the 4x4 matrix
  ## `o`.
  o[0..2] = m[0..2]
  o[4..6] = m[4..6]
  o[8..10] = m[8..10]

proc copyRotation*(m: Mat4): Mat4 =
  ## Copy the 3x3 rotation portion of the 4x4 matrix `m` into the rotation portion of a new 4x4
  ## matrix. The remaining component along its main diagonal is set to 1.
  result.copyRotation(m)
  result[15] = 1

proc rotationToMat3*(o: var Mat3, m: Mat4) =
  ## Copy the 3x3 rotation portion of the 4x4 matrix `m` into the 3x3 matrix `o`.
  o[0..2] = m[0..2]
  o[3..5] = m[4..6]
  o[6..8] = m[8..10]

proc rotationToMat3*(m: Mat4): Mat3 =
  ## Copy the 3x3 rotation portion of the 4x4 matrix `m` into a new 3x3 matrix.
  result.rotationToMat3(m)

proc rotationFromMat3*(o: var Mat4, m: Mat3) =
  ## Copy the components of the 3x3 matrix `m` into the rotation portion of the 4x4 matrix `o`.
  o[0..2] = m[0..2]
  o[4..6] = m[3..5]
  o[8..10] = m[6..8]

proc rotationFromMat3*(m: Mat3): Mat4 =
  ## Copy the components of the 3x3 matrix `m` into the rotation portion of a new 4x4 matrix.
  result.rotationFromMat3(m)

proc normalizeRotation*(o: var Mat4, m: Mat4) =
  ## Normalize the columns of the 3x3 rotation portion of the 4x4 matrix `m`, storing the result in
  ## the 4x4 output matrix `o`.
  var
    x = vec3(m[0], m[1], m[2]).normalize
    y = vec3(m[4], m[5], m[6]).normalize
    z = vec3(m[8], m[9], m[10]).normalize
  o[0..2] = x[0..2]
  o[4..6] = y[0..2]
  o[8..10] = z[0..2]

proc normalizeRotation*(m: Mat4): Mat4 =
  ## Normalize the rotation portion of the 4x4 matrix `m`, storing the result in a new matrix.
  result = m
  result.normalizeRotation(m)

proc column*(o: var Vec4, m: Mat4, index: range[0..3]) =
  ## Extract the 4D column vector at the given `index` from the 4x4 matrix `m`, storing the result
  ## in the output vector `o`.
  case index
  of 0: o[0..3] = m[0..3]
  of 1: o[0..3] = m[4..7]
  of 2: o[0..3] = m[8..11]
  of 3: o[0..3] = m[12..15]

proc column*(m: Mat4, index: range[0..3]): Vec4 =
  ## Extract the 4D column vector at the given `index` from the 4x4 matrix `m`, storing the result
  ## in a new vector.
  result.column(m, index)

proc `column=`*(o: var Mat4, m: Mat4, v: Vec4, index: range[0..3]) =
  ## Set the components of a column at the given `index` of the 4x4 matrix `m` from the vector `v`,
  ## storing the result in the output matrix `o`.
  o = m
  case index
  of 0: o[0..3] = v[0..3]
  of 1: o[4..7] = v[0..3]
  of 2: o[8..11] = v[0..3]
  of 3: o[12..15] = v[0..3]

proc `column=`*(m: Mat4, v: Vec4, index: range[0..3]): Mat4 =
  ## Set the components of a column at the given `index` of the 4x4 matrix `m` from the vector `v`,
  ## storing the result in a new matrix.
  result.`column=`(m, v, index)

proc translation*(o: var Vec3, m: Mat4) =
  ## Extract the 3D translation vector from the 4x4 matrix `m`, storing the result in the output
  ## vector `o`.
  o[0..2] = m[12..14]

proc translation*(m: Mat4): Vec3 =
  ## Extract the 3D translation vector from the 4x4 matrix `m`, storing the result in a new vector.
  result.translation(m)

proc `translation=`*(o: var Mat4, m: Mat4, v: Vec3) =
  ## Set the translation components of the 4x4 matrix `m` from the vector `v`, storing the result in
  ## the output matrix `o`
  o.copyRotation(m)
  o[12..14] = v[0..2]
  o[15] = m[15]

proc `translation=`*(m: Mat4, v: Vec3): Mat4 =
  ## Set the translation components of the 4x4 matrix `m` from the vector `v`, storing the result in
  ## a new matrix.
  result.`translation=`(m, v)

proc translate*(o: var Mat4, m: Mat4, v: Vec3) =
  ## Translate the 4x4 matrix `m` by the 3D translation vector `v`, storing the result in the output
  ## matrix `o`.
  o[0] = m[0] + m[3] * v[0]
  o[1] = m[1] + m[3] * v[1]
  o[2] = m[2] + m[3] * v[2]
  o[3] = m[3]
  o[4] = m[4] + m[7] * v[0]
  o[5] = m[5] + m[7] * v[1]
  o[6] = m[6] + m[7] * v[2]
  o[7] = m[7]
  o[8] = m[8] + m[11] * v[0]
  o[9] = m[9] + m[11] * v[1]
  o[10] = m[10] + m[11] * v[2]
  o[11] = m[11]
  o[12] = m[12] + m[15] * v[0]
  o[13] = m[13] + m[15] * v[1]
  o[14] = m[14] + m[15] * v[2]
  o[15] = m[15]

proc translate*(m: Mat4, v: Vec3): Mat4 =
  ## Translate the 4x4 matrix `m` by the 3D translation vector `v`, storing the result in a new
  ## matrix.
  result.translate(m, v)

proc rotationToVec3*(o: var Vec3, m: Mat4, axis: Axis3d) =
  ## Extract the 3D rotation along `axis` from the 4x4 matrix `m`, storing the result in the output
  ## vector `o`.
  case axis
  of Axis3d.X: o[0..2] = m[0..2]
  of Axis3d.Y: o[0..2] = m[4..6]
  of Axis3d.Z: o[0..2] = m[8..10]

proc rotationToVec3*(m: Mat4, axis: Axis3d): Vec3 =
  ## Extract the 3D rotation along `axis` from the 4x4 matrix `m`, storing the result in a new
  ## vector.
  result.rotationToVec3(m, axis)

proc rotationFromVec3*(o: var Mat4, v: Vec3, axis: Axis3d) =
  ## Set the rotation components along `axis` of the 4x4 matrix `m` from the 3D vector `v`, storing
  ## the result in the output matrix `o`.
  case axis
  of Axis3d.X: o[0..2] = v[0..2]
  of Axis3d.Y: o[4..6] = v[0..2]
  of Axis3d.Z: o[8..10] = v[0..2]

proc rotationFromVec3*(m: Mat4, v: Vec3, axis: Axis3d): Mat4 =
  ## Set the rotation components along `axis` of the 4x4 matrix `m` from the 3D vector `v`, storing
  ## the result in a new matrix.
  result = m
  result.rotationFromVec3(v, axis)

proc rotate*(o: var Mat4, m: Mat4, v: Vec3, space: Space = Space.local) =
  ## Rotate the 4x4 matrix `m` by the vector of Euler angles `v`, storing the result in the output
  ## matrix `o`. `space` can be set to `Space.local` or `Space.world` to perform the rotation in
  ## local or world space.
  proc rotateAxis(o: var Mat3, m: Mat3, space: Space) =
    case space:
      of Space.local: o = o*m
      of Space.world: o = m*o
  var
    t = mat3(1)
    outMat3 = o.rotationToMat3
  let
    s = v.sin
    c = v.cos
  o = m
  t[0..1] = [c[2], s[2]]
  t[3..4] = [-s[2], c[2]]
  rotateAxis(outMat3, t, space)
  t[0..8] = [1f, 0, 0, 0, c[0], s[0], 0, -s[0], c[0]]
  rotateAxis(outMat3, t, space)
  t[0..8] = [c[1], 0, -s[1], 0, 1, 0, s[1], 0, c[1]]
  rotateAxis(outMat3, t, space)
  o.rotationFromMat3(outMat3)

proc rotate*(m: Mat4, v: Vec3, space: Space = Space.local): Mat4 =
  ## Rotate the matrix `m` by the vector of Euler angles `v`, storing the result in a new
  ## matrix. `space` can be set to `Space.local` or `Space.world` to perform the rotation in
  ## local or world space.
  result = m
  result.rotate(m, v, space)

proc scale*(o: var Vec3, m: Mat4) =
  ## Extract the 3D scale vector from the 4x4 matrix `m`, storing the result in the output
  ## vector `o`.
  o[0] = m.rotationToVec3(Axis3d.X).len
  o[1] = m.rotationToVec3(Axis3d.Y).len
  o[2] = m.rotationToVec3(Axis3d.Z).len

proc scale*(m: Mat4): Vec3 =
  ## Extract the 3D scale vector from the 4x4 matrix `m`, storing the result in a new vector.
  result.scale(m)

proc `scale=`*(o: var Mat4, m: Mat4, v: Vec3) =
  ## Set the scale of the 4x4 matrix `m` from the 3D vector `v`, storing the result in the output
  ## matrix `o`.
  o = m
  o[0] = v[0]
  o[5] = v[1]
  o[10] = v[2]

proc `scale=`*(m: Mat4, v: Vec3): Mat4 =
  ## Set the scale of the 4x4 matrix `m` from the 3D vector `v`, storing the result in a new matrix.
  result.`scale=`(m, v)

proc scale*(o: var Mat4, m: Mat4, v: Vec3) =
  ## Scale the 4x4 matrix `m` by the 3D vector `v`, storing the result in the output matrix `o`.
  o[0] = m[0] * v[0]
  o[1] = m[1] * v[1]
  o[2] = m[2] * v[2]
  o[3] = m[3]
  o[4] = m[4] * v[0]
  o[5] = m[5] * v[1]
  o[6] = m[6] * v[2]
  o[7] = m[7]
  o[8] = m[8] * v[0]
  o[9] = m[9] * v[1]
  o[10] = m[10] * v[2]
  o[11] = m[11]
  o[12] = m[12] * v[0]
  o[13] = m[13] * v[1]
  o[14] = m[14] * v[2]
  o[15] = m[15]

proc scale*(m: Mat4, v: Vec3): Mat4 =
  ## Scale the 4x4 matrix `m` by the 3D vector `v`, storing the result in a new matrix.
  result.scale(m, v)

proc transpose*(o: var Mat4, m: Mat4) =
  ## Transpose the 4x4 matrix `m`, storing the result in the output matrix `o`.
  o = m
  swap(o[1], o[4])
  swap(o[2], o[8])
  swap(o[3], o[12])
  swap(o[6], o[9])
  swap(o[7], o[13])
  swap(o[11], o[14])

proc transpose*(m: Mat4): Mat4 =
  ## Transpose the 4x4 matrix `m`, storing the result in a new matrix.
  result.transpose(m)

proc isOrthogonal*(m: Mat4): bool =
  ## Check if the 4x4 matrix `m` is orthogonal.
  m*m.transpose ~= id

proc orthoNormalize*(o: var Mat4, m: Mat4) =
  ## Orthonormalize the 4x4 matrix `m` using the Gram-Schmidt process, storing the result in the
  ## output matrix `o`.
  var
    x = m.rotationToVec3(Axis3d.X)
    y = m.rotationToVec3(Axis3d.Y)
    z = m.rotationToVec3(Axis3d.Z)
  echo y
  x.normalize(x)
  y.normalize(y - x * dot(y, x))
  z.cross(x, y)
  o.rotationFromVec3(x, Axis3d.X)
  o.rotationFromVec3(y, Axis3d.Y)
  o.rotationFromVec3(z, Axis3d.Z)

proc orthoNormalize*(m: Mat4): Mat4 =
  ## Orthonormalize the 4x4 matrix `m` using the Gram-Schmidt process, storing the result in a new
  ## matrix.
  result = m
  result.orthoNormalize(m)

proc trace*(m: Mat4): float32 =
  ## Calculate the trace of the 4x4 matrix `m`.
  m[0] + m[5] + m[10] + m[15]

proc isDiagonal*(m: Mat4): bool =
  ## Check if the 4x4 matrix `m` is a diagonal matrix.
  let x = default(array[4, float32])
  m[1..4] == x and m[6..9] == x and m[11..14] == x and
  m[0] == m[5] and m[5] == m[10] and m[10] == m[15]

proc mainDiagonal*(o: var Vec4, m: Mat4) =
  ## Extract the main diagonal of the 4x4 matrix `m`, storing it in the 4D output vector `o`.
  o[0] = m[0]
  o[1] = m[5]
  o[2] = m[10]
  o[3] = m[15]

proc mainDiagonal*(m: Mat4): Vec4 =
  ## Extract the main diagonal of the 4x4 matrix `m`, storing it in a new 4D vector.
  result.mainDiagonal(m)

proc antiDiagonal*(o: var Vec4, m: Mat4) =
  ## Extract the anti-diagonal of the 4x4 matrix `m`, storing it in the 4D output vector `o`.
  o[0] = m[12]
  o[1] = m[9]
  o[2] = m[6]
  o[3] = m[3]

proc antiDiagonal*(m: Mat4): Vec4 =
  ## Extract the anti-diagonal of the 4x4 matrix `m`, storing it in a new 4D vector.
  result.antiDiagonal(m)

proc determinant*(m: Mat4): float32 =
  ## Calculate the determinant of the 4x4 matrix `m`.
  m[0] * m[5] * m[10] * m[15] + m[0] * m[9] * m[14] * m[7] +
  m[0] * m[13] * m[6] * m[11] + m[4] * m[1] * m[14] * m[11] +
  m[4] * m[9] * m[2] * m[15] + m[4] * m[13] * m[10] * m[3] +
  m[8] * m[1] * m[6] * m[15] + m[8] * m[5] * m[14] * m[3] +
  m[8] * m[13] * m[2] * m[7] + m[12] * m[1] * m[10] * m[7] +
  m[12] * m[5] * m[2] * m[11] + m[12] * m[9] * m[6] * m[3] -
  m[0] * m[5] * m[14] * m[11] - m[0] * m[9] * m[6] * m[15] -
  m[0] * m[13] * m[10] * m[7] - m[4] * m[1] * m[10] * m[15] -
  m[4] * m[9] * m[14] * m[3] - m[4] * m[13] * m[2] * m[11] -
  m[8] * m[1] * m[14] * m[7] - m[8] * m[5] * m[2] * m[15] -
  m[8] * m[13] * m[6] * m[3] - m[12] * m[1] * m[6] * m[11] -
  m[12] * m[5] * m[10] * m[3] - m[12] * m[9] * m[2] * m[7]

proc invertOrthogonal*(o: var Mat4, m: Mat4) =
  ## Invert the orthogonal 4x4 matrix `m`, storing the result in the output matrix `o`.
  ##
  ## **Note**: This is a less expensive invert method that can be used if is known that a matrix is
  ## orthogonal.
  o = m
  swap(o[1], o[4])
  swap(o[2], o[8])
  swap(o[6], o[9])
  o[12] = o[0] * -o[12] + o[4] * -o[13] + o[8] * -o[14]
  o[13] = o[1] * -o[12] + o[5] * -o[13] + o[9] * -o[14]
  o[14] = o[2] * -o[12] + o[6] * -o[13] + o[10] * -o[14]

proc invertOrthogonal*(m: Mat4): Mat4 =
  ## Invert the orthogonal 4x4 matrix `m`, storing the result in a new matrix.
  ##
  ## **Note**: This is a less expensive invert method that can be used if is known that a matrix is
  ## orthogonal.
  result.invertOrthogonal(m)

proc invert*(o: var Mat4, m: Mat4) =
  ## Invert the 4x4 matrix `m`, storing the result in the output matrix `o`.
  let
    det = m.determinant
    ma = m[0]
    mb = m[1]
    mc = m[2]
    md = m[3]
    me = m[4]
    mf = m[5]
    mg = m[6]
    mh = m[7]
    mi = m[8]
    mj = m[9]
    mk = m[10]
    ml = m[11]
    mm = m[12]
    mn = m[13]
    mo = m[14]
    mp = m[15]
  if det.abs < 1e-5:
    raise newException(MatrixInvertError, "Matrix cannot be inverted.")
  o[0] = (mf*mk*mp+mj*mo*mh+mn*mg*ml-mf*mo*ml-mj*mg*mp-mn*mk*mh) / det
  o[1] = (mb*mo*ml+mj*mc*mp+mn*mk*md-mb*mk*mp-mj*mo*md-mn*mc*ml) / det
  o[2] = (mb*mg*mp+mf*mo*md+mn*mc*mh-mb*mo*mh-mf*mc*mp-mn*mg*md) / det
  o[3] = (mb*mk*mh+mf*mc*ml+mj*mg*md-mb*mg*ml-mf*mk*md-mj*mc*mh) / det
  o[4] = (me*mo*ml+mi*mg*mp+mm*mk*mh-me*mk*mp-mi*mo*mh-mm*mg*ml) / det
  o[5] = (ma*mk*mp+mi*mo*md+mm*mc*ml-ma*mo*ml-mi*mc*mp-mm*mk*md) / det
  o[6] = (ma*mo*mh+me*mc*mp+mm*mg*md-ma*mg*mp-me*mo*md-mm*mc*mh) / det
  o[7] = (ma*mg*ml+me*mk*md+mi*mc*mh-ma*mk*mh-me*mc*ml-mi*mg*md) / det
  o[8] = (me*mj*mp+mi*mn*mh+mm*mf*ml-me*mn*ml-mi*mf*mp-mm*mj*mh) / det
  o[9] = (ma*mn*ml+mi*mb*mp+mm*mj*md-ma*mj*mp-mi*mn*md-mm*mb*ml) / det
  o[10] = (ma*mf*mp+me*mn*md+mm*mb*mh-ma*mn*mh-me*mb*mp-mm*mf*md) / det
  o[11] = (ma*mj*mh+me*mb*ml+mi*mf*md-ma*mf*ml-me*mj*md-mi*mb*mh) / det
  o[12] = (me*mn*mk+mi*mf*mo+mm*mj*mg-me*mj*mo-mi*mn*mg-mm*mf*mk) / det
  o[13] = (ma*mj*mo+mi*mn*mc+mm*mb*mk-ma*mn*mk-mi*mb*mo-mm*mj*mc) / det
  o[14] = (ma*mn*mg+me*mb*mo+mm*mf*mc-ma*mf*mo-me*mn*mc-mm*mb*mg) / det
  o[15] = (ma*mf*mk+me*mj*mc+mi*mb*mg-ma*mj*mg-me*mb*mk-mi*mf*mc) / det

proc invert*(m: Mat4): Mat4 =
  ## Invert the 4x4 matrix `m`, storing the result in a new matrix.
  result.invert(m)

proc lookAt*(o: var Mat4, eye, target, up: Vec3) =
  ## Construct a 4x4 view matrix, storing the result in the output matrix `o`
  let
    a = normalize(target-eye)
    b = vec3(a[1] * up[2] - a[2] * up[1],
             a[2] * up[0] - a[0] * up[2],
             a[0] * up[1] - a[1] * up[0]).normalize
  o[0] = b[0]
  o[1] = b[1] * a[2] - b[2] * a[1]
  o[2] = -a[0]
  o[4] = b[1]
  o[5] = b[2] * a[0] - b[0] * a[2]
  o[6] = -a[1]
  o[8] = b[2]
  o[9] = b[0] * a[1] - b[1] * a[0]
  o[10] = -a[2]
  o[12] = o[0] * -eye[0] + o[4] * -eye[1] + o[8] * -eye[2] + o[12]
  o[13] = o[1] * -eye[0] + o[5] * -eye[1] + o[9] * -eye[2] + o[13]
  o[14] = o[2] * -eye[0] + o[6] * -eye[1] + o[10] * -eye[2] + o[14]
  o[15] = o[3] * -eye[0] + o[7] * -eye[1] + o[11] * -eye[2] + o[15]

proc lookAt*(eye, target, up: Vec3): Mat4 =
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
  o[0] = 2 / x
  o[5] = 2 / y
  o[10] = -2 / z
  o[12] = (right + left) / -x
  o[13] = (top + bottom) / -y
  o[14] = (far + near) / -z

proc ortho*(left, right, bottom, top, near, far: float32): Mat4 =
  ## Construct a 4x4 orthographic projection matrix, storing the result in a new matrix.
  result.ortho(left, right, bottom, top, near, far)

proc perspective*(o: var Mat4, fovY, aspect, near, far: float32) =
  ## Construct a 4x4 perspective projection matrix, storing the result in the output matrix `o`.
  let
    f = 1 / tan(fovY / 2)
    z = near - far
  o[0] = f * (1 / aspect)
  o[5] = f
  o[10] = (near + far) / z
  o[11] = -1
  o[14] = (near * far * 2) / z

proc perspective*(fovY, aspect, near, far: float32): Mat4 =
  ## Construct a 4x4 perspective projection matrix, storing the result in a new matrix.
  result.perspective(fovY, aspect, near, far)

