import std/macros

proc buildSceneProcs(sceneName: string, sceneBody: NimNode): NimNode =
  result = newStmtList()
  let prefix = "scene_" & sceneName

  for hook in sceneBody:
    if hook.kind != nnkCall: continue
    case $hook[0]
    of "onLoad":
      let pname = ident(prefix & "_onLoad")
      result.add newProc(pname, params = [newEmptyNode()], body = hook[^1])
    of "onUpdate":
      let pname = ident(prefix & "_onUpdate")
      result.add newProc(pname,
        params = [newEmptyNode(), newIdentDefs(hook[1], ident("float32"))],
        body   = hook[^1])
    of "onDraw":
      let pname = ident(prefix & "_onDraw")
      result.add newProc(pname, params = [newEmptyNode()], body = hook[^1])
    else: discard

proc buildSceneImpl(sceneName: string): NimNode =
  let prefix = "scene_" & sceneName
  result = newNimNode(nnkObjConstr)
  result.add ident("SceneImpl")
  result.add newColonExpr(ident("name"),     newStrLitNode(sceneName))
  result.add newColonExpr(ident("onLoad"),   ident(prefix & "_onLoad"))
  result.add newColonExpr(ident("onUpdate"), ident(prefix & "_onUpdate"))
  result.add newColonExpr(ident("onDraw"),   ident(prefix & "_onDraw"))

macro game*(title: static string, width, height: static int,
            body: untyped): untyped =
  result = newStmtList()

  var sceneNames: seq[string]

  for node in body:
    let isScene = node.kind == nnkCommand and node.len >= 3 and
                  node[0].eqIdent("scene") and node[1].kind == nnkStrLit
    if not isScene: continue
    let sceneName = node[1].strVal
    sceneNames.add sceneName
    result.add buildSceneProcs(sceneName, node[^1])

  var arr = newNimNode(nnkBracket)
  for name in sceneNames:
    arr.add buildSceneImpl(name)
  result.add newVarStmt(ident("gimScenes"), arr)

  let loop = quote do:
    import backend
    let cfg = BackendConfig(
      title:  `title`,
      width:  cint(`width`),
      height: cint(`height`))
    backend.init(cfg)
    var current = 0
    if gimScenes[current].onLoad != nil:
      gimScenes[current].onLoad()
    while backend.isRunning():
      backend.pollEvents()
      let dt = backend.deltaTime()
      if gimScenes[current].onUpdate != nil:
        gimScenes[current].onUpdate(dt)
      if gimScenes[current].onDraw != nil:
        gimScenes[current].onDraw()
      backend.swapBuffers()
    backend.shutdown()
  result.add loop