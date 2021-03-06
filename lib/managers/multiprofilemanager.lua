MultiProfileManager = MultiProfileManager or class()

-- Lines: 3 to 11
function MultiProfileManager:init()
	if not Global.multi_profile then
		Global.multi_profile = {}
	end

	self._global = self._global or Global.multi_profile
	self._global._profiles = self._global._profiles or {}
	self._global._current_profile = self._global._current_profile or 1

	self:_check_amount()
end

-- Lines: 13 to 35
function MultiProfileManager:save_current()
	print("[MultiProfileManager:save_current] current profile:", self._global._current_profile)

	local profile = self:current_profile() or {}
	local blm = managers.blackmarket
	local skt = managers.skilltree._global
	profile.primary = blm:equipped_weapon_slot("primaries")
	profile.secondary = blm:equipped_weapon_slot("secondaries")
	profile.melee = blm:equipped_melee_weapon()
	profile.throwable = blm:equipped_grenade()
	profile.deployable = blm:equipped_deployable()
	profile.deployable_secondary = blm:equipped_deployable(2)
	profile.armor = blm:equipped_armor()
	profile.armor_skin = blm:equipped_armor_skin()
	profile.skillset = skt.selected_skill_switch
	profile.perk_deck = Application:digest_value(skt.specializations.current_specialization, false)
	profile.mask = blm:equipped_mask_slot()
	self._global._profiles[self._global._current_profile] = profile

	print("[MultiProfileManager:save_current] done")
end

-- Lines: 37 to 70
function MultiProfileManager:load_current()
	local profile = self:current_profile()
	local blm = managers.blackmarket
	local skt = managers.skilltree

	skt:switch_skills(profile.skillset)
	managers.player:check_skills()
	skt:set_current_specialization(profile.perk_deck)
	blm:equip_weapon("primaries", profile.primary)
	blm:equip_weapon("secondaries", profile.secondary)
	blm:equip_melee_weapon(profile.melee)
	blm:equip_grenade(profile.throwable)
	blm:equip_deployable({
		target_slot = 1,
		name = profile.deployable
	})
	blm:equip_deployable({
		target_slot = 2,
		name = profile.deployable_secondary
	})
	blm:equip_armor(profile.armor)
	blm:set_equipped_armor_skin(profile.armor_skin)
	blm:equip_mask(profile.mask)

	local mcm = managers.menu_component

	if mcm._player_inventory_gui then
		local node = mcm._player_inventory_gui._node

		mcm:close_inventory_gui()
		mcm:create_inventory_gui(node)
	elseif mcm._mission_briefing_gui then
		managers.assets:reload_locks()

		local node = mcm._mission_briefing_gui._node

		mcm:close_mission_briefing_gui()
		mcm:create_mission_briefing_gui(node)
	end
end

-- Lines: 72 to 76
function MultiProfileManager:current_profile_name()
	if not self:current_profile() then
		return "Error"
	end

	return self:current_profile().name or "Profile " .. self._global._current_profile
end

-- Lines: 79 to 80
function MultiProfileManager:profile_count()
	return math.max(#self._global._profiles, 1)
end

-- Lines: 83 to 96
function MultiProfileManager:set_current_profile(index)
	if index < 0 or self:profile_count() < index then
		return
	end

	if index == self._global._current_profile then
		return
	end

	self:save_current()

	self._global._current_profile = index

	self:load_current()
	print("[MultiProfileManager:set_current_profile] current profile:", self._global._current_profile)
end

-- Lines: 98 to 99
function MultiProfileManager:current_profile()
	return self:profile(self._global._current_profile)
end

-- Lines: 102 to 103
function MultiProfileManager:profile(index)
	return self._global._profiles[index]
end

-- Lines: 107 to 110
function MultiProfileManager:_add_profile(profile, index)
	index = index or #self._global._profiles + 1
	self._global._profiles[index] = profile
end

-- Lines: 112 to 114
function MultiProfileManager:next_profile()
	self:set_current_profile(self._global._current_profile + 1)
end

-- Lines: 116 to 118
function MultiProfileManager:previous_profile()
	self:set_current_profile(self._global._current_profile - 1)
end

-- Lines: 120 to 121
function MultiProfileManager:has_next()
	return self._global._current_profile < self:profile_count()
end

-- Lines: 124 to 125
function MultiProfileManager:has_previous()
	return self._global._current_profile > 1
end

-- Lines: 129 to 169
function MultiProfileManager:open_quick_select()
	local dialog_data = {
		title = "",
		text = "",
		button_list = {}
	}

	for idx, profile in pairs(self._global._profiles) do
		local text = profile.name or "Profile " .. idx

		table.insert(dialog_data.button_list, {
			text = text,
			callback_func = function ()
				self:set_current_profile(idx)
			end,
			focus_callback_func = function ()
			end
		})
	end

	local no_button = {
		text = managers.localization:text("dialog_cancel"),
		focus_callback_func = function ()
		end,
		cancel_button = true
	}

	table.insert(dialog_data.button_list, no_button)

	dialog_data.image_blend_mode = "normal"
	dialog_data.text_blend_mode = "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 480
	dialog_data.h = 532
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size
	dialog_data.text_formating_color = Color.white
	dialog_data.text_formating_color_table = {}
	dialog_data.clamp_to_screen = true

	managers.system_menu:show_buttons(dialog_data)
end

-- Lines: 171 to 177
function MultiProfileManager:save(data)
	local save_data = deep_clone(self._global._profiles)
	save_data.current_profile = self._global._current_profile
	data.multi_profile = save_data
end

-- Lines: 179 to 188
function MultiProfileManager:load(data)
	if data.multi_profile then
		for i, profile in ipairs(data.multi_profile) do
			self:_add_profile(profile, i)
		end

		self._global._current_profile = data.multi_profile.current_profile
	end

	self:_check_amount()
end

-- Lines: 191 to 210
function MultiProfileManager:_check_amount()
	local wanted_amount = 15

	if not self:current_profile() then
		self:save_current()
	end

	if wanted_amount < self:profile_count() then
		table.crop(self._global._profiles, wanted_amount)

		self._global._current_profile = math.min(self._global._current_profile, wanted_amount)
	elseif self:profile_count() < wanted_amount then
		local prev_current = self._global._current_profile
		self._global._current_profile = self:profile_count()

		while self._global._current_profile < wanted_amount do
			self._global._current_profile = self._global._current_profile + 1

			self:save_current()
		end

		self._global._current_profile = prev_current
	end
end

