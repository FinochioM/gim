# gim

A 2D game library for Nim, where Nim's features are the foundation of every design decision.

_You can use the `gim.doc.nim` file as a cheatsheet_ \
_It might not be fully updated since the library is under development_ 

## Basic example

```nim
import gim

game "My Game", 800, 600:
  scene "Play":
    onLoad:
      player = newSprite("player.png", at(100, 200))
    onUpdate(dt):
      player.move(input.axis() * dt)
    onDraw:
      player.draw()
```

gim is built around Nim's macro system. `game` is a macro that expands into a window, game loop, and scene state machine at compile time.

## Status

Early development. API is subject to change. Backend is SDL2 + OpenGL 3.3.
