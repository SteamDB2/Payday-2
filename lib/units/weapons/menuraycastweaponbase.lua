NewRaycastWeaponBase = NewRaycastWeaponBase or class()

require("lib/units/weapons/CosmeticsWeaponBase")
require("lib/units/weapons/ScopeBase")

-- Lines: 6 to 15
function NewRaycastWeaponBase:init(unit)
	self._unit = unit
	self._name_id = self.name_id or "test_raycast_weapon"
	self.name_id = nil
	self._textures = {}
	self._cosmetics_data = nil
	self._materials = nil
end

-- Lines: 17 to 30
function NewRaycastWeaponBase:_check_thq_align_anim()
	if not self:is_npc() then
		return
	end

	if not self:use_thq() then
		return
	end

	local tweak_data = tweak_data.weapon[self._name_id]
	local thq_anim_name = tweak_data.animations and tweak_data.animations.thq_align_anim

	if thq_anim_name then
		self._unit:anim_set_time(Idstring(thq_anim_name), self._unit:anim_length(Idstring(thq_anim_name)))
	end
end

-- Lines: 32 to 35
function NewRaycastWeaponBase:set_factory_data(factory_id)
	self._factory_id = factory_id
end

-- Lines: 37 to 39
function NewRaycastWeaponBase:set_texture_switches(texture_switches)
	self._texture_switches = texture_switches
end

-- Lines: 45 to 47
function NewRaycastWeaponBase:set_npc(npc)
	self._npc = npc
end

-- Lines: 49 to 50
function NewRaycastWeaponBase:is_npc()
	return self._npc or false
end

-- Lines: 56 to 57
function NewRaycastWeaponBase:use_thq()
	return true
end

-- Lines: 61 to 62
function NewRaycastWeaponBase:skip_thq_parts()
	return tweak_data.weapon.factory[self._factory_id .. "_npc"].skip_thq_parts
end

-- Lines: 65 to 66
function NewRaycastWeaponBase:skip_queue()
	return false
end

-- Lines: 69 to 78
function NewRaycastWeaponBase:_third_person()
	if not self:is_npc() then
		return false
	end

	if not self:use_thq() then
		return true
	end

	return self:skip_thq_parts() and true or false
end

-- Lines: 81 to 94
function NewRaycastWeaponBase:assemble(factory_id, skip_queue)
	local third_person = self:_third_person()
	self._parts, self._blueprint = managers.weapon_factory:assemble_default(factory_id, self._unit, third_person, self:is_npc(), callback(self, self, "_assemble_completed", function ()
	end), skip_queue)

	self:_check_thq_align_anim()
	self:_update_stats_values()

	return

	local third_person = self:is_npc()
	self._parts, self._blueprint = managers.weapon_factory:assemble_default(factory_id, self._unit, third_person, self:is_npc())

	self:_update_fire_object()
	self:_update_stats_values()
end

-- Lines: 96 to 110
function NewRaycastWeaponBase:assemble_from_blueprint(factory_id, blueprint, skip_queue, clbk)
	local third_person = self:_third_person()
	self._parts, self._blueprint = managers.weapon_factory:assemble_from_blueprint(factory_id, self._unit, blueprint, third_person, self:is_npc(), callback(self, self, "_assemble_completed", clbk or function ()
	end), skip_queue)

	self:_check_thq_align_anim()
	self:_update_stats_values()

	return

	local third_person = self:is_npc()
	self._parts, self._blueprint = managers.weapon_factory:assemble_from_blueprint(factory_id, self._unit, blueprint, third_person, self:is_npc())

	self:_update_fire_object()
	self:_update_stats_values()
end

-- Lines: 114 to 132
function NewRaycastWeaponBase:_assemble_completed(clbk, parts, blueprint)
	self._parts = parts
	self._blueprint = blueprint

	self:_apply_cosmetics(clbk or function ()
	end)
	self:apply_texture_switches()
	self:apply_material_parameters()
	self:configure_scope()
	self:_update_fire_object()
	self:_update_stats_values()
	self:set_scope_enabled(true)

	if clbk then
		clbk()
	end
end
local material_type_ids = Idstring("material")

