ConnectionNetworkHandler = ConnectionNetworkHandler or class(BaseNetworkHandler)

-- Lines: 3 to 8
function ConnectionNetworkHandler:server_up(sender)
	if not self._verify_in_session() or Application:editor() then
		return
	end

	managers.network:session():on_server_up_received(sender)
end

-- Lines: 12 to 17
function ConnectionNetworkHandler:request_host_discover_reply(sender)
	if not self._verify_in_server_session() then
		return
	end

	managers.network:on_discover_host_received(sender)
end

-- Lines: 21 to 26
function ConnectionNetworkHandler:discover_host(sender)
	if not self._verify_in_server_session() or Application:editor() then
		return
	end

	managers.network:on_discover_host_received(sender)
end

-- Lines: 30 to 42
function ConnectionNetworkHandler:discover_host_reply(sender_name, level_id, level_name, my_ip, state, difficulty, sender)
	if not self._verify_in_client_session() then
		return
	end

	if level_name == "" then
		level_name = tweak_data.levels:get_world_name_from_index(level_id)

		if not level_name then
			cat_print("multiplayer_base", "[ConnectionNetworkHandler:discover_host_reply] Ignoring host", sender_name, ". I do not have this level in my revision.")

			return
		end
	end

	managers.network:on_discover_host_reply(sender, sender_name, level_name, my_ip, state, difficulty)
end

-- Lines: 46 to 51
function ConnectionNetworkHandler:request_join(peer_name, preferred_character, dlcs, xuid, peer_level, peer_rank, gameversion, join_attempt_identifier, auth_ticket, sender)
	if not self._verify_in_server_session() then
		return
	end

	managers.network:session():on_join_request_received(peer_name, preferred_character, dlcs, xuid, peer_level, peer_rank, gameversion, join_attempt_identifier, auth_ticket, sender)
end

-- Lines: 55 to 62
function ConnectionNetworkHandler:join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, one_down, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	print("[Debug] ConnectionNetworkHandler:join_request_reply - one_down:", one_down)
	print(" 1 ConnectionNetworkHandler:join_request_reply", reply_id, my_peer_id, my_character, level_index, difficulty_index, one_down, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)

	if not self._verify_in_client_session() then
		return
	end

	managers.network:session():on_join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, one_down, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
end

-- Lines: 66 to 73
function ConnectionNetworkHandler:peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
	print(" 1 ConnectionNetworkHandler:peer_handshake", name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)

	if not self._verify_in_client_session() then
		return
	end

	print(" 2 ConnectionNetworkHandler:peer_handshake")
	managers.network:session():peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
end

-- Lines: 75 to 82
function ConnectionNetworkHandler:request_player_name(sender)
	if not self._verify_sender(sender) then
		return
	end

	local name = managers.network:session():local_peer():name()

	sender:request_player_name_reply(name)
end

