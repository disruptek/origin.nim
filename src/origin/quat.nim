import std/algorithm
import std/math
import std/random

import internal
import vec
import mat

type
  QuatStore*[N: static[int]] = array[N, float32]
  Quat* = QuatStore[4]

proc `$`*(q: Quat): string =
  ## Prints a quaternion readably.
  result = "["
  for i, c in q:
    result &= c.fmt
    if i < 3: result &= ", "
  result &= "]"

# Component accessors

template w*(q: Quat): float32 = q[0]
template x*(q: Quat): float32 = q[1]
template y*(q: Quat): float32 = q[2]
template z*(q: Quat): float32 = q[3]
template `w=`*(q: var Quat, n: float32) = q[0] = n
template `x=`*(q: var Quat, n: float32) = q[1] = n
template `y=`*(q: var Quat, n: float32) = q[2] = n
template `z=`*(q: var Quat, n: float32) = q[3] = n

# Constructors

proc quat*(): Quat {.inline.} =
  ## Initialize a zero quaternion.
  result.fill(0)

proc quat*(n: float32): Quat {.inline.} =
  ## Initialize a quaternion with the real part set to `n`.
  [n, 0, 0, 0]

proc quat*(w, x, y, z: float32): Quat {.inline.} =
  ## Initialize a quaternion with `w` as the real part and `x`, `y`, and `z` as the imaginary part.
  [w, x, y, z]

proc quat*(v: Vec3): Quat {.inline.} =
  ## Initialize a quaternion with the components of the 3D vector `v` as its imaginary part.
  [0f, v.x, v.y, v.z]

proc quat*(v: Vec4): Quat {.inline.} =
  ## Initialize a quaternion from the components of the 4D vector `v`.
  [v.x, v.y, v.z, v.w]

# Constants

const quat_zero* = ## \
  ## A zero quaternion.
  quat()

const quat_id* = ## \
  ## An identity quaternion.
  quat(1)

# Operations

proc rand*[T: Quat](o: var T, range = 0f..1f): var T {.inline.} =
  ## Randomize the components of the quaternion `o` to be within the range `range`, storing the
  ## result in the output quaternion `o`.
  for i, _ in o: o[i] = rand(range)
  result = o

proc rand*[T: Quat](t: typedesc[T], range = 0f..1f): T {.inline.} =
  ## Initialize a new quaternion with its components randomized to be within the range `range`.
  result.rand(range)

proc zero*[T: Quat](o: var T): var T {.inline.} =
  ## Set all components of the quaternion `o` to zero.
  o.fill(0)
  result = o

proc setId*[T: Quat](o: var T): var T {.inline.} =
  o.fill(0)
  o.w = 1
  result = o

proc `~=`*(a, b: Quat, tolerance = 1e-5): bool {.inline.} =
  ## Check if the quaternions `a` and `b` are approximately equal.
  genComponentWiseBool(`~=`, a, b, tolerance)

proc `+`*[T: Quat](o: var T, a, b: T): var T {.inline.} =
  ## Component-wise addition of the quaternions `a` and `b`, storing the result in the output
  ## quaternion `o`.
  for i, _ in o: o[i] = a[i] + b[i]
  result = o

proc `+`*[T: Quat](a, b: T): T {.inline.} =
  ## Component-wise addition of the quaternions `a` and `b`, storing the result in a new quaternion.
  result.`+`(a, b)

proc `-`*[T: Quat](o: var T, a, b: T): var T {.inline.} =
  ## Component-wise subtraction of the quaternions `a` and `b`, storing the result in the output
  ## quaternion `o`.
  for i, _ in o: o[i] = a[i] - b[i]
  result = o

proc `-`*[T: Quat](a, b: T): T {.inline.} =
  ## Component-wise subtraction of the quaternions `a` and `b`, storing the result in a new
  ## quaternion.
  result.`-`(a, b)

