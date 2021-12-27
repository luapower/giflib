
--giflib ffi binding.
--Written by Cosmin Apreutesei. Public Domain.

if not ... then require'giflib_demo'; return end

local ffi = require'ffi'
local glue = require'glue'
require'giflib_h'
local C = ffi.load'gif'

local function open(opt)

	local data = ffi.cast('uint8_t*', opt.data)
	local size = opt.size or #opt.data

	local cb, ft
	local function free()
		local _ = opt.data --pin it so it doesn't get collected (if string)
		if cb then cb:free(); cb = nil end
		if ft then C.DGifCloseFile(ft); ft = nil end
	end

	local function read(_, buf, sz)
		assert(sz > 0)
		if size == 0 then
			return 0
		end
		sz = math.min(size, sz)
		ffi.copy(buf, data, sz)
		data = data + sz
		size = size - sz
		return sz
	end
	--[[local]] cb = ffi.cast('GifInputFunc', read)

	local err = ffi.new'int[1]'
	--[[local]] ft = C.DGifOpen(nil, cb, err)
	if ft == nil then
		free()
		return nil, ffi.string(C.GifErrorString(err[0]))
	end

	local gif = {free = free}
	gif.w = ft.SWidth
	gif.h = ft.SHeight
	local c = ft.SColorMap.Colors[ft.SBackGroundColor]
	gif.bg_color = {c.Red/255, c.Green/255, c.Blue/255}
	gif.image_count = ft.ImageCount

	function gif:load(opt)
		local transparent = not opt.opaque

		local ok = C.DGifSlurp(ft) ~= 0
		if not ok then
			return nil, ffi.string(C.GifErrorString(ft.Error))
		end

		local frames = {}
		local gcb = ffi.new'GraphicsControlBlock'
		for i = 0, ft.ImageCount-1 do
			local si = ft.SavedImages[i]

			--find delay and transparent color index, if any.
			local delay, tcolor_idx
			if C.DGifSavedExtensionToGCB(ft, i, gcb) == 1 then
				delay = gcb.DelayTime / 100 --make it in seconds
				tcolor_idx = gcb.TransparentColor
			end
			local w, h = si.ImageDesc.Width, si.ImageDesc.Height
			local colormap = si.ImageDesc.ColorMap ~= nil
				and si.ImageDesc.ColorMap or ft.SColorMap

			--convert image to top-down 8bpc rgba.
			local stride = w * 4
			local size = stride * h
			local data = ffi.new('uint8_t[?]', size)
			local di = 0
			local assert = assert
			for i=0, w * h-1 do
				local idx = si.RasterBits[i]
				assert(idx < colormap.ColorCount)
				if idx == tcolor_idx and transparent then
					data[di+0] = 0
					data[di+1] = 0
					data[di+2] = 0
					data[di+3] = 0
				else
					data[di+0] = colormap.Colors[idx].Blue
					data[di+1] = colormap.Colors[idx].Green
					data[di+2] = colormap.Colors[idx].Red
					data[di+3] = 0xff
				end
				di = di+4
			end

			frames[i+1] = {
				data = data,
				size = size,
				format = 'bgra8',
				stride = stride,
				w = w,
				h = h,
				x = si.ImageDesc.Left,
				y = si.ImageDesc.Top,
				delay = delay,
			}
		end

		return frames
	end

	return gif
end

return {
	open = open,
	C = C,
}
