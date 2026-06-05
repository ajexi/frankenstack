@icon ("res://addons/at-icons/node2d/book.svg")
class_name CardManager extends Node2D

signal position_selected

const CARD_COLLISION_MASK: int = 1
const CARD_SLOT_COLLISION_MASK: int = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1

var card_being_dragged: CombinedCard
var screen_size: Vector2
var is_hovering_on_card: bool
var selected_creature : PlayerCard
var menu_open : bool = false
var scouting_cards : bool = false

@onready var player_hand: Node2D = %PlayerHand
@onready var input_manager: InputManager = %InputManager
@onready var battle_manager: BattleManager = %BattleManager

func _ready() -> void:
	screen_size = get_viewport_rect().size
	input_manager.left_mouse_button_released.connect(on_left_click_released)


func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		#Moves the card's position to the mouse position and clamps it so it can't be moved past
		#the screen boundaries
		card_being_dragged.position = Vector2(clamp(mouse_position.x, 0, screen_size.x),
			clamp(mouse_position.y, 0, screen_size.y))


func start_drag(card) -> void:
	if menu_open == false:
		card_being_dragged = card
		card_being_dragged.z_index = 2
		card.scale = Vector2(1,1)
	

func finish_drag() -> void:
	card_being_dragged.scale = Vector2(1.05,1.05)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		#there isn't already a card in the slot
		if card_being_dragged.card_supertype == card_slot_found.card_slot_type:
			#card is the correct type of slot for that card
			if card_being_dragged.card_action_point_cost <= battle_manager.player_action_points:
				#Player has enough action points to play the card
				player_hand.remove_card_from_hand(card_being_dragged)
				#Card dropped into an empty card slot.
				is_hovering_on_card = false
				#Move the card to the card slot position
				card_being_dragged.position = card_slot_found.position
				card_slot_found.card_in_slot = true
				card_slot_found.collision_shape_2d.disabled = true
				#Get a reference to the slot the card has been placed in.
				card_being_dragged.card_slot_card_is_in = card_slot_found
				#Deduct action points.
				battle_manager.player_action_points -= card_being_dragged.card_action_point_cost
				battle_manager._player_action_point_bar.value = battle_manager.player_action_points
				#Create a position selection menu if the card is a creature.
				if card_being_dragged.card_supertype == "CREATURE":
					battle_manager.player_creatures_in_play.append(card_being_dragged)
					var card_played = card_being_dragged
					const POSITION_MENU = preload("uid://bsjaief2eo471")
					var new_position_menu = POSITION_MENU.instantiate() as PositionMenu
					menu_open = true
					battle_manager._end_turn_button.disabled = true
					card_slot_found.collision_shape_2d.disabled = true
					new_position_menu.global_position = card_played.global_position
					add_child(new_position_menu)
					new_position_menu.attack_position_button.pressed.connect(func() -> void:
						menu_open = false
						battle_manager._end_turn_button.disabled = false
						position_selected.emit()
						new_position_menu.queue_free())
					new_position_menu.defence_position_button.pressed.connect(func() -> void:
						card_played.global_rotation_degrees = -90.0
						card_played.is_in_defence_position = true
						menu_open = false
						battle_manager._end_turn_button.disabled = false
						position_selected.emit()
						new_position_menu.queue_free())
				if card_being_dragged.lower_card_part.lower_card_ability_script != "" or null:
					card_being_dragged.ability_script.trigger_ability(self, battle_manager, card_being_dragged, 'Player')
			else:
				player_hand.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
		else:
			player_hand.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	else:
		player_hand.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	
	card_being_dragged.scale = Vector2(1,1)
	card_being_dragged.z_index = 1
	card_being_dragged = null
	

func connect_card_signals(card: CombinedCard) -> void:
	card.hovered.connect(on_hovered_over_card)
	card.hovered_off.connect(on_hovered_off_card)


func on_hovered_over_card(card: CombinedCard) -> void:
	if card.card_slot_card_is_in:
		return
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	

func on_hovered_off_card(card: CombinedCard) -> void:
	if not card.defeated:
		if not card_being_dragged:
			highlight_card(card, false)
			#Check if hovered off one card amd straight on to another one.
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered:
				highlight_card(new_card_hovered, true)
			else:
				is_hovering_on_card = false
	
	
func highlight_card(card: CombinedCard, hovered: bool) -> void:
	if hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1.0,1.0)
		card.z_index = 1
	

##Checks the mouse position for a card underneath it. Returns a CombinedCard if a card is found,
##otherwise returns null.
func raycast_check_for_card() -> CombinedCard:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = CARD_COLLISION_MASK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null


func raycast_check_for_card_slot() -> CardSlot:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = CARD_SLOT_COLLISION_MASK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
	
func get_card_with_highest_z_index(cards: Array) -> CombinedCard:
	#assume the first card in the cards array has the highest z index
	if cards[0].collider.get_parent() is CombinedCard:
		var highest_z_card: CombinedCard = cards[0].collider.get_parent()
		var highest_z_index: int = highest_z_card.z_index
		
		#loop through the rest of the cards checking for a higher z index
		for count in range(1, cards.size()):
			var current_card = cards[count].collider.get_parent()
			if current_card.z_index > highest_z_index:
				highest_z_card = current_card
				highest_z_index = current_card.z_index
		return highest_z_card
	else:
		return null
			
		
func on_left_click_released() -> void:
	if card_being_dragged:
		finish_drag()
		

func card_clicked(card : PlayerCard) -> void:
	if card.card_slot_card_is_in:
		#there's a card in the slot that can be clicked
		if battle_manager.turn_number > 1:
			#it's not the first turn
			if battle_manager.is_opponents_turn == false:
				#it's not the opponent's turn
				if battle_manager.player_is_attacking == false:
					#player is not already attacking
					if menu_open == false:
						#there is not a menu open taking priority
						if card not in battle_manager.player_cards_attacked_this_turn:
							#card hasn't already attacked this turn
							if card.is_in_defence_position == false:
								#card is in attack position
								if card.card_action_point_cost <= battle_manager.player_action_points:
									#player can afford the cost to attack
									if battle_manager.opponent_creatures_in_play.size() == 0:
										#opponent has no creatures on the field
										battle_manager.direct_attack(card, "Player")
										battle_manager.player_action_points -= card.card_action_point_cost
										battle_manager._player_action_point_bar.value = battle_manager.player_action_points
										battle_manager.player_cards_attacked_this_turn.append(card)
										return
									else:
										select_card_for_battle(card)
	else:
		#card in hand
		start_drag(card)
	

func select_card_for_battle(card) -> void:
	if selected_creature:
		if selected_creature == card:
			card.position.y += 20
			selected_creature = null
		else:
			card.position.y += 20
			selected_creature = card
			card.position.y -= 20
	else:
		selected_creature = card
		card.position.y -= 20
		

func unselect_selected_creature() -> void:
	if selected_creature:
		selected_creature.position.y  += 20
		selected_creature = null
