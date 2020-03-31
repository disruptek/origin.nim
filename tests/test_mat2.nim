import std/math
import std/sequtils
import std/unittest

import origin/internal
import origin/vec
import origin/mat

suite "mat2":

  test "accessors":
    var a = mat2(1, 2, 3, 4)
    check a.m00 == 1 and a.m10 == 2 and a.m01 == 3 and a.m11 == 4
    a[0] = 10; a[1] = 11; a[2] = 12; a[3] = 13
    check a.m00 == 10 and a.m10 == 11 and a.m01 == 12 and a.m11 == 13

  test "constructors":
    var a = mat2()
    check a.allIt(it == 0)
    a = mat2(2)
    check a.m00 == 2 and a.m10 == 0 and a.m01 == 0 and a.m11 == 2
    a = mat2(mat2())
    check a.allIt(it == 0)
    a = mat2(vec2(1, 2), vec2(3, 4))
    check a.m00 == 1 and a.m10 == 2 and a.m01 == 3 and a.m11 == 4
    a = mat2(5, 6, 7, 8)
    check a.m00 == 5 and a.m10 == 6 and a.m01 == 7 and a.m11 == 8

  test "constants":
    check mat2_zero.allIt(it == 0)
    check mat2_id.m00 == 1 and mat2_id.m10 == 0 and mat2_id.m01 == 0 and mat2_id.m11 == 1

  test "rand":
    var a = mat2()
    check a.rand.allIt(it >= 0 and it <= 1)
    check a.rand(50f..100f).allIt(it >= 50 and it <= 100)
    check Mat2.rand.allIt(it >= 0 and it <= 1)
    check Mat2.rand(50f..100f).allIt(it >= 50 and it <= 100)

  test "zero":
    var a = Mat2.rand
    check a.zero.allIt(it == 0)

  test "~=":
    check mat2() ~= mat2(1e-5)
    check not(mat2() ~= mat2(1e-4))

  test "clamp":
    var a = mat2()
    let
      b = mat2(-1.5, 0.3, 1.2, 0.5)
      c = mat2(0, 0.3, 1, 0.5)
      d = mat2(-1.5, 0, 0, 0)
      e = mat2(0, 0.1, 0.1, 0.1)
    check a.clamp(b) == b
    check a.clamp(b, 0f..1f) == c
    check a.clamp(b, -1.5f..0f) == d
    check a.clamp(b, 0f..0.1f) == e
    check b.clamp == b
    check b.clamp(0f..1f) == c
    check b.clamp(-1.5f..0f) == d
    check b.clamp(0f..0.1f) == e

  test "+":
    var a = mat2()
    let
      b = mat2(0.4, -0.8, 0.1, 0.3)
      c = mat2(0.4, 0.6, -0.1, 0.4)
      d = mat2(0.8, -0.2, 0, 0.7)
    check `+`(a, b, c) ~= d
    check `+`(a, b, mat2()) == b
    check `+`(a, mat2(), b) == b
    check b + c ~= d
    check b + mat2() == b
    check mat2() + b == b

  test "-":
    var a = mat2()
    let
      b = mat2(0.4, -0.8, 0.1, 0.3)
      c = mat2(0.4, 0.6, -0.1, 0.4)
      d = mat2(0, -1.4, 0.2, -0.1)
    check `-`(a, b, c) ~= d
    check `-`(a, b, mat2()) == b
    check b - c ~= d
    check b - mat2() == b

  test "- (unary)":
    var a = mat2(0.7, -0.9, -0.1, 0.2)
    let b = a
    let c = mat2(-0.7, 0.9, 0.1, -0.2)
    check -a == c
    check -b == c

  test "setId":
    var a = Mat2.rand
    discard a.setId
    check a.m00 == 1 and a.m10 == 0 and a.m01 == 0 and a.m11 == 1

  test "*":
    var a = mat2()
    let
      b = mat2(1, 2, 3, 4)
      c = mat2(7, 10, 15, 22)
      d = mat2(1).rotate(Pi/3)
    check a.`*`(b, b) == c
    check a.`*`(b, mat2_id) ~= b
    check a.`*`(mat2_id, b) ~= b
    check not (a.`*`(b, d) == d * b)
    check b * b ~= c
    check mat2_id * b ~= b
    check b * mat2_id ~= b
    check not (b * d ~= d * b)

  test "column":
    var a = vec2()
    let b = mat2(1, 2, 3, 4)
    check a.column(b, 1) == vec2(3, 4)
    check b.column(0) == vec2(1, 2)

  test "column=":
    var a = mat2()
    let
      b = mat2()
      c = vec2(2, 3)
    discard a.`column=`(b, c, 1)
    check a.m01 == 2 and a.m11 == 3
    check b.`column=`(c, 1).column(1) == c

  test "rotation":
    var a = vec2()
    let b = mat2(1).rotate(Pi/3)
    check a.rotation(b, Axis2d.X) ~= vec2(0.5, 0.86602545)
    check a.rotation(b, Axis2d.Y) ~= vec2(-0.86602545, 0.5)
    check b.rotation(Axis2d.X) ~= vec2(0.5, 0.86602545)
    check b.rotation(Axis2d.Y) ~= vec2(-0.86602545, 0.5)

  test "rotation=":
    var a = mat2(1)
    let
      b = mat2(1, 0, 0.5, 0.86602545)
      c = mat2(-0.86602545, 0.5, 0, 1)
    check a.`rotation=`(vec2(1, 0), Axis2d.X) ~= mat2(1)
    a = mat2(1)
    check a.`rotation=`(vec2(0.5, 0.86602545), Axis2d.Y) ~= b
    a = mat2(1)
    check a.`rotation=`(vec2(-0.86602545, 0.5), Axis2d.X) ~= c
    check mat2(1).`rotation=`(vec2(1, 0), Axis2d.X) ~= mat2(1)
    check mat2(1).`rotation=`(vec2(0.5, 0.86602545), Axis2d.Y) ~= b
    check mat2(1).`rotation=`(vec2(-0.86602545, 0.5), Axis2d.X) ~= c

  test "rotate":
    var a = mat2(1)
    let b = mat2(0.5, 0.86602545, -0.86602545, 0.5)
    check a.rotate(mat2_id, Pi/3) ~= b
    check mat2_id.rotate(Pi/3) ~= b

  test "transpose":
    var a = mat2(1)
    let
      b = mat2(1, 3, 2, 4)
      c = mat2(1, 2, 3, 4)
    check a.transpose(b) ~= c
    check b.transpose ~= c

  test "isOrthogonal":
    check mat2_id.rotate(Pi).isOrthogonal
    check mat2_id.rotate(Pi/2).isOrthogonal
    check mat2_id.rotate(Pi/3).isOrthogonal

  test "trace":
    check mat2_zero.trace == 0f
    check mat2_id.trace == 2f
    check mat2(1, 2, 3, 4).trace == 5f

  test "isDiagonal":
    check mat2_id.isDiagonal
    check not mat2(1, 2, 3, 4).isDiagonal

  test "mainDiagonal":
    var a = vec2()
    let b = mat2(1, 2, 3, 4)
    check a.mainDiagonal(b) ~= vec2(1, 4)
    check b.mainDiagonal ~= vec2(1, 4)

  test "antiDiagonal":
    var a = vec2()
    let b = mat2(1, 2, 3, 4)
    check a.antiDiagonal(b) ~= vec2(3, 2)
    check b.antiDiagonal ~= vec2(3, 2)
