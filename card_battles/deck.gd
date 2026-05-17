class_name PlayerDeck extends Node2D

const CARD_SCENE_PATH = "uid://t1llh3i80kg6"
const CARD_DRAW_SPEED = 0.3

var player_deck = ["Knight", "Archer", "Demon"]

@onready var card_manager: CardManager = %CardManager
@onready var player_hand: Node2D = %PlayerHand
@onready var deck_sprite: Sprite2D = %DeckSprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionArea/CollisionShape2D
@onready var deck_size_label: RichTextLabel = %DeckSizeLabel

func _ready() -> void:
	player_deck.shuffle()
	deck_size_label.text = str(player_deck.size())


func draw_card() -> void:
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		collision_shape_2d.disabled = true
		deck_sprite.visible = false
		deck_size_label.visible = false
	
	deck_size_label.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.global_position = global_position
	card_manager.add_child(new_card)
	new_card.name = "Card"
	new_card.animation_player.play("card_flip")
	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
