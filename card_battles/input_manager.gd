@icon ("res://addons/at-icons/node2d/mouse.svg")
class_name InputManager extends Node2D

const CARD_COLLISION_MASK: int = 1
const DECK_COLLISION_MASK: int = 4
const COLLISION_MASK_OPPONENT_CARD : int = 16

signal left_mouse_button_clicked
signal left_mouse_button_released

@onready var card_manager: CardManager = %CardManager
@onready var player_deck: Node2D = %PlayerDeck
@onready var battle_manager: BattleManager = %BattleManager

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			left_mouse_button_clicked.emit()
			raycast_at_cursor()
		else:
			left_mouse_button_released.emit()


##Checks the mouse position for an interactable object underneath. R
func raycast_at_cursor() -> void:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == CARD_COLLISION_MASK:
			#Card clicked
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager.card_clicked(card_found)
		elif result_collision_mask == DECK_COLLISION_MASK:
			#Deck clicked
			player_deck.draw_card()
		elif result_collision_mask == COLLISION_MASK_OPPONENT_CARD:
			battle_manager.enemy_card_selected(result[0].collider.get_parent())
