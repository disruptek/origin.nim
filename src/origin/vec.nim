import std/math

import common

# Operations

proc `<`*(v1, v2: SomeVec): bool =
  ## Perform a component-wise less than comparison of the vectors `v1` and `v2`.
  ##
  ## **Note**: The system-defined template will allow `>` to be used as well.
  genComponentWiseBool(`<`, v1, v2)

proc `<=`*(v1, v2: SomeVec): bool {.inline.} =
  ## Perform a component-wise greater than comparison of the vectors `v1` and
  ## `v2`.
  ##
  ## **Note**: The system-defined template will allow `>=` to be used as well.
  genComponentWiseBool(`<=`, v1, v2)

proc sign*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Extract the sign of each component of vector `v`, storing the result in
  ## the output vector `o`.
  ##
  ## Each component becomes `-1` if it is less than zero, `0` if it is equal to
  ## zero, or `1` if it is greater than zero.
  for i, _ in o: o[i] = v[i].cmp(0).float

proc sign*[T: SomeVec](v: T): T {.inline.} =
  ## Extract the sign of each component of vector `v`, storing the result in
  ## a new vector.
  ##
  ## Each component becomes `-1` if it is less than zero, `0` if it is equal to
  ## zero, or `1` if it is greater than zero.
  result.sign(v)

proc fract*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Compute the fractional part of each component of vector `v`, storing the
  ## result in the output vector `o`.
  for i, _ in o: o[i] = v[i] - v[i].floor

proc fract*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the fractional part of each component of vector `v`, storing the
  ## result in a new vector.
  result.fract(v)

proc `*`*[T: SomeVec](v1, v2: T): T {.inline.} =
  ## Calculate the Hadamard product (component-wise vector multiplication) of
  ## vectors `v1` and `v2`, storing the result in a new vector.
  for i, _ in v1: result[i] = v1[i] * v2[i]

proc `*=`*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Calculate the Hadamard product (component-wise vector multiplication) of
  ## vectors `o` and `v`, storing the result back into vector `o`.
  for i, _ in o: o[i] *= v[i]

proc `*`*[T: SomeVec](v: T, scalar: float32): T {.inline.} =
  ## Scale vector `v` by `scalar`, storing the result in a new vector.
  for i, _ in v: result[i] = v[i] * scalar

proc `*=`*(o: var SomeVec, scalar: float32) {.inline.} =
  ## Scale vector `o` by `scalar`, storing the result back into vector `o`.
  for i, c in o: o[i] *= scalar

proc `/`*[T: SomeVec](v1, v2: T): T {.inline.} =
  ## Calculate the Hadamard quotient (component-wise vector division) of vectors
  ## `v1` and `v2`, storing the result in a new vector.
  for i, _ in v1: result[i] = if v2[i] == 0: 0.0 else: v1[i] / v2[i]

proc `/=`*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Calculate the Hadamard quotient (component-wise vector division) of vectors
  ## `o` and `v`, storing the result back into vector `o`.
  for i, _ in o: o[i] = if v[i] == 0: 0.0 else: o[i] / v[i]

proc `/`*[T: SomeVec](v: T, scalar: float32): T {.inline.} =
  ## Scale vector `v` by the inverse of `scalar`, storing the result in a new
  ## vector.
  ##
  ## **Note**: If `scalar` is zero, the result will be zero rather than
  ## undefined.
  for i, _ in v: result[i] = if scalar == 0: 0.0 else: v[i] / scalar

proc `/=`*(o: var SomeVec, scalar: float32) {.inline.} =
  ## Scale vector `o` by the inverse of `scalar`, storing the result back into
  ## the output vector `o`.
  ##
  ## **Note**: If `scalar` is zero, the result will be zero rather than
  ## undefined.
  for i, _ in o: o[i] = if scalar == 0: 0.0 else: o[i] / scalar

proc `^`*[T: SomeVec](o: var T, v: T, power: float32) {.inline.} =
  ## Raise each component of vector `v` to the power of `power`, storing the
  ## result in the output vector `o`.
  for i, _ in o: o[i] = v[i].pow(power)

proc `^`*[T: SomeVec](v: T, power: float32): T {.inline.} =
  ## Raise each component of vector `v` to the power of `power`, storing the
  ## result in a new vector.
  result.`^`(v, power)

