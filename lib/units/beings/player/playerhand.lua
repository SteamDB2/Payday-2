require("lib/units/beings/player/PlayerHandStateMachine")
require("lib/units/beings/player/PlayerWatch")
require("lib/input/HandStateMachine")
require("lib/input/HandStatesPlayer")

PlayerHand = PlayerHand or class()
PlayerHand.RIGHT = 1
PlayerHand.LEFT = 2

-- Lines: 13 to 19
function PlayerHand.hand_id(arg)
	if arg == PlayerHand.RIGHT or string.lower(arg) == "right" then
		return PlayerHand.RIGHT
	elseif arg == PlayerHand.LEFT or string.lower(arg) == "left" then
		return PlayerHand.LEFT
	end
end

-- Lines: 21 to 22
function PlayerHand.other_hand_id(arg)
	return 3 - PlayerHand.hand_id(arg)
end

-- Lines: 25 to 155
function PlayerHand:init(unit)
	print("[PlayerHand] Init")

	if not PackageManager:loaded("packages/vr_base") then
		PackageManager:load("packages/vr_base")
	end

	local camera = unit:camera()
	local camera_unit = camera:camera_unit()
	local controller = unit:base():controller()
	local hand_states = {
		empty = EmptyHandState:new(),
		point = PointHandState:new(),
		weapon = WeaponHandState:new(),
		mask = MaskHandState:new(),
		item = ItemHandState:new(),
		ability = AbilityHandState:new(),
		equipment = EquipmentHandState:new(),
		akimbo = AkimboHandState:new(),
		tablet = TabletHandState:new(),
		belt = BeltHandState:new(),
		repeater = RepeaterHandState:new(),
		driving = DrivingHandState:new(),
		arrow = ArrowHandState:new()
	}
	self._hand_state_machine = HandStateMachine:new(hand_states, hand_states.empty, hand_states.empty)

	self._hand_state_machine:attach_controller(controller, true)
	self._hand_state_machine:attach_controller(managers.menu:get_controller())
	managers.vr:set_hand_state_machine(self._hand_state_machine)

	self._controller = controller
	self._vr_controller = controller:get_controller("vr")
	local base_rotation = camera_unit:base():base_rotation()
	self._base_rotation = base_rotation
	self._unit = unit
	self._unit_movement_ext = unit:movement()
	self._camera_unit = camera_unit
	self._belt_yaw = base_rotation:yaw()
	self._prev_ghost_position = mvector3.copy(self._unit_movement_ext:ghost_position())
	self._hand_data = {}
	local l_hand_unit = World:spawn_unit(Idstring("units/pd2_dlc_vr/player/vr_hand_left"), Vector3(0, 0, 0), Rotation())
	local r_hand_unit = World:spawn_unit(Idstring("units/pd2_dlc_vr/player/vr_hand_right"), Vector3(0, 0, 0), Rotation())

	l_hand_unit:base():set_other_hand_unit(r_hand_unit)
	r_hand_unit:base():set_other_hand_unit(l_hand_unit)
	l_hand_unit:warp():set_player_unit(unit)
	r_hand_unit:warp():set_player_unit(unit)

	self._shadow_unit = World:spawn_unit(Idstring("units/pd2_dlc_vr/player/vr_shadow"), Vector3(0, 0, 0), Rotation())

	unit:link(l_hand_unit)
	unit:link(r_hand_unit)
	unit:link(self._shadow_unit)

	local controller_rotation = Rotation()

	if managers.vr:is_oculus() then
		controller_rotation = Rotation(math.X, -30)
	end

	table.insert(self._hand_data, {
		hand = "right",
		state = "idle",
		unit = r_hand_unit,
		base_rotation = Rotation(math.X, -50),
		base_rotation_controller = controller_rotation,
		base_position = Vector3(0, -2, -7),
		base_position_finger = Vector3(3.5, 11, 3.5),
		position = Vector3(),
		finger_position = Vector3(),
		rotation = Rotation(),
		rotation_raw = Rotation(),
		prev_position = Vector3(),
		prev_rotation = Rotation()
	})
	table.insert(self._hand_data, {
		hand = "left",
		state = "idle",
		unit = l_hand_unit,
		base_rotation = Rotation(math.X, -50),
		base_rotation_controller = controller_rotation,
		base_position = Vector3(0, -2, -7),
		base_position_finger = Vector3(-3.5, 11, 3.5),
		position = Vector3(),
		finger_position = Vector3(),
		rotation = Rotation(),
		rotation_raw = Rotation(),
		prev_position = Vector3(),
		prev_rotation = Rotation()
	})
	r_hand_unit:base():set_hand_data(self._hand_data[1])
	l_hand_unit:base():set_hand_data(self._hand_data[2])

	self._watch = PlayerWatch:new(l_hand_unit)
	self._shared_transition_queue = StateMachineTransitionQueue:new()
	self._hand_data[PlayerHand.RIGHT].state_machine = PlayerHandStateMachine:new(self._hand_data[PlayerHand.RIGHT].unit, PlayerHand.RIGHT, self._shared_transition_queue)
	self._hand_data[PlayerHand.LEFT].state_machine = PlayerHandStateMachine:new(self._hand_data[PlayerHand.LEFT].unit, PlayerHand.LEFT, self._shared_transition_queue)

	self._hand_data[PlayerHand.RIGHT].state_machine:set_other_hand(self._hand_data[PlayerHand.LEFT].state_machine)
	self._hand_data[PlayerHand.LEFT].state_machine:set_other_hand(self._hand_data[PlayerHand.RIGHT].state_machine)

	self._belt_unit = World:spawn_unit(Idstring("units/pd2_dlc_vr/player/vr_hud_belt"), Vector3(0, 0, 0), Rotation())

	self._belt_unit:set_visible(false)

	self._float_unit = World:spawn_unit(Idstring("units/pd2_dlc_vr/player/vr_hud_belt"), Vector3(0, 0, 0), Rotation())

	self._float_unit:set_visible(false)

	local default_weapon_hand = self.hand_id(managers.vr:get_setting("default_weapon_hand") or "right")
	local default_tablet_hand = self.hand_id(managers.vr:get_setting("default_tablet_hand") or "left")

	managers.hud:bind_hud_to_vr_hand(self:hand_unit(default_weapon_hand), self:hand_unit(default_tablet_hand), self._belt_unit, default_weapon_hand, default_tablet_hand, self._float_unit)
	self._hand_data[default_weapon_hand].state_machine:set_default_state("weapon")
	self._hand_data[self.other_hand_id(default_tablet_hand)].unit:damage():run_sequence_simple("hide_gadgets")

	self._tablet_hand_changed_clbk = callback(self, self, "on_tablet_hand_changed")

	managers.vr:add_setting_changed_callback("default_tablet_hand", self._tablet_hand_changed_clbk)

	self._belt_size_changed_clbk = callback(self, self, "on_belt_size_changed")

	managers.vr:add_setting_changed_callback("belt_size", self._belt_size_changed_clbk)
