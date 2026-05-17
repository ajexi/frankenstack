class_name CardManager extends Node2D

const CARD_COLLISION_MASK: int = 1
const CARD_SLOT_COLLISION_MASK: int = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1

var card_being_dragged: CombinedCard
var screen_size: Vector2
var is_hovering_on_card: bool

@onready var player_hand: Node2D = %PlayerHand
@onready var input_manager: InputManager = %InputManager

func _ready() -> void:
	screen_size = get_viewport_rect().size
	input_manager.left_mouse_button_released.connect(on_left_click_released)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		#Moves the card's position to the mouse position and clamps it so it can't be moved past
		#the screen boundaries
		card_being_dragged.position = Vector2(clamp(mouse_position.x, 0, screen_size.x),
			clamp(mouse_position.y, 0, screen_size.y))


func start_drag(card) -> void:
	card_being_dragged = card
	card.scale = Vector2(1,1)
	

func finish_drag() -> void:
	card_being_dragged.scale = Vector2(1.05,1.05)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		player_hand.remove_card_from_hand(card_being_dragged)
		#Card dropped into an empty card slot.
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("CollisionArea/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
	else:
		player_hand.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null
	


func connect_card_signals(card: CombinedCard) -> void:
	card.hovered.connect(on_hovered_over_card)
	card.hovered_off.connect(on_hovered_off_card)



func on_hovered_over_card(card: CombinedCard) -> void:
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	

func on_hovered_off_card(card: CombinedCard) -> void:
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
		
