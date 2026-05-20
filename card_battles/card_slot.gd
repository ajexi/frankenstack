class_name CardSlot extends Node2D

var card_in_slot: bool = false
@onready var collision_area: Area2D = %CollisionArea
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

@export_enum('CREATURE', 'TERRAIN', 'MAGIC', 
	'OPPONENT_CREATURE', 'OPPONENT_MAGIC') var card_slot_type : String
