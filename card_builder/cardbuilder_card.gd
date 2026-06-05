class_name CardbuilderCard extends Control

var upper_card_part : UpperCardPart
var lower_card_part : LowerCardPart

var card_rank: int

var amount : int

@onready var _upper_card_image: TextureRect = %UpperCardImage
@onready var _lower_card_image: TextureRect = %LowerCardImage
@onready var _type_label: Label = %TypeLabel
@onready var _attack_points_label: Label = %AttackPointsLabel
@onready var _defence_points_label: Label = %DefencePointsLabel
@onready var _attribute_label: Label = %AttributeLabel
@onready var _card_name_label: Label = %CardNameLabel
@onready var _card_rank_label: Label = %CardRankLabel
@onready var _card_ability_label: Label = %CardAbilityLabel

func _ready() -> void:
	pass
	

##Updates the combined card information on the Cardbuilder screen. Writes the resource properties
##to the CardbuilderCombinedCard so the combination can be previewed.
func update_upper_part_information() -> void:
	if upper_card_part != null:
		_upper_card_image.texture = upper_card_part.upper_card_image
		_attribute_label.text = upper_card_part.attribute
		if upper_card_part.combined_card_supertype == 'CREATURE':
			_attack_points_label.text = str(upper_card_part.attack_points)
		else:
			_attack_points_label.text = ""
		if lower_card_part != null:
			_card_name_label.text = upper_card_part.upper_part_name + lower_card_part.lower_card_name
			calculate_card_type()
			calculate_card_rank()
		else:
			_type_label.text = upper_card_part.upper_card_type
			_card_name_label.text = upper_card_part.upper_part_name
			

##Updates the combined card information on the Cardbuilder screen. Writes the resource properties
##to the CardbuilderCombinedCard so the combination can be previewed.
func update_lower_part_information() -> void:
	if lower_card_part != null:
		_lower_card_image.texture = lower_card_part.lower_card_image
		_defence_points_label.text = str(lower_card_part.defence_points)
		_card_ability_label.text = lower_card_part.lower_card_ability
		if upper_card_part != null:
			_card_name_label.text = upper_card_part.upper_part_name + lower_card_part.lower_card_name
			if upper_card_part.combined_card_supertype == 'MAGIC':
				_defence_points_label.text = ""
			else:
				_defence_points_label.text = str(lower_card_part.defence_points)
			calculate_card_type()
			calculate_card_rank()
		else:
			_type_label.text = lower_card_part.lower_card_type
			_card_name_label.text = lower_card_part.lower_card_name
			

##Calculates the final type of the CardbuilderCombinedCard. If both part types are the same,
##the cardbuilder preview displays a single type.
func calculate_card_type() -> void:
	if upper_card_part.upper_card_type == lower_card_part.lower_card_type:
		_type_label.text = upper_card_part.upper_card_type
	else:
		_type_label.text = upper_card_part.upper_card_type + " " + lower_card_part.lower_card_type
	

##Calculates the final rank of the card based on the combination of its attack and defence points.
func calculate_card_rank() -> void:
	if upper_card_part.attack_points + (lower_card_part.defence_points) <= 2500:
		card_rank = 1
	elif upper_card_part.attack_points + (lower_card_part.defence_points) < 4001:
		card_rank = 2
	elif upper_card_part.attack_points + (lower_card_part.defence_points) >= 4001:
		card_rank = 3
		
	_card_rank_label.text = str(card_rank)
