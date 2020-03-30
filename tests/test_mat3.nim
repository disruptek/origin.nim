import std/math
import std/sequtils
import std/unittest

import origin/common
import origin/vec
import origin/mat

suite "mat3":

  test "accessors":
    var a = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
    check a.m00 == 1 and a.m10 == 2 and a.m20 == 3
    check a.m01 == 4 and a.m11 == 5 and a.m21 == 6
    check a.m02 == 7 and a.m12 == 8 and a.m22 == 9
    a[0] = 10; a[1] = 11; a[2] = 12
    a[3] = 13; a[4] = 14; a[5] = 15
    a[6] = 16; a[7] = 17; a[8] = 18
    check a.m00 == 10 and a.m10 == 11 and a.m20 == 12
    check a.m01 == 13 and a.m11 == 14 and a.m21 == 15
    check a.m02 == 16 and a.m12 == 17 and a.m22 == 18

  test "constructors":
    var a = mat3()
    check a.allIt(it == 0)
    a = mat3(2)
    check a.m00 == 2 and a.m10 == 0 and a.m20 == 0
    check a.m01 == 0 and a.m11 == 2 and a.m21 == 0
    check a.m02 == 0 and a.m12 == 0 and a.m22 == 2
    a = mat3(mat3())
    check a.allIt(it == 0)
    a = mat3(mat2(1, 2, 3, 4))
    check a.m00 == 1 and a.m10 == 2 and a.m20 == 0
    check a.m01 == 3 and a.m11 == 4 and a.m21 == 0
    check a.m02 == 0 and a.m12 == 0 and a.m22 == 1
    a = mat3(mat4(5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20))
    check a.m00 == 5 and a.m10 == 6 and a.m20 == 7
    check a.m01 == 9 and a.m11 == 10 and a.m21 == 11
    check a.m02 == 13 and a.m12 == 14 and a.m22 == 15
    a = mat3(vec3(1, 2, 3), vec3(4, 5, 6), vec3(7, 8, 9))
    check a.m00 == 1 and a.m10 == 2 and a.m20 == 3
    check a.m01 == 4 and a.m11 == 5 and a.m21 == 6
    check a.m02 == 7 and a.m12 == 8 and a.m22 == 9
    a = mat3(17, 18, 19, 20, 21, 22, 23, 24, 25)
    check a.m00 == 17 and a.m10 == 18 and a.m20 == 19
    check a.m01 == 20 and a.m11 == 21 and a.m21 == 22
    check a.m02 == 23 and a.m12 == 24 and a.m22 == 25

  test "constants":
    check mat3_zero.allIt(it == 0)
    check mat3_id.m00 == 1 and mat3_id.m10 == 0 and mat3_id.m20 == 0
    check mat3_id.m01 == 0 and mat3_id.m11 == 1 and mat3_id.m21 == 0
    check mat3_id.m02 == 0 and mat3_id.m12 == 0 and mat3_id.m22 == 1

  test "rand":
    var a = mat3()
    a.rand
    check a.allIt(it >= 0 and it <= 1)
    a.rand(50f..100f)
    check a.allIt(it >= 50 and it <= 100)
    a = Mat3.rand
    check a.allIt(it >= 0 and it <= 1)
    a = Mat3.rand(50f..100f)
    check a.allIt(it >= 50 and it <= 100)

  test "zero":
    var a = Mat3.rand
    a.zero
    check a.allIt(it == 0)

  test "~=":
    check mat3() ~= mat3(1e-5)
    check not(mat3() ~= mat3(1e-4))

  test "clamp":
    var a = mat3()
    let
      b = mat3(-1.5, 0.3, 1.2, 0.5, 2.1, 0.1, 0.4, 1.3, 1.1)
      c = mat3(0, 0.3, 1, 0.5, 1, 0.1, 0.4, 1, 1)
      d = mat3(-1.5, 0, 0, 0, 0, 0, 0, 0, 0)
      e = mat3(0, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1)
    a.clamp(b)
    check a == b
    a.clamp(b, 0f..1f)
    check a == c
    a.clamp(b, -1.5f..0f)
    check a == d
    a.clamp(b, 0f..0.1f)
    check a == e
    check b.clamp == b
    check b.clamp(0f..1f) == c
    check b.clamp(-1.5f..0f) == d
    check b.clamp(0f..0.1f) == e

  test "+":
    var a = mat3()
    let
      b = mat3(0.4, -0.8, 0.1, 0.3, 0.2, -0.6, 0.5, 0.9, 1.2)
      c = mat3(0.4, 0.6, -0.1, 0.4, 0.7, 0.9, -0.2, -0.8, 1.3)
      d = mat3(0.8, -0.2, 0, 0.7, 0.9, 0.3, 0.3, 0.1, 2.5)
    `+`(a, b, c)
    check a ~= d
    `+`(a, b, mat3())
    check a == b
    `+`(a, mat3(), b)
    check a == b
    check b + c ~= d
    check b + mat3() == b
    check mat3() + b == b

  test "-":
    var a = mat3()
    let
      b = mat3(0.4, -0.8, 0.1, 0.3, 0.2, -0.6, 0.5, 0.9, 1.2)
      c = mat3(0.4, 0.6, -0.1, 0.4, 0.7, 0.9, -0.2, -0.8, 1.3)
      d = mat3(0, -1.4, 0.2, -0.1, -0.5, -1.5, 0.7, 1.7, -0.1)
    `-`(a, b, c)
    check a ~= d
    `-`(a, b, mat3())
    check a == b
    check b - c ~= d
    check b - mat3() == b

  test "- (unary)":
    var a = mat3(0.7, -0.9, -0.1, 0.2, 1.2, 0, 0.4, 2.1, 1.3)
    let b = a
    let c = mat3(-0.7, 0.9, 0.1, -0.2, -1.2, 0, -0.4, -2.1, -1.3)
    -a
    check a == c
    check -b == c

  test "setId":
    var a = Mat3.rand
    a.setId
    check a.m00 == 1 and a.m10 == 0 and a.m20 == 0
    check a.m01 == 0 and a.m11 == 1 and a.m21 == 0
    check a.m02 == 0 and a.m12 == 0 and a.m22 == 1

  test "* (by mat4)":
    var a = mat3()
    let
      b = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
      c = mat3(30, 36, 42, 66, 81, 96, 102, 126, 150)
      d = mat3(1).rotate(PI/3)
      e = mat3(1).translate(vec2(5, 10))
      f = mat3(1).translate(vec2(10, 20))
    a.`*`(b, b)
    check a ~= c
    a.`*`(b, mat3_id)
    check a ~= b
    a.`*`(mat3_id, b)
    check a ~= b
    a.`*`(b, d)
    check not (a ~= d * b)
    check b * b ~= c
    check mat3_id * b ~= b
    check b * mat3_id ~= b
    check not (b * d ~= d * b)
    check translation(e * f) ~= vec2(15, 30)
    check translation(f * e) ~= vec2(15, 30)

  test "* (by vec3)":
    var a = vec3()
    let
      b = mat3(1).rotate(PI/3)
      c = vec3(1, 2, 3)
      d = vec3(-1.2320509, 1.8660254, 3)
    a.`*`(b, c)
    check a ~= d
    check b * c ~= d
    check mat3(1) * c ~= c

  test "column":
    var a = vec3()
    let b = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
    a.column(b, 1)
    check a == vec3(4, 5, 6)
    check b.column(2) == vec3(7, 8, 9)

  test "column=":
    var a = mat3()
    let
      b = mat3()
      c = vec3(1, 2, 3)
    a.`column=`(b, c, 2)
    check a.m02 == 1 and a.m12 == 2 and a.m22 == 3
    check b.`column=`(c, 1).column(1) == c

  test "copyRotation":
    var a = mat3(1)
    let
      b = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
      c = mat3(1, 2, 0, 4, 5, 0, 0, 0, 1)
    a.copyRotation(b)
    check a == c
    check b.copyRotation == c

  test "rotation":
    var a = vec2()
    let b = mat3(1).rotate(PI/3)
    a.rotation(b, Axis2d.X)
    check a ~= vec2(0.5, 0.86602545)
    a.rotation(b, Axis2d.Y)
    check a ~= vec2(-0.86602545, 0.5)
    check b.rotation(Axis2d.X) ~= vec2(0.5, 0.86602545)
    check b.rotation(Axis2d.Y) ~= vec2(-0.86602545, 0.5)

  test "rotation=":
    var a = mat3(1)
    let
      b = mat3(1, 0, 0, 0.5, 0.86602545, 0, 0, 0, 1)
      c = mat3(-0.86602545, 0.5, 0, 0, 1, 0, 0, 0, 1)
    a.`rotation=`(vec2(1, 0), Axis2d.X)
    check a ~= mat3(1)
    a = mat3(1)
    a.`rotation=`(vec2(0.5, 0.86602545), Axis2d.Y)
    check a ~= b
    a = mat3(1)
    a.`rotation=`(vec2(-0.86602545, 0.5), Axis2d.X)
    check a ~= c
    check mat3(1).`rotation=`(vec2(1, 0), Axis2d.X) ~= mat3(1)
    check mat3(1).`rotation=`(vec2(0.5, 0.86602545), Axis2d.Y) ~= b
    check mat3(1).`rotation=`(vec2(-0.86602545, 0.5), Axis2d.X) ~= c

  test "rotate":
    var a = mat3(1)
    let b = mat3(0.5, 0.86602545, 0, -0.86602545, 0.5, 0, 0, 0, 1)
    a.rotate(mat3_id, PI/3)
    check a ~= b
    check mat3_id.rotate(PI/3) ~= b

  test "normalizeRotation":
    var a = mat3(vec3(2, 0, 0), vec3(0, 3, 0), vec3(0, 0, 1))
    let b = a
    a.normalizeRotation(a)
    check a == mat3(1)
    check b.normalizeRotation ~= mat3(1)

  test "translation":
    var a = vec2()
    let b = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
    a.translation(b)
    check a ~= vec2(7, 8)
    check translation(b) ~= vec2(7, 8)

  test "translation=":
    var a = mat3(1)
    let b = mat3(1, 0, 0, 0, 1, 0, 10, 11, 1)
    a.`translation=`(a, vec2(10, 11))
    check a ~= b
    check mat3(1).`translation=`(vec2(10, 11)) ~= b

  test "translate":
    var a = mat3()
    let
      b = mat3(1).rotate(PI/3)
    a.translate(b, vec2(5, 10))
    check a.translation ~= vec2(5, 10)
    check b.`translation=`(vec2(5, 10)).translation ~= vec2(5, 10)

  test "scale (extract)":
    var a = vec2()
    let b = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
    a.scale(b)
    check a ~= vec2(2.236068, 6.403124)
    check scale(b) ~= vec2(2.236068, 6.403124)

  test "scale=":
    var a = mat3(1)
    a.`scale=`(a, vec2(2, 3))
    check a.m00 == 2 and a.m11 == 3
    check mat3(1).`scale=`(vec2(2, 3)).scale ~= vec2(2, 3)

  test "scale":
    var a = mat3(1)
    let
      b = mat3(10, 0, 0, 0, 20, 0, 0, 0, 2)
      c = mat3(20, 0, 0, 0, 60, 0, 0, 0, 2)
    a.scale(b, vec2(2, 3))
    check a ~= c
    check b.scale(vec2(2, 3)) ~= c

  test "transpose":
    var a = mat3(1)
    let
      b = mat3(1, 4, 7, 2, 5, 8, 3, 6, 9)
      c = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
    a.transpose(b)
    check a ~= c
    check b.transpose ~= c

  test "isOrthogonal":
    check mat3_id.rotate(PI).isOrthogonal
    check mat3_id.rotate(PI/2).isOrthogonal
    check mat3_id.rotate(PI/3).isOrthogonal

  test "trace":
    check mat3_zero.trace == 0f
    check mat3_id.trace == 3f
    check mat3(1, 2, 3, 4, 5, 6, 7, 8, 9).trace == 15f

  test "isDiagonal":
    check mat3_id.isDiagonal
    check not mat3(1, 2, 3, 4, 5, 6, 7, 8, 9).isDiagonal

  test "mainDiagonal":
    var a = vec3()
    let b = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
    a.mainDiagonal(b)
    check a ~= vec3(1, 5, 9)
    check b.mainDiagonal ~= vec3(1, 5, 9)

  test "antiDiagonal":
    var a = vec3()
    let b = mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)
    a.antiDiagonal(b)
    check a ~= vec3(7, 5, 3)
    check b.antiDiagonal ~= vec3(7, 5, 3)

