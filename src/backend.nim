# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

import sdl2
import opengl
import renderer
import input

## Imports: sdl2, opengl, renderer, input.
## The main purpose of this file is to be a setup layer for SDL and OPENGL.
## This file is mainly used by `gamemacro.nim`.
##
## **NOTE**: Later on we could support different backends (GLFW for example)
## In that case only this file would change, `gamemacro` would still only
## call `backend.nim`.

type
  ## Data struct with window title, width and height.
  ## Passed into `init` as the window config.
  BackendConfig* = object
    title*:  cstring
    width*:  cint
    height*: cint

  ## Internal state of the backend.
  ## It holds the SDL window pointer, the opengl context, a flag
  ## for the running state and a timestamp for delta time.
  ## It is used as a global named `gBackend` because there is only
  ## one window.
  Backend* = object
    window*:   WindowPtr
    glCtx*:    GlContextPtr
    running*:  bool
    lastTick*: uint32

var gBackend: Backend

## Reads the state of the `running` flag (from the Backend object)
## This is called every frame inside the game loop.
## The game keeps running while this returns true and stops when
## it returns false.
proc isRunning*(): bool {.inline.} = gBackend.running

## Loads the OpenGL extensions so function pointers can be resolved.
## --
## **NOTE**: This also sets the alpha blend mode once to
## `GL_BLEND`, which is the "normal" transparency mode.
## This might change in the future, it would be nice to have
## configurable blend modes instead of setting one as default.
proc initGl*() {.raises: [].} =
  {.cast(raises: []).}:
    loadExtensions()
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

## Sets a color and clears the color buffer.
## This is called at the start of `onDraw`.
## --
## **NOTE**: depth buffer is not being used at the moment.
## This might change in the future for things like
## Z-layer ordering.
proc clearScreen*(r, g, b, a: float32) {.raises: [].} =
  {.cast(raises: []).}:
    glClearColor(r, g, b, a)
    glClear(GL_COLOR_BUFFER_BIT)

## This is the main function from the backend.
## It does a few things lised below:
## - initializes SDL (video & joystick, although the latter is unused)
## - sets OPENGL version hints (3.3 core)
## - requests an OPENGL double buffer.
## - creates the window
## - creates the OPENGL context and attaches it to the window.
## - calls the `initGl` and `renderer.initRenderer` functions.
## - sets the `running` flag to true.
## - when the program fails for any reason it sets `running` to false.
##
## **NOTE**: This might change in the future.
## Currently the program failing just means "stop running". At some
## point I would want to have better logging and error handling.
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
  renderer.initRenderer(cfg.width.int, cfg.height.int)

  gBackend.running  = true
  gBackend.lastTick = getTicks()

## This does the opposite to the `init` function.
## It tears everything down in the reverse order
## ** OPENGL context -> window -> SDL quit. **
## It sets the `running` flag to false.
## SDL and OPENGL use C pointers, so we have to clean
## them up manually.
proc shutdown*() =
  if gBackend.glCtx != nil: glDeleteContext(gBackend.glCtx)
  if gBackend.window != nil: destroyWindow(gBackend.window)
  sdl2.quit()
  gBackend.running = false

## This maps SDL events into the library's own input system.
## It starts by calling `inputBeginFrame` which returns a
## snapshot of the previous frame.
## Then matches each SDL event into the specific library
## event.
##
## **NOTE**: This is missing a LOT of events such as
## window resize, scroll wheel, gamepad later on.
proc pollEvents*() =
  inputBeginFrame()
  var evt = sdl2.defaultEvent
  while sdl2.pollEvent(evt):
    case evt.kind
    of QuitEvent:
      gBackend.running = false
    of KeyDown:
      inputHandleKey(evt.key.keysym.scancode, true)
    of KeyUp:
      inputHandleKey(evt.key.keysym.scancode, false)
    of MouseButtonDown:
      inputHandleMouseButton(evt.button.button, true)
    of MouseButtonUp:
      inputHandleMouseButton(evt.button.button, false)
    of MouseMotion:
      inputHandleMouseMove(evt.motion.x, evt.motion.y)
    of MouseWheel:
      inputHandleScroll(float32(evt.wheel.y))
    else: discard

## This computes the time since the last call (in seconds)
## It uses SDL's tick counter for this.
## This is called once per frame inside the game loop.
proc deltaTime*(): float32 =
  let now  = getTicks()
  let dt   = float32(now - gBackend.lastTick) / 1000f
  gBackend.lastTick = now
  dt

## This flips the back buffer to the screen.
## Is is called at the end of every frame.
proc swapBuffers*() =
  glSwapWindow(gBackend.window)

{.pop.}
