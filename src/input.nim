# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

import sdl2

type
  Key* = enum
    keyUnknown
    keyA, keyB, keyC, keyD, keyE, keyF, keyG, keyH, keyI, keyJ, keyK, keyL,
    keyM, keyN, keyO, keyP, keyQ, keyR, keyS, keyT, keyU, keyV, keyW, keyX,
    keyY, keyZ
    key0, key1, key2, key3, key4, key5, key6, key7, key8, key9
    keySpace, keyEnter, keyEscape, keyBackspace, keyTab
    keyLeft, keyRight, keyUp, keyDown
    keyLShift, keyRShift, keyLCtrl, keyRCtrl, keyLAlt, keyRAlt

  MouseButton* = enum
    mbLeft, mbMiddle, mbRight

  InputState = object
    keys:     array[Key, bool]   ## held this frame
    keysPrev: array[Key, bool]   ## held last frame
    mouse:    array[MouseButton, bool]
    mousePrev: array[MouseButton, bool]
    mouseX*, mouseY*: int32

var gInput: InputState

func toKey(sc: Scancode): Key {.inline.} =
  case sc
  of SDL_SCANCODE_A: keyA
  of SDL_SCANCODE_B: keyB
  of SDL_SCANCODE_C: keyC
  of SDL_SCANCODE_D: keyD
  of SDL_SCANCODE_E: keyE
  of SDL_SCANCODE_F: keyF
  of SDL_SCANCODE_G: keyG
  of SDL_SCANCODE_H: keyH
  of SDL_SCANCODE_I: keyI
  of SDL_SCANCODE_J: keyJ
  of SDL_SCANCODE_K: keyK
  of SDL_SCANCODE_L: keyL
  of SDL_SCANCODE_M: keyM
  of SDL_SCANCODE_N: keyN
  of SDL_SCANCODE_O: keyO
  of SDL_SCANCODE_P: keyP
  of SDL_SCANCODE_Q: keyQ
  of SDL_SCANCODE_R: keyR
  of SDL_SCANCODE_S: keyS
  of SDL_SCANCODE_T: keyT
  of SDL_SCANCODE_U: keyU
  of SDL_SCANCODE_V: keyV
  of SDL_SCANCODE_W: keyW
  of SDL_SCANCODE_X: keyX
  of SDL_SCANCODE_Y: keyY
  of SDL_SCANCODE_Z: keyZ
  of SDL_SCANCODE_0: key0
  of SDL_SCANCODE_1: key1
  of SDL_SCANCODE_2: key2
  of SDL_SCANCODE_3: key3
  of SDL_SCANCODE_4: key4
  of SDL_SCANCODE_5: key5
  of SDL_SCANCODE_6: key6
  of SDL_SCANCODE_7: key7
  of SDL_SCANCODE_8: key8
  of SDL_SCANCODE_9: key9
  of SDL_SCANCODE_SPACE:     keySpace
  of SDL_SCANCODE_RETURN:    keyEnter
  of SDL_SCANCODE_ESCAPE:    keyEscape
  of SDL_SCANCODE_BACKSPACE: keyBackspace
  of SDL_SCANCODE_TAB:       keyTab
  of SDL_SCANCODE_LEFT:      keyLeft
  of SDL_SCANCODE_RIGHT:     keyRight
  of SDL_SCANCODE_UP:        keyUp
  of SDL_SCANCODE_DOWN:      keyDown
  of SDL_SCANCODE_LSHIFT:    keyLShift
  of SDL_SCANCODE_RSHIFT:    keyRShift
  of SDL_SCANCODE_LCTRL:     keyLCtrl
  of SDL_SCANCODE_RCTRL:     keyRCtrl
  of SDL_SCANCODE_LALT:      keyLAlt
  of SDL_SCANCODE_RALT:      keyRAlt
  else: keyUnknown

proc inputBeginFrame*() =
  gInput.keysPrev   = gInput.keys
  gInput.mousePrev  = gInput.mouse

proc inputHandleKey*(sc: Scancode, down: bool) =
  let k = toKey(sc)
  if k != keyUnknown:
    gInput.keys[k] = down

proc inputHandleMouseButton*(btn: uint8, down: bool) =
  case btn
  of BUTTON_LEFT:   gInput.mouse[mbLeft]   = down
  of BUTTON_MIDDLE: gInput.mouse[mbMiddle] = down
  of BUTTON_RIGHT:  gInput.mouse[mbRight]  = down
  else: discard

proc inputHandleMouseMove*(x, y: int32) =
  gInput.mouseX = x
  gInput.mouseY = y

proc isKeyDown*(k: Key): bool {.inline.} =
  gInput.keys[k]

proc isKeyPressed*(k: Key): bool {.inline.} =
  gInput.keys[k] and not gInput.keysPrev[k]

proc isKeyReleased*(k: Key): bool {.inline.} =
  not gInput.keys[k] and gInput.keysPrev[k]

proc isMouseDown*(btn: MouseButton): bool {.inline.} =
  gInput.mouse[btn]

proc isMousePressed*(btn: MouseButton): bool {.inline.} =
  gInput.mouse[btn] and not gInput.mousePrev[btn]

proc isMouseReleased*(btn: MouseButton): bool {.inline.} =
  not gInput.mouse[btn] and gInput.mousePrev[btn]

proc mousePos*(): tuple[x, y: int32] {.inline.} =
  (gInput.mouseX, gInput.mouseY)

{.pop.}
