# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
import std/macros

func sanitizeName(s: string): string =
  for c in s:
    result.add(if c == ' ': '_' else: c)

func newDiscardStmt(): NimNode =
  newNimNode(nnkDiscardStmt).add(newEmptyNode())

proc buildSceneProcs(sceneName: string, sceneBody: NimNode): NimNode =
  result = newStmtList()
  let prefix = "scene_" & sanitizeName(sceneName)

  var hasLoad, hasUpdate, hasDraw = false

  for hook in sceneBody:
    if hook.kind != nnkCall: continue
    case $hook[0]
    of "onLoad":
      hasLoad = true
      let pname = ident(prefix & "_onLoad")
      result.add newProc(pname, params = [newEmptyNode()], body = hook[^1])
    of "onUpdate":
      hasUpdate = true
      let pname = ident(prefix & "_onUpdate")
      result.add newProc(pname,
        params = [newEmptyNode(), newIdentDefs(hook[1], ident("float32"))],
        body   = hook[^1])
    of "onDraw":
      hasDraw = true
      let pname = ident(prefix & "_onDraw")
      result.add newProc(pname, params = [newEmptyNode()], body = hook[^1])
    else: discard

  if not hasLoad:
    result.add newProc(ident(prefix & "_onLoad"),
      params = [newEmptyNode()], body = newStmtList(newDiscardStmt()))
  if not hasUpdate:
    result.add newProc(ident(prefix & "_onUpdate"),
      params = [newEmptyNode(),
                newIdentDefs(ident("dt"), ident("float32"))],
      body = newStmtList(newDiscardStmt()))
  if not hasDraw:
    result.add newProc(ident(prefix & "_onDraw"),
      params = [newEmptyNode()], body = newStmtList(newDiscardStmt()))

proc buildSceneImpl(sceneName: string): NimNode =
  let prefix = "scene_" & sanitizeName(sceneName)
  result = newNimNode(nnkObjConstr)
  result.add ident("SceneImpl")
  result.add newColonExpr(ident("name"),     newStrLitNode(sceneName))
  result.add newColonExpr(ident("onLoad"),   ident(prefix & "_onLoad"))
  result.add newColonExpr(ident("onUpdate"), ident(prefix & "_onUpdate"))
  result.add newColonExpr(ident("onDraw"),   ident(prefix & "_onDraw"))

proc buildSwitchSceneProc(names: seq[string]): NimNode =
  var whenChain = newNimNode(nnkWhenStmt)

  for i, name in names:
    let cond  = infix(ident("name"), "==", newStrLitNode(name))
    let setIdx = newAssignment(ident("gimCurrent"), newLit(i))
    let gimSC  = newNimNode(nnkBracketExpr).add(ident("gimScenes"), ident("gimCurrent"))
    let callLoad = newIfStmt((
      infix(newDotExpr(gimSC, ident("onLoad")), "!=", newNilLit()),
      newStmtList(newCall(newDotExpr(gimSC, ident("onLoad"))))))
    whenChain.add newNimNode(nnkElifBranch).add(cond, newStmtList(setIdx, callLoad))

  let errNode = newNimNode(nnkPragma).add(
    newColonExpr(ident("error"), newStrLitNode("switchScene: unknown scene name")))
  whenChain.add newNimNode(nnkElse).add(newStmtList(errNode))

  let nameParam = newIdentDefs(
    ident("name"),
    newNimNode(nnkStaticTy).add(ident("string")))

  result = newProc(
    postfix(ident("switchScene"), "*"),
    params = [newEmptyNode(), nameParam],
    body   = newStmtList(whenChain))

macro game*(title: static string, width, height: static int,
            body: untyped): untyped =
  result = newStmtList()

  var sceneNames: seq[string]
  for node in body:
    if node.kind == nnkCommand and node.len >= 3 and
        node[0].eqIdent("scene") and node[1].kind == nnkStrLit:
      sceneNames.add node[1].strVal

  let arrayTy = newNimNode(nnkBracketExpr).add(
    ident("array"), newLit(sceneNames.len), ident("SceneImpl"))
  result.add newNimNode(nnkVarSection).add(
    newNimNode(nnkIdentDefs).add(ident("gimScenes"), arrayTy, newEmptyNode()))
  result.add newVarStmt(ident("gimCurrent"), newLit(0))

  result.add buildSwitchSceneProc(sceneNames)

  for node in body:
    if node.kind == nnkCommand and node.len >= 3 and
        node[0].eqIdent("scene") and node[1].kind == nnkStrLit:
      result.add buildSceneProcs(node[1].strVal, node[^1])

  for i, name in sceneNames:
    result.add newAssignment(
      newNimNode(nnkBracketExpr).add(ident("gimScenes"), newLit(i)),
      buildSceneImpl(name))

  let loop = quote do:
    import backend
    let cfg = BackendConfig(
      title:  `title`,
      width:  cint(`width`),
      height: cint(`height`))
    backend.init(cfg)
    if gimScenes[gimCurrent].onLoad != nil:
      gimScenes[gimCurrent].onLoad()
    while backend.isRunning():
      backend.pollEvents()
      let dt = backend.deltaTime()
      if gimScenes[gimCurrent].onUpdate != nil:
        gimScenes[gimCurrent].onUpdate(dt)
      if gimScenes[gimCurrent].onDraw != nil:
        gimScenes[gimCurrent].onDraw()
      backend.swapBuffers()
    backend.shutdown()
  result.add loop
