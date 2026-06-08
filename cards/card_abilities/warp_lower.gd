extends CardAbility

signal card_selected

var selected_cards : Array[CombinedCard] = []

func trigger_ability(card_manager: CardManager, battle_manager: BattleManager, card : CombinedCard, turn_player : String, effect_trigger : String) -> void:
	
	if effect_trigger != 'on_played':
		return
	
	if card.card_supertype == 'CREATURE' and turn_player == 'Player':
		await card_manager.position_selected
		
	if turn_player == 'Player':
		if battle_manager.opponent_creatures_in_play.size() + battle_manager.player_creatures_in_play.size() < 2:
			battle_manager.destroy_card(card, turn_player)
			return
	
	card_manager.menu_open = true
	for count in 2:
		var new_targeting_menu : TargetingMenu = TARGETING_MENU.instantiate()
		battle_manager.get_tree().current_scene.add_child(new_targeting_menu)
		card_manager.menu_open = true
		if battle_manager.opponent_creatures_in_play != []:
			for card_on_field in battle_manager.opponent_creatures_in_play:
				if card_on_field in selected_cards:
					pass
				var new_card_icon : CardbuilderCard = CARD_ICON.instantiate()
				new_targeting_menu.h_box_container.add_child(new_card_icon)
				new_card_icon.upper_card_part = card_on_field.upper_card_part
				new_card_icon.lower_card_part = card_on_field.lower_card_part
				new_card_icon.update_upper_part_information()
				new_card_icon.update_lower_part_information()
				new_card_icon.get_node("AddOrRemoveButton").pressed.connect(func() -> void:
					selected_cards.append(card_on_field)
					card_selected.emit()
					new_targeting_menu.queue_free()
					)
				cards_in_targeting_box += 1
		
		if battle_manager.player_creatures_in_play != []:
			for card_on_field in battle_manager.player_creatures_in_play:
				if card_on_field in selected_cards:
					pass
				var new_card_icon : CardbuilderCard = CARD_ICON.instantiate()
				new_targeting_menu.h_box_container.add_child(new_card_icon)
				new_card_icon.upper_card_part = card_on_field.upper_card_part
				new_card_icon.lower_card_part = card_on_field.lower_card_part
				new_card_icon.update_upper_part_information()
				new_card_icon.update_lower_part_information()
				new_card_icon.get_node("AddOrRemoveButton").pressed.connect(func() -> void:
					selected_cards.append(card_on_field)
					card_selected.emit()
					new_targeting_menu.queue_free()
					)
				cards_in_targeting_box += 1
			var targeting_box_width = (cards_in_targeting_box * CARD_WIDTH) + CARD_WIDTH
			if targeting_box_width < 1920:
				new_targeting_menu.panel_container.size.x = targeting_box_width
			else:
				new_targeting_menu.panel_container.size.x = 1920
			new_targeting_menu.z_index = 5
		
		await card_selected
		
	var first_card_lower_part = selected_cards[0].lower_card_part
	var second_card_lower_part = selected_cards[1].lower_card_part
	selected_cards[0].lower_card_part = second_card_lower_part
	selected_cards[1].lower_card_part = first_card_lower_part
	selected_cards[0].load_card_information()
	selected_cards[1].load_card_information()
	
	if card.card_supertype == "MAGIC":
		battle_manager.destroy_card(card, turn_player)
	
	card_manager.menu_open = false
		
	
