# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

import types, vec2

type
  Rect2*[T: Scalar] = object
    pos*:  Vec2[T]  # top-left
    size*: Vec2[T]  # width, height

func rect2*[T: Scalar](x, y, w, h: T): Rect2[T] {.inline.} =
  Rect2[T](pos: vec2(x, y), size: vec2(w, h))

func rect2*[T: Scalar](pos, size: Vec2[T]): Rect2[T] {.inline.} =
  Rect2[T](pos: pos, size: size)

func left*[T: Scalar](r: Rect2[T]):   T {.inline.} = r.pos.x
func top*[T: Scalar](r: Rect2[T]):    T {.inline.} = r.pos.y
func right*[T: Scalar](r: Rect2[T]):  T {.inline.} = r.pos.x + r.size.x
func bottom*[T: Scalar](r: Rect2[T]): T {.inline.} = r.pos.y + r.size.y

func center*[T: Scalar](r: Rect2[T]): Vec2[T] {.inline.} =
  r.pos + r.size * 0.5f

func contains*[T: Scalar](r: Rect2[T], p: Vec2[T]): bool {.inline.} =
  p.x >= r.left and p.x <= r.right and
  p.y >= r.top  and p.y <= r.bottom

func overlaps*[T: Scalar](a, b: Rect2[T]): bool {.inline.} =
  a.left < b.right  and a.right  > b.left and
  a.top  < b.bottom and a.bottom > b.top

func `==`*[T: Scalar](a, b: Rect2[T]): bool {.inline.} =
  a.pos == b.pos and a.size == b.size

type
  Rect2px* = Rect2[Pixels]
  Rect2w*  = Rect2[WorldUnits]

{.pop.}
