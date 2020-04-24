
-- Lines: 2 to 9
local function redirect_to_member(class, member_name, functions)
	for _, name in pairs(functions) do

		-- Lines: 4 to 6
		class[name] = function (self, ...)
			local member = self[member_name]

			return member[name](member, ...)
		end
	end

	return class
end

-- Lines: 16 to 27
local function redirect_to_panel(class, blacklist)
	local old_index = class.__index

	-- Lines: 18 to 25
	function class.__index(table, key)
		for k, func in pairs(Panel) do
			if not blacklist[k] and not rawget(class, k) then

				-- Lines: 20 to 21
				class[k] = function (self, ...)
					return func(self._panel, ...)
				end
			end
		end

		class.__index = old_index

		return class[key]
	end
end

ExtendedPanel = ExtendedPanel or redirect_to_member(class(), "_panel", {
	"set_world_shape",
	"set_leftbottom",
	"set_right",
	"set_world_lefttop",
	"after",
	"animate",
	"world_position",
	"panel",
	"rightbottom",
	"width",
	"set_world_left",
	"top",
	"set_width",
	"size",
	"halign",
	"set_world_center_x",
	"center_x",
	"set_world_leftbottom",
	"valign",
	"set_center",
	"children",
	"set_righttop",
	"left",
	"set_center_y",
	"gradient",
	"leftbottom",
	"set_shape",
	"world_left",
	"tree",
	"height",
	"stop",
	"world_x",
	"inside",
	"alpha",
	"world_center",
	"set_height",
	"set_y",
	"set_bottom",
	"gui",
	"set_position",
	"center_y",
	"set_w",
	"bottom",
	"unit",
	"set_x",
	"set_world_x",
	"set_align",
	"world_right",
	"set_world_righttop",
	"set_world_y",
	"y",
	"set_visible",
	"set_top",
	"set_center_x",
	"hide",
	"rect",
	"world_leftbottom",
	"visible",
	"text",
	"move",
	"set_alpha",
	"set_valign",
	"set_world_rightbottom",
	"outside",
	"world_bottom",
	"test_gui",
	"shape",
	"child",
	"num_children",
	"remove",
	"x",
	"show",
	"set_rightbottom",
	"polyline",
	"multi_bitmap",
	"bitmap",
	"clear",
	"world_y",
	"world_top",
	"position",
	"set_left",
	"polygon",
	"world_layer",
	"tree_visible",
	"alive",
	"righttop",
	"world_rightbottom",
	"root",
	"h",
	"parent",
	"right",
	"set_name",
	"w",
	"world_center_x",
	"world_shape",
	"grow",
	"set_lefttop",
	"set_world_bottom",
	"set_world_center_y",
	"set_world_position",
	"set_world_center",
	"world_center_y",
	"set_size",
	"layer",
	"center",
	"set_world_right",
	"name",
	"set_layer",
	"world_lefttop",
	"set_h",
	"set_halign",
	"enter_text",
	"key",
	"world_righttop",
	"lefttop",
	"video",
	"set_world_top"
})

-- Lines: 71 to 84
function ExtendedPanel:init(parent_or_me, config)
	self._panel = config and config.use_given and parent_or_me or parent_or_me:panel(config)
	self._input_components_set = {}
	self.__input_parents = {}

	if config and config.input then
		if config.use_given or not parent_or_me.add_input_component then
			print(config.use_given, parent_or_me.add_input_component)
			error("Can't add as input_component if we aren't given a parent panel or if parent panel doesn't have add_input_component function!")
		else
			parent_or_me:add_input_component(self)
		end
	end
end

-- Lines: 86 to 89
function ExtendedPanel:clear()
	self:clear_input_components()
	self._panel:clear()
end

-- Lines: 91 to 100
function ExtendedPanel:remove_self()
	if alive(self._panel) then
		self:parent():remove(self._panel)

		self._panel = nil
	end

	for v, _ in pairs(self.__input_parents) do
		v:remove_input_component(self, true)
	end
end

-- Lines: 102 to 106
function ExtendedPanel.make_fine_text(text, keep_w, keep_h)
	local x, y, w, h = text:text_rect()

	text:set_size(keep_w and text:w() or math.ceil(w), keep_h and text:h() or math.ceil(h))
	text:set_position(math.round(text:x()), math.round(text:y()))

	return text
end

-- Lines: 109 to 131
function ExtendedPanel.limit_text_rows(text, limit, make_fine, ...)
	local line_breaks = text:line_breaks()
	local str = text:text()
	local last_size = #str

	if limit <= #line_breaks and line_breaks[limit] < limit * 4 then
		text:set_text(str:sub(1, line_breaks[limit] - 6) .. "...")

		return
	end

	while limit < #line_breaks do
		text:set_text(str:sub(1, line_breaks[limit + 1] - 1) .. "...")

		line_breaks = text:line_breaks()
		str = text:text()

		if last_size <= #str then
			text:set_text(str:sub(1, last_size - 4) .. "...")
		end

		last_size = #str
	end

	ExtendedPanel.make_fine_text(text, ...)
end