-- Lines: 136 to 161
function NewRaycastWeaponBase:apply_material_parameters()
	local parts_tweak = tweak_data.weapon.factory.parts

	for part_id, part in pairs(self._parts) do
		local material_parameters = parts_tweak[part_id] and parts_tweak[part_id].material_parameters

		if material_parameters then
			local unit = part.unit
			local material_config = unit:get_objects_by_type(material_type_ids)

			for material_name, parameters in pairs(material_parameters) do
				local material_ids = Idstring(material_name)

				for _, material in ipairs(material_config) do
					if material:name() == material_ids then
						for _, parameter in ipairs(parameters) do
							if not parameter.condition or parameter.condition() then
								local value = type(parameter.value) == "function" and parameter.value() or parameter.value

								material:set_variable(parameter.id, value)
							end
						end
					end
				end
			end
		end
	end
end

-- Lines: 163 to 219
function NewRaycastWeaponBase:apply_texture_switches()
	local parts_tweak = tweak_data.weapon.factory.parts
	self._parts_texture_switches = self._parts_texture_switches or {}

	if self._texture_switches then
		local texture_switch, part_data, unit, material_ids, material_config, switch_material = nil

		for part_id, texture_data in pairs(self._texture_switches) do
			if self._parts_texture_switches[part_id] ~= texture_data then
				local switch_materials = {}
				texture_switch = parts_tweak[part_id] and parts_tweak[part_id].texture_switch
				part_data = self._parts and self._parts[part_id]

				if texture_switch and part_data then
					unit = part_data.unit
					material_config = unit:get_objects_by_type(Idstring("material"))
					local ids = {}

					if type(texture_switch.material) == "table" then
						for _, name in ipairs(texture_switch.material) do
							table.insert(ids, Idstring(name))
						end
					else
						table.insert(ids, Idstring(texture_switch.material))
					end

					for _, material in ipairs(material_config) do
						for _, material_name in ipairs(ids) do
							if material:name() == material_name then
								table.insert(switch_materials, material)
							end
						end
					end

					if #switch_materials > 0 then
						local texture_id = managers.blackmarket:get_texture_switch_from_data(texture_data, part_id)

						if texture_id and DB:has(Idstring("texture"), texture_id) then
							local retrieved_texture = TextureCache:retrieve(texture_id, "normal")

							for _, switch_material in ipairs(switch_materials) do
								Application:set_material_texture(switch_material, Idstring(texture_switch.channel), retrieved_texture)
							end

							if self._parts_texture_switches[part_id] then
								TextureCache:unretrieve(self._parts_texture_switches[part_id])
							end

							self._parts_texture_switches[part_id] = Idstring(texture_id)
						else
							Application:error("[NewRaycastWeaponBase:apply_texture_switches] Switch texture do not exists", texture_id)
						end
					end
				end
			end
		end
	end
end

-- Lines: 222 to 223
function NewRaycastWeaponBase:check_npc()
end

-- Lines: 228 to 233
function NewRaycastWeaponBase:change_part(part_id)
	self._parts = managers.weapon_factory:change_part(self._unit, self._factory_id, part_id or "wpn_fps_m4_uupg_b_sd", self._parts, self._blueprint)

	self:_update_fire_object()
	self:_update_stats_values()
end

-- Lines: 235 to 239
function NewRaycastWeaponBase:remove_part(part_id)
	self._parts = managers.weapon_factory:remove_part(self._unit, self._factory_id, part_id, self._parts, self._blueprint)

	self:_update_fire_object()
	self:_update_stats_values()
end

-- Lines: 241 to 245
function NewRaycastWeaponBase:remove_part_by_type(type)
	self._parts = managers.weapon_factory:remove_part_by_type(self._unit, self._factory_id, type, self._parts, self._blueprint)

	self:_update_fire_object()
	self:_update_stats_values()
end

-- Lines: 247 to 252
function NewRaycastWeaponBase:change_blueprint(blueprint)
	self._blueprint = blueprint
	self._parts = managers.weapon_factory:change_blueprint(self._unit, self._factory_id, self._parts, blueprint)

	self:_update_fire_object()
	self:_update_stats_values()
end

