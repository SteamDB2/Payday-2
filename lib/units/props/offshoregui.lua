OffshoreGui = OffshoreGui or class()
OffshoreGui.TITLE_COLOR = Color(0.5, 0.6, 0.5)
OffshoreGui.MONEY_COLOR = Color(0.5, 0.6, 0.5)

-- Lines: 6 to 24
function OffshoreGui:init(unit)
	self._unit = unit
	self._visible = true
	self._gui_object = self._gui_object or "gui_object"
	self._new_gui = World:gui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()
	self._unit:set_extension_update_enabled(Idstring("offshore_gui"), false)

	if managers.sync then
		managers.sync:add_managed_unit(self._unit:id(), self)
		self:perform_sync()
	end
end

-- Lines: 26 to 28
function OffshoreGui:add_workspace(gui_object)
	self._ws = self._new_gui:create_object_workspace(1280, 720, gui_object, Vector3(0, 0, 0))
end

-- Lines: 30 to 52
function OffshoreGui:setup()
	if self._back_drop_gui then
		self._back_drop_gui:destroy()
	end

	self._ws:panel():clear()
	self._ws:panel():set_alpha(0.8)
	self._ws:panel():rect({
		layer = -1,
		color = Color.black
	})

	self._back_drop_gui = MenuBackdropGUI:new(self._ws)
	local panel = self._back_drop_gui:get_new_background_layer()
	local font_size = 120
	local default_offset = 48
	local text = managers.localization:to_upper_text("menu_offshore_account")
	self._title_text = panel:text({
		vertical = "bottom",
		align = "center",
		font = "fonts/font_medium_noshadow_mf",
		visible = true,
		layer = 0,
		text = text,
		y = -self._ws:panel():h() / 2 - default_offset,
		font_size = font_size,
		color = OffshoreGui.TITLE_COLOR
	})
	local font_size = 220
	local money_text = managers.experience:cash_string(managers.money:offshore())
	self._money_text = panel:text({
		vertical = "top",
		align = "center",
		font = "fonts/font_medium_noshadow_mf",
		visible = true,
		layer = 0,
		text = money_text,
		y = self._ws:panel():h() / 2 - default_offset,
		font_size = font_size,
		color = OffshoreGui.MONEY_COLOR
	})

	self._ws:panel():set_visible(self._visible)
end

-- Lines: 54 to 55
function OffshoreGui:_start()
end

-- Lines: 57 to 58
function OffshoreGui:start()
end

-- Lines: 60 to 62
function OffshoreGui:sync_start()
	self:_start()
end

-- Lines: 64 to 70
function OffshoreGui:set_visible(visible)
	self._visible = visible

	if self._ws and self._ws:panel() then
		self._ws:panel():set_visible(visible)
	end

	self:perform_sync()
end

-- Lines: 72 to 75
function OffshoreGui:lock_gui()
	self._ws:set_cull_distance(self._cull_distance)
	self._ws:set_frozen(true)
end

-- Lines: 77 to 83
function OffshoreGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end
end

-- Lines: 85 to 87
function OffshoreGui:update_offshore(cash)
	self._money_text:set_text(managers.experience:cash_string(cash or managers.money:offshore()))
end

-- Lines: 89 to 93
function OffshoreGui:perform_sync()
	if managers.sync and Network:is_server() then
		managers.sync:add_synced_offshore_gui(self._unit:id(), self._visible, managers.money:offshore())
	end
end

