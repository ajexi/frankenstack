class_name EnemyCard extends CombinedCard

@onready var enemy_card_collision: Area2D = %EnemyCardCollision

func _ready() -> void:
	load_card_information()


func _on_mouse_entered() -> void:
	pass


func _on_mouse_exited() -> void:
	pass


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
