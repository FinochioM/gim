# Package
packageName = "gim"
version = "0.0.1"
author = "Matias Finochio"
description = "2D game library written in and for Nim"
license = "MIT"
srcDir = "src"

# Dependencies
requires "nim >= 2.0.0"
requires "sdl2 >= 2.0.0"
requires "opengl >= 1.2.6"

task docs, "generate gim.doc.nim from src/ exports and ## comments":
  exec "nim r tools/gendoc.nim"
