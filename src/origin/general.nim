import vec
import mat
import quat

proc unproject*[T: Vec3](o: var T, pt: T, m, p: Mat4, vp: Vec4): T =
  var tmp = vec4()
  let
    inv_pm = invert(p * m)
    i = vec4((pt.x - vp.x) * 2 / vp.z - 1, (pt.y - vp.y) * 2 / vp.w - 1, pt.z * 2 - 1, 1)
  tmp.`*`(inv_pm, i)
  if tmp.w == 0: return
  o.scale(vec3(tmp), 1/tmp.w)

proc unproject*[T: Vec3](pt: T, m, p: Mat4, vp: Vec4): T =
  result.unproject(pt, m, p, vp)

proc translatePoint*[T: Vec3](pt: T, dir: T, dist: float32): T =
  pt + dir.scale(dist)

proc lineSegmentMidpoint*[T: Vec3](pt1, pt2: T): T =
  lerp(pt1, pt2, 0.5)

proc lineDirection*[T: Vec3](pt1, pt2: T): T =
  normalize(pt2 - pt1)

proc linePlaneIntersect*[T: Vec3](linePt1, linePt2, planePt, planeNormal: T): T =
  let
    dir = lineDirection(linePt1, linePt2)
    dirDotPlane = dot(dir, planeNormal)
    planeLine = linePt1 - planePt
  if dirDotPlane == 0:
    vec3()
  else:
    let dist = -dot(planeNormal, planeLine) / dirDotPlane
    linePt1.translatePoint(dir, dist)

proc linePointDistance*[T: Vec3](linePt1, linePt2, pt: T): float32 =
  let
    dir = lineDirection(linePt1, linePt2)
    intersect = linePlaneIntersect(linePt1, linePt2, pt, dir)
  dist(pt, intersect)

proc velocity*[T: Vec3](o: var T, axis: T, rate: float32) =
  o.normalize(axis)
  o.`*`(o, rate)

proc velocity*(axis: Vec3, rate: float32): Vec3 =
  result.velocity(axis, rate)

proc velocityToRotation*(o: var Quat, vel: Vec3, delta: float32) =
  let tmp = vel.normalize
  o.fromAxisAngle(tmp, vel.len * delta)
  o.normalize(o)

proc velocityToRotation*(vel: Vec3, delta: float32): Quat =
  result.velocityToRotation(vel, delta)

