class_name EnemyCard extends CombinedCard

func _ready() -> void:
	_upper_card_sprite.texture = upper_card_part.upper_card_image
	_lower_card_sprite.texture = lower_card_part.lower_card_image
	_attack_points_label.text = str(upper_card_part.attack_points)
	_defence_points_label.text = str(lower_card_part.defence_points)
	_attribute_label.text = str(upper_card_part.attribute)
	_card_name_label.text = upper_card_part.upper_part_name + lower_card_part.lower_card_name
	
	calculate_card_type()
	calculate_card_rank()


func _on_mouse_entered() -> void:
	pass


func _on_mouse_exited() -> void:
	pass
