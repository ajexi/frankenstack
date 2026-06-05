class_name CardAbility extends Node

var cards_in_targeting_box : int = 0

const TARGETING_MENU := preload("uid://blh5jyogcoqya")
const CARD_ICON := preload("uid://4gewp7uaig5e")
const CARD_WIDTH : int = 200

func trigger_ability(card_manager: CardManager, battle_manager: BattleManager, card : CombinedCard, turn_player : String) -> void:
	if card.card_supertype == "CREATURE":
		await card_manager.position_selected
		print("Ability Triggered!")
	else:
		print("Ability Triggered!")
