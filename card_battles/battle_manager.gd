@icon ("res://addons/at-icons/node/dagger.svg")
class_name BattleManager extends Node

#constant for managing card animation speed
const CARD_MOVE_SPEED := 0.2

#constant for animating card position when selected
const BATTLE_POS_OFFSET : int = 25

#constant for each player's starting life points
const STARTING_LIFE_POINTS : int = 4000

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
@onready var _player_action_point_bar: ProgressBar = %PlayerActionPointBar
@onready var _opponent_action_point_bar: ProgressBar = %OpponentActionPointBar

@export var _opponent_magic_card_slot : CardSlot
@export var _terrain_card_slot : CardSlot

##These arrays manage where a card is in relation to the field.
var opponent_empty_monster_card_slots = []
var opponent_creatures_in_play : Array[EnemyCard] = []
var player_creatures_in_play : Array[PlayerCard] = []
var player_cards_attacked_this_turn : Array[PlayerCard] = []

#Player & Opponent current life point values
var player_life_points : int 
var opponent_life_points : int 

var initial_board_setup_complete : bool = false
var is_opponents_turn : bool = false
var player_is_attacking : bool = false
var opponent_scouting_card : bool = false

##Manages the current turn number. Used to manage current Action Points and whether a first turn
##player can attack.
var turn_number : int = 1

##Constant for the maximum possible number of Action Points a player can have
const MAXIMUM_ACTION_POINTS : int = 5
#current action points of each player
var player_action_points : int 
var opponent_action_points : int

##used for calculating attribute bonuses during attacks
##dictionary key is for the attacking attribute, the value is the attribute
##it gets a bonus against
const ATTRIBUTE_BONUS_CHART : Dictionary = {
	"METAL" : "AURA",
	"AURA" : "VOID",
	"VOID" : "METAL",
	"WATER" : "FIRE",
	"FIRE" : "EARTH",
	"EARTH" : "AIR",
	"AIR" : "WATER",
}

const ATTRIBUTE_BONUS_VALUE : int = 300


func _ready() -> void:
	_end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	player_life_points = STARTING_LIFE_POINTS
	opponent_life_points = STARTING_LIFE_POINTS
	_player_life_points_label.text = str(player_life_points)
	_opponent_life_points_label.text = str(opponent_life_points)
	turn_number = 1
	initial_board_setup_complete = true
	begin_turn("Player")
	
	for slot : CardSlot in _opponent_card_slots.get_children():
		if slot.card_slot_type == 'OPPONENT_CREATURE':
			opponent_empty_monster_card_slots.append(slot)

##Resets the action points of the turn player.
func begin_turn(turn_player : String) -> void:
	if turn_player == "Player":
		if turn_number < MAXIMUM_ACTION_POINTS:
			player_action_points = turn_number
		else:
			player_action_points = MAXIMUM_ACTION_POINTS
		_player_action_point_bar.value = player_action_points
	elif turn_player == "Opponent":
		if turn_number < MAXIMUM_ACTION_POINTS:
			opponent_action_points = turn_number
		else:
			opponent_action_points = MAXIMUM_ACTION_POINTS
		_opponent_action_point_bar.value = opponent_action_points


func _on_end_turn_button_pressed() -> void:
	card_manager.unselect_selected_creature()
	player_cards_attacked_this_turn.clear()
	opponent_turn()


func opponent_turn() -> void:
	begin_turn("Opponent")
	await wait(0.1)
	#turn start cleanup
	is_opponents_turn = true
	_end_turn_button.disabled = true
	_end_turn_button.visible = false
	for card : PlayerCard in _player_hand.get_children():
		card._collision_area.disabled = true
	_player_deck.collision_shape_2d.disabled = true
	
	await wait(1.0)
	#first, if there is already a playable card in hand, play that
	if opponent_empty_monster_card_slots.size() != 0:
		try_play_card_with_highest_atk()
	await wait(0.5)
	#then, draw a card if able
	if _opponent_deck.opponent_deck.size() != 0 and opponent_action_points > 0:
		_opponent_deck.draw_card()
	
	#Wait 1 second for opponent thinking.
	await wait(1.0)
	
	#Check if monster card slots, and try to play a creature.
	if opponent_empty_monster_card_slots.size() != 0:
		try_play_card_with_highest_atk()
		
	#Wait 1 second for opponent thinking.
	await wait(1.0)
	
	#Try attack
	if opponent_creatures_in_play.size() != 0:
		var opponent_cards_to_attack = opponent_creatures_in_play.duplicate()
		for card : EnemyCard in opponent_cards_to_attack:
			#loop through player's field
			if card.card_action_point_cost > opponent_action_points:
				pass
			else:
				if player_creatures_in_play.size() == 0:
					opponent_action_points -= card.card_action_point_cost
					_opponent_action_point_bar.value = opponent_action_points
					await direct_attack(card, "Opponent")
				else:
					#choose a random card to attack
					var card_to_attack : CombinedCard = player_creatures_in_play.pick_random()
					opponent_action_points -= card.card_action_point_cost
					_opponent_action_point_bar.value = opponent_action_points
					await attack(card, card_to_attack, "Opponent", "Player")
				
	
	#if any AP left at the end of the turn, draw cards
	if opponent_action_points > 0:
		for ap in opponent_action_points:
			_opponent_deck.draw_card()
	
	#End turn
	end_opponent_turn()


func end_opponent_turn() -> void:
	_end_turn_button.disabled = false
	_end_turn_button.visible = true
	for card : PlayerCard in _player_hand.get_children():
		card._collision_area.disabled = false
	_player_deck.collision_shape_2d.disabled = false
	is_opponents_turn = false
	turn_number += 1
	begin_turn("Player")
	

