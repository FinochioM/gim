# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

import types
import std/math

type
  Scalar* = concept s
    float32(s) is float32

  Vec2*[T: Scalar] = object
    x*, y*: T

func vec2*[T: Scalar](x, y: T): Vec2[T] {.inline.} = Vec2[T](x: x, y: y)
func vec2*[T: Scalar](v: float32): Vec2[T] {.inline.} = Vec2[T](x: T(v), y: T(v))

func `+`*[T: Scalar](a, b: Vec2[T]): Vec2[T] {.inline.} =
  Vec2[T](x: a.x + b.x, y: a.y + b.y)

func `-`*[T: Scalar](a, b: Vec2[T]): Vec2[T] {.inline.} =
  Vec2[T](x: a.x - b.x, y: a.y - b.y)

func `*`*[T: Scalar](a: Vec2[T], s: float32): Vec2[T] {.inline.} =
  Vec2[T](x: a.x * s, y: a.y * s)

func `/`*[T: Scalar](a: Vec2[T], s: float32): Vec2[T] {.inline.} =
  Vec2[T](x: a.x / s, y: a.y / s)

func `==`*[T: Scalar](a, b: Vec2[T]): bool {.inline.} =
  a.x == b.x and a.y == b.y

func dot*[T: Scalar](a, b: Vec2[T]): float32 {.inline.} =
  float32(a.x) * float32(b.x) + float32(a.y) * float32(b.y)

func lengthSq*[T: Scalar](a: Vec2[T]): float32 {.inline.} = dot(a, a)

func length*[T: Scalar](a: Vec2[T]): float32 {.inline.} =
  sqrt(a.lengthSq)

func normalize*[T: Scalar](a: Vec2[T]): Vec2[T] {.inline.} =
  let l = a.length
  if l == 0f: a else: a / l

func neg*[T: Scalar](a: Vec2[T]): Vec2[T] {.inline.} =
  Vec2[T](x: T(-float32(a.x)), y: T(-float32(a.y)))

type
  Vec2px* = Vec2[Pixels]
  Vec2w*  = Vec2[WorldUnits]

{.pop.}
