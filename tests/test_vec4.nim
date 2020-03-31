import std/math
import std/sequtils
import std/unittest

import origin/internal
import origin/vec

suite "vec4":

  test "accessors":
    var a = vec4(1, 2, 3, 4)
    check a.x == 1 and a.y == 2 and a.z == 3 and a.w == 4
    a[0] = 5; a[1] = 6; a[2] = 7; a[3] = 8
    check a.x == 5 and a.y == 6 and a.z == 7 and a.w == 8

  test "constructors":
    var a = vec4()
    check a.allIt(it == 0)
    a = vec4(2)
    check a.allIt(it == 2)
    a = vec4(vec2(3))
    check a.x == 3 and a.y == 3 and a.z == 0 and a.w == 0
    a = vec4(vec3(4))
    check a.x == 4 and a.y == 4 and a.z == 4 and a.w == 0
    a = vec4(vec4(5))
    check a.allIt(it == 5)
    a = vec4(6, 7)
    check a.x == 6 and a.y == 7 and a.z == 0 and a.w == 0
    a = vec4(7, 8, 9)
    check a.x == 7 and a.y == 8 and a.z == 9 and a.w == 0
    a = vec4(10, 11, 12, 13)
    check a.x == 10 and a.y == 11 and a.z == 12 and a.w == 13
    a = vec4(vec2(14, 15), 16)
    check a.x == 14 and a.y == 15 and a.z == 16 and a.w == 0
    a = vec4(17, vec2(18, 19))
    check a.x == 17 and a.y == 18 and a.z == 19 and a.w == 0
    a = vec4(vec2(20, 21), vec2(22, 23))
    check a.x == 20 and a.y == 21 and a.z == 22 and a.w == 23
    a = vec4(24, vec3(25, 26, 27))
    check a.x == 24 and a.y == 25 and a.z == 26 and a.w == 27
    a = vec4(vec3(28, 29, 30), 31)
    check a.x == 28 and a.y == 29 and a.z == 30 and a.w == 31
    a = vec4(vec2(32, 33), 34, 35)
    check a.x == 32 and a.y == 33 and a.z == 34 and a.w == 35
    a = vec4(36, 37, vec2(38, 39))
    check a.x == 36 and a.y == 37 and a.z == 38 and a.w == 39
    a = vec4(40, vec2(41, 42), 43)
    check a.x == 40 and a.y == 41 and a.z == 42 and a.w == 43

  test "constants":
    check vec4_zero.allIt(it == 0)

  test "zero":
    var a = vec3(1, 2, 3)
    check a.zero.allIt(it == 0)

  test "rand":
    var a = vec4()
    check a.rand.allIt(it >= 0 and it <= 1)
    check a.rand(50f..100f).allIt(it >= 50 and it <= 100)
    check Vec4.rand.allIt(it >= 0 and it <= 1)
    check Vec4.rand(50f..100f).allIt(it >= 50 and it <= 100)

  test "~=":
    check vec4() ~= vec4(1e-5)
    check not(vec4() ~= vec4(1e-4))

  test "clamp":
    var a = vec4()
    let b = vec4(-1.5, 0.3, 1.2, 0.5)
    check a.clamp(b) == b
    check a.clamp(b, 0f..1f) == vec4(0, 0.3, 1, 0.5)
    check a.clamp(b, -1.5f..0f) == vec4(-1.5, 0, 0, 0)
    check a.clamp(b, 0f..0.1f) == vec4(0, 0.1, 0.1, 0.1)
    check b.clamp == b
    check b.clamp(0f..1f) == vec4(0, 0.3, 1, 0.5)
    check b.clamp(-1.5f..0f) == vec4(-1.5, 0, 0, 0)
    check b.clamp(0f..0.1f) == vec4(0, 0.1, 0.1, 0.1)

  test "+":
    var a = vec4()
    let b = vec4(0.41, -0.87, 0.12, 0.34)
    check `+`(a, b, vec4(0.11, 0.42, 0.31, 0.59)) ~= vec4(0.52, -0.45, 0.43, 0.93)
    check `+`(a, b, vec4()) == b
    check `+`(a, vec4(), b) == b
    check b + vec4(0.11, 0.42, 0.31, 0.59) ~= vec4(0.52, -0.45, 0.43, 0.93)
    check b + vec4() == b
    check vec4() + b == b

  test "-":
    var a = vec4()
    let b = vec4(-0.16, -0.72, 0.55, 0.93)
    check `-`(a, b, vec4(-0.69, 0.61, 0.23, 0.17)) ~= vec4(0.53, -1.33, 0.32, 0.76)
    check `-`(a, b, vec4()) == b
    check b - vec4(-0.69, 0.61, 0.23, 0.17) ~= vec4(0.53, -1.33, 0.32, 0.76)
    check b - vec4() == b

  test "- (unary)":
    var a = vec4(0.78, -0.95, -0.11, 0.22)
    check -a == vec4(-0.78, 0.95, 0.11, -0.22)
    check -vec4(0.78, -0.95, -0.11, 0.22) == vec4(-0.78, 0.95, 0.11, -0.22)

  test "* (hadamard)":
    var a = vec4()
    let
      b = vec4(-0.62, -0.81, 0.56, 0.66)
      c = vec4(0.66, -0.21, 0.22, 0.26)
    check `*`(a, b, c) ~= vec4(-0.4092, 0.1701, 0.1232, 0.1716)
    check `*`(a, b, vec4()) == vec4()
    check `*`(a, vec4(), b) == vec4()
    check b * c ~= vec4(-0.4092, 0.1701, 0.1232, 0.1716)
    check b * vec4() == vec4()
    check vec4() * b == vec4()

  test "* (scalar)":
    var a = vec4()
    check `*`(a, vec4(0.82, -0.53, 0.1, 0.98), 0.94) ~= vec4(0.7708, -0.4982, 0.094, 0.9212)
    check vec4(0.82, -0.53, 0.1, 0.98) * 0.94 ~= vec4(0.7708, -0.4982, 0.094, 0.9212)

  test "/ (hadamard)":
    var a = vec4()
    let
      b = vec4(0.94, 0.40, 0.17, 0.38)
      c = vec4(0.32, 0.17, 0.96, 0.51)
    check `/`(a, b, c) ~= vec4(2.9375, 2.352941, 0.177083, 0.745098)
    check `/`(a, b, vec4()) == vec4()
    check `/`(a, vec4(), c) == vec4()
    check b / c ~= vec4(2.9375, 2.352941, 0.177083, 0.745098)
    check vec4() / c == vec4()
    check b / vec4() == vec4()

  test "/ (scalar)":
    var a = vec4()
    check `/`(a, vec4(0.54, -0.12, 0.75, 0.63), 0.23) ~=
      vec4(2.347826, -0.521739, 3.260870, 2.739130)
    check vec4(0.54, -0.12, 0.75, 0.63) / 0.23 ~= vec4(2.347826, -0.521739, 3.260870, 2.739130)

  test "^":
    var a = vec4()
    let b = vec4(0.81, 0.32, 0.33, 0.27)
    check `^`(a, b, 2.2) ~= vec4(0.629024, 0.081532, 0.087243, 0.056105)
    check b ^ 2.2 ~= vec4(0.629024, 0.081532, 0.087243, 0.056105)

  test "<":
    let
      a = vec4(0.34, -0.49, 0.12, -0.18)
      b = vec4(0.65, -0.11, 0.23, -0.02)
      c = vec4(0.97, 0.83, 0.34, 0.92)
    check b < c
    check c > a

  test "<=":
    let
      a = vec4(0.34, -0.49, 0.12, -0.18)
      b = vec4(0.65, -0.11, 0.23, -0.02)
      c = vec4(0.97, 0.83, 0.34, 0.92)
    check a <= b
    check b <= b
    check c >= c
    check c >= b

  test "sign":
    var a = vec4()
    check a.sign(vec4()) == vec4()
    check a.sign(vec4(10)) == vec4(1)
    check a.sign(vec4(-10)) == vec4(-1)
    check a.sign(vec4(10, -10, 10, -10)) == vec4(1, -1, 1, -1)
    check vec4().sign == vec4()
    check vec4(10).sign == vec4(1)
    check vec4(-10).sign == vec4(-1)
    check vec4(10, -10, 10, -10).sign == vec4(1, -1, 1, -1)

  test "fract":
    var a = vec4()
    check a.fract(vec4()) == vec4()
    check a.fract(vec4(10.42)) ~= vec4(0.42)
    check a.fract(vec4(-10.42)) ~= vec4(0.58)
    check a.fract(vec4(10.42, -10.42, 10.42, -10.42)) ~= vec4(0.42, 0.58, 0.42, 0.58)
    check vec4().fract == vec4()
    check vec4(10.42).fract ~= vec4(0.42)
    check vec4(-10.42).fract ~= vec4(0.58)
    check vec4(10.42, -10.42, 10.42, -10.42).fract ~= vec4(0.42, 0.58, 0.42, 0.58)

  test "dot":
    check dot(vec4(-0.21361923, 0.39387107, 0.0043354, 0.8267517),
              vec4(-0.13104868, 0.399935, 0.62945867, 0.44206798)) ~= 0.55372673f
    check dot(vec4(1, 0, 0, 0), vec4(0, 1, 0, 0)) == 0f
    check dot(vec4(1, 0, 0, 0), vec4(0, 0, 1, 0)) == 0f
    check dot(vec4(0, 1, 0, 0), vec4(0, 0, 1, 0)) == 0f
    check dot(vec4(1, 0, 0, 0), vec4(1, 0, 0, 0)) == 1f
    check dot(vec4(1, 0, 0, 0), vec4(-1, 0, 0, 0)) == -1f

  test "sqrt":
    var a = vec4()
    check a.sqrt(vec4(49, 9, 16, 64)) == vec4(7, 3, 4, 8)
    check sqrt(vec4(49, 9, 16, 64)) == vec4(7, 3, 4, 8)

  test "lenSq":
    check vec4().lenSq == 0f
    check vec4(2, 3, 4, 5).lenSq == 54f

  test "len":
    check vec4().len == 0f
    check vec4(0.32, 0.25, 0.44, 0.52).len ~= 0.79303216f

  test "distSq":
    check distSq(vec4(), vec4(3)) == 36f
    check distSq(vec4(4, 3, 2, 1), vec4(1, 2, 3, 4)) == 20f

  test "dist":
    check dist(vec4(), vec4(8)) ~= 16f
    check dist(vec4(2.2, 3.1, 4.0, 1.5), vec4(0.4, 1.8, 2.4, 1.2)) ~= 2.75318f

  test "normalize":
    var a = vec4()
    check a.normalize(vec4(-0.65, 0.23, -0.1, 0.34)) ~=
      vec4(-0.838448, 0.296682, -0.128992, 0.438573)
    check a.normalize(vec4(2, 0, 0, 0)) == vec4(1, 0, 0, 0)
    check a.normalize(vec4(0, 2, 0, 0)) == vec4(0, 1, 0, 0)
    check a.normalize(vec4(0, 0, 2, 0)) == vec4(0, 0, 1, 0)
    check a.normalize(vec4(0, 0, 0, 2)) == vec4(0, 0, 0, 1)
    check a.normalize(vec4()) == vec4()
    check vec4(-0.65, 0.23, -0.1, 0.34).normalize ~= vec4(-0.838448, 0.296682, -0.128992, 0.438573)
    check vec4(2, 0, 0, 0).normalize == vec4(1, 0, 0, 0)
    check vec4(0, 2, 0, 0).normalize == vec4(0, 1, 0, 0)
    check vec4(0, 0, 2, 0).normalize == vec4(0, 0, 1, 0)
    check vec4(0, 0, 0, 2).normalize == vec4(0, 0, 0, 1)
    check vec4().normalize == vec4()

  test "round":
    var a = vec4()
    check a.round(vec4(-0.70, 0.36, -1.2, 0.1)) == vec4(-1, 0, -1, 0)
    check a.round(vec4(-0.3, 0.2, 0.4, 0.49)) == vec4()
    check vec4(-0.70, 0.36, -1.2, 0.1).round == vec4(-1, 0, -1, 0)
    check vec4(-0.3, 0.2, 0.4, 0.49).round == vec4()

  test "floor":
    var a = vec4()
    check a.floor(vec4(-0.1, 0.9, 0.4, 0.99)) == vec4(-1, 0, 0, 0)
    check a.floor(vec4(-0.3, -1.1, 1.9, -0.01)) == vec4(-1, -2, 1, -1)
    check vec4(-0.1, 0.9, 0.4, 0.99).floor == vec4(-1, 0, 0, 0)
    check vec4(-0.3, -1.1, 1.9, -0.01).floor == vec4(-1, -2, 1, -1)

  test "ceil":
    var a = vec4()
    check a.ceil(vec4(-0.2, 0.1, 1.01, 0.4)) == vec4(0, 1, 2, 1)
    check a.ceil(vec4(0.9, 1.1, -0.2, 0.3)) == vec4(1, 2, 0, 1)
    check vec4(-0.2, 0.1, 1.01, 0.4).ceil == vec4(0, 1, 2, 1)
    check vec4(0.9, 1.1, -0.2, 0.3).ceil == vec4(1, 2, 0, 1)

  test "abs":
    var a = vec4()
    check a.abs(vec4(-0.42, 0.52, -0.2, 0.3)) == vec4(0.42, 0.52, 0.2, 0.3)
    check vec4(-0.42, 0.52, -0.2, 0.55).abs == vec4(0.42, 0.52, 0.2, 0.55)

  test "min":
    var a = vec4()
    check a.min(vec4(0.98, 0.06, 0.21, 0.41), vec4(0.87, 0.25, 0.34, 0.11)) ==
      vec4(0.87, 0.06, 0.21, 0.11)
    check vec.min(vec4(0.98, 0.06, 0.21, 0.93), vec4(0.87, 0.25, 0.32, 0.24)) ==
      vec4(0.87, 0.06, 0.21, 0.24)

  test "max":
    var a = vec4()
    check a.max(vec4(0.64, 0.38, 0.34, 0.34), vec4(0.63, 0.52, 0.22, 0.87)) ==
      vec4(0.64, 0.52, 0.34, 0.87)
    check vec.max(vec4(0.64, 0.38, 0.34, 0.34), vec4(0.63, 0.52, 0.22, 0.87)) ==
      vec4(0.64, 0.52, 0.34, 0.87)

  test "mod":
    var a = vec4()
    check a.mod(vec4(0.34, 0.72, 0.23, 0.91), 0.1) ~= vec4(0.04, 0.02, 0.03, 0.01)
    check vec4(0.34, 0.72, 0.23, 0.91) mod 0.1 ~= vec4(0.04, 0.02, 0.03, 0.01)

  test "sin":
    var a = vec4()
    check a.sin(vec4(Pi/2, Pi/4, Pi/3, Pi)) ~= vec4(1, 0.707107, 0.866025, 0)
    check sin(vec4(Pi/2, Pi/4, Pi/3, Pi)) ~= vec4(1, 0.707107, 0.866025, 0)

  test "cos":
    var a = vec4()
    check a.cos(vec4(Pi/2, Pi/4, Pi/3, Pi)) ~= vec4(0, 0.707107, 0.5, -1)
    check cos(vec4(Pi/2, Pi/4, Pi/3, Pi)) ~= vec4(0, 0.707107, 0.5, -1)

  test "tan":
    var a = vec4()
    check a.tan(vec4(Pi/3)) ~= vec4(3).sqrt
    check a.tan(vec4(Pi)) ~= vec4()
    check tan(vec4(Pi/3)) ~= vec4(3).sqrt
    check tan(vec4(Pi)) ~= vec4()

  test "asin":
    var a = vec4()
    check a.asin(vec4(1)) ~= vec4(Pi/2)
    check a.asin(vec4()) ~= vec4()
    check asin(vec4(1)) ~= vec4(Pi/2)
    check asin(vec4()) ~= vec4()

  test "acos":
    var a = vec4()
    check a.acos(vec4(0)) ~= vec4(Pi/2)
    check a.acos(vec4(0.5)) ~= vec4(Pi/3)
    check acos(vec4(0)) ~= vec4(Pi/2)
    check acos(vec4(0.5)) ~= vec4(Pi/3)

  test "atan":
    var a = vec4()
    check a.atan(vec4(1)) ~= vec4(Pi/4)
    check a.atan(vec4(3).sqrt) ~= vec4(Pi/3)
    check atan(vec4(1)) ~= vec4(Pi/4)
    check atan(vec4(3).sqrt) ~= vec4(Pi/3)

  test "radians":
    var a = vec4()
    check a.radians(vec4(90, 60, 45, 180)) ~= vec4(Pi/2, Pi/3, Pi/4, Pi)
    check radians(vec4(90, 60, 45, 180)) ~= vec4(Pi/2, Pi/3, Pi/4, Pi)

  test "degrees":
    var a = vec4()
    check a.degrees(vec4(Pi/2, Pi/3, Pi/4, Pi)) ~= vec4(90, 60, 45, 180)
    check degrees(vec4(Pi/2, Pi/3, Pi/4, Pi)) ~= vec4(90, 60, 45, 180)

  test "lerp":
    var a = vec4()
    let
      b = vec4(0.74, 0.09, 0.22, 0.45)
      c = vec4(0.19, 0.98, 0.34, 0.11)
    check a.lerp(b, c, 0.5) ~= vec4(0.465, 0.535, 0.28, 0.28)
    check a.lerp(b, c, 0) == b
    check a.lerp(b, c, 1) == c
    check lerp(b, c, 0.5) ~= vec4(0.465, 0.535, 0.28, 0.28)
    check lerp(b, c, 0) == b
    check lerp(b, c, 1) == c

