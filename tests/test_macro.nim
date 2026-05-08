import gim

game "My first game!", 800, 600:
  scene "Test Scene":
    onLoad:
      discard
    onUpdate(dt):
      if input.isKeyPressed(keyEscape):
        quit(0)
    onDraw:
      backend.clearScreen(0.15f, 0.15f, 0.2f, 1f)
      renderer.drawRect(Vec2px(x: Pixels(100f), y: Pixels(100f)),Vec2px(x: Pixels(200f), y: Pixels(150f)),Red)