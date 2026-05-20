class_name CardbuilderMain extends Control

const CARDBUILDER_UPPER_PART = preload("uid://de1xoci5e3yrr")
const CARDBUILDER_LOWER_PART = preload("uid://bsvvr7pwgjjr4")
@onready var _upper_part_container: GridContainer = %UpperPartContainer
@onready var _lower_part_container: GridContainer = %LowerPartContainer
@onready var _cardbuilder_card: CardbuilderCard = %CardbuilderCard
@onready var _build_card_button: Button = %BuildCardButton
@onready var _battle_button: Button = %BattleButton
@onready var _build_10_cards_button: Button = $Build10CardsButton

func _ready() -> void:
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
	
	_build_card_button.pressed.connect(build_card)
	_build_10_cards_button.pressed.connect(build_ten_cards)
	_battle_button.pressed.connect(func() -> void:
		if CardDatabaseManager.player_created_cards != []:
			get_tree().change_scene_to_file("uid://eqqt3ry8xat7")
		else:
			print("build some cards first!"))


func _upper_part_selected(upper_card_part: UpperCardPart) -> void:
	_cardbuilder_card.upper_card_part = upper_card_part
	_cardbuilder_card.update_upper_part_information()
	

func _lower_part_selected(lower_card_part: LowerCardPart) -> void:
	_cardbuilder_card.lower_card_part = lower_card_part
	_cardbuilder_card.update_lower_part_information()


func build_card() -> void:
	if _cardbuilder_card.upper_card_part != null and _cardbuilder_card.lower_card_part != null:
		var combined_card = [_cardbuilder_card.upper_card_part,_cardbuilder_card.lower_card_part]
		CardDatabaseManager.player_created_cards.append(combined_card)
		CardDatabaseManager.test_opponent_deck.append(combined_card)
		print("card built!")
	else:
		print("a card needs two parts!")

func build_ten_cards() -> void:
	for i in 10:
		build_card()
