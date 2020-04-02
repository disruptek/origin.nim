import std/algorithm
import std/math
import std/random

import internal

type
  Vec*[N: static[int]] = object
    data*: Storage[N]
  Vec2* = Vec[2]
  Vec3* = Vec[3]
  Vec4* = Vec[4]

Vec2.genAccessors x, y
Vec3.genAccessors x, y, z
Vec4.genAccessors x, y, z, w

proc `$`*(v: Vec): string =
  result = "["
  for i, c in v:
    result &= c.fmt
    if i < v.N-1: result &= ", "
  result &= "]"

# Constructors

proc vec2*(): Vec2 {.inline.} = discard
proc vec2*(n: float32): Vec2 {.inline.} = result.data.fill(n)
proc vec2*(v: Vec): Vec2 {.inline.} = result[0..1] = v[0..1]
proc vec2*(x, y: float32): Vec2 {.inline.} = result.data = [x, y]
proc vec3*(): Vec3 {.inline.} = discard
proc vec3*(n: float32): Vec3 {.inline.} = result.data.fill(n)
proc vec3*(v: Vec): Vec3 {.inline.} =
  let high = min(2, system.len(v.data)-1)
  result[0..high] = v[0..high]
proc vec3*(x, y: float32): Vec3 {.inline.} = result.data[0..1] = [x, y]
proc vec3*(x, y, z: float32): Vec3 {.inline.} = result.data[0..2] = [x, y, z]
proc vec3*(xy: Vec2, z: float32): Vec3 {.inline.} = result.data[0..2] = [xy.x, xy.y, z]
proc vec3*(x: float32, yz: Vec2): Vec3 {.inline.} = result.data[0..2] = [x, yz.x, yz.y]
proc vec4*(): Vec4 {.inline.} = discard
proc vec4*(n: float32): Vec4 {.inline.} = result.data.fill(n)
proc vec4*(v: Vec): Vec4 {.inline.} =
  let high = min(3, system.len(v.data)-1)
  result[0..high] = v[0..high]
proc vec4*(x, y: float32): Vec4 {.inline.} = result.data[0..1] = [x, y]
proc vec4*(x, y, z: float32): Vec4 {.inline.} = result.data[0..2] = [x, y, z]
proc vec4*(x, y, z, w: float32): Vec4 {.inline.} = result.data = [x, y, z, w]
proc vec4*(xy: Vec2, z: float32): Vec4 {.inline.} = result.data[0..2] = [xy.x, xy.y, z]
proc vec4*(x: float32, yz: Vec2): Vec4 {.inline.} = result.data[0..2] = [x, yz.x, yz.y]
proc vec4*(xy, zw: Vec2): Vec4 {.inline.} = result.data = [xy.x, xy.y, zw.x, zw.y]
proc vec4*(x: float32, yzw: Vec3): Vec4 {.inline.} = result.data = [x, yzw.x, yzw.y, yzw.z]
proc vec4*(xyz: Vec3, w: float32): Vec4 {.inline.} = result.data = [xyz.x, xyz.y, xyz.z, w]
proc vec4*(xy: Vec2, z, w: float32): Vec4 {.inline.} = result.data = [xy.x, xy.y, z, w]
proc vec4*(x, y: float32, zw: Vec2): Vec4 {.inline.} = result.data = [x, y, zw.x, zw.y]
proc vec4*(x: float32, yz: Vec2, w: float32): Vec4 {.inline.} = result.data = [x, yz.x, yz.y, w]

# Constants

const vec2_zero* = vec2()
const vec3_zero* = vec3()
const vec4_zero* = vec4()
const up* = vec3(0, 1, 0)
const down* = vec3(0, -1, 0)
const left* = vec3(-1, 0, 0)
const right* = vec3(1, 0, 0)
const forward* = vec3(0, 0, 1)
const backward* = vec3(0, 0, -1)

# Common operations

proc rand*[T: Vec](o: var T, range = 0f..1f): var T {.inline.} =
  for i, _ in o: o[i] = rand(range)
  result = o
proc rand*[T: Vec](t: typedesc[T], range = 0f..1f): T {.inline.} = result.rand(range)

