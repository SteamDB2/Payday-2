core:module("CorePlayer")
core:import("CoreAvatar")

Player = Player or class()

-- Lines: 6 to 12
function Player:init(player_slot, player_handler)
	self._player_slot = player_slot
	self._player_handler = player_handler

	assert(self._player_handler)

	self._player_handler._core_player = self
end

-- Lines: 14 to 23
function Player:destroy()
	if self._level_handler then
		self:leave_level(self._level_handler)
	end

	if self._avatar then
		self:_destroy_avatar()
	end

	self._player_handler:destroy()

	self._player_handler = nil
end

-- Lines: 25 to 26
function Player:avatar()
	return self._avatar
end

-- Lines: 29 to 30
function Player:has_avatar()
	return self._avatar ~= nil
end

-- Lines: 33 to 34
function Player:is_alive()
	return self._player_handler ~= nil
end

-- Lines: 37 to 41
function Player:_destroy_avatar()
	self._player_handler:release_avatar()
	self._avatar:destroy()

	self._avatar = nil
end

-- Lines: 43 to 44
function Player:avatar_handler()
	return self._avatar_handler
end

-- Lines: 47 to 57
function Player:enter_level(level_handler)
	self._player_handler:enter_level(level_handler)

	local avatar_handler = self._player_handler:spawn_avatar()
	self._avatar = CoreAvatar.Avatar:new(avatar_handler)
	avatar_handler._core_avatar = self._avatar

	self._player_handler:set_avatar(avatar_handler)

	self._level_handler = level_handler
end

-- Lines: 59 to 65
function Player:leave_level(level_handler)
	if self._avatar then
		self:_destroy_avatar()
	end

	self._player_handler:leave_level(level_handler)

	self._level_handler = nil
end

-- Lines: 67 to 68
function Player:player_slot()
	return self._player_slot
end

-- Lines: 71 to 73
function Player:set_leaderboard_position(position)
	self._leaderboard_position = position
end

-- Lines: 75 to 77
function Player:set_team(team)
	self._team = team
end

