extends CardAbility

const BURN_DAMAGE : int = 200

func trigger_ability(card_manager: CardManager, battle_manager: BattleManager, card : CombinedCard, 
	turn_player : String, effect_trigger : String) -> void:
	
	if turn_player == 'Player' and card.card_supertype == 'CREATURE':
		await card_manager.position_selected
	
	if effect_trigger != 'on_played':
		return
	
	card_manager.particle_effect_manager.effect_activation(card)
	
	if turn_player == 'Player':
		battle_manager.damage_opponent_life_points(BURN_DAMAGE)
	elif turn_player == 'Opponent':
		battle_manager.damage_player_life_points(BURN_DAMAGE)
