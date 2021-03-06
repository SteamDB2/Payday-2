core:module("CoreMenuLogic")

Logic = Logic or class()

-- Lines: 5 to 35
function Logic:init(menu_data)
	self._data = menu_data
	self._node_stack = {}
	self._callback_map = {
		renderer_show_node = nil,
		renderer_refresh_node_stack = nil,
		renderer_refresh_node = nil,
		renderer_update_node = nil,
		renderer_select_item = nil,
		renderer_deselect_item = nil,
		renderer_trigger_item = nil,
		renderer_navigate_back = nil,
		renderer_node_item_dirty = nil,
		input_accept_input = nil,
		menu_manager_menu_closed = nil,
		menu_manager_select_node = nil
	}
	self._action_queue = {}
	self._action_callback_map = {
		select_node = callback(self, self, "_select_node"),
		navigate_back = callback(self, self, "_navigate_back"),
		select_item = callback(self, self, "_select_item"),
		trigger_item = callback(self, self, "_trigger_item"),
		refresh_node = callback(self, self, "_refresh_node"),
		refresh_node_stack = callback(self, self, "_refresh_node_stack"),
		update_node = callback(self, self, "_update_node")
	}
end

-- Lines: 37 to 43
function Logic:open(...)
	self._accept_input = not managers.system_menu:is_active()

	self:select_node(nil, true)
end

-- Lines: 45 to 47
function Logic:_queue_action(action_name, ...)
	table.insert(self._action_queue, {
		action_name = action_name,
		parameters = {...}
	})
end

-- Lines: 49 to 58
function Logic:_execute_action_queue()
	while self._accept_input and #self._action_queue > 0 do
		local action = self._action_queue[1]

		if self._action_callback_map[action.action_name] then
			self._action_callback_map[action.action_name](unpack(action.parameters))
		end

		table.remove(self._action_queue, 1)
	end
end

-- Lines: 60 to 65
function Logic:update(t, dt)
	if self:selected_node() then
		self:selected_node():update(t, dt)
	end

	self:_execute_action_queue()
end

-- Lines: 67 to 74
function Logic:select_node(node_name, queue, ...)
	if self._accept_input or queue then
		self:_queue_action("select_node", node_name, ...)
	end
end

-- Lines: 76 to 105
function Logic:_select_node(node_name, ...)
	local node = self:get_node(node_name, ...)
	local has_active_menu = managers.menu._open_menus and #managers.menu._open_menus > 0 and true or false

	if has_active_menu and node then
		local selected_node = self:selected_node()

		if selected_node then
			selected_node:trigger_focus_changed(false)
		end

		node:trigger_focus_changed(true, ...)

		if node:parameters().menu_components then
			managers.menu_component:set_active_components(node:parameters().menu_components, node)
		end

		node:parameters().create_params = {...}

		table.insert(self._node_stack, node)
		self:_call_callback("renderer_show_node", node)
		node:select_item()
		self:_call_callback("renderer_select_item", node:selected_item())
		self:_call_callback("menu_manager_select_node", node)
	end
end

-- Lines: 109 to 112
function Logic:refresh_node_stack(queue, ...)
	self:_queue_action("refresh_node_stack", ...)
end

-- Lines: 114 to 125
function Logic:_refresh_node_stack(...)
	for i, node in ipairs(self._node_stack) do
		if node:parameters().refresh then
			for _, refresh_func in ipairs(node:parameters().refresh) do
				node = refresh_func(node, ...)
			end
		end

		local selected_item = node:selected_item()

		node:select_item(selected_item and selected_item:name())
	end

	self:_call_callback("renderer_refresh_node_stack")
end

-- Lines: 129 to 132
function Logic:refresh_node(node_name, queue, ...)
	self:_queue_action("refresh_node", node_name, ...)
end

-- Lines: 135 to 154
function Logic:_refresh_node(node_name, ...)
	local node = self:selected_node()

	if node and node:parameters().refresh then
		for _, refresh_func in ipairs(node:parameters().refresh) do
			node = refresh_func(node, ...)
		end
	end

	if node then
		self:_call_callback("renderer_refresh_node", node)

		local selected_item = node:selected_item()

		node:select_item(selected_item and selected_item:name())
		self:_call_callback("renderer_select_item", node:selected_item())
	end
end

-- Lines: 158 to 161
function Logic:update_node(node_name, queue, ...)
	self:_queue_action("update_node", node_name, ...)
end

-- Lines: 164 to 187
function Logic:_update_node(node_name, ...)
	local node = self:selected_node()

	if node then
		if node:parameters().update then
			for _, update_func in ipairs(node:parameters().update) do
				node = update_func(node, ...)
			end
		end
	else
		Application:error("[CoreLogic:_update_node] Trying to update selected node, but none is selected!")
	end
