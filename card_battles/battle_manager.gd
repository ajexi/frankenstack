class_name BattleManager extends Node

const CARD_MOVE_SPEED := 0.2
const STARTING_LIFE_POINTS : int = 4000
const BATTLE_POS_OFFSET : int = 25

@onready var card_manager: CardManager = %CardManager

@onready var _end_turn_button: Button = %EndTurnButton
@onready var _opponent_deck: OpponentDeck = %OpponentDeck
@onready var _opponent_hand: OpponentHand = %OpponentHand
@onready var _opponent_card_slots: Node2D = %OpponentCardSlots
@onready var _player_hand: Node2D = %PlayerHand
@onready var _player_deck: PlayerDeck = %PlayerDeck
@onready var _player_discard_pile: Node2D = $"../DiscardPile"
@onready var _opponent_discard_pile: Node2D = $"../OpponentDiscardPile"
@onready var _battle_timer: Timer = $BattleTimer
@onready var _player_life_points_label: RichTextLabel = %PlayerLifePointsLabel
@onready var _opponent_life_points_label: RichTextLabel = %OpponentLifePointsLabel

var opponent_empty_monster_card_slots = []
var opponent_creatures_in_play : Array[EnemyCard] = []
var player_creatures_in_play : Array[PlayerCard] = []
var player_cards_attacked_this_turn : Array[PlayerCard] = []

var player_life_points : int 
var opponent_life_points : int 

var is_opponents_turn : bool = false
var player_is_attacking : bool = false

func _ready() -> void:
	_end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	player_life_points = STARTING_LIFE_POINTS
	opponent_life_points = STARTING_LIFE_POINTS
	_player_life_points_label.text = str(player_life_points)
	_opponent_life_points_label.text = str(opponent_life_points)
	
	for slot : CardSlot in _opponent_card_slots.get_children():
		if slot.card_slot_type == 'OPPONENT_CREATURE':
			opponent_empty_monster_card_slots.append(slot)


func _on_end_turn_button_pressed() -> void:
	card_manager.unselect_selected_creature()
	player_cards_attacked_this_turn.clear()
	opponent_turn()

func opponent_turn() -> void:
	is_opponents_turn = true
	_end_turn_button.disabled = true
	_end_turn_button.visible = false
	for card : PlayerCard in _player_hand.get_children():
		card._collision_area.disabled = true
	_player_deck.collision_shape_2d.disabled = true
	
	if _opponent_deck.opponent_deck.size() != 0:
		_opponent_deck.draw_card()
	
	#Wait 1 second for opponent thinking.
	await wait(1.0)
	
	#Check if monster card slots, and if no, end turn.
	if opponent_empty_monster_card_slots.size() != 0:
		try_play_card_with_highest_atk()
		
	#Wait 1 second for opponent thinking.
	await wait(1.0)
	
	#Try attack
	if opponent_creatures_in_play.size() != 0:
		var opponent_cards_to_attack = opponent_creatures_in_play.duplicate()
		for card in opponent_cards_to_attack:
			if player_creatures_in_play.size() == 0:
				await direct_attack(card, "Opponent")
			else:
				var card_to_attack : CombinedCard = player_creatures_in_play.pick_random()
				await attack(card, card_to_attack, "Opponent", "Player")
	
	#End turn
	end_opponent_turn()


func end_opponent_turn() -> void:
	_end_turn_button.disabled = false
	_end_turn_button.visible = true
	for card : PlayerCard in _player_hand.get_children():
		card._collision_area.disabled = false
	_player_deck.collision_shape_2d.disabled = false
	is_opponents_turn = false
	

func try_play_card_with_highest_atk() -> void:
	#Play card in hand with highest attack
	if _opponent_hand.opponent_hand.size() == 0:
		end_opponent_turn()
	var random_empty_monster_card_slot = opponent_empty_monster_card_slots.pick_random()
	opponent_empty_monster_card_slots.erase(random_empty_monster_card_slot)
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
	current_card_with_highest_atk.card_slot_card_is_in = random_empty_monster_card_slot
	opponent_creatures_in_play.append(current_card_with_highest_atk)
	
	await wait(1.0)