proc dot*(v1, v2: SomeVec): float32 {.inline.} =
  ## Calculate the dot product of vectors `v1` and `v2`.
  for i, _ in v1: result += v1[i] * v2[i]

proc sqrt*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Calculate the square root of each component of vector `v`, storing the
  ## result in the output vector `o`.
  ##
  ## **Note**: If a component is negative, the result will be zero rather than
  ## undefined.
  for i, _ in o: o[i] = if v[i] < 0: 0.0 else: v[i].sqrt

proc sqrt*[T: SomeVec](v: T): T {.inline.} =
  ## Calculate the square root of each component of vector `v`, storing the
  ## result in a new vector.
  ##
  ## **Note**: If a component is negative, the result will be zero rather than
  ## undefined.
  result.sqrt(v)

proc lenSq*(v: SomeVec): float32 {.inline.} =
  ## Calculate the squared magnitude of vector `v`.
  ##
  ## **Note**: This can sometimes be used instead of the more expensive square
  ## root version (`len`), for example when comparing relative distances.
  for c in v: result += c^2

proc len*(v: SomeVec): float32 {.inline.} =
  ## Calculate the magnitude of vector `v`.
  ##
  ## **Note**: This is more expensive than the squared version (`lenSq`) as it
  ## involves a square root calculation. In some cases, the less expensive
  ## `lenSq` method can be used instead, for example when comparing relative
  ## distances.
  v.lenSq.sqrt

proc distSq*(v1, v2: SomeVec): float32 {.inline.} =
  ## Calculate the squared distance between vectors `v1` and `v2`.
  lenSq(v2-v1)

proc dist*(v1, v2: SomeVec): float32 {.inline.} =
  ## Calculate the distance between vectors `v1` and `v2`.
  distSq(v1, v2).sqrt

proc normalize*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Calculate the unit vector in the same direction as vector `v`, storing the
  ## result in the output vector `o`.
  let len = v.len
  o = v
  if len != 0: o *= 1/len

proc normalize*[T: SomeVec](v: T): T {.inline.} =
  ## Calculate the unit vector in the same direction as vector `v`, storing the
  ## result in a new vector.
  result.normalize(v)

proc round*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Round each component of vector `v` to the nearest integer, storing the
  ## result in the output vector `o`.
  for i, _ in o: o[i] = v[i].round

proc round*[T: SomeVec](v: T): T {.inline.} =
  ## Round each component of vector `v` to the nearest integer, storing the
  ## result in a new vector.
  result.round(v)

proc floor*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Maps each component of vector `v` to the greatest integer that is less than
  ## or equal to itself, storing the result in the output vector `o`.
  for i, _ in o: o[i] = v[i].floor

proc floor*[T: SomeVec](v: T): T {.inline.} =
  ## Maps each component of vector `v` to the greatest integer that is less than
  ## or equal to itself, storing the result in a new vector.
  result.floor(v)

proc ceil*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Maps each component of vector `v` to the least integer that is greater than
  ## or equal to itself, storing the result in the output vector `o`.
  for i, _ in o: o[i] = v[i].ceil

proc ceil*[T: SomeVec](v: T): T {.inline.} =
  ## Maps each component of vector `v` to the least integer that is greater than
  ## or equal to itself, storing the result in a new vector.
  result.ceil(v)

proc abs*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Calculate the absolute value of each component of vector `v`, storing the
  ## result in the output vector `o`.
  for i, _ in o: o[i] = v[i].abs

proc abs*[T: SomeVec](v: T): T {.inline.} =
  ## Calculate the absolute value of each component of vector `v`, storing the
  ## result in a new vector.
  result.abs(v)

proc min*[T: SomeVec](o: var T, v1, v2: T) {.inline.} =
  ## Retrieve the lesser of each component for vectors `v1` and `v2`, storing
  ## the result in the output vector `o`.
  for i, _ in o: o[i] = min(v1[i], v2[i])

proc min*[T: SomeVec](v1, v2: T): T {.inline.} =
  ## Retrieve the lesser of each component for vectors `v1` and `v2`, storing
  ## the result in a new vector.
  result.min(v1, v2)

proc max*[T: SomeVec](o: var T, v1, v2: T) {.inline.} =
  ## Retrieve the greater of each component for vectors `v1` and `v2`, storing
  ## the result in the output vector `o`.
  for i, _ in o: o[i] = max(v1[i], v2[i])

