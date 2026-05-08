# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

type
  Color* = object
    r*, g*, b*, a*: float32

func rgba*(r, g, b, a: float32): Color {.inline.} = Color(r: r, g: g, b: b, a: a)
func rgb*(r, g, b: float32):     Color {.inline.} = Color(r: r, g: g, b: b, a: 1f)

func rgba8*(r, g, b, a: uint8): Color {.inline.} =
  Color(r: float32(r)/255f, g: float32(g)/255f,
        b: float32(b)/255f, a: float32(a)/255f)

func rgb8*(r, g, b: uint8): Color {.inline.} = rgba8(r, g, b, 255)

func hex*(v: uint32): Color {.inline.} =
  rgba8(uint8(v shr 24),       uint8((v shr 16) and 0xff),
        uint8((v shr 8) and 0xff), uint8(v and 0xff))

func `==`*(a, b: Color): bool {.inline.} =
  a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a

func lerp*(a, b: Color, t: float32): Color {.inline.} =
  Color(r: a.r + (b.r - a.r) * t, g: a.g + (b.g - a.g) * t,
        b: a.b + (b.b - a.b) * t, a: a.a + (b.a - a.a) * t)

func withAlpha*(c: Color, a: float32): Color {.inline.} =
  Color(r: c.r, g: c.g, b: c.b, a: a)

const
  White*       = Color(r: 1f, g: 1f, b: 1f, a: 1f)
  Black*       = Color(r: 0f, g: 0f, b: 0f, a: 1f)
  Transparent* = Color(r: 0f, g: 0f, b: 0f, a: 0f)
  Red*         = Color(r: 1f, g: 0f, b: 0f, a: 1f)
  Green*       = Color(r: 0f, g: 1f, b: 0f, a: 1f)
  Blue*        = Color(r: 0f, g: 0f, b: 1f, a: 1f)

{.pop.}
