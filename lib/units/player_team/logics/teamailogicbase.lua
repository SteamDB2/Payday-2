require("lib/units/enemies/cop/logics/CopLogicBase")

TeamAILogicBase = TeamAILogicBase or class(CopLogicBase)

-- Lines: 5 to 6
function TeamAILogicBase.on_long_dis_interacted(data, other_unit, secondary)
end

-- Lines: 10 to 11
function TeamAILogicBase.on_cop_neutralized(data, cop_key)
end

-- Lines: 15 to 16
function TeamAILogicBase.on_recovered(data, reviving_unit)
end

-- Lines: 20 to 21
function TeamAILogicBase.clbk_heat(data)
end

-- Lines: 25 to 29
function TeamAILogicBase.on_objective_unit_destroyed(data, unit)
	data.objective.destroy_clbk_key = nil
	data.objective.death_clbk_key = nil

	data.objective_failed_clbk(data.unit, data.objective)
end

-- Lines: 33 to 39
function TeamAILogicBase._get_logic_state_from_reaction(data, reaction)
	if not reaction or reaction <= AIAttentionObject.REACT_SCARED then
		return "idle"
	else
		return "assault"
	end
end

-- Lines: 43 to 61
function TeamAILogicBase.actually_revive(data, revive_unit, show_hint_locally)
	if revive_unit:interaction() then
		if revive_unit:interaction():active() then
			revive_unit:interaction():interact(data.unit)
		end
	elseif revive_unit:character_damage() and (revive_unit:character_damage():need_revive() or revive_unit:character_damage():arrested()) then
		local hint = revive_unit:character_damage():need_revive() and 2 or 3

		managers.network:session():send_to_peers_synched("sync_teammate_helped_hint", hint, revive_unit, data.unit)
		revive_unit:character_damage():revive(data.unit)

		if show_hint_locally then
			managers.trade:sync_teammate_helped_hint(revive_unit, data.unit, hint)
		end
	end
end

-- Lines: 65 to 88
function TeamAILogicBase._set_attention_obj(data, new_att_obj, new_reaction)
	local old_att_obj = data.attention_obj
	data.attention_obj = new_att_obj

	if new_att_obj then
		new_att_obj.reaction = new_reaction or new_att_obj.settings.reaction
	end

	if old_att_obj and new_att_obj and old_att_obj.u_key == new_att_obj.u_key then
		if new_att_obj.stare_expire_t and new_att_obj.stare_expire_t < data.t then
			if new_att_obj.settings.pause then
				new_att_obj.stare_expire_t = nil
				new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())

				print("[TeamAILogicBase._chk_focus_on_attention_object] pausing for", current_attention.pause_expire_t - data.t, "sec")
			end
		elseif new_att_obj.pause_expire_t and new_att_obj.pause_expire_t < data.t then
			new_att_obj.pause_expire_t = nil
			new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
		end
	elseif new_att_obj and new_att_obj.settings.duration then
		new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
		new_att_obj.pause_expire_t = nil
	end
end

-- Lines: 92 to 93
function TeamAILogicBase._chk_nearly_visible_chk_needed(data, attention_info, u_key)
	return not data.attention_obj or data.attention_obj.key == u_key
end

-- Lines: 98 to 112
function TeamAILogicBase._chk_reaction_to_attention_object(data, attention_data, stationary)
	local att_unit = attention_data.unit

	if not attention_data.is_person or att_unit:character_damage() and att_unit:character_damage():dead() then
		return attention_data.settings.reaction
	end

	if data.cool then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_SURPRISED)
	elseif stationary then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_SHOOT)
	else
		return attention_data.settings.reaction
	end
end

