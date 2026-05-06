{.push raises: [].}

import sdl2
import opengl

type
  BackendConfig* = object
    title*:  cstring
    width*:  cint
    height*: cint

  Backend* = object
    window*:   WindowPtr
    glCtx*:    GlContextPtr
    running*:  bool
    lastTick*: uint32

var gBackend: Backend

proc isRunning*(): bool {.inline.} = gBackend.running

proc initGl*() {.raises: [].} =
  {.cast(raises: []).}:
    loadExtensions()
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc clearScreen*(r, g, b, a: float32) {.raises: [].} =
  {.cast(raises: []).}:
    glClearColor(r, g, b, a)
    glClear(GL_COLOR_BUFFER_BIT)

proc init*(cfg: BackendConfig) =
  if sdl2.init(INIT_VIDEO or INIT_JOYSTICK) != SdlSuccess:
    gBackend.running = false
    return

  discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
  discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
  discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
  discard glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)

  gBackend.window = createWindow(
    cfg.title,
    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
    cfg.width, cfg.height,
    SDL_WINDOW_OPENGL or SDL_WINDOW_SHOWN)

  if gBackend.window == nil:
    sdl2.quit()
    gBackend.running = false
    return

  gBackend.glCtx = glCreateContext(gBackend.window)
  if gBackend.glCtx == nil:
    destroyWindow(gBackend.window)
    sdl2.quit()
    gBackend.running = false
    return

  initGl()

  gBackend.running  = true
  gBackend.lastTick = getTicks()

proc shutdown*() =
  if gBackend.glCtx != nil: glDeleteContext(gBackend.glCtx)
  if gBackend.window != nil: destroyWindow(gBackend.window)
  sdl2.quit()
  gBackend.running = false

proc pollEvents*() =
  var evt = sdl2.defaultEvent
  while sdl2.pollEvent(evt):
    case evt.kind
    of QuitEvent:
      gBackend.running = false
    else: discard

proc deltaTime*(): float32 =
  let now  = getTicks()
  let dt   = float32(now - gBackend.lastTick) / 1000f
  gBackend.lastTick = now
  dt

proc swapBuffers*() =
  glSwapWindow(gBackend.window)

{.pop.}