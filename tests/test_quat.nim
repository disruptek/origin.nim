import std/math
import std/sequtils
import std/unittest

import origin/common
import origin/vec
import origin/mat
import origin/quat

suite "quat":

  test "accessors":
    var a = quat(1, 2, 3, 4)
    check a.w == 1 and a.x == 2 and a.y == 3 and a.z == 4
    a[0] = 10; a[1] = 11; a[2] = 12; a[3] = 13
    check a.w == 10 and a.x == 11 and a.y == 12 and a.z == 13

  test "constructors":
    var a = quat()
    check a.allIt(it == 0)
    a = quat(2)
    check a.w == 2 and a.x == 0 and a.y == 0 and a.z == 0
    a = quat(1, 2, 3, 4)
    check a.w == 1 and a.x == 2 and a.y == 3 and a.z == 4
    a = quat(vec3(5, 6, 7))
    check a.w == 0 and a.x == 5 and a.y == 6 and a.z == 7
    a = quat(vec4(8, 9, 10, 11))
    check a.w == 8 and a.x == 9 and a.y == 10 and a.z == 11

  test "constants":
    check quat_zero.allIt(it == 0)
    check quat_id.w == 1 and quat_id.x == 0 and quat_id.y == 0 and quat_id.z == 0

  test "rand":
    var a = quat()
    a.rand
    check a.allIt(it >= 0 and it <= 1)
    a.rand(50f..100f)
    check a.allIt(it >= 50 and it <= 100)
    a = Quat.rand
    check a.allIt(it >= 0 and it <= 1)
    a = Quat.rand(50f..100f)
    check a.allIt(it >= 50 and it <= 100)

  test "zero":
    var a = Quat.rand
    a.zero
    check a.allIt(it == 0)

  test "~=":
    check quat() ~= quat(1e-5)
    check not(quat() ~= quat(1e-4))

  test "+":
    var a = quat()
    let
      b = quat(0.4, -0.8, 0.1, 0.3)
      c = quat(0.4, 0.6, -0.1, 0.4)
      d = quat(0.8, -0.2, 0, 0.7)
    `+`(a, b, c)
    check a ~= d
    `+`(a, b, quat())
    check a == b
    `+`(a, quat(), b)
    check a == b
    check b + c ~= d
    check b + quat() == b
    check quat() + b == b

  test "-":
    var a = quat()
    let
      b = quat(0.4, -0.8, 0.1, 0.3)
      c = quat(0.4, 0.6, -0.1, 0.4)
      d = quat(0, -1.4, 0.2, -0.1)
    `-`(a, b, c)
    check a ~= d
    `-`(a, b, quat())
    check a == b
    check b - c ~= d
    check b - quat() == b

  test "- (unary)":
    var a = quat(0.7, -0.9, -0.1, 0.2)
    let b = a
    let c = quat(-0.7, 0.9, 0.1, -0.2)
    -a
    check a == c
    check -b == c

  test "*":
    var a = quat()
    let
      b = quat(1, 2, 3, 4)
      c = quat(10, 20, 30, 40)
      d = quat(-280, 40, 60, 80)
      e = quat_id.rotateEuler(vec3(PI/3, 0, 0))
      f = quat_id.rotateEuler(vec3(0, PI/4, 0))
      g = quat_id.rotateEuler(vec3(PI/3, PI/4, 0))
    a.`*`(b, c)
    check a ~= d
    a.`*`(b, quat_id)
    check a ~= b
    a.`*`(quat_id, b)
    check a ~= b
    a.`*`(b, d)
    check a ~= d * b
    a.`*`(e, f)
    check a ~= g
    check not (a ~= f * e)
    check b * c ~= d
    check b * quat_id ~= b
    check quat_id * b ~= b
    check b * d ~= d * b
    check e * f ~= g
    check not (e * f ~= f * e)

  test "* (scalar)":
    var a = quat()
    let
      b = quat(0.2, -0.4, 0.6, 0.3)
      c = quat(0.1, -0.2, 0.3, 0.15)
    a.`*`(b, 0.5)
    check a ~= c
    check b * 0.5 ~= c

  test "conjugate":
    var a = quat()
    let
      b = quat(0.87, 0.65, -0.11, -0.47)
      c = quat(0.87, -0.65, 0.11, 0.47)
    a.conjugate(b)
    check a ~= c
    check b.conjugate ~= c

  test "cross":
    var a = quat()
    let
      b = quat(0.86602545, 0.5, 0, 0)
      c = quat(0.86602545, 0, 0.5, 0)
      d = quat(0.75, 0, 0.4330127, 0.25)
    a.cross(b, c)
    check a ~= d
    check cross(b, c) ~= d

  test "lenSq":
    check quat().lenSq == 0f
    check quat(2, 3, 4, 5).lenSq == 54f

  test "len":
    check quat().len == 0f
    check quat(0.32, 0.25, 0.44, 0.52).len ~= 0.79303216f

  test "normalize":
    var a = quat()
    let
      b = quat(-0.24647212, -0.812474, 0.9715252, 0.8300271)
      c = quat(-0.16065533, -0.52958643, 0.6332591, 0.5410279)
    a.normalize(b)
    check a ~= c
    a.normalize(quat(2, 0, 0, 0))
    check a ~= quat_id
    check b.normalize ~= c
    check quat(2, 0, 0, 0).normalize ~= quat_id

  test "dot":
    let
      a = quat(-0.55014205, 0.66294193, -0.44094658, 0.1688292)
      b = quat(0.5137224, 0.83796954, -0.9853494, -0.3770373)
    check dot(a, b) ~= 0.64373636

  test "inverse":
    var a = quat()
    let
      b = quat(0.19171429, -0.8571534, 0.4451759, 0.39651704)
      c = quat(0.17012934, 0.76064724, -0.39505392, -0.35187355)
    a.inverse(b)
    check a ~= c
    check b.inverse ~= c

  test "rotateEuler":
    var a = quat()
    let
      b = quat(0.86602545, 0.5, 0, 0)
      c = quat(0.86602545, 0, 0.5, 0)
      d = quat(0.86602545, 0, 0, 0.5)
      e = vec3(PI/3, 0, 0)
      f = vec3(0, PI/3, 0)
      g = vec3(0, 0, PI/3)
    a.rotateEuler(quat_id, e)
    check a ~= b
    a.rotateEuler(quat_id, f)
    check a ~= c
    a.rotateEuler(quat_id, g)
    check a ~= d
    check quat_id.rotateEuler(e) ~= b
    check quat_id.rotateEuler(f) ~= c
    check quat_id.rotateEuler(g) ~= d

  test "toEulerAngle":
    var a = vec3()
    let
      b = quat(1, 0.86602545, 0.5, 0)
      c = vec3(2.0943952, 1.5707964, 1.0471976)
    a.toEulerAngle(b)
    check a ~= c
    check b.toEulerAngle ~= c

  test "fromAxisAngle":
    var a = quat()
    let b = quat(0.86602545, 0, 0.5, 0)
    a.fromAxisAngle(vec3(0, 1, 0), PI/3)
    check a ~= b
    check fromAxisAngle(vec3(0, 1, 0), PI/3) ~= b

  test "toVec3":
    var a = vec3()
    let b = quat(1, 2, 3, 4)
    a.toVec3(b)
    check a ~= vec3(2, 3, 4)
    check b.toVec3 ~= vec3(2, 3, 4)

  test "toVec4":
    var a = vec4()
    let b = quat(1, 2, 3, 4)
    a.toVec4(b)
    check a ~= vec4(1, 2, 3, 4)
    check b.toVec4 ~= vec4(1, 2, 3, 4)

  test "toMat3":
    var a = mat3()
    let
      b = quat_id.rotateEuler(vec3(PI/3, 0, 0))
      c = mat3(1, 0, 0, 0, 0.5, 0.86602545, 0, -0.86602545, 0.5)
    a.toMat3(b)
    check a ~= c
    check b.toMat3 ~= c

  test "toMat4":
    var a = mat4()
    let
      b = quat_id.rotateEuler(vec3(PI/3, 0, 0))
      c = mat4(1, 0, 0, 0, 0, 0.5, 0.86602545, 0, 0, -0.86602545, 0.5, 0, 0, 0, 0, 1)
    a.toMat4(b)
    check a ~= c
    check b.toMat4 ~= c

  test "fromMat":
    var a = quat()
    let
      b = mat3(1, 0, 0, 0, 0.5, 0.86602545, 0, -0.86602545, 0.5)
      c = mat4(1, 0, 0, 0, 0, 0.5, 0.86602545, 0, 0, -0.86602545, 0.5, 0, 0, 0, 0, 1)
      d = quat_id.rotateEuler(vec3(PI/3, 0, 0))
    a.fromMat(b)
    check a ~= d
    a.fromMat(c)
    check a ~= d
    check b.fromMat ~= d
    check c.fromMat ~= d

  test "slerp":
    var a = quat()
    let
      b = quat(-0.15230274, 0.7359729, -0.27456188, -0.28505945)
      c = quat(0.594954, 0.030960321, -0.037411213, -0.02747035)
      d = quat(-0.5157237, 0.4865686, -0.16367096, -0.17777666)
    a.slerp(b, c, 0.5)
    check a ~= d
    check slerp(b, c, 0.5) ~= d

  test "orient":
    var a = quat()
    a.orient(Space.local,
              (Axis3d.X, PI.float32/2),
              (Axis3d.Y, PI.float32/3),
              (Axis3d.Z, PI.float32/4))
    check a ~= quat(0.701057, 0.430459, 0.560986, -0.092296)
    check orient(Space.local,
                  (Axis3d.X, PI.float32/2),
                  (Axis3d.Y, PI.float32/3),
                  (Axis3d.Z, PI.float32/4)) ~= quat(0.701057, 0.430459, 0.560986, -0.092296)