##Opponent AI function.
##There will be more of these in future, this is a basic function that just plays the card in hand
##with the highest attack, if the opponent can afford it
func try_play_card_with_highest_atk() -> void:
	#Play card in hand with highest attack
	if _opponent_hand.opponent_hand.size() == 0:
		end_opponent_turn()
	#Start by assuming the first card in hand has the highest attack.
	var current_card_with_highest_atk = _opponent_hand.opponent_hand[0]
	#loop through the cards in hand to check all of their ATK values. If one is higher than
	#the current, replace it.
	for card : EnemyCard in _opponent_hand.opponent_hand:
		if card.upper_card_part.attack_points > current_card_with_highest_atk.upper_card_part.attack_points:
			if card.card_action_point_cost <= opponent_action_points:
				current_card_with_highest_atk = card
	
	if current_card_with_highest_atk.card_action_point_cost > opponent_action_points:
		await wait(1.0)
		return
	
	await opponent_play_creature_card(current_card_with_highest_atk)
	
	await wait(1.0)


##Opponent will play the creature card passed to this function.
func opponent_play_creature_card(card : EnemyCard) -> void:
	var random_empty_monster_card_slot : CardSlot = opponent_empty_monster_card_slots.pick_random()
	opponent_empty_monster_card_slots.erase(random_empty_monster_card_slot)
	
	#Animate card into position
	var tween = create_tween()
	tween.tween_property(card, "position", random_empty_monster_card_slot.position, CARD_MOVE_SPEED)
	card.animation_player.play('card_flip')
	
	#deduct the Action Point cost of the card
	opponent_action_points -= card.card_action_point_cost
	_opponent_action_point_bar.value = opponent_action_points
	
	#Remove card from opponent's hand
	_opponent_hand.remove_card_from_hand(card)
	card.card_slot_card_is_in = random_empty_monster_card_slot
	opponent_creatures_in_play.append(card)
	
	random_empty_monster_card_slot.collision_shape_2d.disabled = true
	
	#activate card ability, if there is one.
	if card.lower_card_part.lower_card_ability_script != "" or null:
		card.ability_script.trigger_ability(card_manager, self, card, 'Opponent')
	await wait(0.5)


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
	
	#Calculate the attribute bonus
	var attack_points_before_attack = attacking_card.current_attack_points
	if defending_card.upper_card_part.attribute == ATTRIBUTE_BONUS_CHART[attacking_card.upper_card_part.attribute]:
		attacking_card.current_attack_points += ATTRIBUTE_BONUS_VALUE
		attacking_card._attack_points_label.text = str(attacking_card.current_attack_points)
	elif attacking_card.upper_card_part.attribute == ATTRIBUTE_BONUS_CHART[defending_card.upper_card_part.attribute]:
		attacking_card.current_attack_points -= ATTRIBUTE_BONUS_VALUE
		attacking_card._attack_points_label.text = str(attacking_card.current_attack_points)
	
	await wait(0.5)
	
	#Animate card attacking
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	
	var tween = create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	
	await wait(0.15)
	
	var tween2 = create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	# determine if opposing card is in defence position
	var stat_being_attacked : int
	if defending_card.is_in_defence_position:
		stat_being_attacked = defending_card.current_defence_points
	else:
		stat_being_attacked = defending_card.current_attack_points
	
	await wait(0.5)
	
	#deal damage
	var card_was_destroyed : bool = false
	if attacking_card.upper_card_part.current_attack_points > stat_being_attacked:
		var remainder_damage = attacking_card.current_attack_points - stat_being_attacked
		if defending_card.is_in_defence_position == false:
			if attacker == "Opponent":
				damage_player_life_points(remainder_damage)
			else:
				damage_opponent_life_points(remainder_damage)
		destroy_card(defending_card, defender)
		card_was_destroyed = true
	elif attacking_card.current_attack_points == stat_being_attacked:
		if defending_card.is_in_defence_position == false:
			destroy_card(attacking_card, attacker)
			destroy_card(defending_card, defender)
			card_was_destroyed = true
	elif attacking_card.current_attack_points < stat_being_attacked:
		var remainder_damage = stat_being_attacked - attacking_card.current_attack_points
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
		
	#return card attack points to their original value
	attacking_card.current_attack_points = attack_points_before_attack
	attacking_card._attack_points_label.text = str(attacking_card.current_attack_points)
	
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
		if card.card_slot_card_is_in:
			card.card_slot_card_is_in.collision_shape_2d.disabled = false
	else:
		new_pos = _opponent_discard_pile.position
		if card in opponent_creatures_in_play:
			opponent_creatures_in_play.erase(card)
			opponent_empty_monster_card_slots.append(card.card_slot_card_is_in)
			
	if card.is_in_defence_position:
		var rotation_tween = create_tween()
		rotation_tween.tween_property(card, "global_rotation", 0, 0.2)
	
	card.animation_player.play_backwards("card_flip")
	if card.card_slot_card_is_in:
		card.card_slot_card_is_in.collision_shape_2d.disabled = false
		card.card_slot_card_is_in.card_in_slot = false
		card.card_slot_card_is_in = null
	
	var tween = create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)


func enemy_card_selected(defending_card : EnemyCard) -> void:
	var attacking_card = card_manager.selected_creature
	if attacking_card:
		#there is an attacking card selected
		if defending_card in opponent_creatures_in_play:
			#player has selected an opponent's creature
			if player_is_attacking == false:
				#player isn't already attacking with a card
				if attacking_card.card_action_point_cost <= player_action_points:
					#player can afford the action point cost to attack
					card_manager.selected_creature = null
					player_action_points -= attacking_card.card_action_point_cost
					_player_action_point_bar.value = player_action_points
					attack(attacking_card, defending_card, "Player", "Opponent")
		
