# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
import gim

var tex: Texture

game "My first game!", 800, 600:
  scene "Scene 1":
    onLoad:
      tex = loadTexture("assets/test.png")
    onUpdate(dt):
      if input.isKeyPressed(keySpace):
        switchScene("Scene 2")
    onDraw:
      backend.clearScreen(0.1f, 0.1f, 0.1f, 1f)
      renderer.drawTexture(Vec2px(x: Pixels(100f), y: Pixels(100f)), tex)

  scene "Scene 2":
    onUpdate(dt):
      if input.isKeyPressed(keyEscape):
        switchScene("Scene 1")
    onDraw:
      backend.clearScreen(0.15f, 0.15f, 0.15f, 1f)
      renderer.drawRect(Vec2px(x: Pixels(100f), y: Pixels(100f)),Vec2px(x: Pixels(200f), y: Pixels(150f)),Blue)