end

-- Lines: 157 to 167
function PlayerHand:destroy()
	print("[PlayerHand] Destroy")

	for _, controller in ipairs(self._hand_data) do
		controller.unit:unlink()
		World:delete_unit(controller.unit)

		controller.unit = nil
	end

	managers.vr:remove_setting_changed_callback("default_tablet_hand", self._tablet_hand_changed_clbk)
	managers.vr:remove_setting_changed_callback("belt_size", self._belt_size_changed_clbk)
end

-- Lines: 169 to 181
function PlayerHand:on_tablet_hand_changed(setting, old, new)
	self:hand_unit(new):damage():run_sequence_simple("show_gadgets")
	self:hand_unit(old):damage():run_sequence_simple("hide_gadgets")

	local default_weapon_hand = self.hand_id(managers.vr:get_setting("default_weapon_hand") or "right")
	local default_tablet_hand = self.hand_id(managers.vr:get_setting("default_tablet_hand") or "left")

	managers.hud:bind_hud_to_vr_hand(self:hand_unit(default_weapon_hand), self:hand_unit(default_tablet_hand), self._belt_unit, default_weapon_hand, default_tablet_hand, self._float_unit)

	local current_mask_hand_id = self:get_active_hand_id("mask")

	if current_mask_hand_id then
		self:current_hand_state(current_mask_hand_id):switch_hands()
	end
