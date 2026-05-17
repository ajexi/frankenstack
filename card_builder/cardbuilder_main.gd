class_name CardbuilderMain extends Control

const CARDBUILDER_UPPER_PART = preload("uid://de1xoci5e3yrr")
const CARDBUILDER_LOWER_PART = preload("uid://bsvvr7pwgjjr4")
@onready var _upper_part_container: GridContainer = %UpperPartContainer
@onready var _lower_part_container: GridContainer = %LowerPartContainer
@onready var _cardbuilder_card: CardbuilderCard = %CardbuilderCard

func _ready() -> void:
	print("loading parts array")
	print(CardDatabaseManager.upper_card_parts)
	for part : UpperCardPart in CardDatabaseManager.upper_card_parts:
		var new_upper_card_part : CardbuilderUpperPart = CARDBUILDER_UPPER_PART.instantiate()
		new_upper_card_part.upper_card_part = part
		_upper_part_container.add_child(new_upper_card_part)
		new_upper_card_part.upper_part_selected.connect(_upper_part_selected)
	for part in CardDatabaseManager.lower_card_parts:
		var new_lower_card_part : CardbuilderLowerPart = CARDBUILDER_LOWER_PART.instantiate()
		new_lower_card_part.lower_card_part = part
		_lower_part_container.add_child(new_lower_card_part)
		new_lower_card_part.lower_part_selected.connect(_lower_part_selected)
	print("loading parts finished")


func _upper_part_selected(upper_card_part: UpperCardPart) -> void:
	_cardbuilder_card.upper_card_part = upper_card_part
	_cardbuilder_card.update_upper_part_information()
	

func _lower_part_selected(lower_card_part: LowerCardPart) -> void:
	_cardbuilder_card.lower_card_part = lower_card_part
	_cardbuilder_card.update_lower_part_information()