-- Lines: 255 to 259
function NewRaycastWeaponBase:blueprint_to_string()
	local s = managers.weapon_factory:blueprint_to_string(self._factory_id, self._blueprint)

	return s
end

-- Lines: 263 to 269
function NewRaycastWeaponBase:_update_fire_object()
	local fire = managers.weapon_factory:get_part_from_weapon_by_type("barrel_ext", self._parts) or managers.weapon_factory:get_part_from_weapon_by_type("slide", self._parts) or managers.weapon_factory:get_part_from_weapon_by_type("barrel", self._parts)
end

-- Lines: 271 to 319
function NewRaycastWeaponBase:_update_stats_values()
	return

	local base_stats = self:weapon_tweak_data().stats

	if not base_stats then
		return
	end

	local parts_stats = managers.weapon_factory:get_stats(self._factory_id, self._blueprint)
	self._silencer = managers.weapon_factory:has_perk("silencer", self._factory_id, self._blueprint)
	local stats = deep_clone(base_stats)
	local tweak_data = tweak_data.weapon.stats
	local modifier_stats = self:weapon_tweak_data().stats_modifiers

	if stats.zoom then
		stats.zoom = math.min(stats.zoom + managers.player:upgrade_value(self:weapon_tweak_data().categories[1], "zoom_increase", 0), #tweak_data.zoom)
	end

	for stat, _ in pairs(stats) do
		if parts_stats[stat] then
			stats[stat] = stats[stat] + parts_stats[stat]
		end

		stats[stat] = stats[stat] + managers.player:upgrade_value("weapon", stat .. "_index_addend", 0)
		stats[stat] = stats[stat] + managers.player:upgrade_value(self._name_id, stat .. "_index_addend", 0)
		stats[stat] = math_clamp(stats[stat], 1, #tweak_data[stat])
	end

	self._current_stats = {}

	for stat, i in pairs(stats) do
		self._current_stats[stat] = tweak_data[stat][i]

		if modifier_stats and modifier_stats[stat] then
			self._current_stats[stat] = self._current_stats[stat] * modifier_stats[stat]
		end
	end

	self._alert_size = self._current_stats.alert_size or self._alert_size
	self._suppression = self._current_stats.suppression or self._suppression
	self._zoom = self._current_stats.zoom or self._zoom
	self._spread = self._current_stats.spread or self._spread
	self._recoil = self._current_stats.recoil or self._recoil
	self._spread_moving = self._current_stats.spread_moving or self._spread_moving
end

-- Lines: 324 to 325
function NewRaycastWeaponBase:stance_id()
	return "new_m4"
end

-- Lines: 328 to 329
function NewRaycastWeaponBase:weapon_hold()
	return self:weapon_tweak_data().weapon_hold
end

-- Lines: 332 to 346
function NewRaycastWeaponBase:stance_mod()
	if not self._parts then
		return nil
	end

	local factory = tweak_data.weapon.factory

	for part_id, data in pairs(self._parts) do
		if factory.parts[part_id].stance_mod and factory.parts[part_id].stance_mod[self._factory_id] then
			return {translation = factory.parts[part_id].stance_mod[self._factory_id].translation}
		end
	end

	return nil
end

-- Lines: 354 to 378
function NewRaycastWeaponBase:tweak_data_anim_play(anim, speed_multiplier)
	local data = tweak_data.weapon.factory[self._factory_id]

	if data.animations and data.animations[anim] then
		local anim_name = data.animations[anim]
		local length = self._unit:anim_length(Idstring(anim_name))
		speed_multiplier = speed_multiplier or 1

		self._unit:anim_stop(Idstring(anim_name))
		self._unit:anim_set_time(Idstring(anim_name), length)
	end

	for part_id, data in pairs(self._parts) do
		if data.animations and data.animations[anim] then
			local anim_name = data.animations[anim]
			local length = data.unit:anim_length(Idstring(anim_name))
			speed_multiplier = speed_multiplier or 1

			data.unit:anim_stop(Idstring(anim_name))
			data.unit:anim_set_time(Idstring(anim_name), length)
		end
	end

	return true
end

-- Lines: 384 to 398
function NewRaycastWeaponBase:tweak_data_anim_stop(anim)
	local data = tweak_data.weapon.factory[self._factory_id]

	if data.animations and data.animations[anim] then
		local anim_name = data.animations[anim]

		self._unit:anim_stop(Idstring(anim_name))
	end

	for part_id, data in pairs(self._parts) do
		if data.unit and data.animations and data.animations[anim] then
			local anim_name = data.animations[anim]

			data.unit:anim_stop(Idstring(anim_name))
		end
	end
end

-- Lines: 402 to 410
function NewRaycastWeaponBase:_set_parts_enabled(enabled)
	if self._parts then
		for part_id, data in pairs(self._parts) do
			if alive(data.unit) then
				data.unit:set_enabled(enabled)
			end
		end
	end
end

-- Lines: 412 to 415
function NewRaycastWeaponBase:on_enabled(...)
	NewRaycastWeaponBase.super.on_enabled(self, ...)
	self:_set_parts_enabled(true)
end

-- Lines: 418 to 422
function NewRaycastWeaponBase:on_disabled(...)
	self:gadget_off()
	self:_set_parts_enabled(false)
end

-- Lines: 426 to 427
function NewRaycastWeaponBase:has_gadget()
	return managers.weapon_factory:get_part_from_weapon_by_type("gadget", self._parts) and true or false
end

-- Lines: 430 to 436
function NewRaycastWeaponBase:gadget_on()
	self._gadget_on = true
	local gadget = managers.weapon_factory:get_part_from_weapon_by_type("gadget", self._parts)

	if gadget then
		gadget.unit:base():set_state(self._gadget_on)
	end
end

-- Lines: 438 to 444
function NewRaycastWeaponBase:gadget_off()
	self._gadget_on = false
	local gadget = managers.weapon_factory:get_part_from_weapon_by_type("gadget", self._parts)

	if gadget then
		gadget.unit:base():set_state(self._gadget_on)
	end
end

-- Lines: 446 to 452
function NewRaycastWeaponBase:toggle_gadget()
	self._gadget_on = not self._gadget_on
	local gadget = managers.weapon_factory:get_part_from_weapon_by_type("gadget", self._parts)

	if gadget then
		gadget.unit:base():set_state(self._gadget_on)
	end
end

-- Lines: 454 to 455
function NewRaycastWeaponBase:toggle_firemode()
end

-- Lines: 458 to 496
function NewRaycastWeaponBase:check_stats()
	local base_stats = self:weapon_tweak_data().stats

	if not base_stats then
		print("no stats")

		return
	end

	local parts_stats = managers.weapon_factory:get_stats(self._factory_id, self._blueprint)
	local stats = deep_clone(base_stats)
	local tweak_data = tweak_data.weapon.stats
	local modifier_stats = self:weapon_tweak_data().stats_modifiers
	stats.zoom = math.min(stats.zoom + managers.player:upgrade_value(self:weapon_tweak_data().categories[1], "zoom_increase", 0), #tweak_data.zoom)

	for stat, _ in pairs(stats) do
		if parts_stats[stat] then
			stats[stat] = math_clamp(stats[stat] + parts_stats[stat], 1, #tweak_data[stat])
		end
	end

	self._current_stats = {}

	for stat, i in pairs(stats) do
		self._current_stats[stat] = tweak_data[stat][i]

		if modifier_stats and modifier_stats[stat] then
			self._current_stats[stat] = self._current_stats[stat] * modifier_stats[stat]
		end
	end

	self._current_stats.alert_size = tweak_data.alert_size[math_clamp(stats.alert_size, 1, #tweak_data.alert_size)]

	if modifier_stats and modifier_stats.alert_size then
		self._current_stats.alert_size = self._current_stats.alert_size * modifier_stats.alert_size
	end

	return stats
end

-- Lines: 501 to 518
function NewRaycastWeaponBase:destroy(unit)
	if self._parts_texture_switches then
		for part_id, texture_ids in pairs(self._parts_texture_switches) do
			TextureCache:unretrieve(texture_ids)
		end
	end

	if self._textures then
		for tex_id, texture_data in pairs(self._textures) do
			if not texture_data.applied then
				texture_data.applied = true

				TextureCache:unretrieve(texture_data.name)
			end
		end
	end

	managers.weapon_factory:disassemble(self._parts)
end

