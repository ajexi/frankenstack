class_name OpponentHand extends Node2D

const CARD_WIDTH = 200
const HAND_Y_POSITION = 0
const DEFAULT_CARD_MOVE_SPEED = 0.1

var opponent_hand: Array[EnemyCard] = []

func _ready() -> void:
	pass


func add_card_to_hand(card, speed) -> void:
	if card not in opponent_hand:
		opponent_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)


func update_hand_positions(speed) -> void:
	for count in range(opponent_hand.size()):
		#Get new card position based on index
		var new_position = Vector2(calculate_card_position(count), HAND_Y_POSITION)
		var card = opponent_hand[count]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)


func animate_card_to_position(card, new_position, speed) -> void:
	var tween = create_tween()
	tween.tween_property(card, "position", new_position, speed)
	

func calculate_card_position(index):
	var x_offset = (opponent_hand.size() - 1) * CARD_WIDTH
	var x_position = (get_viewport().size.x / 2) - index * CARD_WIDTH + x_offset / 2
	return x_position
	

func remove_card_from_hand(card):
	if card in opponent_hand:
		opponent_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
