class_name BattleManager extends Node

const CARD_MOVE_SPEED := 0.2

@onready var _end_turn_button: Button = %EndTurnButton
@onready var _opponent_deck: OpponentDeck = %OpponentDeck
@onready var _opponent_hand: OpponentHand = %OpponentHand
@onready var _opponent_card_slots: Node2D = %OpponentCardSlots
@onready var _player_hand: Node2D = %PlayerHand
@onready var _player_deck: PlayerDeck = %PlayerDeck

var empty_monster_card_slots = []


func _ready() -> void:
	_end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	for slot in _opponent_card_slots.get_children():
		empty_monster_card_slots.append(slot)


func _on_end_turn_button_pressed() -> void:
	opponent_turn()

func opponent_turn() -> void:
	_end_turn_button.disabled = true
	_end_turn_button.visible = false
	for card : PlayerCard in _player_hand.get_children():
		card._collision_area.disabled = true
	_player_deck.collision_shape_2d.disabled = true
	
	if _opponent_deck.opponent_deck.size() != 0:
		_opponent_deck.draw_card()
	
	#Wait 1 second for opponent thinking.
	await get_tree().create_timer(1.0).timeout
	
	#Check if monster card slots, and if no, end turn.
	if empty_monster_card_slots.size() == 0:
		end_opponent_turn()
		return
	
	#Enemy AI function
	try_play_card_with_highest_atk()
	
	#End turn
	end_opponent_turn()


func end_opponent_turn() -> void:
	_end_turn_button.disabled = false
	_end_turn_button.visible = true
	for card : PlayerCard in _player_hand.get_children():
		card._collision_area.disabled = false
	_player_deck.collision_shape_2d.disabled = false
	

func try_play_card_with_highest_atk() -> void:
	#Play card in hand with highest attack
	if _opponent_hand.opponent_hand.size() == 0:
		end_opponent_turn()
	var random_empty_monster_card_slot = empty_monster_card_slots.pick_random()
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	#Start by assuming the first card in hand has the highest attack.
	var current_card_with_highest_atk = _opponent_hand.opponent_hand[0]
	for card : EnemyCard in _opponent_hand.opponent_hand:
		if card.upper_card_part.attack_points > current_card_with_highest_atk.upper_card_part.attack_points:
			current_card_with_highest_atk = card
	#Animate card into position
	var tween = create_tween()
	tween.tween_property(current_card_with_highest_atk, "position", random_empty_monster_card_slot.position, CARD_MOVE_SPEED)
	current_card_with_highest_atk.animation_player.play('card_flip')
	#Remove card from opponent's hand
	_opponent_hand.remove_card_from_hand(current_card_with_highest_atk)
	
	await get_tree().create_timer(1.0).timeout
