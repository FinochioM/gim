## gim - Matias Finochio - 2026
## MIT license

## Single import for the user `import gim`.
## Every sub-module from the library gets re-exported through this single file.

{.push raises: [].}
import types, vec2, rect2, color, transform2, scene, gamemacro, backend, renderer, input
export types, vec2, rect2, color, transform2, scene, gamemacro, backend, renderer, input
{.pop.}