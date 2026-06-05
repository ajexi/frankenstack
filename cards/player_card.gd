class_name PlayerCard extends CombinedCard

signal hovered
signal hovered_off

@onready var _collision_area: Area2D = %CollisionArea
@onready var _collision_shape_2d: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	load_card_information()
	
	_collision_area.mouse_entered.connect(_on_mouse_entered)
	_collision_area.mouse_exited.connect(_on_mouse_exited)
	
	if Engine.is_editor_hint():
		return
	get_parent().connect_card_signals(self)
	

func _on_mouse_entered() -> void:
	hovered.emit(self)


func _on_mouse_exited() -> void:
	hovered_off.emit(self)
	
	
func load_card_information() -> void:
	card_supertype = upper_card_part.combined_card_supertype
	_upper_card_sprite.texture = upper_card_part.upper_card_image
	_lower_card_sprite.texture = lower_card_part.lower_card_image
	current_attack_points = upper_card_part.attack_points
	current_defence_points = lower_card_part.defence_points
	_card_ability_label.text = lower_card_part.lower_card_ability
	if card_supertype == "CREATURE":
		_attack_points_label.text = str(current_attack_points)
		_defence_points_label.text = str(current_defence_points)
		_attribute_label.text = str(upper_card_part.attribute)
	else:
		_attack_points_label.text = ""
		_defence_points_label.text = ""
		_attribute_label.text = ""
	_card_name_label.text = upper_card_part.upper_part_name + lower_card_part.lower_card_name
	
	calculate_card_type()
	calculate_card_rank()
	
	card_action_point_cost = card_rank
