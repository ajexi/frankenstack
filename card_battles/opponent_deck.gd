@icon ("res://addons/at-icons/node2d/playing_card.svg")
class_name OpponentDeck extends Node2D

const CARD_SCENE_PATH = "uid://blkx3viqrb1x8"
const CARD_DRAW_SPEED = 0.3
const STARTING_HAND_COUNT := 4

@export var opponent_decklist : SavedDeck
var opponent_deck = []

@onready var card_manager: CardManager = %CardManager
@onready var opponent_hand: Node2D = %OpponentHand
@onready var deck_sprite: Sprite2D = %DeckSprite
@onready var deck_size_label: RichTextLabel = %DeckSizeLabel
@onready var battle_manager: BattleManager = %BattleManager


func _ready() -> void:
	for card in opponent_decklist.deck_list:
		opponent_deck.append(card)
	
	opponent_deck.shuffle()
	deck_size_label.text = str(opponent_deck.size())
	for i in STARTING_HAND_COUNT:
		draw_card()


func draw_card() -> void:
	if battle_manager.initial_board_setup_complete == true:
		if battle_manager.opponent_scouting_card == false:
			if battle_manager.opponent_action_points == 0:
				return
			else:
				battle_manager.opponent_action_points -= 1
				battle_manager._opponent_action_point_bar.value = battle_manager.opponent_action_points
		
	
	if opponent_deck.size() == 0:
		return
	
	var card_drawn = opponent_deck[0]
	opponent_deck.erase(card_drawn)
	
	if opponent_deck.size() == 0:
		deck_sprite.visible = false
		deck_size_label.visible = false
	
	deck_size_label.text = str(opponent_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card : CombinedCard = card_scene.instantiate()
	new_card.global_position = global_position
	new_card.upper_card_part = card_drawn[0]
	new_card.lower_card_part = card_drawn[1]
	if new_card.lower_card_part.lower_card_ability_script != "" or null:
		new_card.ability_script = load(new_card.lower_card_part.lower_card_ability_script).new()
	card_manager.add_child(new_card)
	new_card.name = "Card"
	opponent_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