proc `-`*[T: Quat](o: var T): var T {.inline.} =
  ## Unary subtraction (negation) of the components of the quaternion `q`, storing the result in the
  ## output quaternion `o`.
  for i, _ in o: o[i] = -o[i]
  result = o

proc `-`*[T: Quat](q: T): T {.inline.} =
  ## Unary subtraction (negation) of the components of the quaternion `q`, storing the result in a
  ## new quaternion.
  result = q
  discard -result

proc `*`*[T: Quat](o: var T, a, b: T): var T {.inline.} =
  ## Multiply the quaternions `a` and `b`, storing the result in the output quaternion `o`.
  let
    a = a
    b = b
  o.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
  o.x = a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y
  o.y = a.w * b.y + a.y * b.w + a.z * b.x - a.x * b.z
  o.z = a.w * b.z + a.z * b.w + a.x * b.y - a.y * b.x
  result = o

proc `*`*[T: Quat](a, b: T): T {.inline.} =
  ## Multiply the quaternions `a` and `b`, storing the result in a new quaternion
  result.`*`(a, b)

proc `*`*[T: Quat](o: var T, q: T, scalar: float32): var T {.inline.} =
  ## Scale quaternion `q` by `scalar`, storing the result in the output quaternion `o`.
  for i, _ in o: o[i] = q[i] * scalar
  result = o

proc `*`*[T: Quat](q: T, scalar: float32): T {.inline.} =
  ## Scale quaternion `o` by `scalar`, storing the result back into quaternion `o`.
  result.`*`(q, scalar)

proc conjugate*[T: Quat](o: var T, q: T): var T {.inline.} =
  ## Calculate the conjugate of quaternion `q`, storing the result in the output quaternion `o`.
  o.w = q.w
  o.x = -q.x
  o.y = -q.y
  o.z = -q.z
  result = o

proc conjugate*[T: Quat](q: T): T {.inline.} =
  ## Calculate the conjugate of quaternion `q`, storing the result in a new quaternion.
  result.conjugate(q)

proc cross*[T: Quat](o: var T, a, b: T): var T {.inline.} =
  ## Calculate the cross product of quaternions `a` and `b`, storing the result in the output
  ## quaternion `o`.
  discard o.`*`(b * a.conjugate + a * b, 0.5)
  result = o

proc cross*[T: Quat](a, b: T): T {.inline.} =
  ## Calculate the cross product of quaternions `a` and `b`, storing the result in a new quaternion.
  result.cross(a, b)

proc lenSq*(q: Quat): float32 {.inline.} =
  ## Calculate the squared magnitude of quaternion `q`.
  for c in q: result += c^2

proc len*(q: Quat): float32 {.inline.} =
  ## Calculate the magnitude of quaternion `q`.
  q.lenSq.sqrt

proc normalize*[T: Quat](o: var T, q: T): var T {.inline.} =
  ## Normalize quaternion `q`, storing the result in the output quaternion `o`.
  let len = q.len
  if len != 0:
    result = o.`*`(q, 1/len)
  else:
    result = o.zero

proc normalize*[T: Quat](q: T): T {.inline.} =
  ## Normalize quaternion `q`, storing the result in a new quaternion.
  result.normalize(q)

proc dot*(a, b: Quat): float32 {.inline.} =
  ## Calculate the dot product of quaternions `a` and `b`.
  a.w * b.w + a.x * b.x + a.y * b.y + a.z * b.z

proc inverse*[T: Quat](o: var T, q: T): var T {.inline.} =
  ## Calculate the inverse of quaternion `q`, storing the result in the output quaternion `o`.
  discard o.conjugate(q)
  o.`*`(o, 1/q.lenSq)

proc inverse*[T: Quat](q: T): T {.inline.} =
  ## Calculate the inverse of quaternion `q`, storing the result in a new quaternion.
  result.inverse(q)

