import gim

game "My first game!", 800, 600:
  scene "Play":
    onLoad:
      discard
    onUpdate(dt):
      discard
    onDraw:
      backend.clearScreen(0.15f, 0.15f, 0.2f, 1f)