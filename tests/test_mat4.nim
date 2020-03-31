import std/math
import std/sequtils
import std/unittest

import origin/internal
import origin/vec
import origin/mat

suite "mat4":

  test "accessors":
    var a = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
    check a.m00 == 1 and a.m10 == 2 and a.m20 == 3 and a.m30 == 4
    check a.m01 == 5 and a.m11 == 6 and a.m21 == 7 and a.m31 == 8
    check a.m02 == 9 and a.m12 == 10 and a.m22 == 11 and a.m32 == 12
    check a.m03 == 13 and a.m13 == 14 and a.m23 == 15 and a.m33 == 16
    a[0] = 17; a[1] = 18; a[2] = 19; a[3] = 20
    a[4] = 21; a[5] = 22; a[6] = 23; a[7] = 24
    a[8] = 25; a[9] = 26; a[10] = 27; a[11] = 28
    a[12] = 29; a[13] = 30; a[14] = 31; a[15] = 32
    check a.m00 == 17 and a.m10 == 18 and a.m20 == 19 and a.m30 == 20
    check a.m01 == 21 and a.m11 == 22 and a.m21 == 23 and a.m31 == 24
    check a.m02 == 25 and a.m12 == 26 and a.m22 == 27 and a.m32 == 28
    check a.m03 == 29 and a.m13 == 30 and a.m23 == 31 and a.m33 == 32

  test "constructors":
    var a = mat4()
    check a.allIt(it == 0)
    a = mat4(2)
    check a.m00 == 2 and a.m10 == 0 and a.m20 == 0 and a.m30 == 0
    check a.m01 == 0 and a.m11 == 2 and a.m21 == 0 and a.m31 == 0
    check a.m02 == 0 and a.m12 == 0 and a.m22 == 2 and a.m32 == 0
    check a.m03 == 0 and a.m13 == 0 and a.m23 == 0 and a.m33 == 2
    a = mat4(mat4())
    check a.allIt(it == 0)
    a = mat4(mat2(1, 2, 3, 4))
    check a.m00 == 1 and a.m10 == 2 and a.m20 == 0 and a.m30 == 0
    check a.m01 == 3 and a.m11 == 4 and a.m21 == 0 and a.m31 == 0
    check a.m02 == 0 and a.m12 == 0 and a.m22 == 1 and a.m32 == 0
    check a.m03 == 0 and a.m13 == 0 and a.m23 == 0 and a.m33 == 1
    a = mat4(mat3(5, 6, 7, 8, 9, 10, 11, 12, 13))
    check a.m00 == 5 and a.m10 == 6 and a.m20 == 7 and a.m30 == 0
    check a.m01 == 8 and a.m11 == 9 and a.m21 == 10 and a.m31 == 0
    check a.m02 == 11 and a.m12 == 12 and a.m22 == 13 and a.m32 == 0
    check a.m03 == 0 and a.m13 == 0 and a.m23 == 0 and a.m33 == 1
    a = mat4(vec4(1, 2, 3, 4), vec4(5, 6, 7, 8), vec4(9, 10, 11, 12), vec4(13, 14, 15, 16))
    check a.m00 == 1 and a.m10 == 2 and a.m20 == 3 and a.m30 == 4
    check a.m01 == 5 and a.m11 == 6 and a.m21 == 7 and a.m31 == 8
    check a.m02 == 9 and a.m12 == 10 and a.m22 == 11 and a.m32 == 12
    check a.m03 == 13 and a.m13 == 14 and a.m23 == 15 and a.m33 == 16
    a = mat4(17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32)
    check a.m00 == 17 and a.m10 == 18 and a.m20 == 19 and a.m30 == 20
    check a.m01 == 21 and a.m11 == 22 and a.m21 == 23 and a.m31 == 24
    check a.m02 == 25 and a.m12 == 26 and a.m22 == 27 and a.m32 == 28
    check a.m03 == 29 and a.m13 == 30 and a.m23 == 31 and a.m33 == 32

  test "constants":
    check mat4_zero.allIt(it == 0)
    check mat4_id.m00 == 1 and mat4_id.m10 == 0 and mat4_id.m20 == 0 and mat4_id.m30 == 0
    check mat4_id.m01 == 0 and mat4_id.m11 == 1 and mat4_id.m21 == 0 and mat4_id.m31 == 0
    check mat4_id.m02 == 0 and mat4_id.m12 == 0 and mat4_id.m22 == 1 and mat4_id.m32 == 0
    check mat4_id.m03 == 0 and mat4_id.m13 == 0 and mat4_id.m23 == 0 and mat4_id.m33 == 1

  test "rand":
    var a = mat4()
    check a.rand.allIt(it >= 0 and it <= 1)
    check a.rand(50f..100f).allIt(it >= 50 and it <= 100)
    check Mat4.rand.allIt(it >= 0 and it <= 1)
    check Mat4.rand(50f..100f).allIt(it >= 50 and it <= 100)

  test "zero":
    var a = Mat4.rand
    check a.zero.allIt(it == 0)

  test "~=":
    check mat4() ~= mat4(1e-5)
    check not(mat4() ~= mat4(1e-4))

  test "clamp":
    var a = mat4()
    let
      b = mat4(-1.5, 0.3, 1.2, 0.5, 2.1, 0.1, 0.4, 1.3, 1.1, 0.1, 1.2, 0.8, 0.7, 1.4, 2.2, 0.4)
      c = mat4(0, 0.3, 1, 0.5, 1, 0.1, 0.4, 1, 1, 0.1, 1, 0.8, 0.7, 1, 1, 0.4)
      d = mat4(-1.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
      e = mat4(0, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1)
    check a.clamp(b) == b
    check a.clamp(b, 0f..1f) == c
    check a.clamp(b, -1.5f..0f) == d
    check a.clamp(b, 0f..0.1f) == e
    check b.clamp == b
    check b.clamp(0f..1f) == c
    check b.clamp(-1.5f..0f) == d
    check b.clamp(0f..0.1f) == e

  test "+":
    var a = mat4()
    let
      b = mat4(0.4, -0.8, 0.1, 0.3, 0.2, -0.6, 0.5, 0.9, 1.2, 0.3, 0.5, -0.1, -0.5, 1.2, 0.2, -1.3)
      c = mat4(0.4, 0.6, -0.1, 0.4, 0.7, 0.9, -0.2, -0.8, 1.3, 1.2, -0.8, 1.3, 0.1, 0.2, 0.8, 1.1)
      d = mat4(0.8, -0.2, 0, 0.7, 0.9, 0.3, 0.3, 0.1, 2.5, 1.5, -0.3, 1.2, -0.4, 1.4, 1, -0.2)
    check `+`(a, b, c) ~= d
    check `+`(a, b, mat4()) == b
    check `+`(a, mat4(), b) == b
    check b + c ~= d
    check b + mat4() == b
    check mat4() + b == b

  test "-":
    var a = mat4()
    let
      b = mat4(0.4, -0.8, 0.1, 0.3, 0.2, -0.6, 0.5, 0.9, 1.2, 0.3, 0.5, -0.1, -0.5, 1.2, 0.2, -1.3)
      c = mat4(0.4, 0.6, -0.1, 0.4, 0.7, 0.9, -0.2, -0.8, 1.3, 1.2, -0.8, 1.3, 0.1, 0.2, 0.8, 1.1)
      d = mat4(0, -1.4, 0.2, -0.1, -0.5, -1.5, 0.7, 1.7, -0.1, -0.9, 1.3, -1.4, -0.6, 1, -0.6, -2.4)
    check `-`(a, b, c) ~= d
    check `-`(a, b, mat4()) == b
    check b - c ~= d
    check b - mat4() == b

  test "- (unary)":
    var a = mat4(0.7, -0.9, -0.1, 0.2, 1.2, 0, 0.4, 2.1,
                 1.3, 0.4, 0.9, 1.2, 0.1, 2.1, 0.8, 0.2)
    let b = a
    let c = mat4(-0.7, 0.9, 0.1, -0.2, -1.2, 0, -0.4, -2.1,
                 -1.3, -0.4, -0.9, -1.2, -0.1, -2.1, -0.8, -0.2)
    check -a == c
    check -b == c

  test "setId":
    var a = Mat4.rand
    discard a.setId
    check a.m00 == 1 and a.m10 == 0 and a.m20 == 0 and a.m30 == 0
    check a.m01 == 0 and a.m11 == 1 and a.m21 == 0 and a.m31 == 0
    check a.m02 == 0 and a.m12 == 0 and a.m22 == 1 and a.m32 == 0
    check a.m03 == 0 and a.m13 == 0 and a.m23 == 0 and a.m33 == 1

  test "* (by mat4)":
    var a = mat4()
    let
      b = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
      c = mat4(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160)
      d = mat4(90, 100, 110, 120, 202, 228, 254, 280, 314, 356, 398, 440, 426, 484, 542, 600)
      e = mat4(1).rotate(vec3(Pi/3, 0, 0))
      f = mat4(1).rotate(vec3(0, Pi/4, 0))
      g = mat4(1).rotate(vec3(Pi/3, Pi/4, 0))
      h = mat4(1).translate(vec3(5, 10, 15))
      i = mat4(1).translate(vec3(10, 20, 30))
    check a.`*`(b, b) ~= d
    check a.`*`(b, mat4_id) ~= b
    check a.`*`(mat4_id, b) ~= b
    check b * b ~= d
    check mat4_id * b ~= b
    check b * mat4_id ~= b
    check b * c ~= c * b
    check e * f ~= g
    check not(e * f ~= f * e)
    check translation(h * g) ~= h.translation
    check translation(h * i) ~= vec3(15, 30, 45)
    check translation(i * h) ~= vec3(15, 30, 45)

  test "* (by vec4)":
    var a = vec4()
    let
      b = mat4(1).rotate(vec3(Pi/3, 0, 0))
      c = vec4(1, 2, 3, 4)
      d = vec4(1, -1.5980763, 3.232051, 4)
    check a.`*`(b, c) ~= d
    check b * c ~= d
    check mat4(1) * c ~= c

  test "column":
    var a = vec4()
    let b = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
    check a.column(b, 1) == vec4(5, 6, 7, 8)
    check b.column(2) == vec4(9, 10, 11, 12)

  test "column=":
    var a = mat4()
    let
      b = mat4()
      c = vec4(1, 2, 3, 4)
    discard a.`column=`(b, c, 2)
    check a.m02 == 1 and a.m12 == 2 and a.m22 == 3 and a.m32 == 4
    check b.`column=`(c, 3).column(3) == c

  test "copyRotation":
    var a = mat4(1)
    let
      b = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
      c = mat4(1, 2, 3, 0, 5, 6, 7, 0, 9, 10, 11, 0, 0, 0, 0, 1)
    check a.copyRotation(b) == c
    check b.copyRotation == c

  test "rotation":
    var a = vec3()
    let b = mat4(1).rotate(vec3(Pi/3, 0, 0))
    check a.rotation(b, Axis3d.X) ~= vec3(1, 0, 0)
    check a.rotation(b, Axis3d.Y) ~= vec3(0, 0.5, 0.86602545)
    check a.rotation(b, Axis3d.Z) ~= vec3(0, -0.86602545, 0.5)
    check b.rotation(Axis3d.X) ~= vec3(1, 0, 0)
    check b.rotation(Axis3d.Y) ~= vec3(0, 0.5, 0.86602545)
    check b.rotation(Axis3d.Z) ~= vec3(0, -0.86602545, 0.5)

  test "rotation=":
    var a = mat4(1)
    let
      b = mat4(1, 0, 0, 0, 0, 0.5, 0.86602545, 0, 0, 0, 1, 0, 0, 0, 0, 1)
      c = mat4(1, 0, 0, 0, 0, 1, 0, 0, 0, -0.86602545, 0.5, 0, 0, 0, 0, 1)
    check a.`rotation=`(vec3(1, 0, 0), Axis3d.X) ~= mat4(1)
    a = mat4(1)
    check a.`rotation=`(vec3(0, 0.5, 0.86602545), Axis3d.Y) ~= b
    a = mat4(1)
    check a.`rotation=`(vec3(0, -0.86602545, 0.5), Axis3d.Z) ~= c
    check mat4(1).`rotation=`(vec3(1, 0, 0), Axis3d.X) ~= mat4(1)
    check mat4(1).`rotation=`(vec3(0, 0.5, 0.86602545), Axis3d.Y) ~= b
    check mat4(1).`rotation=`(vec3(0, -0.86602545, 0.5), Axis3d.Z) ~= c

  test "rotate":
    var a = mat4(1)
    let
      b = mat4(1, 0, 0, 0, 0, 0.5, 0.86602545, 0, 0, -0.86602545, 0.5, 0, 0, 0, 0, 1)
      c = mat4(0.5, 0, -0.86602545, 0, 0, 1, 0, 0, 0.86602545, 0, 0.5, 0, 0, 0, 0, 1)
      d = mat4(0.5, 0.86602545, 0, 0, -0.86602545, 0.5, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
    check a.rotate(mat4_id, vec3(Pi/3, 0, 0)) ~= b
    a = mat4(1)
    check a.rotate(mat4_id, vec3(0, Pi/3, 0)) ~= c
    a = mat4(1)
    check a.rotate(mat4_id, vec3(0, 0, Pi/3)) ~= d

  test "normalizeRotation":
    var a = mat4(vec4(2, 0, 0, 0), vec4(0, 3, 0, 0), vec4(0, 0, 3, 0), vec4(0, 0, 0, 1))
    let b = a
    check a.normalizeRotation(a) ~= mat4(1)
    check b.normalizeRotation ~= mat4(1)

  test "translation":
    var a = vec3()
    let b = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
    check a.translation(b) ~= vec3(13, 14, 15)
    check translation(b) ~= vec3(13, 14, 15)

  test "translation=":
    var a = mat4(1)
    let b = mat4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 10, 11, 12, 1)
    check a.`translation=`(a, vec3(10, 11, 12)) ~= b
    check mat4(1).`translation=`(vec3(10, 11, 12)) ~= b

  test "translate":
    var a = mat4()
    let
      b = mat4(1).rotate(vec3(Pi/3, 0, 0))
    discard a.translate(b, vec3(5, 10, 15))
    check a.translation ~= vec3(5, 10, 15)
    check b.`translation=`(vec3(5, 10, 15)).translation ~= vec3(5, 10, 15)

  test "scale (extract)":
    var a = vec3()
    let b = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
    check a.scale(b) ~= vec3(3.741657, 10.488089, 17.378147)
    check scale(b) ~= vec3(3.741657, 10.488089, 17.378147)

  test "scale=":
    var a = mat4(1)
    discard a.`scale=`(a, vec3(1, 2, 3))
    check a.m00 == 1 and a.m11 == 2 and a.m22 == 3
    check mat4(1).`scale=`(vec3(1, 2, 3)).scale ~= vec3(1, 2, 3)

  test "scale":
    var a = mat4(1)
    let
      b = mat4(10, 0, 0, 0, 0, 20, 0, 0, 0, 0, 30, 0, 0, 0, 0, 2)
      c = mat4(10, 0, 0, 0, 0, 40, 0, 0, 0, 0, 90, 0, 0, 0, 0, 2)
    check a.scale(b, vec3(1, 2, 3)) ~= c
    check b.scale(vec3(1, 2, 3)) ~= c

  test "transpose":
    var a = mat4(1)
    let
      b = mat4(1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16)
      c = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
    check a.transpose(b) ~= c
    check b.transpose ~= c

  test "isOrthogonal":
    check mat4_id.rotate(vec3(Pi, 0, 0)).isOrthogonal
    check mat4_id.rotate(vec3(Pi/2, 0, 0)).isOrthogonal
    check mat4_id.rotate(vec3(Pi, Pi/2, 0)).isOrthogonal
    check mat4_id.rotate(vec3(Pi, Pi/3, 0)).isOrthogonal
    check mat4_id.rotate(vec3(Pi, Pi/2, Pi/3)).isOrthogonal

  test "orthoNormalize":
    var a = mat4(1)
    let
      b = mat4(0, 0, 1, 0, 1, 0, 0, 0,
                 -0.12988785, 0.3997815, 0.5468181, 0, 1.0139829, -0.027215311, 0.18567966, 0)
      c = mat4(0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1)
    check a.orthoNormalize(b) ~= c
    check b.orthoNormalize ~= c

  test "trace":
    check mat4_zero.trace == 0f
    check mat4_id.trace == 4f
    check mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16).trace == 34f

  test "isDiagonal":
    check mat4_id.isDiagonal
    check not mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16).isDiagonal

  test "mainDiagonal":
    var a = vec4()
    let b = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
    check a.mainDiagonal(b) ~= vec4(1, 6, 11, 16)
    check b.mainDiagonal ~= vec4(1, 6, 11, 16)

  test "antiDiagonal":
    var a = vec4()
    let b = mat4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
    check a.antiDiagonal(b) ~= vec4(13, 10, 7, 4)
    check b.antiDiagonal ~= vec4(13, 10, 7, 4)

  test "determinant":
    check mat4(1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16).determinant == 0f
    check mat4(1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16).determinant == 0f
    check mat4_id.determinant == 1f
    check mat4_id.rotate(vec3(Pi/3, 0, 0)).determinant == 1f
    check mat4(1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1).determinant == -1f

  test "invertOrthogonal":
    var a = mat4()
    let
      b = mat4_id.rotate(vec3(Pi, Pi/2, Pi/3))
      c = mat4(0, 0.86602545, 0.5, 0, 0, -0.5, 0.86602545, 0, 1, 0, 0, 0, 0, 0, 0, 1)
    check a.invertOrthogonal(b) ~= c
    check b.invertOrthogonal ~= c

  test "invert":
    var a = mat4()
    let
      b = mat4_id.rotate(vec3(Pi/3, 0, 0))
      c = mat4_id.rotate(vec3(-Pi/3, 0, 0))
    check a.invert(b) ~= c
    check b.invert ~= c

  test "lookAt":
    var a = mat4(1)
    let
      b = mat4(-0.7071068, 0, 0.7071068, 0, 0, 1, 0, 0,
               -0.7071068, 0, -0.7071068, 0, 0.7071068, 0, -0.7071068, 1)
      c = mat4(0.9622504, 0.05143445, 0.26726124, 0, -0.19245008, 0.8229512, 0.5345225, 0,
               -0.19245008, -0.5657789, 0.80178374, 0, -2.3841858e-7, -9.536743e-7, -18.708286, 1)
    check a.lookAt(vec3(1, 0, 0), vec3(0, 0, 1), vec3(0, 1, 0)) ~= b
    a = mat4(1)
    check a.lookAt(vec3(5, 10, 15), vec3(), vec3(0, 1, -1)) ~= c
    check lookAt(vec3(1, 0, 0), vec3(0, 0, 1), vec3(0, 1, 0)) ~= b
    check lookAt(vec3(5, 10, 15), vec3(), vec3(0, 1, -1)) ~= c

  test "ortho":
    var a = mat4()
    let b = mat4(0.05, 0, 0, 0, 0, 0.1, 0, 0, 0, 0, -0.002, 0, 0, 0, -1, 1)
    check a.ortho(-20, 20, -10, 10, 0, 1000) ~= b
    check ortho(-20, 20, -10, 10, 0, 1000) ~= b

  test "perspective":
    var a = mat4()
    let b = mat4(0.9742786, 0, 0, 0, 0, 1.7320509, 0, 0, 0, 0, -1.002002, -1, 0, 0, -2.002002, 0)
    check a.perspective(Pi/3, 16/9, 1, 1000) ~= b
    check perspective(Pi/3, 16/9, 1, 1000) ~= b