proc zero*[T: Vec](o: var T): var T {.inline.} =
  o.data.fill(0)
  result = o

proc `~=`*(a, b: Vec, tolerance = 1e-5): bool {.inline.} =
  genComponentWiseBool(`~=`, a.data, b.data, tolerance)

proc clamp*[T: Vec](o: var T, v: T, range = -Inf.float32 .. Inf.float32): var T {.inline.} =
  for i, _ in o: o[i] = v[i].clamp(range.a, range.b)
  result = o
proc clamp*[T: Vec](v: T, range = -Inf.float32 .. Inf.float32): T {.inline.} =
  result.clamp(v, range)

proc `+`*[T: Vec](o: var T, a, b: T): var T {.inline.} =
  for i, _ in o: o[i] = a[i] + b[i]
  result = o
proc `+`*[T: Vec](a, b: T): T {.inline.} = result.`+`(a, b)

proc `-`*[T: Vec](o: var T, a, b: T): var T {.inline.} =
  for i, _ in o: o[i] = a[i] - b[i]
  result = o
proc `-`*[T: Vec](a, b: T): T {.inline.} = result.`-`(a, b)

proc `-`*[T: Vec](o: var T): var T {.inline.} =
  for i, _ in o: o[i] = -o[i]
  result = o
proc `-`*[T: Vec](v: T): T {.inline.} =
  result = v
  discard -result

proc `*`*[T: Vec](o: var T, a, b: T): var T {.inline.} =
  for i, _ in o: o[i] = a[i] * b[i]
  result = o
proc `*`*[T: Vec](a, b: T): T {.inline.} = result.`*`(a, b)

proc `*`*[T: Vec](o: var T, v: T, scalar: float32): var T {.inline.} =
  for i, _ in o: o[i] = v[i] * scalar
  result = o
proc `*`*[T: Vec](v: T, scalar: float32): T {.inline.} = result.`*`(v, scalar)

proc `/`*[T: Vec](o: var T, a, b: T): var T {.inline.} =
  for i, _ in o: o[i] = if b[i] == 0: 0.0 else: a[i] / b[i]
  result = o
proc `/`*[T: Vec](a, b: T): T {.inline.} = result.`/`(a, b)

proc `/`*[T: Vec](o: var T, v: T, scalar: float32): var T {.inline.} =
  for i, _ in o: o[i] = if scalar == 0: 0.0 else: v[i] / scalar
  result = o
proc `/`*[T: Vec](v: T, scalar: float32): T {.inline.} = result.`/`(v, scalar)

proc `^`*[T: Vec](o: var T, v: T, power: float32): var T {.inline.} =
  for i, _ in o: o[i] = v[i].pow(power)
  result = o
proc `^`*[T: Vec](v: T, power: float32): T {.inline.} = result.`^`(v, power)

proc `<`*(a, b: Vec): bool = genComponentWiseBool(`<`, a.data, b.data)
proc `<=`*(a, b: Vec): bool {.inline.} = genComponentWiseBool(`<=`, a.data, b.data)

proc sign*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].cmp(0).float
  result = o
proc sign*[T: Vec](v: T): T {.inline.} = result.sign(v)

proc fract*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i] - v[i].floor
  result = o
proc fract*[T: Vec](v: T): T {.inline.} = result.fract(v)

proc dot*(a, b: Vec): float32 {.inline.} =
  for i, _ in a: result += a[i] * b[i]

proc sqrt*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = if v[i] < 0: 0.0 else: v[i].sqrt
  result = o
proc sqrt*[T: Vec](v: T): T {.inline.} = result.sqrt(v)

proc lenSq*(v: Vec): float32 {.inline.} =
  for c in v: result += c^2
proc len*(v: Vec): float32 {.inline.} = v.lenSq.sqrt

proc distSq*(a, b: Vec): float32 {.inline.} = lenSq(b-a)
proc dist*(a, b: Vec): float32 {.inline.} = distSq(a, b).sqrt

proc normalize*[T: Vec](o: var T, v: T): var T {.inline.} =
  let len = v.len
  if len != 0:
    result = o.`*`(v, 1/len)
  else:
    result = o.zero
