NPCSawWeaponBase = NPCSawWeaponBase or class(NewNPCRaycastWeaponBase)

-- Lines: 3 to 8
function NPCSawWeaponBase:init(unit)
	NPCSawWeaponBase.super.init(self, unit, false)

	self._active_effect_name = Idstring("effects/payday2/particles/weapons/saw/sawing")
	self._active_effect_table = {
		force_synch = true,
		effect = self._active_effect_name,
		parent = self._obj_fire
	}
end

-- Lines: 12 to 14
function NPCSawWeaponBase:_play_sound_sawing()
	self:play_sound("Play_npc_saw_handheld_grind_generic")
end

-- Lines: 16 to 18
function NPCSawWeaponBase:_play_sound_idle()
	self:play_sound("Play_npc_saw_handheld_loop_idle")
end

-- Lines: 20 to 29
function NPCSawWeaponBase:update(unit, t, dt)
	if self._check_shooting_expired and self._check_shooting_expired.check_t < t then
		self._check_shooting_expired = nil

		self._unit:set_extension_update_enabled(Idstring("base"), false)
		SawWeaponBase._stop_sawing_effect(self)
		self:play_tweak_data_sound("stop_fire")
	end
end

-- Lines: 31 to 34
function NPCSawWeaponBase:change_fire_object(new_obj)
	NPCSawWeaponBase.super.change_fire_object(self, new_obj)

	self._active_effect_table.parent = new_obj
end
local mto = Vector3()
local mfrom = Vector3()

-- Lines: 39 to 63
function NPCSawWeaponBase:fire_blank(direction, impact)
	if not self._check_shooting_expired then
		self:play_tweak_data_sound("fire")
	end

	self._check_shooting_expired = {check_t = Application:time() + 0.5}

	self._unit:set_extension_update_enabled(Idstring("base"), true)
	self._obj_fire:m_position(mfrom)

	direction = self._obj_fire:rotation():y()

	mvector3.add(mfrom, direction * -30)
	mvector3.set(mto, direction)
	mvector3.multiply(mto, 50)
	mvector3.add(mto, mfrom)

	local col_ray = World:raycast("ray", mfrom, mto, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

	if col_ray and col_ray.unit then
		SawWeaponBase._start_sawing_effect(self)
	else
		SawWeaponBase._stop_sawing_effect(self)
	end
end

-- Lines: 66 to 73
function NPCSawWeaponBase:_sound_autofire_start(nr_shots)
	local tweak_sound = tweak_data.weapon[self._name_id].sounds or {}

	self._sound_fire:stop()

	local sound = self._sound_fire:post_event(tweak_sound.fire, callback(self, self, "_on_auto_fire_stop"), nil, "end_of_event")
	sound = sound or self._sound_fire:post_event(tweak_sound.fire)
end

-- Lines: 75 to 81
function NPCSawWeaponBase:_sound_autofire_end()
	local tweak_sound = tweak_data.weapon[self._name_id].sounds or {}
	local sound = self._sound_fire:post_event(tweak_sound.stop_fire)
	sound = sound or self._sound_fire:post_event(tweak_sound.stop_fire)
end

-- Lines: 84 to 85
function NPCSawWeaponBase:third_person_important()
	return SawWeaponBase.third_person_important(self)
end

-- Lines: 88 to 91
function NPCSawWeaponBase:destroy(...)
	NPCSawWeaponBase.super.destroy(self, ...)
	SawWeaponBase._stop_sawing_effect(self)
end

