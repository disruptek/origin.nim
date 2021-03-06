import std/math
import std/sequtils
import std/unittest

import origin/internal
import origin/vec

suite "vec2":

  test "accessors":
    var a = vec2(1, 2)
    check a.x == 1 and a.y == 2
    a[0] = 3; a[1] = 4
    check a.x == 3 and a.y == 4

  test "constructors":
    var a = vec2()
    check a.allIt(it == 0)
    a = vec2(2)
    check a.allIt(it == 2)
    a = vec2(vec2(3))
    check a.allIt(it == 3)
    a = vec2(vec3(4))
    check a.allIt(it == 4)
    a = vec2(vec4(5))
    check a.allIt(it == 5)
    a = vec2(6, 7)
    check a.x == 6 and a.y == 7

  test "constants":
    check vec2_zero.allIt(it == 0)

  test "zero":
    var a = vec2(1, 2)
    check a.zero.allIt(it == 0)

  test "rand":
    var a = vec2()
    check a.rand.allIt(it >= 0 and it <= 1)
    check a.rand(50f..100f).allIt(it >= 50 and it <= 100)
    check Vec2.rand.allIt(it >= 0 and it <= 1)
    check Vec2.rand(50f..100f).allIt(it >= 50 and it <= 100)

  test "~=":
    check vec2() ~= vec2(1e-5)
    check not(vec2() ~= vec2(1e-4))

  test "clamp":
    var a = vec2()
    let b = vec2(-1.5, 0.3)
    check a.clamp(b) == b
    check a.clamp(a, 0f..1f) == vec2(0, 0.3)
    check a.clamp(b, -1.5f..0f) == vec2(-1.5, 0)
    check a.clamp(b, 0f..0.1f) == vec2(0, 0.1)
    check b.clamp == b
    check b.clamp(0f..1f) == vec2(0, 0.3)
    check b.clamp(-1.5f..0f) == vec2(-1.5, 0)
    check b.clamp(0f..0.1f) == vec2(0, 0.1)

  test "+":
    var a = vec2()
    let b = vec2(0.41, -0.87)
    check `+`(a, b, vec2(0.11, 0.42)) ~= vec2(0.52, -0.45)
    check `+`(a, b, vec2()) == b
    check `+`(a, vec2(), b) == b
    check b + vec2(0.11, 0.42) ~= vec2(0.52, -0.45)
    check b + vec2() == b
    check vec2() + b == b

  test "-":
    var a = vec2()
    let b = vec2(-0.16, -0.72)
    check `-`(a, b, vec2(-0.69, 0.61)) ~= vec2(0.53, -1.33)
    check `-`(a, b, vec2()) == b
    check a - vec2(-0.69, 0.61) ~= vec2(0.53, -1.33)
    check b - vec2() == b

  test "- (unary)":
    var a = vec2(0.78, -0.95)
    check -a == vec2(-0.78, 0.95)
    check -vec2(0.78, -0.95) == vec2(-0.78, 0.95)

  test "* (hadamard)":
    var a = vec2()
    let
      b = vec2(-0.62, -0.81)
      c = vec2(0.66, -0.21)
    check `*`(a, b, c) ~= vec2(-0.4092, 0.1701)
    check `*`(a, b, vec2()) == vec2()
    check `*`(a, vec2(), b) == vec2()
    check b * c ~= vec2(-0.4092, 0.1701)
    check b * vec2() == vec2()
    check vec2() * b == vec2()

  test "* (scalar)":
    var a = vec2()
    check `*`(a, vec2(0.82, -0.53), 0.94) ~= vec2(0.7708, -0.4982)
    check vec2(0.82, -0.53) * 0.94 ~= vec2(0.7708, -0.4982)

  test "/ (hadamard)":
    var a = vec2()
    let
      b = vec2(0.94, 0.40)
      c = vec2(0.32, 0.17)
    check `/`(a, b, c) ~= vec2(2.9375, 2.352941)
    check `/`(a, b, vec2()) == vec2()
    check `/`(a, vec2(), c) == vec2()
    check b / c ~= vec2(2.9375, 2.352941)
    check vec2() / c == vec2()
    check b / vec2() == vec2()

  test "/ (scalar)":
    var a = vec2()
    check `/`(a, vec2(0.54, -0.12), 0.23) ~= vec2(2.347826, -0.521739)
    check vec2(0.54, -0.12) / 0.23 ~= vec2(2.347826, -0.521739)

  test "^":
    var a = vec2()
    let b = vec2(0.81, 0.32)
    check `^`(a, b, 2.2) ~= vec2(0.629024, 0.081532)
    check b ^ 2.2 ~= vec2(0.629024, 0.081532)

  test "<":
    let
      a = vec2(0.34, -0.49)
      b = vec2(0.65, -0.11)
      c = vec2(0.97, 0.83)
    check b < c
    check c > a

  test "<=":
    let
      a = vec2(0.34, -0.49)
      b = vec2(0.65, -0.11)
      c = vec2(0.97, 0.83)
    check a <= b
    check b <= b
    check c >= c
    check c >= b

  test "sign":
    var a = vec2()
    check a.sign(vec2()) == vec2()
    check a.sign(vec2(10)) == vec2(1)
    check a.sign(vec2(-10)) == vec2(-1)
    check a.sign(vec2(10, -10)) == vec2(1, -1)
    check vec2().sign == vec2()
    check vec2(10).sign == vec2(1)
    check vec2(-10).sign == vec2(-1)
    check vec2(10, -10).sign == vec2(1, -1)

  test "fract":
    var a = vec2()
    check a.fract(vec2()) == vec2()
    check a.fract(vec2(10.42)) ~= vec2(0.42)
    check a.fract(vec2(-10.42)) ~= vec2(0.58)
    check a.fract(vec2(10.42, -10.42)) ~= vec2(0.42, 0.58)
    check vec2().fract == vec2()
    check vec2(10.42).fract ~= vec2(0.42)
    check vec2(-10.42).fract ~= vec2(0.58)
    check vec2(10.42, -10.42).fract ~= vec2(0.42, 0.58)

  test "dot":
    check dot(vec2(-0.21361923, 0.39387107), vec2(-0.13104868, 0.399935)) ~= 0.18551734f
    check dot(vec2(1, 0), vec2(0, 1)) == 0f
    check dot(vec2(1, 0), vec2(1, 0)) == 1f
    check dot(vec2(1, 0), vec2(-1, 0)) == -1f

  test "sqrt":
    var a = vec2()
    check a.sqrt(vec2(49, 9)) == vec2(7, 3)
    check sqrt(vec2(49, 9)) == vec2(7, 3)

  test "lenSq":
    check vec2().lenSq == 0f
    check vec2(2, 3).lenSq == 13f

  test "len":
    check vec2().len == 0f
    check vec2(0.32, 0.25).len ~= 0.40607f

  test "distSq":
    check distSq(vec2(), vec2(3)) == 18f
    check distSq(vec2(4, 3), vec2(1, 2)) == 10f

  test "dist":
    check dist(vec2(), vec2(8)) ~= 11.313708f
    check dist(vec2(2.2, 3.1), vec2(0.4, 1.8)) ~= 2.2203605f

  test "normalize":
    var a = vec2()
    check a.normalize(vec2(-0.65, 0.23)) ~= vec2(-0.942722, 0.333579)
    check a.normalize(vec2(2, 0)) == vec2(1, 0)
    check a.normalize(vec2(0, 2)) == vec2(0, 1)
    check a.normalize(vec2()) == vec2()
    check vec2(-0.65, 0.23).normalize ~= vec2(-0.942722, 0.333579)
    check vec2(2, 0).normalize == vec2(1, 0)
    check vec2(0, 2).normalize == vec2(0, 1)
    check vec2().normalize == vec2()

  test "round":
    var a = vec2()
    check a.round(vec2(-0.70, 0.36)) == vec2(-1, 0)
    check a.round(vec2(-0.3, 0.2)) == vec2()
    check vec2(-0.70, 0.36).round == vec2(-1, 0)
    check vec2(-0.3, 0.2).round == vec2()

  test "floor":
    var a = vec2()
    check a.floor(vec2(-0.1, 0.9)) == vec2(-1, 0)
    check a.floor(vec2(-0.3, -1.1)) == vec2(-1, -2)
    check vec2(-0.1, 0.9).floor == vec2(-1, 0)
    check vec2(-0.3, -1.1).floor == vec2(-1, -2)

  test "ceil":
    var a = vec2()
    check a.ceil(vec2(-0.2, 0.1)) == vec2(0, 1)
    check a.ceil(vec2(0.9, 1.1)) == vec2(1, 2)
    check vec2(-0.2, 0.1).ceil == vec2(0, 1)
    check vec2(0.9, 1.1).ceil == vec2(1, 2)

  test "abs":
    var a = vec2()
    check a.abs(vec2(-0.42, 0.52)) == vec2(0.42, 0.52)
    check vec2(-0.42, 0.52).abs == vec2(0.42, 0.52)

  test "min":
    var a = vec2()
    check a.min(vec2(0.98, 0.06), vec2(0.87, 0.25)) == vec2(0.87, 0.06)
    check vec.min(vec2(0.98, 0.06), vec2(0.87, 0.25)) == vec2(0.87, 0.06)

  test "max":
    var a = vec2()
    check a.max(vec2(0.64, 0.38), vec2(0.63, 0.52)) == vec2(0.64, 0.52)
    check vec.max(vec2(0.64, 0.38), vec2(0.63, 0.52)) == vec2(0.64, 0.52)

  test "mod":
    var a = vec2()
    check a.mod(vec2(0.34, 0.72), 0.1) ~= vec2(0.04, 0.02)
    check vec2(0.34, 0.72) mod 0.1 ~= vec2(0.04, 0.02)

  test "sin":
    var a = vec2()
    check a.sin(vec2(Pi/2, Pi/4)) ~= vec2(1, 0.707107)
    check sin(vec2(Pi/2, Pi/4)) ~= vec2(1, 0.707107)

  test "cos":
    var a = vec2()
    check a.cos(vec2(Pi/2, Pi/4)) ~= vec2(0, 0.707107)
    check cos(vec2(Pi/2, Pi/4)) ~= vec2(0, 0.707107)

  test "tan":
    var a = vec2()
    check a.tan(vec2(Pi/3)) ~= vec2(3).sqrt
    check a.tan(vec2(Pi)) ~= vec2()
    check tan(vec2(Pi/3)) ~= vec2(3).sqrt
    check tan(vec2(Pi)) ~= vec2()

  test "asin":
    var a = vec2()
    check a.asin(vec2(1)) ~= vec2(Pi/2)
    check a.asin(vec2()) ~= vec2()
    check asin(vec2(1)) ~= vec2(Pi/2)
    check asin(vec2()) ~= vec2()

  test "acos":
    var a = vec2()
    check a.acos(vec2(0)) ~= vec2(Pi/2)
    check a.acos(vec2(0.5)) ~= vec2(Pi/3)
    check acos(vec2(0)) ~= vec2(Pi/2)
    check acos(vec2(0.5)) ~= vec2(Pi/3)

  test "atan":
    var a = vec2()
    check a.atan(vec2(1)) ~= vec2(Pi/4)
    check a.atan(vec2(3).sqrt) ~= vec2(Pi/3)
    check atan(vec2(1)) ~= vec2(Pi/4)
    check atan(vec2(3).sqrt) ~= vec2(Pi/3)

  test "radians":
    var a = vec2()
    check a.radians(vec2(90, 60)) ~= vec2(Pi/2, Pi/3)
    check radians(vec2(90, 60)) ~= vec2(Pi/2, Pi/3)

  test "degrees":
    var a = vec2()
    check a.degrees(vec2(Pi/2, Pi/3)) ~= vec2(90, 60)
    check degrees(vec2(Pi/2, Pi/3)) ~= vec2(90, 60)

  test "lerp":
    var a = vec2()
    let
      b = vec2(0.74, 0.09)
      c = vec2(0.19, 0.98)
    check a.lerp(b, c, 0.5) ~= vec2(0.465, 0.535)
    check a.lerp(b, c, 0) == vec2(0.74, 0.09)
    check a.lerp(b, c, 1) == vec2(0.19, 0.98)
    check lerp(b, c, 0.5) ~= vec2(0.465, 0.535)
    check lerp(b, c, 0) == b
    check lerp(b, c, 1) == c

  test "angle":
    check angle(vec2(0, 1), vec2(1, 0)) ~= Pi/2
    check angle(vec2(1, 0), vec2(1, 1)) ~= Pi/4

  test "sameDirection":
    check sameDirection(vec2(0.7, 0), vec2(0.3, 0))
    check sameDirection(vec2(0, 0.06), vec2(0, 14.2))
