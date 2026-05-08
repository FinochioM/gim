# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

type
  SceneImpl* = object
    name*:     string
    onLoad*:   proc() {.raises: [].}
    onUpdate*: proc(dt: float32) {.raises: [].}
    onDraw*:   proc() {.raises: [].}

type
  SceneStatus* = enum
    ssActive
    ssTransitioning
    ssPaused
    ssStopped

  SceneEvent* = enum
    seLoad
    seUnload
    seUpdate
    seDraw
    sePause
    seResume

  SceneTransition* = object
    target*: string   ## name of next scene
    delay*:  float32  ## seconds before switch

  Scene* = object
    name*:   string
    status*: SceneStatus

  SceneCmd* = object
    case kind*: SceneEvent
    of seUpdate:
      dt*: float32
    of seLoad, seUnload, seDraw, sePause, seResume:
      discard

func isActive*(s: Scene): bool {.inline.}       = s.status == ssActive
func isPaused*(s: Scene): bool {.inline.}        = s.status == ssPaused
func isStopped*(s: Scene): bool {.inline.}       = s.status == ssStopped
func isTransitioning*(s: Scene): bool {.inline.} = s.status == ssTransitioning

{.pop.}
