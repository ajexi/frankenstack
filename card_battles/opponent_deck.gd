class_name OpponentDeck extends Node2D

const CARD_SCENE_PATH = "uid://blkx3viqrb1x8"
const CARD_DRAW_SPEED = 0.3
const STARTING_HAND_COUNT := 4

var opponent_deck = []

@onready var card_manager: CardManager = %CardManager
@onready var opponent_hand: Node2D = %OpponentHand
@onready var deck_sprite: Sprite2D = %DeckSprite
@onready var deck_size_label: RichTextLabel = %DeckSizeLabel

func _ready() -> void:
	opponent_deck = CardDatabaseManager.test_opponent_deck
	opponent_deck.shuffle()
	deck_size_label.text = str(opponent_deck.size())
	for i in STARTING_HAND_COUNT:
		draw_card()


func draw_card() -> void:
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
	card_manager.add_child(new_card)
	new_card.name = "Card"
	opponent_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