end

-- Lines: 183 to 185
function PlayerHand:on_belt_size_changed(setting, old, new)
	HUDManagerVR.link_belt(managers.hud:belt_workspace(), self._belt_unit)
end

-- Lines: 187 to 191
function PlayerHand:_set_hand_state(hand, state, params)
	if self._hand_data[hand].state_machine:can_change_state_by_name(state) then
		self._hand_data[hand].state_machine:change_state_by_name(state, params)
	end
end

-- Lines: 193 to 195
function PlayerHand:_change_hand_to_default(hand, params)
	self._hand_data[hand].state_machine:change_to_default(params)
end

-- Lines: 197 to 198
function PlayerHand:current_hand_state(hand)
	return self._hand_data[hand].state_machine:current_state()
end

-- Lines: 201 to 207
function PlayerHand:get_default_hand_id(state)
	for id, hand_data in ipairs(self._hand_data) do
		if hand_data.state_machine:default_state_name() == state then
			return id
		end
	end
end

-- Lines: 209 to 211
function PlayerHand:set_default_state(hand, state, force_change)
	self._hand_data[self.hand_id(hand)].state_machine:set_default_state(state, force_change)
end

-- Lines: 213 to 215
function PlayerHand:set_custom_belt_height_ratio(height)
	self._custom_belt_height_ratio = height
end
local pen = Draw:pen()
local prints = 20

-- Lines: 220 to 223
function PlayerHand:set_precision_mode(precision_mode, length)
	self._precision_mode = precision_mode
	self._precision_mode_length = length
end

-- Lines: 225 to 226
function PlayerHand:precision_mode()
	return self._precision_mode
end

