---
tagline: GIF reader
---

## `local giflib = require'giflib'`

Lightweight ffi binding of the antique [GIFLIB][giflib lib].

[giflib lib]: http://sourceforge.net/projects/giflib/

### `giflib.open(opt) -> gif`

Read and decode a GIF image.

* table `opt` can have:
  * `data:` read data from a string or cdata buffer.
  * `size`: data size in bytes.

The returned `gif` object is a table with the fields:

* `w`, `h`: the GIF image dimensions.
* `bg_color: `{r, g, b}` where each color component is in `0..1` range.

### `gif:load([opt]) -> frames`

* table `opt` can have:
  * `opaque`: if `true`, prevents converting the GIF transparent color
to transparent black.

Returns an array of frames where each frame is an image object with the fields:

* `format`, `stride`, `data`, `size`, `w`, `h`: image format, dimensions
and pixel data.
  * the frames are always in top-down `bgra8` format; use [bitmap]
to convert them to other formats.
* `delay_ms`: GIF frame delay in milliseconds, for animated GIFs.
* `x`, `y`: frame position relative to the top-left corner of the virtual
canvas into which to paint the frame. GIF frames can have different
sizes and different positions than (0,0) but this feature is almost
never used.
