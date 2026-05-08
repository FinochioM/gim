# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

import std/math
import types, vec2

type
  Transform2* = object
    pos*:      Vec2px
    rotation*: Radians
    scale*:    Vec2[WorldUnits]

func transform2*(pos: Vec2px,
                 rotation = Radians(0f),
                 scale    = Vec2[WorldUnits](x: WorldUnits(1f),
                                            y: WorldUnits(1f))): Transform2 {.inline.} =
  Transform2(pos: pos, rotation: rotation, scale: scale)

func identity*(_: typedesc[Transform2]): Transform2 {.inline.} =
  Transform2(pos:      Vec2px(x: Pixels(0f), y: Pixels(0f)),
             rotation: Radians(0f),
             scale:    Vec2[WorldUnits](x: WorldUnits(1f), y: WorldUnits(1f)))

func forward*(t: Transform2): Vec2[float32] {.inline.} =
  let r = float32(t.rotation)
  Vec2[float32](x: cos(r), y: sin(r))

func rotated*(t: Transform2, delta: Radians): Transform2 {.inline.} =
  Transform2(pos: t.pos,
             rotation: Radians(float32(t.rotation) + float32(delta)),
             scale: t.scale)

func translated*(t: Transform2, delta: Vec2px): Transform2 {.inline.} =
  Transform2(pos: t.pos + delta, rotation: t.rotation, scale: t.scale)

{.pop.}