-- Lines: 229 to 383
function PlayerHand:_update_controllers(t, dt)
	local hmd_pos = VRManager:hmd_position()
	local current_height = hmd_pos.z

	mvector3.set_z(hmd_pos, 0)

	local ghost_position = self._unit_movement_ext:ghost_position()

	if self._vr_controller then
		local precision_mode = self._precision_mode

		if precision_mode then
			self._precision_mode_t = self._precision_mode_t or t
		elseif self._precision_mode_t and t - self._precision_mode_t > 0.7 then
			self._precision_mode_t = nil
		end

		precision_mode = precision_mode and t - self._precision_mode_t > 0.7 and not self._precision_mode_block_t

		if self._precision_mode_block_t and t - self._precision_mode_block_t > 0.7 then
			self._precision_mode_block_t = nil
		end

		local max_speed = 0

		for i, controller in ipairs(self._hand_data) do
			local pos, rot = self._vr_controller:pose(i - 1)
			rot = self._base_rotation * rot
			pos = pos - hmd_pos

			mvector3.rotate_with(pos, self._base_rotation)

			if precision_mode then
				local deg = math.acos(math.abs(mrotation.dot(rot, controller.prev_rotation)))

				if math.abs(deg) < 0.0001 then
					deg = 0.0001
				end

				if deg < 2 then
					local t_slerp = math.min((math.lerp(2, 5, self._precision_mode_length) * 20 * dt) / deg, 1)

					mrotation.slerp(rot, controller.prev_rotation, rot, t_slerp)
				end
			end

			mrotation.set_zero(controller.prev_rotation)
			mrotation.multiply(controller.prev_rotation, rot)
			mrotation.set_zero(controller.rotation_raw)
			mrotation.multiply(controller.rotation_raw, rot)
			mrotation.multiply(controller.rotation_raw, controller.base_rotation_controller)
			mrotation.multiply(rot, controller.base_rotation)

			controller.rotation = rot
			pos = pos + controller.base_position:rotate_with(controller.rotation)
			local dir = pos - controller.prev_position
			local len = mvector3.normalize(dir)
			local speed = len / dt
			max_speed = math.max(max_speed, speed)

			if precision_mode then
				pos = controller.prev_position + math.lerp(0.15, 0.2, self._precision_mode_length) * dir * speed * dt
			end

			controller.prev_position = pos
			pos = pos + ghost_position
			local forward = Vector3(0, 1, 0)
			controller.forward = forward:rotate_with(controller.rotation)
			controller.position = pos

			mvector3.set(controller.finger_position, controller.base_position_finger)
			mvector3.rotate_with(controller.finger_position, controller.rotation)
			mvector3.add(controller.finger_position, pos)
			controller.unit:set_position(pos)
			controller.unit:set_rotation(rot)
			controller.state_machine:set_position(pos)
			controller.state_machine:set_rotation(rot)

			if self._scheculed_wall_checks and self._scheculed_wall_checks[i] and self._scheculed_wall_checks[i].t < t then
				local custom_obj = self._scheculed_wall_checks[i].custom_obj
				self._scheculed_wall_checks[i] = nil

				if not self:check_hand_through_wall(i, custom_obj) then
					controller.unit:damage():run_sequence_simple(self:current_hand_state(i)._sequence)
				end
			end
		end

		if max_speed > 110 or self._precision_mode_block_t and max_speed > 20 then
			self._precision_mode_block_t = t
		end

		for _, controller in ipairs(self._hand_data) do
			controller.state_machine:update(t, dt)
		end

		self._shared_transition_queue:do_state_change()
	end

	local rot = VRManager:hmd_rotation()
	rot = self._base_rotation * rot
	local forward = Vector3(0, 1, 0)
	local up = Vector3(0, 0, 1)

	mvector3.rotate_with(forward, rot)
	mvector3.rotate_with(up, rot)

	local v = forward

	if forward.y < 0.5 then
		v = up
	end

	mvector3.set_z(v, 0)
	mvector3.normalize(v)
	self._shadow_unit:set_position(ghost_position - v * 30 + Vector3(0, 0, 5))

	local max_angle = managers.vr:get_setting("belt_snap")
	local angle = rot:rotation_difference(Rotation(self._belt_yaw, 0, 0), Rotation(rot:yaw(), 0, 0)):yaw()
	local abs_angle = math.abs(angle)
	local distance = mvector3.distance_sq(self._prev_ghost_position, ghost_position)

	if rot:pitch() > -35 or max_angle < abs_angle or distance > 1600 then
		self._prev_ghost_position = mvector3.copy(ghost_position)
		self._belt_yaw = rot:yaw()
	end

	local belt_rot = Rotation(self._belt_yaw, 0, 0)

	self._belt_unit:set_position(ghost_position + Vector3(0, managers.vr:get_setting("belt_distance"), current_height * (self._custom_belt_height_ratio or managers.vr:get_setting("belt_height_ratio"))):rotate_with(belt_rot))
	self._belt_unit:set_rotation(belt_rot)

	local wanted_float_rot = Rotation(rot:yaw())

	self._float_unit:set_position(ghost_position + Vector3(0, 0, current_height + 40) + self._float_unit:rotation():y() * 10)
	self._float_unit:set_rotation(self._float_unit:rotation():slerp(wanted_float_rot, dt * 8))

	local look_dot = math.clamp(mvector3.dot(rot:y(), Vector3(0, 0, -1)), 0, 1) - 0.6

	managers.hud:belt():set_alpha(look_dot * 1.5)

	for i = 1, 2, 1 do
		local found = nil

		if managers.hud:belt():visible() then
			for _, interact_name in ipairs(managers.hud:belt():valid_interactions()) do
				local interact_pos = managers.hud:belt():get_interaction_point(interact_name)
				local dis = mvector3.distance_sq(self:hand_unit(i):position(), interact_pos)
				local height_diff = self:hand_unit(i):position().z - interact_pos.z

				if managers.hud:belt():interacting(interact_name, self:hand_unit(i):position()) and height_diff < 10 and height_diff > -60 then
					found = true
				end
			end
		end

		self:set_belt_active(found, i)
	end
