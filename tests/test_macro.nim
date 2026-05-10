# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
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
