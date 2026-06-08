extends CardAbility

func trigger_ability(card_manager: CardManager, battle_manager: BattleManager, 
	card : CombinedCard, turn_player: String, effect_trigger : String) -> void:
	
	if effect_trigger != 'on_played':
		return
	
	if card.card_supertype == 'CREATURE' and turn_player == 'Player':
		await card_manager.position_selected
	
	if battle_manager.opponent_creatures_in_play == [] and battle_manager.player_creatures_in_play == []:
		battle_manager.destroy_card(card, turn_player)
		return
		
	var new_targeting_menu : TargetingMenu = TARGETING_MENU.instantiate()
	battle_manager.get_tree().current_scene.add_child(new_targeting_menu)
	card_manager.menu_open = true
	if battle_manager.opponent_creatures_in_play != []:
		for card_on_field in battle_manager.opponent_creatures_in_play:
			var new_card_icon : CardbuilderCard = CARD_ICON.instantiate()
			new_targeting_menu.h_box_container.add_child(new_card_icon)
			new_card_icon.upper_card_part = card_on_field.upper_card_part
			new_card_icon.lower_card_part = card_on_field.lower_card_part
			new_card_icon.update_upper_part_information()
			new_card_icon.update_lower_part_information()
			new_card_icon.get_node("AddOrRemoveButton").pressed.connect(func() -> void:
				battle_manager.destroy_card(card_on_field, "Opponent")
				new_targeting_menu.queue_free()
				if card.card_supertype == "MAGIC":
					battle_manager.destroy_card(card, turn_player)
				card_manager.menu_open = false)
			cards_in_targeting_box += 1
	
	if battle_manager.player_creatures_in_play != []:
		for card_on_field in battle_manager.player_creatures_in_play:
			var new_card_icon : CardbuilderCard = CARD_ICON.instantiate()
			new_targeting_menu.h_box_container.add_child(new_card_icon)
			new_card_icon.upper_card_part = card_on_field.upper_card_part
			new_card_icon.lower_card_part = card_on_field.lower_card_part
			new_card_icon.update_upper_part_information()
			new_card_icon.update_lower_part_information()
			new_card_icon.get_node("AddOrRemoveButton").pressed.connect(func() -> void:
				battle_manager.destroy_card(card_on_field, "Player")
				new_targeting_menu.queue_free()
				if card.card_supertype == "MAGIC":
					battle_manager.destroy_card(card, turn_player)
				card_manager.menu_open = false)
			cards_in_targeting_box += 1
		
	var targeting_box_width = (cards_in_targeting_box * CARD_WIDTH) + 10
	new_targeting_menu.panel_container.size.x = targeting_box_width
	new_targeting_menu.position.x = targeting_box_width / 2
	new_targeting_menu.global_position.x = 1920/2
	new_targeting_menu.position.y = 1080 / 2
	new_targeting_menu.z_index = 5
		
