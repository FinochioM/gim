# ------------------------------------
# Matias Finochio - 2026 - MIT License
# ------------------------------------
{.push raises: [].}

import opengl
import stb_image/read as stbi

type
  Texture* = object
    id:      GLuint
    width*:  int
    height*: int

proc `=copy`*(dst: var Texture, src: Texture) {.error: "Texture cannot copy".}

proc `=destroy`*(t: var Texture) =
  if t.id != 0:
    {.cast(raises: []).}:
      glDeleteTextures(1, unsafeAddr t.id)

proc isValid*(t: var Texture): bool {.inline.} = t.id != 0

proc bindGL*(t: var Texture) {.inline.} =
  {.cast(raises: []).}:
    glBindTexture(GL_TEXTURE_2D, t.id)

proc loadTexture*(path: string): Texture =
  {.cast(raises: []).}:
    var w, h, channels: int
    let data = stbi.load(path, w, h, channels, stbi.RGBA)
    if data.len == 0: return

    var id: GLuint
    glGenTextures(1, addr id)
    glBindTexture(GL_TEXTURE_2D, id)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE.GLint)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA.GLint, w.GLsizei, h.GLsizei,
                 0, GL_RGBA, GL_UNSIGNED_BYTE, unsafeAddr data[0])
    glBindTexture(GL_TEXTURE_2D, 0)
    result = Texture(id: id, width: w, height: h)
{.pop.}
