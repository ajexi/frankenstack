class_name CardbuilderCard extends Control

var upper_card_part : UpperCardPart
var lower_card_part : LowerCardPart
@onready var _upper_card_image: TextureRect = %UpperCardImage
@onready var _lower_card_image: TextureRect = %LowerCardImage
@onready var _type_label: Label = %TypeLabel
@onready var _attack_points_label: Label = %AttackPointsLabel
@onready var _defence_points_label: Label = %DefencePointsLabel
@onready var _attribute_label: Label = %AttributeLabel
@onready var _card_name_label: Label = %CardNameLabel
@onready var _card_rank_label: Label = %CardRankLabel

func _ready() -> void:
	pass
	
	
func update_upper_part_information() -> void:
	if upper_card_part != null:
		_upper_card_image.texture = upper_card_part.upper_card_image
		_attack_points_label.text = str(upper_card_part.attack_points)
		_attribute_label.text = upper_card_part.attribute
		if lower_card_part != null:
			_type_label.text = upper_card_part.upper_card_type + " " + lower_card_part.lower_card_type
			_card_name_label.text = upper_card_part.upper_part_name + lower_card_part.lower_card_name
		else:
			_type_label.text = upper_card_part.upper_card_type
			_card_name_label.text = upper_card_part.upper_part_name
			

func update_lower_part_information() -> void:
	if lower_card_part != null:
		_lower_card_image.texture = lower_card_part.lower_card_image
		_defence_points_label.text = str(lower_card_part.defence_points)
		if upper_card_part != null:
			_type_label.text = upper_card_part.upper_card_type + " " + lower_card_part.lower_card_type
			_card_name_label.text = upper_card_part.upper_part_name + lower_card_part.lower_card_name
		else:
			_type_label.text = lower_card_part.lower_card_type
			_card_name_label.text = lower_card_part.lower_card_name
			
