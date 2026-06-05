@tool
class_name CardbuilderLowerPart extends Control

signal lower_part_selected(selected_part: LowerCardPart)

@export var lower_card_part : LowerCardPart
@onready var _lower_card_sprite: TextureRect = %LowerCardSprite
@onready var _card_name_label: Label = %CardNameLabel
@onready var _type_label: Label = %TypeLabel
@onready var _defence_points_label: Label = %DefencePointsLabel
@onready var _ability_label: Label = %AbilityLabel
@onready var _selection_button: Button = %SelectionButton


func _ready() -> void:
	if lower_card_part != null:
		_set_card_part_information()
	_selection_button.pressed.connect(func() -> void:
		lower_part_selected.emit(lower_card_part))

func _set_card_part_information() -> void:
	_lower_card_sprite.texture = lower_card_part.lower_card_image
	_card_name_label.text = lower_card_part.lower_card_name
	_type_label.text = lower_card_part.lower_card_type
	_defence_points_label.text = str(lower_card_part.defence_points)
	_ability_label.text = lower_card_part.lower_card_ability
