
local giflib = require'giflib'
local glue = require'glue'
local ffi = require'ffi'
local fs = require'fs'
local testui = require'testui'

local white_bg = false
local source_type = 'cdata'
local max_cutsize = 65536
local cut_size = max_cutsize
local opaque = 'transparent'
local frame_state = {} --{[filename] = {frame = <current_frame_no>, time = <next_frame_time>}

function testui:repaint()

	--self:checkerboard()

	self:pushgroup'down'

	self:pushgroup'right'
	self.min_w = 100

	source_type = self:choose('source_type', {'cdata', 'string'}, source_type) or source_type
	cut_size    = self:slide('cut_size', 'cut size', cut_size, 0, max_cutsize, 1) or cut_size
	opaque      = self:choose('mode', {'opaque', 'transparent'}, opaque) or opaque

	self:nextgroup()
	self.y = self.y + 10

	local files = {}
	for filename in fs.dir'media/gif' do
		files[#files+1] = filename
	end

	for _,filename in ipairs(files) do
	--for filename in fs.dir'media/gif' do
		local path = 'media/gif/'..filename

		local t = {}
		local s = assert(glue.readfile(path)):sub(1, cut_size)
		if source_type == 'cdata' then
			local data = ffi.new('uint8_t[?]', #s + 1, s)
			t.data = data
			t.size = #s
		elseif source_type == 'string' then
			t.data = s
		else
			assert(false)
		end

		local gif, err = giflib.open(t)
		if not gif then
			goto skip
		end

		local frames, err = gif:load{opaque = opaque == 'opaque'}
		if not frames then
			gif:free()
			goto skip
		end

		local state = frame_state[filename]
		if not state then
			state = {frame = 0, clock = 0}
			frame_state[filename] = state
		end

		local image
		if self.clock >= state.clock then
			state.frame = state.frame + 1
			if state.frame > #frames then
				state.frame = 1
			end
			image = frames[state.frame]
			state.clock = self.clock + (image.delay or 0)
		else
			image = frames[state.frame]
		end

		if self.x + image.w >= self.window:client_size() then --wrap
			self:nextgroup()
		end

		self:image(image)

		gif:free()

		::skip::
	end

	collectgarbage()
end

testui:init()
testui:continuous_repaint(true)
testui:run()
