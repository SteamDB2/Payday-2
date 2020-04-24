DialogManager = DialogManager or class()

-- Lines: 3 to 15
function DialogManager:init()
	self._dialog_list = {}
	self._current_dialog = nil
	self._next_dialog = nil
	self._bain_unit = World:spawn_unit(Idstring("units/payday2/characters/fps_mover/bain"), Vector3(), Rotation())
	local level_id = Global.level_data and Global.level_data.level_id
	local level_tweak = tweak_data.levels[level_id]

	self:set_narrator(level_tweak and level_tweak.narrator or "bain")
end

-- Lines: 17 to 19
function DialogManager:init_finalize()
	self:_load_dialogs()
end

-- Lines: 22 to 65
function DialogManager:queue_dialog(id, params)
	if not params.skip_idle_check and managers.platform:presence() == "Idle" then
		return
	end

	if not self._dialog_list[id] then
		local error_message = "The dialog script tries to queue a dialog with id '" .. tostring(id) .. "' which doesn't seem to exist!"

		if Application:editor() then
			managers.editor:output_error(error_message, false, true)
		else
			debug_pause(error_message)
		end

		return false
	end

	if not self._current_dialog then
		self._current_dialog = {
			id = id,
			params = params
		}

		self:_play_dialog(self._dialog_list[id], params)
	else
		local dialog = self._dialog_list[id]

		if self._next_dialog and self._dialog_list[self._next_dialog.id].priority < dialog.priority then
			self:_call_done_callback(params and params.done_cbk, "skipped")

			return false
		end

		if dialog.priority < self._dialog_list[self._current_dialog.id].priority then
			if self._next_dialog then
				self:_call_done_callback(self._dialog_list[self._next_dialog.id].params and self._dialog_list[self._next_dialog.id].params.done_cbk, "skipped")
			end

			self._next_dialog = {
				id = id,
				params = params
			}
		else
			self:_call_done_callback(params and params.done_cbk, "skipped")
		end
	end

	return true
end

-- Lines: 69 to 71
function DialogManager:queue_narrator_dialog(id, params)
	self:queue_dialog(self._narrator_prefix .. id, params)
end

-- Lines: 73 to 80
function DialogManager:set_narrator(narrator)
	local narrator_codes = {
		bain = "ban",
		locke = "loc"
	}
	self._narrator_prefix = "Play_" .. narrator_codes[narrator] .. "_"
end

-- Lines: 83 to 109
function DialogManager:finished()
	self:_stop_dialog()

	local done_cbk = self._current_dialog.params and self._current_dialog.params.done_cbk

	if self._next_dialog then
		self._current_dialog = self._next_dialog
		self._next_dialog = nil

		self:_play_dialog(self._dialog_list[self._current_dialog.id], self._current_dialog.params)
	elseif self._current_dialog.line then
		local line = self._current_dialog.line + 1
		local dialog = self._dialog_list[self._current_dialog.id]

		if line <= #dialog.sounds then
			self:_play_dialog(self._dialog_list[self._current_dialog.id], self._current_dialog.params, line)
		else
			self._current_dialog = nil
		end
	else
		self._current_dialog = nil
	end

	if done_cbk then
		self:_call_done_callback(done_cbk, "done")
	end
end

-- Lines: 111 to 123
function DialogManager:quit_dialog(no_done_cbk)
	managers.subtitle:set_visible(false)
	managers.subtitle:set_enabled(false)
	self:_stop_dialog()

	if not no_done_cbk and self._current_dialog and self._current_dialog.params then
		self:_call_done_callback(self._current_dialog.params.done_cbk, "done")
	end

	self._current_dialog = nil
	self._next_dialog = nil
end

-- Lines: 125 to 131
function DialogManager:conversation_names()
	local t = {}

	for name, _ in pairs(self._dialog_list) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

-- Lines: 134 to 136
function DialogManager:on_simulation_ended()
	self:quit_dialog(true)
end

-- Lines: 138 to 170
function DialogManager:_play_dialog(dialog, params, line)
	local unit = params.on_unit or params.override_characters and managers.player:player_unit()

	if not alive(unit) then
		if dialog.character then
			unit = managers.criminals:character_unit_by_name(dialog.character)
		else
			unit = managers.dialog._bain_unit

			if params.position then
				unit:set_position(params.position)
			end
		end
	end

	self._current_dialog.unit = unit

	if not alive(unit) then
		Application:error("The dialog script tries to access a unit named '" .. tostring(dialog.character) .. "', which doesn't seem to exist. Line will be skipped.")
	end

	if alive(unit) then
		if dialog.string_id then
			unit:drama():play_subtitle(dialog.string_id)
		end

		if dialog.sound then
			unit:drama():play_sound(dialog.sound, dialog.sound_source)
		elseif dialog.sounds and #dialog.sounds > 0 then
			self._current_dialog.line = line or 1

			unit:drama():play_sound(dialog.sounds[self._current_dialog.line], dialog.sound_source)
		end
	end
end

-- Lines: 172 to 176
function DialogManager:_stop_dialog()
	if self._current_dialog and self._current_dialog.unit then
		self._current_dialog.unit:drama():stop_cue()
	end
end

-- Lines: 178 to 182
function DialogManager:_call_done_callback(done_cbk, reason)
	if done_cbk then
		done_cbk(reason)
	end
end

-- Lines: 184 to 193
function DialogManager:_load_dialogs()
	local file_name = "gamedata/dialogs/index"
	local data = PackageManager:script_data(Idstring("dialog_index"), file_name:id())

	for _, c in ipairs(data) do
		if c.name then
			self:_load_dialog_data(c.name)
		end
	end
end

-- Lines: 195 to 221
function DialogManager:_load_dialog_data(name)
	local file_name = "gamedata/dialogs/" .. name
	local data = PackageManager:script_data(Idstring("dialog"), file_name:id())

	for _, node in ipairs(data) do
		if node._meta == "dialog" then
			if not node.id then
				Application:throw_exception("Error in '" .. file_name .. "'! A node definition must have an id parameter!")

				break
			end

			self._dialog_list[node.id] = {
				id = node.id,
				character = node.character,
				sound = node.sound,
				string_id = node.string_id,
				priority = node.priority and tonumber(node.priority) or tweak_data.dialog.DEFAULT_PRIORITY
			}

			for _, line_node in ipairs(node) do
				if line_node._meta == "line" and line_node.sound then
					self._dialog_list[node.id].sounds = self._dialog_list[node.id].sounds or {}

					table.insert(self._dialog_list[node.id].sounds, line_node.sound)
				end
			end

			if self._dialog_list[node.id].sounds and node.sound then
				Application:throw_exception("Error in '" .. file_name .. "' in node " .. node.id .. "! Sound can't be defined in parameters when it have sound lines!")

				self._dialog_list[node.id].sound = nil
			end
		end
	end
end

