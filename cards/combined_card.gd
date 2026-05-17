@tool
class_name CombinedCard extends Node2D

signal hovered
signal hovered_off

##Used to determine the card's position in the card manager during battles.
var hand_position

##Calculated based on the ATK/DEF points of the combined card.
var card_rank : int

@export var upper_card_part : UpperCardPart
@export var lower_card_part : LowerCardPart
@onready var _upper_card_sprite: Sprite2D = %UpperCardSprite
@onready var _lower_card_sprite: Sprite2D = %LowerCardSprite
@onready var _type_label: Label = %TypeLabel
@onready var _attack_points_label: Label = %AttackPointsLabel
@onready var _defence_points_label: Label = %DefencePointsLabel
@onready var _attribute_label: Label = %AttributeLabel
@onready var _card_name_label: Label = %CardNameLabel
@onready var _collision_area: Area2D = %CollisionArea
@onready var _card_rank_label: Label = %CardRankLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	_upper_card_sprite.texture = upper_card_part.upper_card_image
	_lower_card_sprite.texture = lower_card_part.lower_card_image
	_type_label.text = upper_card_part.upper_card_type + " " + lower_card_part.lower_card_type
	_attack_points_label.text = str(upper_card_part.attack_points)
	_defence_points_label.text = str(lower_card_part.defence_points)
	_attribute_label.text = str(upper_card_part.attribute)
	_card_name_label.text = upper_card_part.upper_part_name + lower_card_part.lower_card_name
	
	if upper_card_part.attack_points + lower_card_part.defence_points <= 2000:
		card_rank = 1
	elif upper_card_part.attack_points + lower_card_part.defence_points >= 3000:
		card_rank = 2
	elif upper_card_part.attack_points + lower_card_part.defence_points >= 4000:
		card_rank = 3
	_card_rank_label.text = str(card_rank)
	
	_collision_area.mouse_entered.connect(_on_mouse_entered)
	_collision_area.mouse_exited.connect(_on_mouse_exited)
	
	if Engine.is_editor_hint():#
		return
	get_parent().connect_card_signals(self)


func _on_mouse_entered() -> void:
	hovered.emit(self)


func _on_mouse_exited() -> void:
	hovered_off.emit(self)
