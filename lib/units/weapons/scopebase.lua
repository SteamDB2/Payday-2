
-- Lines: 4 to 32
function NewRaycastWeaponBase:set_scope_enabled(enabled)
	if self:is_npc() then
		return
	end

	if self._scope_camera_configuration and _G.IS_VR then
		local user_unit = managers.player:player_unit()
		local camera = nil
		camera = not user_unit and managers.menu:player() or user_unit:camera()

		if camera then
			if enabled then
				local config = self._scope_camera_configuration

				camera:link_scope(config.a_camera, config.a_screen, config.material, config.channel, config.fov)
			else
				camera:unlink_scope()
			end
		end
	end
end

-- Lines: 37 to 72
function NewRaycastWeaponBase:configure_scope()
	if self:is_npc() then
		return
	end

	local parts_tweak = tweak_data.weapon.factory.parts

	for part_id, part in pairs(self._parts) do
		if parts_tweak[part_id] and parts_tweak[part_id].camera then
			local camera = parts_tweak[part_id] and parts_tweak[part_id].camera

			if camera then
				local config = {
					a_camera = part.unit:get_object(Idstring(camera.a_camera)),
					a_screen = part.unit:get_object(Idstring(camera.a_screen))
				}
				local material = nil
				local material_name = Idstring(camera.material)
				local material_config = part.unit:get_objects_by_type(Idstring("material"))

				for _, _material in ipairs(material_config) do
					if _material:name() == material_name then
						material = _material

						break
					end
				end

				config.material = material
				config.channel = Idstring(camera.channel)
				config.fov = camera.fov or 20
				self._scope_camera_configuration = config

				break
			end
		end
	end
end

