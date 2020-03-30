import std/math
import std/sequtils
import std/unittest

import origin/internal
import origin/vec

suite "vec3":

  test "accessors":
    var a = vec3(1, 2, 3)
    check a.x == 1 and a.y == 2 and a.z == 3
    a[0] = 4; a[1] = 5; a[2] = 6
    check a.x == 4 and a.y == 5 and a.z == 6

  test "constructors":
    var a = vec3()
    check a.allIt(it == 0)
    a = vec3(2)
    check a.allIt(it == 2)
    a = vec3(vec2(3))
    check a.x == 3 and a.y == 3 and a.z == 0
    a = vec3(vec3(4))
    check a.allIt(it == 4)
    a = vec3(vec4(5))
    check a.allIt(it == 5)
    a = vec3(6, 7)
    check a.x == 6 and a.y == 7 and a.z == 0
    a = vec3(8, 9, 10)
    check a.x == 8 and a.y == 9 and a.z == 10
    a = vec3(vec2(11, 12), 13)
    check a.x == 11 and a.y == 12 and a.z == 13
    a = vec3(14, vec2(15, 16))
    check a.x == 14 and a.y == 15 and a.z == 16

  test "constants":
    check vec3_zero.allIt(it == 0)

  test "zero":
    var a = vec3(1, 2, 3)
    a.zero
    check a.allIt(it == 0)

  test "rand":
    var a = vec3()
    a.rand
    check a.allIt(it >= 0 and it <= 1)
    a.rand(50f..100f)
    check a.allIt(it >= 50 and it <= 100)
    a = Vec3.rand
    check a.allIt(it >= 0 and it <= 1)
    a = Vec3.rand(50f..100f)
    check a.allIt(it >= 50 and it <= 100)

  test "~=":
    check vec3() ~= vec3(1e-5)
    check not(vec3() ~= vec3(1e-4))

  test "clamp":
    let a = vec3(-1.5, 0.3, 1.2)
    var b = vec3()
    b.clamp(a)
    check b == a
    b.clamp(a, 0f..1f)
    check b == vec3(0, 0.3, 1)
    b.clamp(a, -1.5f..0f)
    check b == vec3(-1.5, 0, 0)
    b.clamp(a, 0f..0.1f)
    check b == vec3(0, 0.1, 0.1)
    check a.clamp == a
    check a.clamp(0f..1f) == vec3(0, 0.3, 1)
    check a.clamp(-1.5f..0f) == vec3(-1.5, 0, 0)
    check a.clamp(0f..0.1f) == vec3(0, 0.1, 0.1)

  test "+":
    let a = vec3(0.41, -0.87, 0.12)
    var b = vec3()
    `+`(b, a, vec3(0.11, 0.42, 0.31))
    check b ~= vec3(0.52, -0.45, 0.43)
    `+`(b, a, vec3())
    check b == a
    `+`(b, vec3(), a)
    check b == a
    check a + vec3(0.11, 0.42, 0.31) ~= vec3(0.52, -0.45, 0.43)
    check a + vec3() == a
    check vec3() + a == a

  test "-":
    let a = vec3(-0.16, -0.72, 0.55)
    var b = vec3()
    `-`(b, a, vec3(-0.69, 0.61, 0.23))
    check b ~= vec3(0.53, -1.33, 0.32)
    `-`(b, a, vec3())
    check b == a
    check a - vec3(-0.69, 0.61, 0.23) ~= vec3(0.53, -1.33, 0.32)
    check a - vec3() == a

  test "- (unary)":
    var a = vec3(0.78, -0.95, -0.11)
    -a
    check a == vec3(-0.78, 0.95, 0.11)
    check -vec3(0.78, -0.95, -0.11) == vec3(-0.78, 0.95, 0.11)

  test "* (hadamard)":
    var a = vec3()
    let
      b = vec3(-0.62, -0.81, 0.56)
      c = vec3(0.66, -0.21, 0.22)
    `*`(a, b, c)
    check a ~= vec3(-0.4092, 0.1701, 0.1232)
    `*`(a, b, vec3())
    check a == vec3()
    `*`(a, vec3(), b)
    check a == vec3()
    check b * c ~= vec3(-0.4092, 0.1701, 0.1232)
    check b * vec3() == vec3()
    check vec3() * b == vec3()

  test "* (scalar)":
    var a = vec3()
    `*`(a, vec3(0.82, -0.53, 0.1), 0.94)
    check a ~= vec3(0.7708, -0.4982, 0.094)
    check vec3(0.82, -0.53, 0.1) * 0.94 ~= vec3(0.7708, -0.4982, 0.094)

  test "/ (hadamard)":
    var a = vec3()
    let
      b = vec3(0.94, 0.40, 0.17)
      c = vec3(0.32, 0.17, 0.96)
    `/`(a, b, c)
    check a ~= vec3(2.9375, 2.352941, 0.177083)
    `/`(a, b, vec3())
    check a == vec3()
    `/`(a, vec3(), c)
    check a == vec3()
    check b / c ~= vec3(2.9375, 2.352941, 0.177083)
    check vec3() / c == vec3()
    check b / vec3() == vec3()

  test "/ (scalar)":
    var a = vec3()
    `/`(a, vec3(0.54, -0.12, 0.75), 0.23)
    check a ~= vec3(2.347826, -0.521739, 3.260870)
    check vec3(0.54, -0.12, 0.75) / 0.23 ~= vec3(2.347826, -0.521739, 3.260870)

  test "^":
    var a = vec3()
    let b = vec3(0.81, 0.32, 0.33)
    `^`(a, b, 2.2)
    check a ~= vec3(0.629024, 0.081532, 0.087243)
    check b ^ 2.2 ~= vec3(0.629024, 0.081532, 0.087243)

  test "<":
    let
      a = vec3(0.34, -0.49, 0.12)
      b = vec3(0.65, -0.11, 0.23)
      c = vec3(0.97, 0.83, 0.34)
    check b < c
    check c > a

  test "<=":
    let
      a = vec3(0.34, -0.49, 0.12)
      b = vec3(0.65, -0.11, 0.23)
      c = vec3(0.97, 0.83, 0.34)
    check a <= b
    check b <= b
    check c >= c
    check c >= b

  test "sign":
    var a = vec3()
    a.sign(vec3())
    check a == vec3()
    a.sign(vec3(10))
    check a == vec3(1)
    a.sign(vec3(-10))
    check a == vec3(-1)
    a.sign(vec3(10, -10, 10))
    check a == vec3(1, -1, 1)
    check vec3().sign == vec3()
    check vec3(10).sign == vec3(1)
    check vec3(-10).sign == vec3(-1)
    check vec3(10, -10, 10).sign == vec3(1, -1, 1)

  test "fract":
    var a = vec3()
    a.fract(vec3())
    check a == vec3()
    a.fract(vec3(10.42))
    check a ~= vec3(0.42)
    a.fract(vec3(-10.42))
    check a ~= vec3(0.58)
    a.fract(vec3(10.42, -10.42, 10.42))
    check a ~= vec3(0.42, 0.58, 0.42)
    check vec3().fract == vec3()
    check vec3(10.42).fract ~= vec3(0.42)
    check vec3(-10.42).fract ~= vec3(0.58)
    check vec3(10.42, -10.42, 10.42).fract ~= vec3(0.42, 0.58, 0.42)

  test "dot":
    check dot(vec3(-0.21361923, 0.39387107, 0.0043354),
              vec3(-0.13104868, 0.399935, 0.62945867)) ~= 0.1882463f
    check dot(vec3(1, 0, 0), vec3(0, 1, 0)) == 0f
    check dot(vec3(1, 0, 0), vec3(0, 0, 1)) == 0f
    check dot(vec3(0, 1, 0), vec3(0, 0, 1)) == 0f
    check dot(vec3(1, 0, 0), vec3(1, 0, 0)) == 1f
    check dot(vec3(1, 0, 0), vec3(-1, 0, 0)) == -1f

  test "sqrt":
    var a = vec3()
    a.sqrt(vec3(49, 9, 16))
    check a == vec3(7, 3, 4)
    check sqrt(vec3(49, 9, 16)) == vec3(7, 3, 4)

  test "lenSq":
    check vec3().lenSq == 0f
    check vec3(2, 3, 4).lenSq == 29f

  test "len":
    check vec3().len == 0f
    check vec3(0.32, 0.25, 0.44).len ~= 0.5987486f

  test "distSq":
    check distSq(vec3(), vec3(3)) == 27f
    check distSq(vec3(4, 3, 2), vec3(1, 2, 3)) == 11f

  test "dist":
    check dist(vec3(), vec3(8)) ~= 13.856406f
    check dist(vec3(2.2, 3.1, 4.0), vec3(0.4, 1.8, 2.4)) ~= 2.7367863f

  test "normalize":
    var a = vec3()
    a.normalize(vec3(-0.65, 0.23, -0.1))
    check a ~= vec3(-0.932961, 0.330125, -0.143532)
    a.normalize(vec3(2, 0, 0))
    check a == vec3(1, 0, 0)
    a.normalize(vec3(0, 2, 0))
    check a == vec3(0, 1, 0)
    a.normalize(vec3(0, 0, 2))
    check a == vec3(0, 0, 1)
    a.normalize(vec3())
    check a == vec3()
    check vec3(-0.65, 0.23, -0.1).normalize ~= vec3(-0.932961, 0.330125, -0.143532)
    check vec3(2, 0, 0).normalize == vec3(1, 0, 0)
    check vec3(0, 2, 0).normalize == vec3(0, 1, 0)
    check vec3(0, 0, 2).normalize == vec3(0, 0, 1)
    check vec3().normalize == vec3()

  test "round":
    var a = vec3()
    a.round(vec3(-0.70, 0.36, -1.2))
    check a == vec3(-1, 0, -1)
    a.round(vec3(-0.3, 0.2, 0.4))
    check a == vec3()
    check vec3(-0.70, 0.36, -1.2).round == vec3(-1, 0, -1)
    check vec3(-0.3, 0.2, 0.4).round == vec3()

  test "floor":
    var a = vec3()
    a.floor(vec3(-0.1, 0.9, 0.4))
    check a == vec3(-1, 0, 0)
    a.floor(vec3(-0.3, -1.1, 1.9))
    check a == vec3(-1, -2, 1)
    check vec3(-0.1, 0.9, 0.4).floor == vec3(-1, 0, 0)
    check vec3(-0.3, -1.1, 1.9).floor == vec3(-1, -2, 1)

  test "ceil":
    var a = vec3()
    a.ceil(vec3(-0.2, 0.1, 1.01))
    check a == vec3(0, 1, 2)
    a.ceil(vec3(0.9, 1.1, -0.2))
    check a == vec3(1, 2, 0)
    check vec3(-0.2, 0.1, 1.01).ceil == vec3(0, 1, 2)
    check vec3(0.9, 1.1, -0.2).ceil == vec3(1, 2, 0)

  test "abs":
    var a = vec3()
    a.abs(vec3(-0.42, 0.52, -0.2))
    check a == vec3(0.42, 0.52, 0.2)
    check vec3(-0.42, 0.52, -0.2).abs == vec3(0.42, 0.52, 0.2)

  test "min":
    var a = vec3()
    a.min(vec3(0.98, 0.06, 0.21), vec3(0.87, 0.25, 0.34))
    check a == vec3(0.87, 0.06, 0.21)
    check vec.min(vec3(0.98, 0.06, 0.21), vec3(0.87, 0.25, 0.32)) == vec3(0.87, 0.06, 0.21)

  test "max":
    var a = vec3()
    a.max(vec3(0.64, 0.38, 0.34), vec3(0.63, 0.52, 0.22))
    check a == vec3(0.64, 0.52, 0.34)
    check vec.max(vec3(0.64, 0.38, 0.34), vec3(0.63, 0.52, 0.22)) == vec3(0.64, 0.52, 0.34)

  test "mod":
    var a = vec3()
    a.mod(vec3(0.34, 0.72, 0.23), 0.1)
    check a ~= vec3(0.04, 0.02, 0.03)
    check vec3(0.34, 0.72, 0.23) mod 0.1 ~= vec3(0.04, 0.02, 0.03)

  test "sin":
    var a = vec3()
    a.sin(vec3(PI/2, PI/4, PI/3))
    check a ~= vec3(1, 0.707107, 0.866025)
    check sin(vec3(PI/2, PI/4, PI/3)) ~= vec3(1, 0.707107, 0.866025)

  test "cos":
    var a = vec3()
    a.cos(vec3(PI/2, PI/4, PI/3))
    check a ~= vec3(0, 0.707107, 0.5)
    check cos(vec3(PI/2, PI/4, PI/3)) ~= vec3(0, 0.707107, 0.5)

  test "tan":
    var a = vec3()
    a.tan(vec3(PI/3))
    check a ~= vec3(3).sqrt
    a.tan(vec3(PI))
    check a ~= vec3()
    check tan(vec3(PI/3)) ~= vec3(3).sqrt
    check tan(vec3(PI)) ~= vec3()

  test "asin":
    var a = vec3()
    a.asin(vec3(1))
    check a ~= vec3(PI/2)
    a.asin(vec3())
    check a ~= vec3()
    check asin(vec3(1)) ~= vec3(PI/2)
    check asin(vec3()) ~= vec3()

  test "acos":
    var a = vec3()
    a.acos(vec3(0))
    check a ~= vec3(PI/2)
    a.acos(vec3(0.5))
    check a ~= vec3(PI/3)
    check acos(vec3(0)) ~= vec3(PI/2)
    check acos(vec3(0.5)) ~= vec3(PI/3)

  test "atan":
    var a = vec3()
    a.atan(vec3(1))
    check a ~= vec3(PI/4)
    a.atan(vec3(3).sqrt)
    check a ~= vec3(PI/3)
    check atan(vec3(1)) ~= vec3(PI/4)
    check atan(vec3(3).sqrt) ~= vec3(PI/3)

  test "radians":
    var a = vec3()
    a.radians(vec3(90, 60, 45))
    check a ~= vec3(PI/2, PI/3, PI/4)
    check radians(vec3(90, 60, 45)) ~= vec3(PI/2, PI/3, PI/4)

  test "degrees":
    var a = vec3()
    a.degrees(vec3(PI/2, PI/3, PI/4))
    check a ~= vec3(90, 60, 45)
    check degrees(vec3(PI/2, PI/3, PI/4)) ~= vec3(90, 60, 45)

  test "lerp":
    var a = vec3()
    let
      b = vec3(0.74, 0.09, 0.22)
      c = vec3(0.19, 0.98, 0.34)
    a.lerp(b, c, 0.5)
    check a ~= vec3(0.465, 0.535, 0.28)
    a.lerp(b, c, 0)
    check a == vec3(0.74, 0.09, 0.22)
    a.lerp(b, c, 1)
    check a == vec3(0.19, 0.98, 0.34)
    check lerp(b, c, 0.5) ~= vec3(0.465, 0.535, 0.28)
    check lerp(b, c, 0) == b
    check lerp(b, c, 1) == c

  test "angle":
    check angle(vec3(0, 1, 0), vec3(1, 0, 1)) ~= PI/2
    check angle(vec3(1, 1, 0), vec3(1, 0, 1)) ~= PI/3
    check angle(vec3(1, 0, 0), vec3(1, 1, 0)) ~= PI/4

  test "sameDirection":
    check sameDirection(vec3(0.7, 0, 0), vec3(0.3, 0, 0))
    check sameDirection(vec3(0, 0.06, 0), vec3(0, 14.2, 0))

  test "cross":
    var a = vec3()
    a.cross(vec3(1, 0, 0), vec3(0, 1, 0))
    check a == vec3(0, 0, 1)
    a.cross(vec3(1, 0, 0), vec3(0, 0, 1))
    check a == vec3(0, -1, 0)
    a.cross(vec3(0, 1, 0), vec3(1, 0, 0))
    check a == vec3(0, 0, -1)
    a.cross(vec3(0, 1, 0), vec3(0, 0, 1))
    check a == vec3(1, 0, 0)
    a.cross(vec3(0, 0, 1), vec3(1, 0, 0))
    check a == vec3(0, 1, 0)
    a.cross(vec3(0, 0, 1), vec3(0, 1, 0))
    check a == vec3(-1, 0, 0)
    check cross(vec3(1, 0, 0), vec3(0, 1, 0)) == vec3(0, 0, 1)
    check cross(vec3(1, 0, 0), vec3(0, 0, 1)) == vec3(0, -1, 0)
    check cross(vec3(0, 1, 0), vec3(1, 0, 0)) == vec3(0, 0, -1)
    check cross(vec3(0, 1, 0), vec3(0, 0, 1)) == vec3(1, 0, 0)
    check cross(vec3(0, 0, 1), vec3(1, 0, 0)) == vec3(0, 1, 0)
    check cross(vec3(0, 0, 1), vec3(0, 1, 0)) == vec3(-1, 0, 0)

  test "box":
    check box(vec3(0.3, 0.1, 3.1), vec3(0.2, 1.3, 4.2), vec3(2.1, 0.8, 1.9)) ~= -7.38999843f

  test "isParallel":
    check isParallel(vec3(0.68, 0, 0), vec3(-0.37, 0, 0))
    check isParallel(vec3(0, -0.31, 0), vec3(0, 0.22, 0))
    check isParallel(vec3(0, 0, 0.18), vec3(0, 0, 0.42))