proc rotate*[T: Quat](o: var T, a, b: T, space = Space.local): var T {.inline.} =
  ## Rotate quaternion `a` by `b`, storing the result in the output quaternion `o`.
  case space
  of Space.local: o = a * b
  of Space.world: o = b * a
  o.normalize(o)

proc rotate*[T: Quat](a, b: T, space = Space.local): T {.inline.} =
  ## Rotate quaternion `a` by `b`, storing the result in a new quaternion.
  result.rotate(a, b, space)

proc rotateEuler*[T: Quat](o: var T, q: T, angle: Vec3, space = Space.local): var T {.inline.} =
  ## Rotate quaternion `q` by the vector of Euler angles `angle`, storing the result in the output
  ## quaternion `o`.
  let
    v = angle * 0.5
    s = v.sin
    c = v.cos
  o.w = c.x * c.y * c.z - s.x * s.y * s.z
  o.x = s.x * c.y * c.z + c.x * s.y * s.z
  o.y = c.x * s.y * c.z - s.x * c.y * s.z
  o.z = s.x * s.y * c.z + c.x * c.y * s.z
  o.rotate(q, o)

proc rotateEuler*[T: Quat](q: T, angle: Vec3, space = Space.local): T {.inline.} =
  ## Rotate quaternion `q` by the vector of Euler angles `angle`, storing the result in a new
  ## quaternion.
  result.rotateEuler(q, angle, space)

proc toEulerAngle*[T: Vec3](o: var T, q: Quat): var T {.inline.} =
  ## Convert the quaternion `q` to a 3D vector of Euler angles, storing the result in the output
  ## vector `o`.
  let
    sinr_cosp = (q.w * q.x + q.y * q.z) * 2
    cosr_cosp = 1 - (q.x ^ 2 + q.y ^ 2) * 2
    sin_p = (q.w * q.y - q.z * q.x) * 2
    siny_cosp = (q.w * q.z + q.x * q.y) * 2
    cosy_cosp = 1 - (q.y ^ 2 + q.z ^ 2) * 2
  o.x = arctan2(sinr_cosp, cosr_cosp)
  o.y = if sin_p.abs >= 1: Pi/2 * sin_p.cmp(0).float else: sin_p.arcsin
  o.z = arctan2(siny_cosp, cosy_cosp)
  result = o

proc toEulerAngle*(q: Quat): Vec3 {.inline.} =
  ## Convert the quaternion `q` to a 3D vector of Euler angles, storing the result in a new vector.
  result.toEulerAngle(q)

proc fromAxisAngle*[T: Quat](o: var T, axis: Vec3, angle: float32): var T {.inline.} =
  ## Convert an axis angle from the 3D vector `axis` and `angle`, to a quaternion, storing the
  ## result in the output quaternion `o`.
  let
    halfAngle = angle * 0.5
    s = halfAngle.sin
    c = halfAngle.cos
  o.w = c
  o.x = axis.x * s
  o.y = axis.y * s
  o.z = axis.z * s
  result = o

proc fromAxisAngle*(axis: Vec3, angle: float32): Quat {.inline.} =
  ## Convert an axis angle from the 3D vector `axis` and `angle`, to a quaternion, storing the
  ## result in the output quaternion `o`.
  result.fromAxisAngle(axis, angle)

proc toVec3*[T: Vec3](o: var T, q: Quat): var T {.inline.} =
  ## Extract the imaginary part of the quaternion `q` into a 3D vector, storing the result in the
  ## output vector `o`.
  o.x = q.x
  o.y = q.y
  o.z = q.z
  result = o

proc toVec3*(q: Quat): Vec3 {.inline.} =
  ## Extract the imaginary part of the quaternion `q` into a 3D vector, storing the result in a new
  ## vector.
  result.toVec3(q)

proc toVec4*[T: Vec4](o: var T, q: Quat): var T {.inline.} =
  ## Extract the components of the quaternion `q` into a 4D vector, storing the result in the output
  ## vector `o`.
  o.x = q.w
  o.y = q.x
  o.z = q.y
  o.w = q.z
  result = o

