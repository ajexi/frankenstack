extends Node2D

const CARD_WIDTH = 200
const HAND_Y_POSITION = 950
const DEFAULT_CARD_MOVE_SPEED = 0.1

var player_hand: Array[CombinedCard] = []
var centre_screen_x

func _ready() -> void:
	centre_screen_x = get_viewport().size.x / 2


func add_card_to_hand(card, speed) -> void:
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)


func update_hand_positions(speed) -> void:
	for count in range(player_hand.size()):
		#Get new card position based on index
		var new_position = Vector2(calculate_card_position(count), HAND_Y_POSITION)
		var card = player_hand[count]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)


func animate_card_to_position(card, new_position, speed) -> void:
	var tween = create_tween()
	tween.tween_property(card, "position", new_position, speed)
	

func calculate_card_position(index):
	var x_offset = (player_hand.size() - 1) * CARD_WIDTH
	var x_position = centre_screen_x + index * CARD_WIDTH - x_offset / 2
	return x_position
	

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