-- Lines: 133 to 149
function ExtendedPanel.scale_font_to_fit(text, w_limit, h_limit, smallest_allowed)
	smallest_allowed = smallest_allowed or 8
	local size = text:font_size()
	local start_w = text:w()

	while w_limit and w_limit < text:w() or h_limit and h_limit < text:h() do
		if size == smallest_allowed then
			return false
		end

		size = size - 1

		text:set_w(start_w)
		text:set_font_size(size)
		ExtendedPanel.make_fine_text(text)
	end

	return true
end

-- Lines: 152 to 158
function ExtendedPanel:fine_text(config)
	config.w = config.w or type(config.keep_w) == "number" and config.keep_w or nil
	config.h = config.h or type(config.keep_h) == "number" and config.keep_h or nil
	local rtn = self:text(config)

	self.make_fine_text(rtn, config.keep_w, config.keep_h)

	return rtn
end

-- Lines: 161 to 170
function ExtendedPanel:fit_bitmap(config, target_w, target_h)
	target_w = target_w or config.w or config.width
	target_h = target_h or config.h or config.height
	config.w = nil
	config.h = nil
	config.width = nil
	config.height = nil
	local rtn = self:bitmap(config)

	self.make_bitmap_fit(rtn, target_w, target_h)

	return rtn
end

-- Lines: 173 to 188
function ExtendedPanel.make_bitmap_fit(bitmap, target_w, target_h)
	local start_width = bitmap:w()
	local start_height = bitmap:h()
	target_w = target_w or bitmap:parent():w()
	target_h = target_h or bitmap:parent():h()
	local aspect = target_w / target_h
	local sw = math.max(start_width, start_height * aspect)
	local sh = math.max(start_height, start_width / aspect)
	local dw = start_width / sw
	local dh = start_height / sh

	bitmap:set_size(math.round(dw * target_w), math.round(dh * target_h))
end

-- Lines: 193 to 198
function ExtendedPanel:add_input_component(component)
	self._input_components_set[component] = true

	if component.__input_parents then
		component.__input_parents[self] = true
	end
end

-- Lines: 200 to 205
function ExtendedPanel:remove_input_component(component, dont_change_input_parents)
	self._input_components_set[component] = nil

	if not dont_change_input_parents then
		component.__input_parents[self] = nil
	end
end

-- Lines: 207 to 209
function ExtendedPanel:clear_input_components()
	self._input_components_set = {}
end

-- Lines: 211 to 212
function ExtendedPanel:allow_input()
	return alive(self._panel) and self._panel:visible()
end

-- Lines: 215 to 222
local function call_on_all_exists(set, func_name, ...)
	for v, _ in pairs(set) do
		if v:allow_input() then
			local func = v[func_name]

			if func then
				v[func_name](v, ...)
			end
		end
	end
end

-- Lines: 224 to 233
local function call_return_b_on_all_exists(set, func_name, ...)
	for v, _ in pairs(set) do
		if v:allow_input() then
			local func = v[func_name]

			if func and func(v, ...) then
				return true
			end
		end
	end
end

-- Lines: 256 to 269
function ExtendedPanel:mouse_moved(o, x, y)
	if not self:allow_input() then
		return
	end

	local hover, cursor_type = nil

	for v, _ in pairs(self._input_components_set) do
		if v.mouse_moved and v:allow_input() then
			local res, t = v:mouse_moved(o, x, y)

			if res then
				hover = res
				cursor_type = t
			end
		end
	end

	return hover, cursor_type
end

-- Lines: 273 to 277
function ExtendedPanel:mouse_released(button, x, y)
	if not self:allow_input() then
		return
	end

	call_on_all_exists(self._input_components_set, "mouse_released", button, x, y)
end

-- Lines: 280 to 282
function ExtendedPanel:mouse_clicked(o, button, x, y)
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "mouse_clicked", o, button, x, y)
end

-- Lines: 285 to 287
function ExtendedPanel:mouse_double_click(o, button, x, y)
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "mouse_double_click", o, button, x, y)
end

-- Lines: 290 to 292
function ExtendedPanel:mouse_pressed(button, x, y)
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "mouse_pressed", button, x, y)
end

-- Lines: 295 to 297
function ExtendedPanel:mouse_wheel_up(x, y)
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "mouse_wheel_up", x, y)
end

-- Lines: 300 to 302
function ExtendedPanel:mouse_wheel_down(x, y)
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "mouse_wheel_down", x, y)
end

-- Lines: 305 to 307
function ExtendedPanel:special_btn_pressed(button)
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "special_btn_pressed", button)
end

-- Lines: 310 to 312
function ExtendedPanel:move_up()
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "move_up")
end

-- Lines: 315 to 317
function ExtendedPanel:move_down()
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "move_down")
end

-- Lines: 320 to 322
function ExtendedPanel:move_left()
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "move_left")
end

-- Lines: 325 to 327
function ExtendedPanel:move_right()
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "move_right")
end

-- Lines: 330 to 332
function ExtendedPanel:previous_page()
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "previous_page")
end

-- Lines: 335 to 337
function ExtendedPanel:next_page()
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "next_page")
end

-- Lines: 340 to 342
function ExtendedPanel:confirm_pressed()
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "confirm_pressed")
end

-- Lines: 345 to 347
function ExtendedPanel:back_pressed()
	if not self:allow_input() then
		return
	end

	return call_return_b_on_all_exists(self._input_components_set, "back_pressed")
end

