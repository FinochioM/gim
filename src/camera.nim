# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

import std/math
import types, vec2, renderer

type Camera* = object
  target*: Vec2Px
  offset*: Vec2Px
  zoom*: float32
  rotation*: Radians

func camera*(target: Vec2px = Vec2px(x: Pixels(0f), y: Pixels(0f)),
  offset: Vec2px = Vec2px(x: Pixels(0f), y: Pixels(0f)),
  zoom: float32 = 1f,
  rotation: Radians = Radians(0f)): Camera {.inline.} =
    Camera(target: target, offset: offset, zoom: zoom, rotation: rotation)

func mat4Mul(a, b: array[16, float32]): array[16, float32] {.inline.} =
  for col in 0..3:
    for row in 0..3:
      var s = 0f
      for k in 0..3:
        s += a[row + k * 4] * b[k + col * 4]
      result[row + col * 4] = s

func ortho2D(w, h: float32): array[16, float32] {.inline.} =
  [ 2f/w,  0f,    0f, 0f,
    0f,   -2f/h,  0f, 0f,
    0f,    0f,   -1f, 0f,
    -1f,    1f,    0f, 1f ]

func viewMatrix(cam: Camera): array[16, float32] {.inline.} =
  let
    cr  = cos(float32(cam.rotation))
    sr  = sin(float32(cam.rotation))
    z   = cam.zoom
    tx  = float32(cam.target.x)
    ty  = float32(cam.target.y)
    ox  = float32(cam.offset.x)
    oy  = float32(cam.offset.y)
    wtx = -z * cr * tx - z * sr * ty + ox
    wty =  z * sr * tx - z * cr * ty + oy
  result = [ z*cr, -z*sr, 0f, 0f,
              z*sr,  z*cr, 0f, 0f,
              0f,    0f,   1f, 0f,
              wtx,   wty,  0f, 1f ]

func toProjection*(cam: Camera, w, h: int): array[16, float32] {.inline.} =
  mat4Mul(ortho2D(float32(w), float32(h)), viewMatrix(cam))

template withCamera*(cam: Camera, body: untyped) =
  block:
    var proj = cam.toProjection(renderer.screenWidth(), renderer.screenHeight())
    renderer.setProjection(proj)
    body
    renderer.resetProjection()

func screenToWorld*(screenPos: Vec2px, cam: Camera): Vec2px {.inline.} =
  let
    cr = cos(float32(cam.rotation))
    sr = sin(float32(cam.rotation))
    z  = cam.zoom
    dx = float32(screenPos.x) - float32(cam.offset.x)
    dy = float32(screenPos.y) - float32(cam.offset.y)
    wx = (cr * dx - sr * dy) / z + float32(cam.target.x)
    wy = (sr * dx + cr * dy) / z + float32(cam.target.y)
  Vec2px(x: Pixels(wx), y: Pixels(wy))

func worldToScreen*(worldPos: Vec2px, cam: Camera): Vec2px {.inline.} =
  let
    cr = cos(float32(cam.rotation))
    sr = sin(float32(cam.rotation))
    z  = cam.zoom
    dx = float32(worldPos.x) - float32(cam.target.x)
    dy = float32(worldPos.y) - float32(cam.target.y)
    sx = z * ( cr * dx + sr * dy) + float32(cam.offset.x)
    sy = z * (-sr * dx + cr * dy) + float32(cam.offset.y)
  Vec2px(x: Pixels(sx), y: Pixels(sy))

{.pop.}