end
local tablet_normal = Vector3(-1, 0, 0)
local rotated_tablet_normal = Vector3(0, 0, 0)

-- Lines: 387 to 402
function PlayerHand:update(unit, t, dt)
	if self._block_input then
		return
	end

	self:_update_controllers(t, dt)

	local hmd_forward = (self._base_rotation * VRManager:hmd_rotation()):y()
	local weapon_hand_id = self:get_active_hand_id("weapon")

	if weapon_hand_id then
		local dot = mvector3.dot(self:hand_unit(weapon_hand_id):rotation():y(), hmd_forward)

		managers.hud:set_ammo_alpha(math.clamp(dot * math.abs(dot) - 0.5, 0, 0.5) * 2)
	end

	self:update_tablet(t, dt, hmd_forward)
end

-- Lines: 408 to 461
function PlayerHand:update_tablet(t, dt, hmd_forward)
	local default_tablet_hand = self.hand_id(managers.vr:get_setting("default_tablet_hand") or "left")
	local other_hand = self.other_hand_id(default_tablet_hand)
	local current = self:current_hand_state(other_hand)
	local swiping = current:name(default_tablet_hand) == "swipe"
	local hand_unit = self:hand_unit(other_hand)
	local pos = hand_unit:base():finger_position()
	local hand_rotation = hand_unit:base():rotation()
	local tablet_hand = self:hand_unit(default_tablet_hand)
	local hud_object = tablet_hand:get_object(Idstring("player_hud_tablet"))
	local oobb = hud_object:oobb()
	local x = oobb:x()
	local y = oobb:y()
	local width = mvector3.normalize(x)
	local height = mvector3.normalize(y)
	local up = Vector3()

	mvector3.cross(up, y, x)

	local dir = mvector3.copy(pos)
	local center = oobb:center()

	mvector3.subtract(dir, center)

	local length = mvector3.dot(dir, up)
	local x_len = mvector3.dot(dir, x)
	local y_len = mvector3.dot(dir, y)
	local inside = false
	local tablet = tweak_data.vr.tablet
	local looking_at_tablet = mvector3.dot(up, hmd_forward) < tablet.view_angle_th

	if not swiping then
		local vol = tweak_data.vr.tablet.interaction_volume_start

		if looking_at_tablet and mvector3.dot(hand_rotation:y(), up) < vol.angle_th and vol.min_depth < length and length < vol.max_depth and math.abs(x_len) <= width + vol.extra_width and math.abs(y_len) <= height + vol.extra_height then
			self:set_point_at_tablet(true)
		end
	elseif not looking_at_tablet or tablet.interaction_radius_sq < mvector3.distance_sq(pos, center) or tablet.interaction_angle_th < mvector3.dot(hand_rotation:y(), up) then
		self:set_point_at_tablet(false)
	end
end

-- Lines: 463 to 469
function PlayerHand:hand_position(hand)
	if hand == 1 or hand == "right" then
		return self._hand_data[PlayerHand.RIGHT].position
	elseif hand == 2 or hand == "left" then
		return self._hand_data[PlayerHand.LEFT].position
	end

	return nil
end

-- Lines: 472 to 478
function PlayerHand:finger_position(hand)
	if hand == 1 or hand == "right" then
		return self._hand_data[PlayerHand.RIGHT].finger_position
	elseif hand == 2 or hand == "left" then
		return self._hand_data[PlayerHand.LEFT].finger_position
	end

	return nil