proc max*[T: SomeVec](v1, v2: T): T {.inline.} =
  ## Retrieve the greater of each component for vectors `v1` and `v2`, storing
  ## the result in a new vector.
  result.max(v1, v2)

proc `mod`*[T: SomeVec](o: var T, v: T, divisor: float32) {.inline.} =
  ## Compute the modulus of each component of vector `v` by `divisor`, storing
  ## the result in the output vector `o`.
  for i, _ in o: o[i] = v[i] mod divisor

proc `mod`*[T: SomeVec](v: T, divisor: float32): T {.inline.} =
  ## Compute the modulus of each component of vector `v` by `divisor`, storing
  ## the result in a new vector.
  result.mod(v, divisor)

proc sin*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Compute the sine of each component of vector `v`, storing the result in the
  ## output vector `o`.
  for i, _ in o: o[i] = v[i].sin

proc sin*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the sine of each component of vector `v`, storing the result in a
  ## new vector.
  result.sin(v)

proc cos*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Compute the cosine of each component of vector `v`, storing the result in
  ## the output vector `o`
  for i, _ in o: o[i] = v[i].cos

proc cos*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the cosine of each component of vector `v`, storing the result in a
  ## new vector.
  result.cos(v)

proc tan*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Compute the tangent of each component of vector `v`, storing the result in
  ## the output vector `o`.
  for i, _ in o: o[i] = v[i].tan

proc tan*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the tangent of each component of vector `v`, storing the result in
  ## a new vector.
  result.tan(v)

proc asin*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Compute the arcsine of each component of vector `v`, storing the result in
  ## the output vector `o`.
  for i, _ in o: o[i] = v[i].arcsin

proc asin*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the arcsine of each component of vector `v`, storing the result in
  ## a new vector.
  result.asin(v)

proc acos*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Compute the arccosine of each component of vector `v`, storing the result
  ## in the output vector `o`.
  for i, _ in o: o[i] = v[i].arccos

proc acos*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the arccosine of each component of vector `v`, storing the result
  ## in a new vector.
  result.acos(v)

proc atan*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Compute the arctangent of each component of vector `v`, storing the result
  ## in the output vector `o`.
  for i, _ in o: o[i] = v[i].arctan

proc atan*[T: SomeVec](v: T): T {.inline.} =
  ## Compute the arctangent of each component of vector `v`, storing the result
  ## in a new vector.
  result.atan(v)

proc radians*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Convert each component of vector `v` from degrees to radians, storing the
  ## result in the output vector `o`.
  for i, _ in o: o[i] = v[i] * degree

proc radians*[T: SomeVec](v: T): T {.inline.} =
  ## Convert each component of vector `v` from degrees to radians, storing the
  ## result in a new vector.
  result.radians(v)

proc degrees*[T: SomeVec](o: var T, v: T) {.inline.} =
  ## Convert each component of vector `v` from radians to degrees, storing the
  ## result in the output vector `o`.
  for i, _ in o: o[i] = v[i] * radian

proc degrees*[T: SomeVec](v: T): T {.inline.} =
  ## Convert each component of vector `v` from radians to degrees, storing the
  ## result in a new vector.
  result.degrees(v)

proc lerp*[T: SomeVec](o: var T, v1, v2: T, factor: float32) {.inline.} =
  ## Linearly interpolate between the values of each component in vectors `v1`
  ## and `v2` by `factor`, storing the result in the output vector `o`.
  for i, _ in o: o[i] = lerp(v1[i], v2[i], factor)

proc lerp*[T: SomeVec](v1, v2: T, factor: float32): T {.inline.} =
  ## Linearly interpolate between the values of each component in vectors `v1`
  ## and `v2` by `factor`, storing the result in a new vector.
  result.lerp(v1, v2, factor)

proc angle*(v1, v2: SomeVec): float32 {.inline.} =
  ## Compute the angle in radians between vectors `v1` and `v2`.
  let m = v1.len * v2.len
  if m == 0: 0f else: arccos(dot(v1, v2) / m)

proc sameDirection*(v1, v2: SomeVec, tolerance = 1e-5): bool {.inline.} =
  ## Check whether vectors `v1` and `v2` are the same direction within
  ## `tolerance`.
  dot(v1.normalize, v2.normalize) >= 1 - 1e-5

