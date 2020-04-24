require("lib/input/HandState")

HandStatesPlayerMenu = HandStatesPlayerMenu or {}
local M = HandStatesPlayerMenu
local common = require("lib/input/HandStatesCommon")
M.DefaultHandState = M.DefaultHandState or class(HandState)

-- Lines: 14 to 24
M.DefaultHandState.init = function (self)
	M.DefaultHandState.super.init(self)

	self._connections = {
		toggle_menu = {inputs = {"menu_"}},
		cancel = {inputs = {"grip_"}}
	}
end
M.EmptyHandState = M.EmptyHandState or class(HandState)

-- Lines: 31 to 56
M.EmptyHandState.init = function (self)
	M.EmptyHandState.super.init(self)

	self._connections = {
		toggle_menu = {inputs = {"menu_"}},
		cancel = {inputs = {"grip_"}},
		warp = {inputs = common.warp_inputs},
		warp_target = {inputs = common.warp_target_inputs},
		touchpad_move = {inputs = {"dpad_"}},
		touchpad_secondary = {inputs = {"dpad_"}},
		menu_challenge_claim = {inputs = {"trigger_"}}
	}
end
M.LaserHandState = M.LaserHandState or class(HandState)

-- Lines: 63 to 84
M.LaserHandState.init = function (self)
	M.LaserHandState.super.init(self)

	self._connections = {
		toggle_menu = {inputs = {"menu_"}},
		laser_primary = {inputs = {"trigger_"}},
		laser_secondary = {inputs = {"trackpad_button_"}},
		cancel = {inputs = {"grip_"}},
		touchpad_primary = {inputs = {"dpad_"}}
	}
end
M.CustomizationLaserHandState = M.CustomizationLaserHandState or class(HandState)

-- Lines: 91 to 117
M.CustomizationLaserHandState.init = function (self)
	M.CustomizationLaserHandState.super.init(self)

	self._connections = {
		toggle_menu = {inputs = {"menu_"}},
		laser_primary = {inputs = {"trigger_"}},
		laser_secondary = {inputs = {"trackpad_button_"}},
		interact_right = {
			hand = 1,
			inputs = {"grip_"}
		},
		interact_left = {
			hand = 2,
			inputs = {"grip_"}
		},
		touchpad_primary = {inputs = {"dpad_"}}
	}
end
M.CustomizationEmptyHandState = M.CustomizationEmptyHandState or class(HandState)

-- Lines: 124 to 151
M.CustomizationEmptyHandState.init = function (self)
	M.CustomizationEmptyHandState.super.init(self)

	self._connections = {
		toggle_menu = {inputs = {"menu_"}},
		interact_right = {
			hand = 1,
			inputs = {"grip_"}
		},
		interact_left = {
			hand = 2,
			inputs = {"grip_"}
		},
		warp = {inputs = common.warp_inputs},
		warp_target = {inputs = common.warp_target_inputs},
		touchpad_move = {inputs = {"dpad_"}},
		touchpad_secondary = {inputs = {"dpad_"}}
	}
end

return M
