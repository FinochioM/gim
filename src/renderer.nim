# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

import opengl
import vec2, color, texture

type
  Shader* = object
    id: GLuint

proc `=copy`*(dst: var Shader, src: Shader) {.error: "Shader is not copyable".}

proc `=destroy`*(s: var Shader) =
  if s.id != 0:
    {.cast(raises: []).}:
      glDeleteProgram(s.id)

proc newShader*(vertSrc, fragSrc: string): Shader =
  {.cast(raises: []).}:
    let vert = glCreateShader(GL_VERTEX_SHADER)
    var vsrc = vertSrc.cstring
    glShaderSource(vert, 1, cast[cstringArray](addr vsrc), nil)
    glCompileShader(vert)

    let frag = glCreateShader(GL_FRAGMENT_SHADER)
    var fsrc = fragSrc.cstring
    glShaderSource(frag, 1, cast[cstringArray](addr fsrc), nil)
    glCompileShader(frag)

    let prog = glCreateProgram()
    glAttachShader(prog, vert)
    glAttachShader(prog, frag)
    glLinkProgram(prog)
    glDeleteShader(vert)
    glDeleteShader(frag)
    result = Shader(id: prog)

proc use*(s: Shader) {.inline.} =
  {.cast(raises: []).}:
    glUseProgram(s.id)

proc setUniform*(s: Shader, name: cstring, x, y: float32) =
  {.cast(raises: []).}:
    glUniform2f(glGetUniformLocation(s.id, name), x, y)

proc setUniform*(s: Shader, name: cstring, r, g, b, a: float32) =
  {.cast(raises: []).}:
    glUniform4f(glGetUniformLocation(s.id, name), r, g, b, a)

proc setUniformMat4*(s: Shader, name: cstring, m: var array[16, float32]) =
  {.cast(raises: []).}:
    glUniformMatrix4fv(glGetUniformLocation(s.id, name), 1, GL_FALSE, addr m[0])

type
  Mesh* = object
    vao:       GLuint
    vbo:       GLuint
    vertCount: int32

proc `=copy`*(dst: var Mesh, src: Mesh) {.error: "Mesh cannot copy".}

proc `=destroy`*(m: var Mesh) =
  {.cast(raises: []).}:
    if m.vbo != 0: glDeleteBuffers(1, unsafeAddr m.vbo)
    if m.vao != 0: glDeleteVertexArrays(1, unsafeAddr m.vao)

proc newQuadMesh*(): Mesh =
  {.cast(raises: []).}:
    let verts: array[12, float32] = [
      0f, 0f,  1f, 0f,  1f, 1f,
      0f, 0f,  1f, 1f,  0f, 1f,
    ]
    var vao, vbo: GLuint
    glGenVertexArrays(1, addr vao)
    glGenBuffers(1, addr vbo)
    glBindVertexArray(vao)
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts).GLsizeiptr,
                 unsafeAddr verts[0], GL_STATIC_DRAW)
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0, 2, cGL_FLOAT, GL_FALSE,
                          (2 * sizeof(float32)).GLsizei, nil)
    glBindVertexArray(0)
    result = Mesh(vao: vao, vbo: vbo, vertCount: 6)

proc newTexturedQuadMesh(): Mesh =
  {.cast(raises: []).}:
    let verts: array[24, float32] = [
      0f, 0f,  0f, 0f,
      1f, 0f,  1f, 0f,
      1f, 1f,  1f, 1f,
      0f, 0f,  0f, 0f,
      1f, 1f,  1f, 1f,
      0f, 1f,  0f, 1f,
    ]
    var vao, vbo: GLuint
    glGenVertexArrays(1, addr vao)
    glGenBuffers(1, addr vbo)
    glBindVertexArray(vao)
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts).GLsizeiptr,
                  unsafeAddr verts[0], GL_STATIC_DRAW)
    let stride = (4 * sizeof(float32)).GLsizei
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0, 2, cGL_FLOAT, GL_FALSE, stride, nil)
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1, 2, cGL_FLOAT, GL_FALSE, stride,
                          cast[pointer](2 * sizeof(float32)))
    glBindVertexArray(0)
    result = Mesh(vao: vao, vbo: vbo, vertCount: 6)

proc draw*(m: Mesh) {.inline.} =
  {.cast(raises: []).}:
    glBindVertexArray(m.vao)
    glDrawArrays(GL_TRIANGLES, 0, m.vertCount.GLsizei)
    glBindVertexArray(0)

const kRectVert = """
#version 330 core
layout(location = 0) in vec2 aPos;
uniform mat4 uProjection;
uniform vec2 uPos;
uniform vec2 uSize;
void main() {
  vec2 world = aPos * uSize + uPos;
  gl_Position = uProjection * vec4(world, 0.0, 1.0);
}
"""

const kRectFrag = """
#version 330 core
uniform vec4 uColor;
out vec4 fragColor;
void main() { fragColor = uColor; }
"""

const kTexVert = """
#version 330 core
layout(location = 0) in vec2 aPos;
layout(location = 1) in vec2 aUV;
uniform mat4 uProjection;
uniform vec2 uPos;
uniform vec2 uSize;
out vec2 vUV;
void main() {
  vec2 world = aPos * uSize + uPos;
  gl_Position = uProjection * vec4(world, 0.0, 1.0);
  vUV = aUV;
}
"""

const kTexFrag = """
#version 330 core
in vec2 vUV;
uniform sampler2D uTex;
uniform vec4 uTint;
out vec4 fragColor;
void main() { fragColor = texture(uTex, vUV) * uTint; }
"""

type
  RectRenderer = object
    shader: Shader
    mesh:   Mesh
    proj:   array[16, float32]

var gRect: RectRenderer

type
  TexRenderer = object
    shader: Shader
    mesh:   Mesh
    proj:   array[16, float32]

var gTex: TexRenderer

func ortho(l, r, b, t: float32): array[16, float32] {.inline.} =
  [  2f/(r-l),       0f,      0f, 0f,
          0f,  2f/(t-b),      0f, 0f,
          0f,        0f,     -1f, 0f,
    -(r+l)/(r-l), -(t+b)/(t-b), 0f, 1f ]

proc initRenderer*(width, height: int) =
  gRect.shader = newShader(kRectVert, kRectFrag)
  gRect.mesh   = newQuadMesh()
  gRect.proj   = ortho(0f, float32(width), float32(height), 0f)
  gTex.shader  = newShader(kTexVert, kTexFrag)
  gTex.mesh    = newTexturedQuadMesh()
  gTex.proj    = ortho(0f, float32(width), float32(height), 0f)

proc drawRect*(pos: Vec2px, size: Vec2px, color: Color) =
  gRect.shader.use()
  gRect.shader.setUniformMat4("uProjection", gRect.proj)
  gRect.shader.setUniform("uPos",   float32(pos.x),  float32(pos.y))
  gRect.shader.setUniform("uSize",  float32(size.x), float32(size.y))
  gRect.shader.setUniform("uColor", color.r, color.g, color.b, color.a)
  gRect.mesh.draw()

proc drawTexture*(pos: Vec2px, tex: var Texture) =
  gTex.shader.use()
  gTex.shader.setUniformMat4("uProjection", gTex.proj)
  gTex.shader.setUniform("uPos",  float32(pos.x), float32(pos.y))
  gTex.shader.setUniform("uSize", float32(tex.width), float32(tex.height))
  gTex.shader.setUniform("uTint", 1f, 1f, 1f, 1f)
  {.cast(raises: []).}:
    glActiveTexture(GL_TEXTURE0)
  tex.bindGL()
  gTex.mesh.draw()

{.pop.}