end

-- Lines: 189 to 193
function Logic:navigate_back(queue, skip_nodes)
	if self._accept_input or queue then
		self:_queue_action("navigate_back", skip_nodes)
	end
end

-- Lines: 195 to 223
function Logic:_navigate_back(skip_nodes)
	local node = self._node_stack[#self._node_stack]

	if node then
		if node:trigger_back() then
			return
		end

		node:trigger_focus_changed(false)
	end

	skip_nodes = type(skip_nodes) == "number" and skip_nodes or 0

	if 1 + skip_nodes < #self._node_stack then
		for i = 1, 1 + skip_nodes, 1 do
			table.remove(self._node_stack, #self._node_stack)
			self:_call_callback("renderer_navigate_back")
		end

		node = self._node_stack[#self._node_stack]

		if node then
			node:trigger_focus_changed(true)

			if node:parameters().menu_components then
				managers.menu_component:set_active_components(node:parameters().menu_components, node)
			end
		end
	end

	self:_call_callback("menu_manager_select_node", node)
end

-- Lines: 226 to 234
function Logic:soft_open()
	local node = self._node_stack[#self._node_stack]

	if node then
		if node:parameters().menu_components then
			managers.menu_component:set_active_components(node:parameters().menu_components, node)
		end

		self:_call_callback("menu_manager_select_node", node)
	end
end

-- Lines: 236 to 237
function Logic:selected_node()
	return self._node_stack[#self._node_stack]
end

-- Lines: 240 to 241
function Logic:selected_node_name()
	return self:selected_node():parameters().name
end

-- Lines: 244 to 248
function Logic:select_item(item_name, queue)
	if self._accept_input or queue then
		self:_queue_action("select_item", item_name)
	end
end

-- Lines: 250 to 254
function Logic:mouse_over_select_item(item_name, queue)
	if self._accept_input or queue then
		self:_queue_action("select_item", item_name, true)
	end
end

-- Lines: 256 to 271
function Logic:_select_item(item_name, mouse_over)
	local current_node = self:selected_node()

	if current_node then
		local current_item = current_node:selected_item()

		if current_item then
			self:_call_callback("renderer_deselect_item", current_item)
		end

		current_node:select_item(item_name)
		self:_call_callback("renderer_select_item", current_node:selected_item(), mouse_over)
	end
end

-- Lines: 273 to 277
function Logic:trigger_item(queue, item)
	if self._accept_input or queue then
		self:_queue_action("trigger_item", item)
	end
end

-- Lines: 279 to 287
function Logic:_trigger_item(item)
	item = item or self:selected_item()

	if item then
		item:trigger()
		self:_call_callback("renderer_trigger_item", item)
	end
end

-- Lines: 289 to 295
function Logic:selected_item()
	local item = nil
	local node = self:selected_node()

	if node then
		item = node:selected_item()
	end

	return item
end

-- Lines: 298 to 304
function Logic:get_item(name)
	local item = nil
	local node = self:selected_node()

	if node then
		item = node:item(name)
	end

	return item
end

-- Lines: 307 to 315
function Logic:get_node(node_name, ...)
	local node = self._data:get_node(node_name, ...)

	if node and not node.dirty_callback then
		node.dirty_callback = callback(self, self, "node_item_dirty")
	end

	return node
end

-- Lines: 318 to 321
function Logic:accept_input(accept)
	self._accept_input = accept

	self:_call_callback("input_accept_input", accept)
end

-- Lines: 323 to 325
function Logic:register_callback(id, callback)
	self._callback_map[id] = callback
end

-- Lines: 327 to 333
function Logic:_call_callback(id, ...)
	if self._callback_map[id] then
		self._callback_map[id](...)
	else
		Application:error("Logic:_call_callback: Callback " .. id .. " not found.")
	end
end

-- Lines: 335 to 337
function Logic:node_item_dirty(node, item)
	self:_call_callback("renderer_node_item_dirty", node, item)
end

-- Lines: 339 to 341
function Logic:renderer_closed()
	self:_call_callback("menu_manager_menu_closed")
end

-- Lines: 344 to 364
function Logic:close(closing_menu)
	local selected_node = self:selected_node()

	managers.menu_component:set_active_components({})

	self._action_queue = {}

	for index = #self._node_stack, 1, -1 do
		local node = self._node_stack[index]

		if not closing_menu and node then
			node:trigger_back()
		end
	end

	self._node_stack = {}

	self:_call_callback("menu_manager_select_node", false)
end