-- Lines: 84 to 91
function ConnectionNetworkHandler:request_player_name_reply(name, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	sender_peer:set_name(name)
end

-- Lines: 96 to 111
function ConnectionNetworkHandler:peer_exchange_info(peer_id, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	if self._verify_in_client_session() then
		if sender_peer:id() == 1 then
			managers.network:session():on_peer_requested_info(peer_id)
		elseif peer_id == sender_peer:id() then
			managers.network:session():send_to_host("peer_exchange_info", peer_id)
		end
	elseif self._verify_in_server_session() then
		managers.network:session():on_peer_connection_established(sender_peer, peer_id)
	end
end

-- Lines: 115 to 124
function ConnectionNetworkHandler:connection_established(peer_id, sender)
	if not self._verify_in_server_session() then
		return
	end

	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.network:session():on_peer_connection_established(sender_peer, peer_id)
end

-- Lines: 128 to 135
function ConnectionNetworkHandler:mutual_connection(other_peer_id)
	print("[ConnectionNetworkHandler:mutual_connection]", other_peer_id)

	if not self._verify_in_client_session() then
		return
	end

	managers.network:session():on_mutual_connection(other_peer_id)
end

-- Lines: 139 to 153
function ConnectionNetworkHandler:kick_peer(peer_id, message_id, sender)
	if not self._verify_sender(sender) then
		return
	end

	sender:remove_peer_confirmation(peer_id)

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		print("[ConnectionNetworkHandler:kick_peer] unknown peer", peer_id)

		return
	end

	managers.network:session():on_peer_kicked(peer, peer_id, message_id)
end

-- Lines: 158 to 165
function ConnectionNetworkHandler:remove_peer_confirmation(removed_peer_id, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.network:session():on_remove_peer_confirmation(sender_peer, removed_peer_id)
end

-- Lines: 169 to 176
function ConnectionNetworkHandler:set_loading_state(state, load_counter, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.network:session():set_peer_loading_state(peer, state, load_counter)
end

-- Lines: 180 to 185
function ConnectionNetworkHandler:set_peer_synched(id, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.network:session():on_peer_synched(id)
end

-- Lines: 189 to 195
function ConnectionNetworkHandler:set_dropin()
	if game_state_machine:current_state().set_dropin then
		game_state_machine:current_state():set_dropin(managers.network:session():local_peer():character())
	end

	Global.statistics_manager.playing_from_start = nil

	managers.network:dispatch_event("on_set_dropin")
end

-- Lines: 200 to 207
function ConnectionNetworkHandler:set_waiting(...)
	print("ConnectionNetworkHandler:set_waiting", ...)

	if not self._verify_gamestate(self._gamestate_filter.waiting_for_players) then
		return
	end

	game_state_machine:change_state_by_name("ingame_waiting_for_spawn_allowed")
end

-- Lines: 211 to 222
function ConnectionNetworkHandler:kick_to_briefing(...)
	print("ConnectionNetworkHandler:kick_to_briefing", ...)

	if not self._verify_gamestate(self._gamestate_filter.waiting_for_spawn_allowed) then
		return
	end

	managers.network:session():local_peer():set_waiting_for_player_ready(false)
	managers.network:session():chk_send_local_player_ready()
	managers.network:session():on_set_member_ready(managers.network:session():local_peer():id(), false, true, false)
	game_state_machine:change_state_by_name("ingame_waiting_for_players", {sync_data = true})
end

-- Lines: 226 to 236
function ConnectionNetworkHandler:spawn_dropin_penalty(dead, bleed_out, health, used_deployable, used_cable_ties, used_body_bags)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	managers.player:spawn_dropin_penalty(dead, bleed_out, health, used_deployable, used_cable_ties, used_body_bags)

	if not managers.groupai:state():whisper_mode() and (game_state_machine:last_queued_state_name() == "ingame_mask_off" or game_state_machine:last_queued_state_name() == "ingame_civilian") then
		managers.player:set_player_state("standard")
	end
end

-- Lines: 240 to 246
function ConnectionNetworkHandler:ok_to_load_level(load_counter, sender)
	print("[ConnectionNetworkHandler:ok_to_load_level]", load_counter)

	if not self:_verify_in_client_session() then
		return
	end

	managers.network:session():ok_to_load_level(load_counter)
end

-- Lines: 248 to 254
function ConnectionNetworkHandler:ok_to_load_lobby(load_counter, sender)
	print("[ConnectionNetworkHandler:ok_to_load_lobby]", load_counter)

	if not self:_verify_in_client_session() then
		return
	end

	managers.network:session():ok_to_load_lobby(load_counter)
end

-- Lines: 256 to 262
function ConnectionNetworkHandler:set_peer_left(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.network:session():on_peer_left(peer, peer:id())
end

-- Lines: 264 to 273
function ConnectionNetworkHandler:set_menu_sync_state_index(index, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if managers.menu then
		managers.menu:set_peer_sync_state_index(peer:id(), index)
	end
end

-- Lines: 275 to 288
function ConnectionNetworkHandler:enter_ingame_lobby_menu(load_counter, sender)
	if not self._verify_sender(sender) then
		return
	end

	if load_counter ~= managers.network:session():load_counter() then
		return
	end

	if managers.menu_component then
		managers.menu_component:close_stage_endscreen_gui()
	end

	game_state_machine:change_state_by_name("ingame_lobby_menu")
end

-- Lines: 290 to 292
function ConnectionNetworkHandler:entered_lobby_confirmation(peer_id)
	managers.network:session():on_entered_lobby_confirmation(peer_id)
end

-- Lines: 294 to 305
function ConnectionNetworkHandler:set_peer_entered_lobby(sender)
	if not self._verify_in_session() then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.network:session():on_peer_entered_lobby(peer)
end

-- Lines: 308 to 337
function ConnectionNetworkHandler:sync_game_settings(job_index, level_id_index, difficulty_index, one_down, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local job_id = tweak_data.narrative:get_job_name_from_index(job_index)
	local level_id = tweak_data.levels:get_level_name_from_index(level_id_index)
	local difficulty = tweak_data:index_to_difficulty(difficulty_index)

	managers.job:activate_job(job_id)

	Global.game_settings.level_id = level_id
	Global.game_settings.mission = managers.job:current_mission()
	Global.game_settings.world_setting = managers.job:current_world_setting()
	Global.game_settings.difficulty = difficulty
	Global.game_settings.one_down = one_down

	if managers.platform then
		managers.platform:update_discord_heist()
	end

	peer:verify_job(job_id)

	if managers.menu_component then
		managers.menu_component:on_job_updated()
	end
end

-- Lines: 370 to 398
function ConnectionNetworkHandler:sync_stage_settings(level_id_index, stage_num, alternative_stage, interupt_stage_level_id, sender)
	print("ConnectionNetworkHandler:sync_stage_settings", level_id_index, stage_num, alternative_stage, interupt_stage_level_id)

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local level_id = tweak_data.levels:get_level_name_from_index(level_id_index)
	Global.game_settings.level_id = level_id

	managers.job:set_current_stage(stage_num)

	if alternative_stage ~= 0 then
		managers.job:synced_alternative_stage(alternative_stage)
	else
		managers.job:synced_alternative_stage(nil)
	end

	if interupt_stage_level_id ~= 0 then
		local interupt_level = tweak_data.levels:get_level_name_from_index(interupt_stage_level_id)

		managers.job:synced_interupt_stage(interupt_level, true)
	else
		managers.job:synced_interupt_stage(nil, true)
	end

	Global.game_settings.mission = managers.job:current_mission()
	Global.game_settings.world_setting = managers.job:current_world_setting()
end

-- Lines: 400 to 407
function ConnectionNetworkHandler:sync_on_retry_job_stage(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.job:synced_on_retry_job_stage()
end

-- Lines: 412 to 425
function ConnectionNetworkHandler:lobby_sync_update_level_id(level_id_index)
	local level_id = tweak_data.levels:get_level_name_from_index(level_id_index)
	local lobby_menu = managers.menu:get_menu("lobby_menu")

	if lobby_menu and lobby_menu.renderer:is_open() then
		lobby_menu.renderer:sync_update_level_id(level_id)
	end

	local kit_menu = managers.menu:get_menu("kit_menu")

	if kit_menu and kit_menu.renderer:is_open() then
		kit_menu.renderer:sync_update_level_id(level_id)
	end
end

-- Lines: 433 to 442
function ConnectionNetworkHandler:lobby_sync_update_difficulty(difficulty)
	local lobby_menu = managers.menu:get_menu("lobby_menu")

	if lobby_menu and lobby_menu.renderer:is_open() then
		lobby_menu.renderer:sync_update_difficulty(difficulty)
	end

	local kit_menu = managers.menu:get_menu("kit_menu")

	if kit_menu and kit_menu.renderer:is_open() then
		kit_menu.renderer:sync_update_difficulty(difficulty)
	end
end

-- Lines: 447 to 468
function ConnectionNetworkHandler:lobby_info(level, rank, character, mask_set, sender)
	local peer = self._verify_sender(sender)

	print("ConnectionNetworkHandler:lobby_info", peer and peer:id(), level, rank)
	print("  IS THIS AN OK PEER?", peer and peer:id())

	if peer then
		peer:set_level(level)
		peer:set_rank(rank)

		local lobby_menu = managers.menu:get_menu("lobby_menu")

		if lobby_menu and lobby_menu.renderer:is_open() then
			lobby_menu.renderer:_set_player_slot(peer:id(), {
				name = peer:name(),
				peer_id = peer:id(),
				level = level,
				rank = rank,
				character = character
			})
		end

		local kit_menu = managers.menu:get_menu("kit_menu")

		if kit_menu and kit_menu.renderer:is_open() then
			kit_menu.renderer:_set_player_slot(peer:id(), {
				name = peer:name(),
				peer_id = peer:id(),
				level = level,
				rank = rank,
				character = character
			})
		end
	end
end

-- Lines: 472 to 477
function ConnectionNetworkHandler:begin_trade()
	if not self._verify_gamestate(self._gamestate_filter.waiting_for_respawn) then
		return
	end

	game_state_machine:current_state():begin_trade()
end

-- Lines: 480 to 485
function ConnectionNetworkHandler:cancel_trade()
	if not self._verify_gamestate(self._gamestate_filter.waiting_for_respawn) then
		return
	end

	game_state_machine:current_state():cancel_trade()
end

-- Lines: 488 to 493
function ConnectionNetworkHandler:finish_trade()
	if not self._verify_gamestate(self._gamestate_filter.waiting_for_respawn) then
		return
	end

	game_state_machine:current_state():finish_trade()
end

-- Lines: 495 to 506
function ConnectionNetworkHandler:request_spawn_member(sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	IngameWaitingForRespawnState.request_player_spawn(peer:id())
end

-- Lines: 508 to 513
function ConnectionNetworkHandler:hostage_trade_dialog(i)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.trade:sync_hostage_trade_dialog(i)
end

-- Lines: 515 to 520
function ConnectionNetworkHandler:warn_about_civilian_free(i)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_warn_about_civilian_free(i)
end

-- Lines: 522 to 524
function ConnectionNetworkHandler:request_drop_in_pause(peer_id, nickname, state, sender)
	managers.network:session():on_drop_in_pause_request_received(peer_id, nickname, state)
end

-- Lines: 526 to 532
function ConnectionNetworkHandler:drop_in_pause_confirmation(dropin_peer_id, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.network:session():on_drop_in_pause_confirmation_received(dropin_peer_id, sender_peer)
end

-- Lines: 536 to 543
function ConnectionNetworkHandler:report_dead_connection(other_peer_id, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.network:session():on_dead_connection_reported(sender_peer:id(), other_peer_id)
end

-- Lines: 547 to 558
function ConnectionNetworkHandler:sanity_check_network_status(sender)
	if not self._verify_in_server_session() then
		sender:sanity_check_network_status_reply()

		return
	end

	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		sender:sanity_check_network_status_reply()

		return
	end
end

-- Lines: 562 to 581
function ConnectionNetworkHandler:sanity_check_network_status_reply(sender)
	if not self._verify_in_client_session() then
		return
	end

	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local session = managers.network:session()

	if sender_peer ~= session:server_peer() then
		return
	end

	if session:is_expecting_sanity_chk_reply() then
		print("[ConnectionNetworkHandler:sanity_check_network_status_reply]")
		managers.network:session():on_peer_lost(sender_peer, sender_peer:id())
	end
end

-- Lines: 585 to 597
function ConnectionNetworkHandler:dropin_progress(dropin_peer_id, progress_percentage, sender)
	if not self._verify_in_client_session() or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local session = managers.network:session()
	local dropin_peer = session:peer(dropin_peer_id)

	if not dropin_peer or dropin_peer_id == session:local_peer():id() then
		return
	end

	session:on_dropin_progress_received(dropin_peer_id, progress_percentage)
end

-- Lines: 601 to 646
function ConnectionNetworkHandler:set_member_ready(peer_id, ready, mode, outfit_versions_str, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return
	end

	if mode == 1 then
		ready = ready ~= 0 and true or false
		local ready_state = peer:waiting_for_player_ready()

		peer:set_waiting_for_player_ready(ready)
		managers.network:session():on_set_member_ready(peer_id, ready, ready_state ~= ready, true)

		if Network:is_server() then
			managers.network:session():send_to_peers_loaded_except(peer_id, "set_member_ready", peer_id, ready and 1 or 0, 1, "")

			if game_state_machine:current_state().start_game_intro then
				-- Nothing
			elseif ready then
				managers.network:session():chk_spawn_member_unit(peer, peer_id)
			end
		end
	elseif mode == 2 then
		peer:set_streaming_status(ready)
		managers.network:session():on_streaming_progress_received(peer, ready)
	elseif mode == 3 then
		if Network:is_server() then
			managers.network:session():on_peer_finished_loading_outfit(peer, ready, outfit_versions_str)
		end
	elseif mode == 4 and Network:is_client() and peer == managers.network:session():server_peer() then
		managers.network:session():notify_host_when_outfits_loaded(ready, outfit_versions_str)
	end
end

-- Lines: 650 to 657
function ConnectionNetworkHandler:send_chat_message(channel_id, message, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	print("send_chat_message peer", peer, peer:id())
	managers.chat:receive_message_by_peer(channel_id, peer, message)
end

-- Lines: 659 to 684
function ConnectionNetworkHandler:sync_outfit(outfit_string, outfit_version, outfit_signature, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	print("[ConnectionNetworkHandler:sync_outfit]", "peer_id", peer:id(), "outfit_string", outfit_string, "outfit_version", outfit_version)

	outfit_string, outfit_version, outfit_signature = peer:set_outfit_string(outfit_string, outfit_version, outfit_signature)

	if managers.network:session():is_host() then
		managers.network:session():chk_request_peer_outfit_load_status()
	end

	local local_peer = managers.network:session() and managers.network:session():local_peer()
	local in_lobby = local_peer and local_peer:in_lobby() and game_state_machine:current_state_name() ~= "ingame_lobby_menu" and not setup:is_unloading()

	if managers.menu_scene and in_lobby then
		managers.menu_scene:set_lobby_character_out_fit(peer:id(), outfit_string, peer:rank())
	end

	local kit_menu = managers.menu:get_menu("kit_menu")

	if kit_menu then
		kit_menu.renderer:set_slot_outfit(peer:id(), peer:character(), outfit_string)
	end

	if managers.menu_component then
		managers.menu_component:peer_outfit_updated(peer:id())
	end
end

-- Lines: 686 to 693
function ConnectionNetworkHandler:sync_profile(level, rank, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	peer:set_profile(level, rank)
end

-- Lines: 697 to 706
function ConnectionNetworkHandler:steam_p2p_ping(sender)
	print("[ConnectionNetworkHandler:steam_p2p_ping] from", sender:ip_at_index(0), sender:protocol_at_index(0))

	local session = managers.network:session()

	if not session or session:closing() then
		print("[ConnectionNetworkHandler:steam_p2p_ping] no session or closing")

		return
	end

	session:on_steam_p2p_ping(sender)
end

-- Lines: 710 to 722
function ConnectionNetworkHandler:re_open_lobby_request(state, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		sender:re_open_lobby_reply(false)

		return
	end

	local session = managers.network:session()

	if session:closing() then
		sender:re_open_lobby_reply(false)

		return
	end

	session:on_re_open_lobby_request(peer, state)
end

-- Lines: 726 to 736
function ConnectionNetworkHandler:re_open_lobby_reply(status, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local session = managers.network:session()

	if session:closing() then
		return
	end

	managers.network.matchmake:from_host_lobby_re_opened(status)
end

-- Lines: 741 to 758
function ConnectionNetworkHandler:feed_lootdrop(global_value, item_category, item_id, max_pc, item_pc, left_pc, right_pc, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if not managers.hud then
		return
	end

	local global_values = tweak_data.lootdrop.global_value_list_index
	local lootdrop_data = {
		peer,
		global_values[global_value] or "normal",
		item_category,
		item_id,
		max_pc,
		item_pc,
		left_pc,
		right_pc
	}

	if item_pc == 0 then
		managers.hud:make_cards_hud(peer, max_pc, left_pc, right_pc)
	else
		managers.hud:make_lootdrop_hud(lootdrop_data)
	end
end

-- Lines: 760 to 769
function ConnectionNetworkHandler:set_selected_lootcard(selected, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if managers.hud then
		managers.hud:set_selected_lootcard(peer:id(), selected)
	end
end

-- Lines: 771 to 780
function ConnectionNetworkHandler:choose_lootcard(card_id, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if managers.hud then
		managers.hud:confirm_choose_lootcard(peer:id(), card_id)
	end
end

-- Lines: 816 to 837
function ConnectionNetworkHandler:sync_explode_bullet(position, normal, damage, peer_id_or_selection_index, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	if InstantExplosiveBulletBase then
		local user_unit = managers.criminals and managers.criminals:character_unit_by_peer_id(peer:id())

		if alive(user_unit) then
			local weapon_unit = user_unit:inventory():unit_by_selection(peer_id_or_selection_index)

			if alive(weapon_unit) then
				InstantExplosiveBulletBase:on_collision_server(position, normal, damage / 163.84, user_unit, weapon_unit, peer:id(), peer_id_or_selection_index)
				InstantExplosiveBulletBase:on_collision_client(position, normal, damage / 163.84, managers.criminals and managers.criminals:character_unit_by_peer_id(peer_id_or_selection_index))
			end
		end
	end
end

-- Lines: 839 to 860
function ConnectionNetworkHandler:sync_flame_bullet(position, normal, damage, peer_id_or_selection_index, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	if FlameBulletBase then
		if Network:is_server() then
			local user_unit = managers.criminals and managers.criminals:character_unit_by_peer_id(peer:id())

			if alive(user_unit) then
				local weapon_unit = user_unit:inventory():unit_by_selection(peer_id_or_selection_index)

				if alive(weapon_unit) then
					FlameBulletBase:on_collision_server(position, normal, damage / 163.84, user_unit, weapon_unit, peer:id(), peer_id_or_selection_index)
				end
			end
		else
			FlameBulletBase:on_collision_client(position, normal, damage / 163.84, managers.criminals and managers.criminals:character_unit_by_peer_id(peer_id_or_selection_index))
		end
	end
end

-- Lines: 862 to 894
function ConnectionNetworkHandler:sync_explosion_results(count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills, selection_index, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local player = managers.player:local_player()
	local weapon_unit = alive(player) and player:inventory():unit_by_selection(selection_index)

	if alive(weapon_unit) then
		local enemies_hit = (count_gangsters or 0) + (count_cops or 0)
		local enemies_killed = (count_gangster_kills or 0) + (count_cop_kills or 0)

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weapon_unit
		})

		for i = 1, enemies_hit, 1 do
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = weapon_unit
			})
		end

		local weapon_pass, weapon_type_pass, count_pass, all_pass = nil

		for achievement, achievement_data in pairs(tweak_data.achievement.explosion_achievements) do
			weapon_pass = not achievement_data.weapon or true
			weapon_type_pass = not achievement_data.weapon_type or weapon_unit:base() and weapon_unit:base().weapon_tweak_data and weapon_unit:base():is_category(achievement_data.weapon_type)
			count_pass = not achievement_data.count or achievement_data.count <= (achievement_data.kill and enemies_killed or enemies_hit)
			all_pass = weapon_pass and weapon_type_pass and count_pass

			if all_pass and achievement_data.award then
				managers.achievment:award(achievement_data.award)
			end
		end
	end
end

-- Lines: 896 to 916
function ConnectionNetworkHandler:sync_fire_results(count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills, selection_index, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local player = managers.player:local_player()
	local weapon_unit = alive(player) and player:inventory():unit_by_selection(selection_index)

	if alive(weapon_unit) then
		local enemies_hit = (count_gangsters or 0) + (count_cops or 0)
		local enemies_killed = (count_gangster_kills or 0) + (count_cop_kills or 0)

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weapon_unit
		})

		for i = 1, enemies_hit, 1 do
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = weapon_unit
			})
		end

		local weapon_pass, weapon_type_pass, count_pass, all_pass = nil
	end
end

-- Lines: 920 to 932
function ConnectionNetworkHandler:preplanning_reserved(type, id, peer_id, state, sender)
	if not self._verify_sender(sender) then
		return
	end

	if state == 0 then
		managers.preplanning:client_reserve_mission_element(type, id, peer_id)
	elseif state == 1 then
		managers.preplanning:client_unreserve_mission_element(id, peer_id)
	elseif state == 2 then
		managers.preplanning:client_vote_on_plan(type, id, peer_id)
	end
end

-- Lines: 934 to 946
function ConnectionNetworkHandler:reserve_preplanning(type, id, state, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if state == 0 then
		managers.preplanning:server_reserve_mission_element(type, id, peer:id())
	elseif state == 1 then
		managers.preplanning:server_unreserve_mission_element(id, peer:id())
	elseif state == 2 then
		managers.preplanning:server_vote_on_plan(type, id, peer:id())
	end
end

-- Lines: 948 to 954
function ConnectionNetworkHandler:draw_preplanning_point(x, y, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.menu_component:sync_preplanning_draw_point(peer:id(), x, y)
end

-- Lines: 956 to 962
function ConnectionNetworkHandler:draw_preplanning_event(event_id, var1, var2, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.menu_component:sync_preplanning_draw_event(peer:id(), event_id, var1, var2)
end

-- Lines: 966 to 973
function ConnectionNetworkHandler:voting_data(type, value, result, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.vote:network_package(type, value, result, peer:id())
end

-- Lines: 977 to 985
function ConnectionNetworkHandler:sync_award_achievement(achievement_id, sender)
	if not self._verify_sender(sender) then
		return
	end

	print("ConnectionNetworkHandler:sync_award_achievement():", achievement_id)
end

-- Lines: 989 to 996
function ConnectionNetworkHandler:propagate_alert(type, position, range, filter, aggressor, head_position, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.groupai:state():propagate_alert({
		type,
		position,
		range,
		filter,
		aggressor,
		head_position
	})
end

-- Lines: 1000 to 1005
function ConnectionNetworkHandler:set_auto_assault_ai_trade(character_name, time)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.trade:sync_set_auto_assault_ai_trade(character_name, time)
end

-- Lines: 1010 to 1012
function ConnectionNetworkHandler:auto_init_respawn_player(pos, peer_id)
	managers.player:init_auto_respawn_callback(pos, peer_id)
end

-- Lines: 1017 to 1019
function ConnectionNetworkHandler:auto_respawn_player(pos, peer_id)
	managers.player:clbk_super_syndrome_respawn({
		pos = pos,
		peer_id = peer_id
	})
end

-- Lines: 1024 to 1028
function ConnectionNetworkHandler:start_super_syndrome_trade(pos, peer_id)
	if not managers.player._coroutine_mgr:is_running("stockholm_syndrome_trade") then
		managers.player._coroutine_mgr:add_coroutine("stockholm_syndrome_trade", PlayerAction.StockholmSyndromeTrade, pos, peer_id)
	end
end

-- Lines: 1033 to 1043
function ConnectionNetworkHandler:request_stockholm_syndrome(pos, peer_id, auto_activate)
	local peer = managers.network:session():peer(peer_id)
	local allowed, feedback_idx = StockholmSyndromeTradeAction.is_allowed()

	if auto_activate then
		feedback_idx = 0
	end

	if allowed then
		managers.player:init_auto_respawn_callback(pos, peer_id, true)
		managers.network:session():send_to_peer(peer, "stockholm_syndrome_results", true, feedback_idx)
	else
		managers.network:session():send_to_peer(peer, "stockholm_syndrome_results", false, feedback_idx)
	end
end

-- Lines: 1047 to 1049
function ConnectionNetworkHandler:stockholm_syndrome_results(can_trade, feedback_idx)
	managers.player:send_message(Message.CanTradeHostage, nil, can_trade, feedback_idx)
end

-- Lines: 1054 to 1056
function ConnectionNetworkHandler:sync_set_super_syndrome(peer_id, active)
	managers.groupai:state():set_super_syndrome(peer_id, active)
end

-- Lines: 1060 to 1062
function ConnectionNetworkHandler:peer_joined_sound(infamous)
	managers.menu:post_event(infamous and "infamous_player_join_stinger" or "player_join")
end

-- Lines: 1066 to 1068
function ConnectionNetworkHandler:client_used_weapon(weapon_id)
	managers.statistics:used_weapon(weapon_id)
end

-- Lines: 1070 to 1072
function ConnectionNetworkHandler:sync_used_weapon(weapon_id)
	managers.statistics:_used_weapon(weapon_id)
end

-- Lines: 1079 to 1081
function ConnectionNetworkHandler:sync_mutators_launch(countdown, sender)
	managers.mutators:show_mutators_launch_countdown(countdown)
end

-- Lines: 1084 to 1090
function ConnectionNetworkHandler:sync_mutators_launch_ready(peer_id, is_ready, sender)
	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return
	end

	managers.mutators:set_peer_is_ready(peer_id, is_ready)
end

-- Lines: 1092 to 1098
function ConnectionNetworkHandler:sync_mutator_hydra_split(position, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	MutatorHydra.play_split_particle(position, Rotation())
end

-- Lines: 1103 to 1109
function ConnectionNetworkHandler:sync_synced_unit_outfit(unit_id, outfit_type, outfit_string, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.sync:on_received_synced_outfit(unit_id, outfit_type, outfit_string)
end

-- Lines: 1111 to 1115
function ConnectionNetworkHandler:sync_safehouse_room_tier(room_name, room_tier)
	if managers.custom_safehouse then
		managers.custom_safehouse:set_host_room_tier(room_name, room_tier)
	end
end

-- Lines: 1122 to 1128
function ConnectionNetworkHandler:sync_crime_spree_level(peer_id, spree_level, has_failed, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.crime_spree:set_peer_spree_level(peer_id, spree_level, has_failed)
end

-- Lines: 1131 to 1137
function ConnectionNetworkHandler:sync_crime_spree_mission(mission_slot, mission_id, selected, perform_randomize, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.crime_spree:set_server_mission(mission_slot, mission_id, selected, perform_randomize)
end

-- Lines: 1140 to 1146
function ConnectionNetworkHandler:sync_crime_spree_modifier(modifier_id, modifier_level, announce, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.crime_spree:set_server_modifier(modifier_id, modifier_level, announce)
end

-- Lines: 1149 to 1155
function ConnectionNetworkHandler:sync_crime_spree_modifiers_finalize(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.crime_spree:on_finalize_modifiers()
end

-- Lines: 1158 to 1164
function ConnectionNetworkHandler:sync_crime_spree_gage_asset_event(event_id, asset_id, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.crime_spree:on_gage_asset_event(event_id, asset_id, peer)
end

-- Lines: 1171 to 1178
function ConnectionNetworkHandler:sync_player_installed_mod(peer_id, mod_id, mod_friendly_name, sender)
	print("[ConnectionNetworkHandler] sync_player_installed_mod", peer_id, mod_id, mod_friendly_name)

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	peer:register_mod(mod_id, mod_friendly_name)
end

-- Lines: 1184 to 1190
function ConnectionNetworkHandler:sync_phalanx_vip_achievement_unlocked(achievement_id, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.achievment:award_enemy_kill_achievement(achievement_id)
end

-- Lines: 1196 to 1202
function ConnectionNetworkHandler:sync_is_vr(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	peer:set_is_vr()
end

-- Lines: 1239 to 1246
function ConnectionNetworkHandler:get_virus_achievement(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.achievment:award("cac_28")
end

-- Lines: 1252 to 1263
function ConnectionNetworkHandler:sync_end_assault_skirmish(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	managers.skirmish:on_end_assault()
end