proc toVec4*(q: Quat): Vec4 {.inline.} =
  ## Extract the components of the quaternion `q` into a 4D vector, storing the result in a new
  ## vector.
  result.toVec4(q)

proc toMat3*[T: Mat3](o: var T, q: Quat): var T {.inline.} =
  ## Convert the quaternion `q` to a 3x3 rotation matrix, storing the result in the output matrix
  ## `o`.
  let
    tmp = 2 / q.lenSq
    s = vec3(q.x * tmp, q.y * tmp, q.z * tmp)
    a = vec3(q.x * s.x, q.x * s.y, q.x * s.z)
    b = vec3(q.y * s.y, q.y * s.z, q.z * s.z)
    c = vec3(q.w * s.x, q.w * s.y, q.w * s.z)
  o.m00 = 1 - (b.x + b.z)
  o.m10 = a.y + c.z
  o.m20 = a.z - c.y
  o.m01 = a.y - c.z
  o.m11 = 1 - (a.x + b.z)
  o.m21 = b.y + c.x
  o.m02 = a.z + c.y
  o.m12 = b.z - c.x
  o.m22 = 1 - (a.x + b.x)
  result = o

proc toMat3*(q: Quat): Mat3 {.inline.} =
  ## Convert the quaternion `q` to a 3x3 rotation matrix, storing the result in a new matrix`.
  result.toMat3(q)

proc toMat4*[T: Mat4](o: var T, q: Quat): var T {.inline.} =
  ## Convert the quaternion `q` to a 4x4 matrix, storing the result in the output matrix `o`.
  let
    tmp = 2 / q.lenSq
    s = vec3(q.x * tmp, q.y * tmp, q.z * tmp)
    a = vec3(q.x * s.x, q.x * s.y, q.x * s.z)
    b = vec3(q.y * s.y, q.y * s.z, q.z * s.z)
    c = vec3(q.w * s.x, q.w * s.y, q.w * s.z)
  o.m00 = 1 - (b.x + b.z)
  o.m10 = a.y + c.z
  o.m20 = a.z - c.y
  o.m30 = 0
  o.m01 = a.y - c.z
  o.m11 = 1 - (a.x + b.z)
  o.m21 = b.y + c.x
  o.m31 = 0
  o.m02 = a.z + c.y
  o.m12 = b.z - c.x
  o.m22 = 1 - (a.x + b.x)
  o.m32 = 0
  o.m03 = 0
  o.m13 = 0
  o.m23 = 0
  o.m33 = 1
  result = o

proc toMat4*(q: Quat): Mat4 {.inline.} =
  ## Convert the quaternion `q` to a 4x4 matrix, storing the result in a new matrix.
  result.toMat4(q)

proc fromMat*[T: Quat](o: var T, m: Mat3 or Mat4): var T =
  ## Convert the 3x3 or 4x4 matrix `m` to a quaternion, storing the result in the output quaternion
  ## `o`.
  let
    rx = sqrt(m.m00^2 + m.m10^2 + m.m20^2)
    ry = sqrt(m.m01^2 + m.m11^2 + m.m21^2)
    rz = sqrt(m.m02^2 + m.m12^2 + m.m22^2)
    n00 = m.m00 / rx
    n10 = m.m10 / rx
    n20 = m.m20 / rx
    n01 = m.m01 / ry
    n11 = m.m11 / ry
    n21 = m.m21 / ry
    n02 = m.m02 / rz
    n12 = m.m12 / rz
    n22 = m.m22 / rz
    trace = n00 + n11 + n22 + 1
    col1 = n00 - n11 - n22 + 1
    col2 = n11 - n00 - n22 + 1
    col3 = n22 - n00 - n11 + 1
  var s = 0f
  if trace > 0:
    s = 0.5 / trace.sqrt
    o.w = 0.25 / s
    o.x = (n21 - n12) * s
    o.y = (n02 - n20) * s
    o.z = (n10 - n01) * s
  elif col1 >= col2 and col1 >= col3:
    s = 0.5 / col1.sqrt
    o.w = (n21 - n12) * s
    o.x = 0.25 / s
    o.y = (n10 + n01) * s
    o.z = (n02 + n20) * s
  elif col2 >= col1 and col2 >= col3:
    s = 0.5 / col2.sqrt
    o.w = (n02 - n20) * s
    o.x = (n01 + n10) * s
    o.y = 0.25 / s
    o.z = (n12 + n21) * s
  else:
    s = 0.5 / col3.sqrt
    o.w = (n10 - n01) * s
    o.x = (n02 + n20) * s
    o.y = (n12 + n21) * s
    o.z = 0.25 / s
  result = o

