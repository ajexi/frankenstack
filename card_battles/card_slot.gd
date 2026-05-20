class_name CardSlot extends Node2D

var card_in_slot: bool = false
@export_enum('CREATURE', 'TERRAIN', 'MAGIC', 
	'OPPONENT_CREATURE', 'OPPONENT_MAGIC') var card_slot_type : String
