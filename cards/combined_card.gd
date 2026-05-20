class_name CombinedCard extends Node2D

##Calculated based on the ATK/DEF points of the combined card using the
##calculate_card_rank() function.
var card_rank : int

##Used to determine the card's position in the card manager during battles.
var hand_position

##Determines the card slot that the card has been placed in. This is used for animations
##etc. on the field.
var card_slot_card_is_in : CardSlot

##The position of the card. True if the card is in defence position, false if the card
##is in attack position.
var is_in_defence_position : bool = false

var defeated : bool = false

@export var upper_card_part : UpperCardPart
@export var lower_card_part : LowerCardPart
@onready var _upper_card_sprite: Sprite2D = %UpperCardSprite
@onready var _lower_card_sprite: Sprite2D = %LowerCardSprite
@onready var _type_label: Label = %TypeLabel
@onready var _attack_points_label: Label = %AttackPointsLabel
@onready var _defence_points_label: Label = %DefencePointsLabel
@onready var _attribute_label: Label = %AttributeLabel
@onready var _card_name_label: Label = %CardNameLabel
@onready var _card_rank_label: Label = %CardRankLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export_enum('CREATURE', 'TERRAIN', 'MAGIC', 
	'OPPONENT_CREATURE', 'OPPONENT_MAGIC') var card_supertype : String


##Calculates the final rank of the card based on the combination of its attack and defence points.
func calculate_card_rank() -> void:
	if upper_card_part.attack_points + lower_card_part.defence_points <= 2500:
		card_rank = 1
	elif upper_card_part.attack_points + lower_card_part.defence_points <= 4500:
		card_rank = 2
	elif upper_card_part.attack_points + lower_card_part.defence_points > 4500:
		card_rank = 3
		
	_card_rank_label.text = str(card_rank)


##Calculates the final type of the CombinedCard. If both part types are the same,
##the cardbuilder preview displays a single type.
func calculate_card_type() -> void:
	if upper_card_part.upper_card_type == lower_card_part.lower_card_type:
		_type_label.text = upper_card_part.upper_card_type
	else:
		_type_label.text = upper_card_part.upper_card_type + " " + lower_card_part.lower_card_type
