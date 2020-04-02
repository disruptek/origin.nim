import std/macros
import std/strutils

type
  Storage*[N: static[int]] = array[N, float32]
  Space* {.pure.} = enum
    local, world
  Axis2d* {.pure.} = enum
    X, Y
  Axis3d* {.pure.} = enum
    X, Y, Z

macro genAccessors*(t; components: varargs[untyped]) =
  let
    brkGetter = ident "[]"
    brkSetter = ident "[]="
  result = nnkStmtList.newTree
  result.add quote do:
    proc `brkGetter`*(t: `t`; i: int): float32 {.inline.} = t.data[i]
    proc `brkGetter`*(t: var `t`; i: int): var float32 {.inline.} = t.data[i]
    proc `brkGetter`*(t: `t`; i: Slice[int]): seq[float32] {.inline.} = t.data[i]
    proc `brkSetter`*(t: var `t`; i: int; v: float32) {.inline.} = t.data[i] = v
    proc `brkSetter`*(t: var `t`; i: Slice[int]; v: openarray[float32]) {.inline.} = t.data[i] = v
    iterator items*(t: `t`): float32 {.inline.} =
      for x in t.data.items: yield x
    iterator mitems*(t: var `t`): var float32 {.inline.} =
      for x in t.data.mitems: yield x
    iterator pairs*(t: `t`): tuple[key: int; value: float32] {.inline.} =
      for i, x in t.data.pairs: yield (i, x)
    iterator mpairs*(t: var `t`): tuple[key: int; value: var float32] {.inline.} =
      for i, x in t.data.mpairs: yield (i, x)
  for i, x in components:
    let
      compGetter = ident $x
      compSetter = ident($x & "=")
    result.add quote do:
      template `compGetter`*(t: `t`): float32 {.dirty.} = t[`i`]
      template `compGetter`*(t: var `t`): var float32 {.dirty.} = t[`i`]
      template `compSetter`*(t: var `t`; value: float32) {.dirty.} = t[`i`] = value

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

