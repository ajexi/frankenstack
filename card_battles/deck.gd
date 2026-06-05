@icon ("res://addons/at-icons/node2d/playing_card.svg")
class_name PlayerDeck extends Node2D

signal card_drawn_signal

const CARD_SCENE_PATH = "uid://t1llh3i80kg6"
const CARD_DRAW_SPEED = 0.3
const STARTING_HAND_COUNT := 4

var player_deck = []

@onready var card_manager: CardManager = %CardManager
@onready var player_hand: Node2D = %PlayerHand
@onready var deck_sprite: Sprite2D = %DeckSprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionArea/CollisionShape2D
@onready var deck_size_label: RichTextLabel = %DeckSizeLabel
@onready var battle_manager: BattleManager = %BattleManager

func _ready() -> void:
	player_deck = CardDatabaseManager.player_created_deck.duplicate()
	player_deck.shuffle()
	deck_size_label.text = str(player_deck.size())
	for i in STARTING_HAND_COUNT:
		draw_card()


func draw_card() -> void:
	
	#Checks if the board has not yet been set up to allow for start-of-game card drawing
	if battle_manager.initial_board_setup_complete == true:
		if card_manager.menu_open == false:
			#Only draw a card if the player has enough Action Points, and only during
			#the playing cards phase
			if battle_manager.player_action_points == 0:
				return
			battle_manager.player_action_points -= 1
			battle_manager._player_action_point_bar.value = battle_manager.player_action_points

	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	card_drawn_signal.emit()
	
	if player_deck.size() == 0:
		collision_shape_2d.disabled = true
		deck_sprite.visible = false
		deck_size_label.visible = false
	
	deck_size_label.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card : CombinedCard = card_scene.instantiate()
	new_card.global_position = global_position
	new_card.upper_card_part = card_drawn[0]
	new_card.lower_card_part = card_drawn[1]
	if new_card.lower_card_part.lower_card_ability_script != "" or null:
		new_card.ability_script = load(new_card.lower_card_part.lower_card_ability_script).new()
	card_manager.add_child(new_card)
	new_card.name = "Card"
	new_card.animation_player.play("card_flip")
	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
