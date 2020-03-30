import std/math

const half_pi = PI/2

proc sineOut*(t: SomeFloat): SomeFloat {.inline.} =
  sin(half_pi * t)

proc sineIn*(t: SomeFloat): SomeFloat {.inline.} =
  sin((t - 1) * half_pi) + 1

proc sineInOut*(t: SomeFloat): SomeFloat {.inline.} =
  (1 - cos(t * PI)) * 0.5

proc quadraticOut*(t: SomeFloat): SomeFloat {.inline.} =
  -(t * (t - 2))

proc quadraticIn*(t: SomeFloat): SomeFloat {.inline.} =
  t * t

proc quadraticInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t > 0.5:
    t * t * 2
  else:
    (t * t * -2) + (t * 4) - 1

proc cubicOut*(t: SomeFloat): SomeFloat {.inline.} =
  let f = t - 1
  f * f * f + 1

proc cubicIn*(t: SomeFloat): SomeFloat {.inline.} =
  t ^ 3

proc cubicInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t < 0.5:
    t * t * t * 4
  else:
    let f = t * 2 - 2
    f * f * f * 0.5 + 1

proc quarticOut*(t: SomeFloat): SomeFloat {.inline.} =
  let f = t - 1
  f * f * f * (1 - t) + 1

proc quarticIn*(t: SomeFloat): SomeFloat {.inline.} =
  t * t * t * t

proc quarticInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t < 0.5:
    t * t * t * t * 8
  else:
    let f = t - 1
    f * f * f * f * -8 + 1

proc quinticOut*(t: SomeFloat): SomeFloat {.inline.} =
  let f = t - 1
  f * f * f * f * f + 1

proc quinticIn*(t: SomeFloat): SomeFloat {.inline.} =
  t * t * t * t * t

proc quinticInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t < 0.5:
    t * t * t * t * t * 16
  else:
    let f = t * 2 - 2
    f * f * f * f * f * 0.5 + 1

proc exponentialOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t == 1:
    t
  else:
    1 - pow(2, -10 * t)

proc exponentialIn*(t: SomeFloat): SomeFloat {.inline.} =
  if t == 0:
    t
  else:
    pow(2, 10 * (t - 1))

proc exponentialInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t == 0 or t == 1:
    t
  elif t < 0.5:
    pow(2, t * 20 - 10) * 0.5
  else:
    pow(2, t * -20 + 10) * -0.5 + 1

proc circularOut*(t: SomeFloat): SomeFloat {.inline.} =
  sqrt((2 - t) * t)

proc circularIn*(t: SomeFloat): SomeFloat {.inline.} =
  1 - sqrt(1 - t * t)

proc circularInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t < 0.5:
    (1 - sqrt(1 - t * t * 4)) * 0.5
  else:
    (sqrt(-((t * 2) - 3) * ((t * 2) - 1)) + 1) * 0.5

proc backOut*(t: SomeFloat): SomeFloat {.inline.} =
  let f = 1 - t
  1 - f * f * f * f * sin(f * PI)

proc backIn*(t: SomeFloat): SomeFloat {.inline.} =
  t * t * t * t * sin(t * PI)

proc backInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t < 0.5:
    let f = t * 2
    (f * f * f * f * sin(f * PI)) * 0.5
  else:
    let f = 1 - (t * 2 - 1)
    ((1 - (f * f * f * f * sin(f * PI))) + 0.5) * 0.5

proc elasticOut*(t: SomeFloat): SomeFloat {.inline.} =
  sin(-13 * half_pi * (t + 1)) * pow(2, -10 * t) + 1

proc elasticIn*(t: SomeFloat): SomeFloat {.inline.} =
  sin(13 * half_pi * t) * pow(2, 10 * (t - 1))

proc elasticInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t < 0.5:
    sin(13 * half_pi * t * 2) * pow(2, 10 * ((t * 2) - 1)) * 0.5
  else:
    (sin(-13 * half_pi * ((t * 2 - 1) + 1)) * pow(2, -10 * (t * 2 - 1)) + 2) * 0.5

proc bounceOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t < 4/11:
    (121 * t * t) / 16
  elif t < 8/11:
    (363/40 * t * t) - (99/10 * t) + 17/5
  elif t < 9/10:
    (4356/361 * t * t) - (35442/1805 * t) + 16061/1805
  else:
    (54/5 * t * t) - (513/25 * t) + 268/25

proc bounceIn*(t: SomeFloat): SomeFloat {.inline.} =
  1 - bounceOut(1 - t)

proc bounceInOut*(t: SomeFloat): SomeFloat {.inline.} =
  if t < 0.5:
    bounceIn(t * 2) * 0.5
  else:
    bounceOut(t * 2 - 1) * 0.5 + 0.5

proc hermiteCurve*(t: SomeFloat): SomeFloat {.inline.} =
  t * t * (3 - (t * 2))

proc quinticCurve*(t: SomeFloat): SomeFloat {.inline.} =
  pow(t, 3) * ((t * 6 - 15) * t + 10)