end

-- Lines: 481 to 487
function PlayerHand:hand_rotation(hand)
	if hand == 1 or hand == "right" then
		return self._hand_data[PlayerHand.RIGHT].rotation
	elseif hand == 2 or hand == "left" then
		return self._hand_data[PlayerHand.LEFT].rotation
	end

	return nil
end

-- Lines: 490 to 496
function PlayerHand:raw_hand_rotation(hand)
	if hand == 1 or hand == "right" then
		return self._hand_data[PlayerHand.RIGHT].rotation_raw
	elseif hand == 2 or hand == "left" then
		return self._hand_data[PlayerHand.LEFT].rotation_raw
	end

	return nil
end

-- Lines: 499 to 505
function PlayerHand:hand_unit(hand)
	if hand == 1 or hand == "right" then
		return self._hand_data[PlayerHand.RIGHT].unit
	elseif hand == 2 or hand == "left" then
		return self._hand_data[PlayerHand.LEFT].unit
	end

	return nil
end

-- Lines: 508 to 510
function PlayerHand:mask_hand_id()
	local default_tablet_hand = self.hand_id(managers.vr:get_setting("default_tablet_hand") or "left")

	return self.other_hand_id(default_tablet_hand)
end

-- Lines: 513 to 514
function PlayerHand:mask_hand_unit()
	return self:hand_unit(self:mask_hand_id())
end

-- Lines: 517 to 524
function PlayerHand:link_mask(mask_unit)
	local default_weapon_hand = self.hand_id(managers.vr:get_setting("default_weapon_hand") or "right")

	self._hand_data[default_weapon_hand].state_machine:set_default_state("idle")
	self:_set_hand_state(self:mask_hand_id(), "item", {
		type = "mask",
		unit = mask_unit,
		prompt = {
			text_id = "hud_instruct_mask_on",
			macros = {BTN_USE_ITEM = managers.localization:btn_macro("use_item")}
		}
	})
	self:_set_hand_state(self.other_hand_id(self:mask_hand_id()), "idle")

	self._mask_unit = mask_unit
end

-- Lines: 526 to 538
function PlayerHand:unlink_mask(next_state)
	local default_weapon_hand = self.hand_id(managers.vr:get_setting("default_weapon_hand") or "right")
	self._mask_unit = nil

	self._hand_data[default_weapon_hand].state_machine:set_default_state("weapon")
	self:_change_hand_to_default(default_weapon_hand)
	self:_change_hand_to_default(self.other_hand_id(default_weapon_hand))
end

-- Lines: 540 to 551
function PlayerHand:set_point_at_tablet(point)
	local non_tablet_hand_id = self.other_hand_id(managers.vr:get_setting("default_tablet_hand") or "left")

	if point then
		self:_set_hand_state(non_tablet_hand_id, "swipe", {flick_callback = callback(managers.hud, managers.hud, "on_flick")})
	else
		local current = self:current_hand_state(non_tablet_hand_id)

		if current:name() == "swipe" then
			self:_set_hand_state(non_tablet_hand_id, current.prev_state)
		end
	end
end

-- Lines: 553 to 568
function PlayerHand:set_belt_active(active, hand)
	if not hand then
		self:set_belt_active(active, PlayerHand.RIGHT)
		self:set_belt_active(active, PlayerHand.LEFT)

		return
	end

	if active then
		self:_set_hand_state(hand, "belt")
	else
		local current = self:current_hand_state(hand)

		if current:name() == "belt" then
			self:_change_hand_to_default(hand)
		end
	end
end

-- Lines: 570 to 571
function PlayerHand:warp()
	return self._hand_data[PlayerHand.LEFT].unit:warp()
end

-- Lines: 574 to 575
function PlayerHand:watch()
	return self._watch
end

