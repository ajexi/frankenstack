extends CardAbility

func trigger_ability(card_manager: CardManager, battle_manager: BattleManager, card : CombinedCard, 
	turn_player : String, effect_trigger : String) -> void:
		
	if effect_trigger != 'on_damage':
		return
	
	print("We workin' baby")
	
	var damage_dealt : int = (battle_manager.damage_dealt_by_card_attack)
	
	if turn_player == 'Player':
		battle_manager.heal_player_life_points(damage_dealt)
	elif turn_player == 'Opponent':
		battle_manager.heal_opponent_life_points(damage_dealt)
