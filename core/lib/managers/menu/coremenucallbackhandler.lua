core:module("CoreMenuCallbackHandler")

CallbackHandler = CallbackHandler or class()

-- Lines: 5 to 13
function CallbackHandler:init()

	-- Lines: 7 to 12
	getmetatable(self).__index = function (t, key)
		local value = rawget(getmetatable(t), key)

		if value then
			return value
		end
	end
end