func direct_attack(attacking_card : CombinedCard, attacker : String) -> void:
	_end_turn_button.disabled = true
	var new_pos_y : int
	if attacker == "Opponent":
		new_pos_y = 1080
	else:
		player_is_attacking = true
		new_pos_y = 0
		player_cards_attacked_this_turn.append(attacking_card)
		
	var new_pos := Vector2(attacking_card.position.x, new_pos_y)
	
	attacking_card.z_index = 5
	
	var tween = create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	
	await wait(0.15)
	
	if attacker == "Opponent":
		damage_player_life_points(attacking_card.upper_card_part.attack_points)
	else:
		damage_opponent_life_points(attacking_card.upper_card_part.attack_points)
		
	var tween2 = create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	attacking_card.z_index = 0
	await wait(0.5)
	if attacker == "Player":
		player_is_attacking = false
	
	_end_turn_button.disabled = false


func attack(attacking_card : CombinedCard, defending_card : CombinedCard, attacker : String, defender : String) -> void:
	_end_turn_button.disabled = true
	if attacker == "Player":
		player_is_attacking = true
		card_manager.selected_creature = null
		player_cards_attacked_this_turn.append(attacking_card)
	attacking_card.z_index = 5
	
	#Animate card attacking
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	
	var tween = create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	
	await wait(0.15)
	
	var tween2 = create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	#Deal damage
	var stat_being_attacked : int
	if defending_card.is_in_defence_position:
		stat_being_attacked = defending_card.lower_card_part.defence_points
	else:
		stat_being_attacked = defending_card.upper_card_part.attack_points
	
	var card_was_destroyed : bool = false
	if attacking_card.upper_card_part.attack_points > stat_being_attacked:
		var remainder_damage = attacking_card.upper_card_part.attack_points - stat_being_attacked
		if defending_card.is_in_defence_position == false:
			if attacker == "Opponent":
				damage_player_life_points(remainder_damage)
			else:
				damage_opponent_life_points(remainder_damage)
			destroy_card(defending_card, defender)
			card_was_destroyed = true
	elif attacking_card.upper_card_part.attack_points == stat_being_attacked:
		if defending_card.is_in_defence_position == false:
			destroy_card(attacking_card, attacker)
			destroy_card(defending_card, defender)
			card_was_destroyed = true
	elif attacking_card.upper_card_part.attack_points < stat_being_attacked:
		var remainder_damage = stat_being_attacked - attacking_card.upper_card_part.attack_points
		if attacker == "Opponent":
			damage_opponent_life_points(remainder_damage)
		else:
			damage_player_life_points(remainder_damage)
		if defending_card.is_in_defence_position == false:
			destroy_card(attacking_card, attacker)
			card_was_destroyed = true
			
	attacking_card.z_index = 0
	if card_was_destroyed:
		await wait(1.0)
	
	if attacker == "Player":
		player_is_attacking = false
		
	_end_turn_button.disabled = false


func wait(wait_time : float) -> void:
	_battle_timer.wait_time = wait_time
	_battle_timer.start()
	await _battle_timer.timeout


func damage_player_life_points(damage: int) -> void:
	player_life_points = max(0, player_life_points - damage)
	_player_life_points_label.text = str(player_life_points)
	
	
func damage_opponent_life_points(damage: int) -> void:
	opponent_life_points = max(0, opponent_life_points - damage)
	_opponent_life_points_label.text = str(opponent_life_points)


func destroy_card(card : CombinedCard, card_owner: String) -> void:
	var new_pos
	if card_owner == 'Player':
		card.defeated = true
		card._collision_shape_2d.disabled = true
		new_pos = _player_discard_pile.position
		if card in player_creatures_in_play:
			player_creatures_in_play.erase(card)
		card.card_slot_card_is_in.collision_shape_2d.disabled = false
	else:
		new_pos = _opponent_discard_pile.position
		if card in opponent_creatures_in_play:
			opponent_creatures_in_play.erase(card)
			
	card.card_slot_card_is_in.card_in_slot = false
	card.card_slot_card_is_in = null
	
	var tween = create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)


func enemy_card_selected(defending_card : EnemyCard) -> void:
	var attacking_card = card_manager.selected_creature
	if attacking_card:
		if defending_card in opponent_creatures_in_play:
			if player_is_attacking == false:
				card_manager.selected_creature = null
				attack(attacking_card, defending_card, "Player", "Opponent")
		