proc fromMat*(m: Mat3 or Mat4): Quat {.inline.} =
  ## Convert the 3x3 or 4x4 matrix `m` to a quaternion, storing the result in a new quaternion.
  result.fromMat(m)

proc slerp*[T: Quat](o: var T, a, b: T, factor: float32): var T =
  ## Performs a spherical linear interpolation between the quaternions `a` and `b` by `factor`,
  ## storing the result in the output quaternion `o`.
  var
    dot = dot(a, b)
    b = b
  result = o
  if dot < 0:
    discard -b
    dot = -dot
  if dot.abs > 0.9995:
    o.w = lerp(a.w, b.w, factor)
    o.x = lerp(a.x, b.x, factor)
    o.y = lerp(a.y, b.y, factor)
    o.z = lerp(a.z, b.z, factor)
  else:
    let
      angle = dot.arccos
      sinAngle = angle.sin
      scale1 = sin(angle * (1 - factor)) / sinAngle
      scale2 = sin(factor * angle) / sinAngle
    o.w = a.w * scale1 + b.w * scale2
    o.x = a.x * scale1 + b.x * scale2
    o.y = a.y * scale1 + b.y * scale2
    o.z = a.z * scale1 + b.z * scale2

proc slerp*[T: Quat](a, b: T, factor: float32): T {.inline.} =
  ## Performs a spherical linear interpolation between the quaternions `a` and `b` by `factor`,
  ## storing the result in a new quaternion.
  result.slerp(a, b, factor)

proc orient*[T: Quat](o: var T, space = Space.local,
                      axes_angles: varargs[(Axis3d, float32)]): var T {.inline.} =
  ## Compute a right to left composite rotation of the `axis_angles` specification, storing the
  ## result in the output quaternion `o`.
  var q = quat(1)
  var v = vec3()
  result = o
  discard o.setId
  for (axis, angle) in axes_angles:
    case axis
    of Axis3d.X:
      v.x = 1; v.y = 0; v.z = 0
    of Axis3d.Y:
      v.x = 0; v.y = 1; v.z = 0
    of Axis3d.Z:
      v.x = 0; v.y = 0; v.z = 1
    # Make the individual quaternion rotation to represent the axis/angle representation.
    discard q.fromAxisAngle(v, angle)
    # Update the accumulating rotation, carefully minding the multiplication order to ensure the
    # final rotation we compute applies in right-to-left order.
    # Note: That means the order for this multiply should be total <- total * current, because
    # we're using a reduction-like pass to associate left to right multiplications. But, since we're
    # keeping the ultimate order of the applications the same as the argument order, the final
    # rotation applies right to left.
    case space
    of Space.local: o = q * o
    of Space.world: o = o * q
    # Ensure it is normalized for the next concatenation.
    discard o.normalize(o)

proc orient*(space = Space.local, axes_angles: varargs[(Axis3d, float32)]): Quat {.inline.} =
  ## Compute a right to left composite rotation of the `axis_angles` specification, storing the
  ## result in a new quaternion.
  result.orient(space, axes_angles)

