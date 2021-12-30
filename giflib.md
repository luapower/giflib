---
tagline: GIF reader
---

## `local giflib = require'giflib'`

Lightweight ffi binding of the antique [GIFLIB][giflib lib].

[giflib lib]: http://sourceforge.net/projects/giflib/

### `giflib.open(opt) -> gif`

Open a GIF image and read its header. `opt` is a table containing at least
the read function and possibly other options.

The read function has the form `read(buf, size) -> readsize`, **it cannot yield**
and it can signal I/O errors by returning `nil, err`. It will only be asked
to read a positive number of bytes and it can return less bytes than asked,
including zero which signals EOF.

The `opt` table has the fields:

* `read`: the read function (required).

The returned `gif` object is a table with the fields:

* `w`, `h`: the GIF image dimensions.
* `bg_color: `{r, g, b}` where each color component is in `0..1` range.

### `gif:load([opt]) -> frames`

The `opt` table has the fields:

* `opaque`: prevent converting the GIF transparent color to transparent black (false).
* `bottom_up`: bottom-up bitmap (false).
* `stride_aligned`: align stride to 4 bytes (false).

Returns an array of frames where each frame is an image object with the fields:

* `format`, `stride`, `bottom_up`, `data`, `size`, `w`, `h`: image format,
dimensions and pixel data.
* `delay_ms`: GIF frame delay in milliseconds, for animated GIFs.
* `x`, `y`: frame position relative to the top-left corner of the virtual
canvas into which to paint the frame. GIF frames can have different
sizes and different positions than (0,0) but this feature is almost
never used.

The frames are always in `bgra8` format. Use [bitmap] to convert them
to other formats.
