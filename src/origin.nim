import strutils

import origin/common
import origin/vec
import origin/vec2
import origin/vec3
import origin/vec4
import origin/mat2
import origin/mat3
import origin/mat4

export vec, vec2, vec3, vec4, mat2, mat3, mat4

proc fmt*(x: float): string =
  x.formatFloat(ffDecimal, 6)

proc `$`*[N: static[int]](v: Vec[N]): string =
  ## Prints a vector readably.
  result = "["
  for i, c in v:
    result &= c.fmt
    if i < N-1: result &= ", "
  result &= "]"

proc `$`*[N: static[int]](m: Mat[N]): string =
  ## Prints a matrix readably.
  result = "["
  for col in 0..N-1:
    var i = 0
    for row in countup(0, (N*N)-1, N):
      result &= m[row+col].fmt
      i.inc
      if i < N: result &= ", "
    if col < N-1: result &= "\n "
  result &= "]"

echo vec3(4)
echo mat4(2)
