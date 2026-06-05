extends CardAbility

var scouted_cards = []

func trigger_ability(card_manager: CardManager, battle_manager: BattleManager, 
	card : CombinedCard, turn_player: String) -> void:
	
	if card.card_supertype == 'CREATURE' and turn_player == 'Player':
		await card_manager.position_selected
	
	var deck
	if turn_player == 'Player':
		deck = battle_manager._player_deck.player_deck
	else:
		deck = battle_manager._opponent_deck.opponent_deck
	
	#loop through the scouted cards to find ones with matching types
	for cards in deck.size():
		if deck[cards - 1][0].upper_card_type == card.upper_card_part.upper_card_type or card.lower_card_part.lower_card_type:
			scouted_cards.append(deck[cards - 1])
	
	if turn_player == 'Player':
		var new_targeting_menu : TargetingMenu = TARGETING_MENU.instantiate()
		battle_manager.get_tree().current_scene.add_child(new_targeting_menu)
		card_manager.menu_open = true
		card_manager.scouting_cards = true
		if scouted_cards != []:
			for scouted_card in scouted_cards:
				var new_card_icon : CardbuilderCard = CARD_ICON.instantiate()
				new_targeting_menu.h_box_container.add_child(new_card_icon)
				new_card_icon.upper_card_part = scouted_card[0]
				new_card_icon.lower_card_part = scouted_card[1]
				new_card_icon.update_upper_part_information()
				new_card_icon.update_lower_part_information()
				new_card_icon.get_node("AddOrRemoveButton").pressed.connect(func() -> void:
					battle_manager._player_deck.player_deck.erase(scouted_card)
					battle_manager._player_deck.player_deck.insert(0, scouted_card)
					battle_manager._player_deck.draw_card()
					new_targeting_menu.queue_free()
					card_manager.scouting_cards = false
					card_manager.menu_open = false
					if card.card_supertype == 'MAGIC':
						battle_manager.destroy_card(card, turn_player))
				cards_in_targeting_box += 1
		
			var targeting_box_width = (cards_in_targeting_box * CARD_WIDTH) + CARD_WIDTH
			if targeting_box_width < 1920:
				new_targeting_menu.panel_container.size.x = targeting_box_width
			else:
				new_targeting_menu.panel_container.size.x = 1920
			new_targeting_menu.z_index = 5
		else:
			new_targeting_menu.queue_free()
			
	elif turn_player == 'Opponent':
		if scouted_cards != []:
			await battle_manager.wait(0.5)
			battle_manager.opponent_scouting_card = true
			var scouted_opponent_card = scouted_cards.pick_random()
			deck.erase(scouted_opponent_card)
			deck.insert(0, scouted_opponent_card)
			battle_manager._opponent_deck.draw_card()
			battle_manager.opponent_scouting_card = false