-- Lines: 578 to 599
function PlayerHand:interaction_ids()
	local weapon_hand_id = self:get_active_hand_id("weapon")

	if not weapon_hand_id then
		for id, hand_data in ipairs(self._hand_data) do
			if hand_data.state_machine:default_state_name() == "weapon" then
				weapon_hand_id = id

				break
			end
		end
	end

	if weapon_hand_id then
		local other_hand_state = self:current_hand_state(self.other_hand_id(weapon_hand_id)):name()

		if other_hand_state == "point" or other_hand_state == "weapon_assist" then
			return {}
		else
			return {self.other_hand_id(weapon_hand_id)}
		end
	else
		return {
			PlayerHand.LEFT,
			PlayerHand.RIGHT
		}
	end
end

-- Lines: 601 to 606
function PlayerHand:interaction_units()
	local units = {}

	for _, id in ipairs(self:interaction_ids()) do
		table.insert(units, self._hand_data[id].unit)
	end

	return units
end

-- Lines: 609 to 616
function PlayerHand:start_show_intrest(blocked, hand)
	if self:current_hand_state(hand):name() == "ready" then
		self:current_hand_state(hand):set_blocked(blocked)
	else
		self:_set_hand_state(hand, "ready", blocked)
	end

	self._vr_controller:trigger_haptic_pulse(hand - 1, 0, 700)
end

-- Lines: 618 to 622
function PlayerHand:end_show_intrest(hand)
	if self:current_hand_state(hand):name() == "ready" then
		self:_change_hand_to_default(hand)
	end
end

-- Lines: 624 to 626
function PlayerHand:intimidate(hand)
	self:_set_hand_state(hand, "point")
end

-- Lines: 628 to 629
function PlayerHand:belt_unit()
	return self._belt_unit
end

-- Lines: 632 to 659
function PlayerHand:set_carry(carry, skip_hand)
	self._carry = carry

	if carry then
		managers.hud:belt():set_state("bag", skip_hand and "default" or "active")

		if not skip_hand then
			local carry_id = managers.player:get_my_carry_data().carry_id
			local unit_name = tweak_data.carry[carry_id].unit

			if unit_name then
				unit_name = string.match(unit_name, "/([^/]*)$")
				unit_name = "units/pd2_dlc_vr/equipment/" .. unit_name .. "_vr"
			else
				unit_name = "units/pd2_dlc_vr/equipment/gen_pku_lootbag_vr"
			end

			local hand_id = self._unit_movement_ext:current_state()._interact_hand or self:interaction_ids()[1]
			local hand_unit = self:hand_unit(hand_id)
			local unit = World:spawn_unit(Idstring(unit_name), hand_unit:position(), hand_unit:rotation() * Rotation(0, 0, -90))

			self:_set_hand_state(hand_id, "item", {
				body = "hinge_body_1",
				type = "bag",
				unit = unit,
				offset = Vector3(0, 15, 0),
				prompt = {
					text_id = "hud_instruct_throw_bag",
					btn_macros = {BTN_USE_ITEM = "use_item_vr"}
				}
			})
		end
	else
		managers.hud:belt():set_state("bag", "inactive")

		local bag_hand = self:get_active_hand_id("bag")

		if bag_hand then
			self:_change_hand_to_default(bag_hand)
		end
	end
end

-- Lines: 664 to 669
function PlayerHand:get_active_hand(item)
	local id = self:get_active_hand_id(item)

	if id then
		return self._hand_data[id].unit
	end
end

-- Lines: 671 to 680
function PlayerHand:get_active_hand_id(item)
	for i in ipairs(self._hand_data) do
		local state = self:current_hand_state(i)

		if state:name() == item then
			return i
		elseif state:name() == "item" and state:item_type() == item then
			return i
		end
	end
end

-- Lines: 682 to 691
function PlayerHand:apply_weapon_kick(amount, akimbo)
	if self:precision_mode() then
		amount = amount * tweak_data.vr.weapon_kick.precision_multiplier
	end

	local id = self:get_active_hand_id(akimbo and "akimbo" or "weapon")

	if id then
		self:current_hand_state(id):set_wanted_weapon_kick(amount)
	end
