GamemodeStandard = GamemodeStandard or class(Gamemode)
GamemodeStandard.id = "standard"
GamemodeStandard._NAME = "Heist Gamemode"

Gamemode.register(GamemodeStandard.id, GamemodeStandard)

-- Lines: 8 to 441
function GamemodeStandard:setup_gsm(gsm, empty, setup_boot, setup_title)
	local editor = EditorState:new(gsm)
	local world_camera = WorldCameraState:new(gsm)
	local bootup = BootupState:new(gsm, setup_boot)
	local menu_titlescreen = MenuTitlescreenState:new(gsm, setup_title)
	local menu_main = MenuMainState:new(gsm)
	local ingame_standard = IngameStandardState:new(gsm)
	local ingame_mask_off = IngameMaskOffState:new(gsm)
	local ingame_bleed_out = IngameBleedOutState:new(gsm)
	local ingame_fatal = IngameFatalState:new(gsm)
	local ingame_arrested = IngameArrestedState:new(gsm)
	local ingame_electrified = IngameElectrifiedState:new(gsm)
	local ingame_incapacitated = IngameIncapacitatedState:new(gsm)
	local ingame_waiting_for_players = IngameWaitingForPlayersState:new(gsm)
	local ingame_waiting_for_respawn = IngameWaitingForRespawnState:new(gsm)
	local ingame_waiting_for_spawn_allowed = IngameWaitingForSpawnAllowed:new(gsm)
	local ingame_clean = IngameCleanState:new(gsm)
	local ingame_civilian = IngameCivilianState:new(gsm)
	local ingame_access_camera = IngameAccessCamera:new(gsm)
	local ingame_driving = IngameDriving:new(gsm)
	local ingame_parachuting = IngameParachuting:new(gsm)
	local ingame_freefall = IngameFreefall:new(gsm)
	local ingame_lobby = IngameLobbyMenuState:new(gsm)
	local gameoverscreen = GameOverState:new(gsm)
	local server_left = ServerLeftState:new(gsm)
	local disconnected = DisconnectedState:new(gsm)
	local kicked = KickedState:new(gsm)
	local victoryscreen = VictoryState:new(gsm)
	local empty_func = callback(nil, empty, "default_transition")
	local editor_func = callback(nil, editor, "default_transition")
	local world_camera_func = callback(nil, world_camera, "default_transition")
	local bootup_func = callback(nil, bootup, "default_transition")
	local menu_titlescreen_func = callback(nil, menu_titlescreen, "default_transition")
	local menu_main_func = callback(nil, menu_main, "default_transition")
	local ingame_standard_func = callback(nil, ingame_standard, "default_transition")
	local ingame_mask_off_func = callback(nil, ingame_mask_off, "default_transition")
	local ingame_bleed_out_func = callback(nil, ingame_bleed_out, "default_transition")
	local ingame_arrested_func = callback(nil, ingame_arrested, "default_transition")
	local ingame_fatal_func = callback(nil, ingame_fatal, "default_transition")
	local ingame_electrified_func = callback(nil, ingame_electrified, "default_transition")
	local ingame_incapacitated_func = callback(nil, ingame_incapacitated, "default_transition")
	local ingame_waiting_for_players_func = callback(nil, ingame_waiting_for_players, "default_transition")
	local ingame_waiting_for_respawn_func = callback(nil, ingame_waiting_for_respawn, "default_transition")
	local ingame_waiting_for_spawn_allowed_func = callback(nil, ingame_waiting_for_spawn_allowed, "default_transition")
	local ingame_clean_func = callback(nil, ingame_clean, "default_transition")
	local ingame_civilian_func = callback(nil, ingame_civilian, "default_transition")
	local ingame_access_camera_func = callback(nil, ingame_access_camera, "default_transition")
	local ingame_driving_func = callback(nil, ingame_driving, "default_transition")
	local ingame_parachuting_func = callback(nil, ingame_parachuting, "default_transition")
	local ingame_freefall_func = callback(nil, ingame_freefall, "default_transition")
	local ingame_lobby_func = callback(nil, ingame_lobby, "default_transition")
	local gameoverscreen_func = callback(nil, gameoverscreen, "default_transition")
	local server_left_func = callback(nil, server_left, "default_transition")
	local disconnected_func = callback(nil, disconnected, "default_transition")
	local kicked_func = callback(nil, disconnected, "default_transition")
	local victoryscreen_func = callback(nil, victoryscreen, "default_transition")

	gsm:add_transition(editor, empty, editor_func)
	gsm:add_transition(editor, world_camera, editor_func)
	gsm:add_transition(editor, editor, editor_func)
	gsm:add_transition(editor, ingame_standard, editor_func)
	gsm:add_transition(editor, ingame_mask_off, editor_func)
	gsm:add_transition(editor, ingame_bleed_out, editor_func)
	gsm:add_transition(editor, ingame_fatal, editor_func)
	gsm:add_transition(editor, victoryscreen, editor_func)
	gsm:add_transition(editor, ingame_clean, editor_func)
	gsm:add_transition(editor, ingame_civilian, editor_func)
	gsm:add_transition(editor, ingame_parachuting, editor_func)
	gsm:add_transition(editor, ingame_freefall, editor_func)
	gsm:add_transition(world_camera, editor, world_camera_func)
	gsm:add_transition(world_camera, empty, world_camera_func)
	gsm:add_transition(world_camera, world_camera, world_camera_func)
	gsm:add_transition(world_camera, ingame_standard, world_camera_func)
	gsm:add_transition(world_camera, ingame_mask_off, world_camera_func)
	gsm:add_transition(world_camera, ingame_bleed_out, world_camera_func)
	gsm:add_transition(world_camera, ingame_fatal, world_camera_func)
	gsm:add_transition(world_camera, ingame_arrested, world_camera_func)
	gsm:add_transition(world_camera, ingame_electrified, world_camera_func)
	gsm:add_transition(world_camera, ingame_incapacitated, world_camera_func)
	gsm:add_transition(world_camera, ingame_waiting_for_players, world_camera_func)
	gsm:add_transition(world_camera, ingame_waiting_for_respawn, world_camera_func)
	gsm:add_transition(world_camera, ingame_parachuting, world_camera_func)
	gsm:add_transition(world_camera, ingame_freefall, world_camera_func)
	gsm:add_transition(world_camera, ingame_clean, world_camera_func)
	gsm:add_transition(world_camera, ingame_civilian, world_camera_func)
	gsm:add_transition(world_camera, server_left, world_camera_func)
	gsm:add_transition(world_camera, disconnected, world_camera_func)
	gsm:add_transition(world_camera, kicked, world_camera_func)
	gsm:add_transition(world_camera, victoryscreen, world_camera_func)
	gsm:add_transition(bootup, menu_titlescreen, bootup_func)
	gsm:add_transition(menu_titlescreen, menu_main, menu_titlescreen_func)
	gsm:add_transition(ingame_standard, editor, ingame_standard_func)
	gsm:add_transition(ingame_standard, world_camera, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_mask_off, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_bleed_out, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_fatal, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_arrested, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_electrified, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_incapacitated, ingame_standard_func)
	gsm:add_transition(ingame_standard, victoryscreen, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_waiting_for_respawn, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_standard, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_waiting_for_players, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_clean, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_civilian, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_access_camera, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_driving, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_parachuting, ingame_standard_func)
	gsm:add_transition(ingame_standard, ingame_freefall, ingame_standard_func)
	gsm:add_transition(ingame_standard, server_left, ingame_standard_func)
	gsm:add_transition(ingame_standard, gameoverscreen, ingame_standard_func)
	gsm:add_transition(ingame_standard, disconnected, ingame_standard_func)
	gsm:add_transition(ingame_standard, kicked, ingame_standard_func)
	gsm:add_transition(ingame_mask_off, editor, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, world_camera, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_standard, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_bleed_out, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_fatal, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_arrested, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_electrified, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_incapacitated, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_waiting_for_respawn, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_clean, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_civilian, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_access_camera, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_driving, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, ingame_freefall, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, server_left, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, victoryscreen, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, gameoverscreen, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, disconnected, ingame_mask_off_func)
	gsm:add_transition(ingame_mask_off, kicked, ingame_mask_off_func)
	gsm:add_transition(ingame_clean, editor, ingame_clean_func)
	gsm:add_transition(ingame_clean, world_camera, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_civilian, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_mask_off, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_standard, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_bleed_out, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_fatal, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_arrested, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_electrified, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_incapacitated, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_waiting_for_respawn, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_access_camera, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_driving, ingame_clean_func)
	gsm:add_transition(ingame_clean, ingame_freefall, ingame_clean_func)
	gsm:add_transition(ingame_clean, server_left, ingame_clean_func)
	gsm:add_transition(ingame_clean, victoryscreen, ingame_clean_func)
	gsm:add_transition(ingame_clean, gameoverscreen, ingame_clean_func)
	gsm:add_transition(ingame_clean, disconnected, ingame_clean_func)
	gsm:add_transition(ingame_clean, kicked, ingame_clean_func)
	gsm:add_transition(ingame_civilian, editor, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, world_camera, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_clean, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_mask_off, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_standard, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_bleed_out, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_fatal, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_arrested, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_electrified, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_incapacitated, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_waiting_for_respawn, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_access_camera, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, ingame_driving, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, server_left, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, victoryscreen, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, gameoverscreen, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, disconnected, ingame_civilian_func)
	gsm:add_transition(ingame_civilian, kicked, ingame_civilian_func)
	gsm:add_transition(ingame_access_camera, editor, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, world_camera, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, ingame_mask_off, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, ingame_standard, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, ingame_bleed_out, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, ingame_fatal, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, ingame_arrested, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, ingame_electrified, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, ingame_incapacitated, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, server_left, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, victoryscreen, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, gameoverscreen, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, disconnected, ingame_access_camera_func)
	gsm:add_transition(ingame_access_camera, kicked, ingame_access_camera_func)
	gsm:add_transition(ingame_driving, editor, ingame_driving_func)
	gsm:add_transition(ingame_driving, world_camera, ingame_driving_func)
	gsm:add_transition(ingame_driving, ingame_mask_off, ingame_driving_func)
	gsm:add_transition(ingame_driving, ingame_standard, ingame_driving_func)
	gsm:add_transition(ingame_driving, ingame_bleed_out, ingame_driving_func)
	gsm:add_transition(ingame_driving, ingame_fatal, ingame_driving_func)
	gsm:add_transition(ingame_driving, ingame_arrested, ingame_driving_func)
	gsm:add_transition(ingame_driving, ingame_electrified, ingame_driving_func)
	gsm:add_transition(ingame_driving, ingame_incapacitated, ingame_driving_func)
	gsm:add_transition(ingame_driving, ingame_waiting_for_respawn, ingame_driving_func)
	gsm:add_transition(ingame_driving, server_left, ingame_driving_func)
	gsm:add_transition(ingame_driving, victoryscreen, ingame_driving_func)
	gsm:add_transition(ingame_driving, gameoverscreen, ingame_driving_func)
	gsm:add_transition(ingame_driving, disconnected, ingame_driving_func)
	gsm:add_transition(ingame_driving, kicked, ingame_driving_func)
	gsm:add_transition(ingame_bleed_out, editor, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, world_camera, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, ingame_standard, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, ingame_mask_off, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, ingame_fatal, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, ingame_arrested, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, ingame_freefall, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, ingame_parachuting, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, victoryscreen, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, ingame_waiting_for_respawn, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, gameoverscreen, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, server_left, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, disconnected, ingame_bleed_out_func)
	gsm:add_transition(ingame_bleed_out, kicked, ingame_bleed_out_func)
	gsm:add_transition(ingame_fatal, editor, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, world_camera, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, ingame_standard, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, ingame_mask_off, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, ingame_bleed_out, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, victoryscreen, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, ingame_waiting_for_respawn, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, gameoverscreen, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, server_left, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, disconnected, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, kicked, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, ingame_freefall, ingame_fatal_func)
	gsm:add_transition(ingame_fatal, ingame_parachuting, ingame_fatal_func)
	gsm:add_transition(ingame_arrested, editor, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, world_camera, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, ingame_standard, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, victoryscreen, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, ingame_waiting_for_respawn, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, gameoverscreen, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, ingame_bleed_out, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, server_left, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, disconnected, ingame_arrested_func)
	gsm:add_transition(ingame_arrested, kicked, ingame_arrested_func)
	gsm:add_transition(ingame_electrified, editor, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, world_camera, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, ingame_standard, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, ingame_incapacitated, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, victoryscreen, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, ingame_bleed_out, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, ingame_fatal, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, server_left, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, gameoverscreen, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, disconnected, ingame_electrified_func)
	gsm:add_transition(ingame_electrified, kicked, ingame_electrified_func)
	gsm:add_transition(ingame_incapacitated, editor, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, world_camera, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, ingame_standard, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, victoryscreen, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, ingame_waiting_for_respawn, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, gameoverscreen, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, server_left, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, gameoverscreen, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, disconnected, ingame_incapacitated_func)
	gsm:add_transition(ingame_incapacitated, kicked, ingame_incapacitated_func)
	gsm:add_transition(ingame_parachuting, editor, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, world_camera, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, ingame_mask_off, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, ingame_standard, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, ingame_bleed_out, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, ingame_fatal, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, server_left, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, victoryscreen, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, gameoverscreen, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, disconnected, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, kicked, ingame_parachuting_func)
	gsm:add_transition(ingame_parachuting, ingame_waiting_for_players, ingame_parachuting_func)
	gsm:add_transition(ingame_freefall, editor, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, world_camera, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, ingame_mask_off, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, ingame_standard, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, ingame_bleed_out, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, ingame_parachuting, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, ingame_fatal, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, server_left, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, victoryscreen, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, gameoverscreen, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, disconnected, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, kicked, ingame_freefall_func)
	gsm:add_transition(ingame_freefall, ingame_waiting_for_players, ingame_freefall_func)
	gsm:add_transition(ingame_waiting_for_players, ingame_standard, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, ingame_mask_off, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, ingame_clean, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, ingame_civilian, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, ingame_freefall, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, ingame_parachuting, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, gameoverscreen, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, victoryscreen, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, server_left, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, disconnected, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, kicked, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, ingame_lobby, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_players, ingame_waiting_for_spawn_allowed, ingame_waiting_for_players_func)
	gsm:add_transition(ingame_waiting_for_respawn, ingame_standard, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, ingame_mask_off, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, editor, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, ingame_clean, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, ingame_civilian, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, gameoverscreen, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, victoryscreen, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, server_left, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, disconnected, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_respawn, kicked, ingame_waiting_for_respawn_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, ingame_standard, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, ingame_mask_off, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, editor, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, ingame_clean, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, ingame_civilian, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, gameoverscreen, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, victoryscreen, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, server_left, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, disconnected, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, kicked, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(ingame_waiting_for_spawn_allowed, ingame_waiting_for_players, ingame_waiting_for_spawn_allowed_func)
	gsm:add_transition(gameoverscreen, gameoverscreen, gameoverscreen_func)
	gsm:add_transition(gameoverscreen, editor, gameoverscreen_func)
	gsm:add_transition(gameoverscreen, ingame_lobby, gameoverscreen_func)
	gsm:add_transition(gameoverscreen, server_left, gameoverscreen_func)
	gsm:add_transition(gameoverscreen, disconnected, gameoverscreen_func)
	gsm:add_transition(gameoverscreen, kicked, gameoverscreen_func)
	gsm:add_transition(gameoverscreen, empty, gameoverscreen_func)
	gsm:add_transition(gameoverscreen, menu_main, gameoverscreen_func)
	gsm:add_transition(ingame_lobby, empty, ingame_lobby_func)
	gsm:add_transition(server_left, ingame_lobby, ingame_lobby_func)
	gsm:add_transition(disconnected, ingame_lobby, ingame_lobby_func)
	gsm:add_transition(kicked, ingame_lobby, ingame_lobby_func)
	gsm:add_transition(server_left, empty, gameoverscreen_func)
	gsm:add_transition(server_left, disconnected, gameoverscreen_func)
	gsm:add_transition(disconnected, empty, gameoverscreen_func)
	gsm:add_transition(kicked, empty, gameoverscreen_func)
	gsm:add_transition(victoryscreen, editor, victoryscreen_func)
	gsm:add_transition(victoryscreen, empty, victoryscreen_func)
	gsm:add_transition(victoryscreen, ingame_lobby, victoryscreen_func)
	gsm:add_transition(victoryscreen, server_left, victoryscreen_func)
	gsm:add_transition(victoryscreen, disconnected, victoryscreen_func)
	gsm:add_transition(victoryscreen, kicked, victoryscreen_func)
	gsm:add_transition(victoryscreen, menu_main, victoryscreen_func)
	gsm:add_transition(empty, editor, empty_func)
	gsm:add_transition(empty, world_camera, empty_func)
	gsm:add_transition(empty, bootup, empty_func)
	gsm:add_transition(empty, menu_titlescreen, empty_func)
	gsm:add_transition(empty, menu_main, empty_func)
	gsm:add_transition(empty, ingame_standard, empty_func)
	gsm:add_transition(empty, ingame_mask_off, empty_func)
	gsm:add_transition(empty, ingame_bleed_out, empty_func)
	gsm:add_transition(empty, ingame_clean, empty_func)
	gsm:add_transition(empty, ingame_civilian, empty_func)
	gsm:add_transition(empty, ingame_waiting_for_players, empty_func)
	gsm:add_transition(empty, ingame_waiting_for_respawn, empty_func)
	gsm:add_transition(empty, ingame_waiting_for_spawn_allowed, empty_func)
	gsm:add_transition(empty, gameoverscreen, empty_func)
	gsm:add_transition(empty, server_left, empty_func)
	gsm:add_transition(empty, victoryscreen, empty_func)
	gsm:add_transition(empty, ingame_parachuting, empty_func)
	gsm:add_transition(empty, ingame_freefall, empty_func)
end

