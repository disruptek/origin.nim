import std/macros
import strutils

type
  Storage*[N: static[int]] = array[N, float32]
  Space* {.pure.} = enum
    local, world
  Axis2d* {.pure.} = enum
    X, Y
  Axis3d* {.pure.} = enum
    X, Y, Z

proc fmt*(x: float): string =
  x.formatFloat(ffDecimal, 6)

macro genComponentWiseBool*[N: static[int]](op; a, b: Storage[N]; args: varargs[untyped]): bool =
  for i in countdown(N-1, 0):
    var check = nnkCall.newTree(
      op,
      nnkBracketExpr.newTree(a, newLit(i)),
      nnkBracketExpr.newTree(b, newLit(i)))
    for arg in args:
      check.add arg
    if result.kind == nnkEmpty:
      result = check
    else:
      result = nnkInfix.newTree(ident("and"), check, result)

proc `~=`*(a, b: float32; tolerance = 1e-5): bool =
  abs(a-b) < tolerance

proc lerp*(a, b, v: float32): float32 =
  a * (1 - v) + b * v

