{.push raises: [].}
import std/math

type
  Pixels*     = distinct float32
  WorldUnits* = distinct float32
  Radians*    = distinct float32
  Degrees*    = distinct float32
  ZLayer*     = distinct int32
  EntityId*   = distinct uint32

func `+`*(a, b: Pixels): Pixels {.inline.} = Pixels(float32(a) + float32(b))
func `-`*(a, b: Pixels): Pixels {.inline.} = Pixels(float32(a) - float32(b))
func `*`*(a: Pixels, b: float32): Pixels {.inline.} = Pixels(float32(a) * b)
func `/`*(a: Pixels, b: float32): Pixels {.inline.} = Pixels(float32(a) / b)
func `<`*(a, b: Pixels): bool {.inline.} = float32(a) < float32(b)
func `<=`*(a, b: Pixels): bool {.inline.} = float32(a) <= float32(b)
func `==`*(a, b: Pixels): bool {.inline.} = float32(a) == float32(b)

func `+`*(a, b: WorldUnits): WorldUnits {.inline.} = WorldUnits(float32(a) + float32(b))
func `-`*(a, b: WorldUnits): WorldUnits {.inline.} = WorldUnits(float32(a) - float32(b))
func `*`*(a: WorldUnits, b: float32): WorldUnits {.inline.} = WorldUnits(float32(a) * b)
func `/`*(a: WorldUnits, b: float32): WorldUnits {.inline.} = WorldUnits(float32(a) / b)
func `<`*(a, b: WorldUnits): bool {.inline.} = float32(a) < float32(b)
func `<=`*(a, b: WorldUnits): bool {.inline.} = float32(a) <= float32(b)
func `==`*(a, b: WorldUnits): bool {.inline.} = float32(a) == float32(b)

const
  DegToRad* = PI.float32 / 180'f32
  RadToDeg* = 180'f32 / PI.float32

func toRadians*(d: Degrees): Radians {.inline.} =
  Radians(float32(d) * DegToRad)

func toDegrees*(r: Radians): Degrees {.inline.} =
  Degrees(float32(r) * RadToDeg)

func `<`*(a, b: ZLayer): bool {.inline.} = int32(a) < int32(b)
func `<=`*(a, b: ZLayer): bool {.inline.} = int32(a) <= int32(b)
func `==`*(a, b: ZLayer): bool {.inline.} = int32(a) == int32(b)

const InvalidEntity*: EntityId = EntityId(0)
func `==`*(a, b: EntityId): bool {.inline.} = uint32(a) == uint32(b)
func isValid*(id: EntityId): bool {.inline.} = id != InvalidEntity

{.pop.}