end

-- Lines: 693 to 702
function PlayerHand:set_cuffed(cuffed)
	for hand in ipairs(self._hand_data) do
		if cuffed then
			self:_set_hand_state(hand, "cuffed")
		else
			self:_change_hand_to_default(hand)
		end
	end
end

-- Lines: 704 to 706
function PlayerHand:set_block_input(block)
	self._block_input = block
end

-- Lines: 708 to 710
function PlayerHand:set_base_rotation(rot)
	self._base_rotation = rot
end

-- Lines: 713 to 720
function PlayerHand:set_warping(warping)
	for hand in ipairs(self._hand_data) do
		local state = self:current_hand_state(hand)

		if state.set_warping then
			state:set_warping(warping)
		end
	end
end

-- Lines: 722 to 739
function PlayerHand:set_tased(tased)
	if self._tase_effects then
		for _, id in ipairs(self._tase_effects) do
			World:effect_manager():fade_kill(id)
		end

		self._tase_effects = nil
	end

	if tased then
		self._tase_effects = {}

		for _, hand_data in ipairs(self._hand_data) do
			table.insert(self._tase_effects, World:effect_manager():spawn({
				effect = Idstring("effects/payday2/particles/vr/vr_taser"),
				parent = hand_data.unit:orientation_object()
			}))
		end
	end
end

-- Lines: 743 to 778
function PlayerHand:check_hand_through_wall(hand, custom_obj)
	local hand_unit = self:hand_unit(hand)
	local head_pos = self._unit_movement_ext:m_head_pos()
	local hand_pos = hand_unit:position()
	local custom_pos = alive(custom_obj) and custom_obj:position()
	local ray = nil
	local raycasts = {
		{ray = {
			custom_pos or hand_pos,
			head_pos
		}},
		{points = {
			custom_pos or hand_pos,
			hand_pos - hand_unit:rotation():y() * 50,
			head_pos
		}},
		{points = {
			custom_pos or hand_pos,
			hand_pos - hand_unit:rotation():y() * 30 + hand_unit:rotation():x() * 30,
			head_pos
		}},
		{points = {
			custom_pos or hand_pos,
			(hand_pos - hand_unit:rotation():y() * 30) - hand_unit:rotation():x() * 30,
			head_pos
		}},
		{points = {
			custom_pos or hand_pos,
			hand_pos - hand_unit:rotation():y() * 30 + hand_unit:rotation():z() * 30,
			head_pos
		}},
		{points = {
			custom_pos or hand_pos,
			(hand_pos - hand_unit:rotation():y() * 30) - hand_unit:rotation():z() * 30,
			head_pos
		}}
	}

	for _, cast in ipairs(raycasts) do
		if cast.ray then
			ray = hand_unit:raycast("slot_mask", 1, "ray", unpack(cast.ray))
		elseif cast.points then
			ray = hand_unit:raycast("points", cast.points, "slot_mask", 1)
		end

		if not ray then
			if self._scheculed_wall_checks and self._scheculed_wall_checks[hand] then
				self:hand_unit(hand):damage():run_sequence_simple(self:current_hand_state(hand)._sequence)

				self._scheculed_wall_checks[hand] = nil
			end

			return false
		end
	end

	self._scheculed_wall_checks = self._scheculed_wall_checks or {}
	self._scheculed_wall_checks[hand] = {
		t = TimerManager:game():time() + tweak_data.vr.wall_check_delay,
		custom_obj = custom_obj
	}

	self:hand_unit(hand):damage():run_sequence_simple("warning")

	return true
end

-- Lines: 781 to 783
function PlayerHand:warp_hand()
	local hand_index = self._hand_state_machine:hand_from_connection("warp") or PlayerHand.other_hand_id(managers.vr:get_setting("default_weapon_hand"))

	return hand_index == PlayerHand.RIGHT and "right" or "left"
end

