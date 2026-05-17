@tool
class_name CardbuilderUpperPart extends Control

signal upper_part_selected(selected_part: UpperCardPart)

@export var upper_card_part : UpperCardPart
@onready var _upper_card_sprite: TextureRect = %UpperCardSprite
@onready var _type_label: Label = %TypeLabel
@onready var _attack_points_label: Label = %AttackPointsLabel
@onready var _card_name_label: Label = %CardNameLabel
@onready var _attribute_label: Label = %AttributeLabel
@onready var _selection_button: Button = %SelectionButton


func _ready() -> void:
	if upper_card_part != null:
		_set_card_part_information()
	
	_selection_button.pressed.connect(func() -> void:
		upper_part_selected.emit(upper_card_part))


func _set_card_part_information() -> void:
	_upper_card_sprite.texture = upper_card_part.upper_card_image
	_type_label.text = upper_card_part.upper_card_type
	_attack_points_label.text = str(upper_card_part.attack_points)
	_card_name_label.text = upper_card_part.upper_part_name
	_attribute_label.text = upper_card_part.attribute