proc normalize*[T: Vec](v: T): T {.inline.} = result.normalize(v)

proc round*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].round
  result = o
proc round*[T: Vec](v: T): T {.inline.} = result.round(v)

proc floor*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].floor
  result = o
proc floor*[T: Vec](v: T): T {.inline.} = result.floor(v)

proc ceil*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].ceil
  result = o
proc ceil*[T: Vec](v: T): T {.inline.} = result.ceil(v)

proc abs*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].abs
  result = o
proc abs*[T: Vec](v: T): T {.inline.} = result.abs(v)

proc min*[T: Vec](o: var T, a, b: T): var T {.inline.} =
  for i, _ in o: o[i] = min(a[i], b[i])
  result = o
proc min*[T: Vec](a, b: T): T {.inline.} = result.min(a, b)

proc max*[T: Vec](o: var T, a, b: T): var T {.inline.} =
  for i, _ in o: o[i] = max(a[i], b[i])
  result = o
proc max*[T: Vec](a, b: T): T {.inline.} = result.max(a, b)

proc `mod`*[T: Vec](o: var T, v: T, divisor: float32): var T {.inline.} =
  for i, _ in o: o[i] = floorMod(v[i], divisor)
  result = o
proc `mod`*[T: Vec](v: T, divisor: float32): T {.inline.} = result.mod(v, divisor)

proc sin*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].sin
  result = o
proc sin*[T: Vec](v: T): T {.inline.} = result.sin(v)

proc cos*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].cos
  result = o
proc cos*[T: Vec](v: T): T {.inline.} = result.cos(v)

proc tan*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].tan
  result = o
proc tan*[T: Vec](v: T): T {.inline.} = result.tan(v)

proc asin*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].arcsin
  result = o
proc asin*[T: Vec](v: T): T {.inline.} = result.asin(v)

proc acos*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].arccos
  result = o
proc acos*[T: Vec](v: T): T {.inline.} = result.acos(v)

proc atan*[T: Vec](o: var T, v: T): var T {.inline.} =
  for i, _ in o: o[i] = v[i].arctan
  result = o
proc atan*[T: Vec](v: T): T {.inline.} = result.atan(v)

proc radians*[T: Vec](o: var T, v: T): var T {.inline.} =
  const degree = Pi/180
  for i, _ in o: o[i] = v[i] * degree
  result = o
proc radians*[T: Vec](v: T): T {.inline.} = result.radians(v)

proc degrees*[T: Vec](o: var T, v: T): var T {.inline.} =
  const radian = 180/Pi
  for i, _ in o: o[i] = v[i] * radian
  result = o
proc degrees*[T: Vec](v: T): T {.inline.} = result.degrees(v)

proc lerp*[T: Vec](o: var T, a, b: T, factor: float32): var T {.inline.} =
  for i, _ in o: o[i] = lerp(a[i], b[i], factor)
  result = o
proc lerp*[T: Vec](a, b: T, factor: float32): T {.inline.} = result.lerp(a, b, factor)

# 2D and 3D vector operations

proc angle*(a, b: Vec2 or Vec3): float32 {.inline.} =
  let m = a.len * b.len
  if m == 0: 0f else: arccos(dot(a, b) / m)

proc sameDirection*(a, b: Vec2 or Vec3, tolerance = 1e-5): bool {.inline.} =
  dot(a.normalize, b.normalize) >= 1 - 1e-5

# 3D vector operations

proc cross*[T: Vec3](o: var T, a, b: T): var T {.inline.} =
  o.x = (a.y * b.z) - (a.z * b.y)
  o.y = (a.z * b.x) - (a.x * b.z)
  o.z = (a.x * b.y) - (a.y * b.x)
  result = o
proc cross*(a, b: Vec3): Vec3 {.inline.} = result.cross(a, b)

proc box*(a, b, c: Vec3): float32 {.inline.} =
  dot(cross(a, b), c)

proc isParallel*(a, b: Vec3): bool {.inline.} = cross(a, b) ~= vec3_zero
