# gim

A 2D game library for Nim, where Nim's features are the foundation of every design decision.

_You can use the `gim.doc.nim` file as a cheatsheet_ \
_It might not be fully updated since the library is under development_ 

## Basic example

```nim
import gim

var tex: Texture
var cam = camera(
  target = Vec2px(x: Pixels(0f), y: Pixels(0f)),
  offset = Vec2px(x: Pixels(400f), y: Pixels(300f)),
  zoom = 2f)

game "My first game!", 800, 600:
  scene "Scene 1":
    onLoad:
      tex = loadTexture("assets/test.png")
    onUpdate(dt):
      if input.isKeyPressed(keyEscape):
        quit(0)
    onDraw:
      backend.clearScreen(0.1f, 0.1f, 0.1f, 1f)
      withCamera(cam):
        renderer.drawTexture(Vec2px(x: Pixels(0f), y: Pixels(0f)), tex)
```

gim is built around Nim's macro system. `game` is a macro that expands into a window, game loop, and scene state machine at compile time.

## Status

Early development. API is subject to change. Backend is SDL2 + OpenGL 3.3.
