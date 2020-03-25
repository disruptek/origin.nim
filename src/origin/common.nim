import std/fenv
import std/macros
import strutils

type Storage*[N: static[int]] = array[N, float32]

proc fmt*(x: float): string =
  x.formatFloat(ffDecimal, 6)

macro genComponentWiseBool*[N: static[int]](op; a1, a2: Storage[N]; args: varargs[untyped]): bool =
  for i in countdown(N-1, 0):
    var check = nnkCall.newTree(
      op,
      nnkBracketExpr.newTree(a1, newLit(i)),
      nnkBracketExpr.newTree(a2, newLit(i)))
    for arg in args:
      check.add arg
    if result.kind == nnkEmpty:
      result = check
    else:
      result = nnkInfix.newTree(ident("and"), check, result)

proc `~=`*(x, y: float32; tolerance = 1e-5): bool =
  if x == y:
    return true
  let
    ax = abs(x)
    ay = abs(y)
    diff = abs(x-y)
    cmb = ax+ay
    min = float32.minimumPositiveValue
    max = float32.maximumPositiveValue
  if x == 0 or y == 0 or (cmb < min):
    return diff < (tolerance * min)
  result = diff / min(cmb, max) < tolerance

proc lerp*(a, b, v: float32): float32 =
  a * (1 - v) + b * v

