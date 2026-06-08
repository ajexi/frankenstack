class_name DeckbuilderMain extends Control

const CARDBUILDER_CARD = preload('uid://4gewp7uaig5e')
const DECK_SIZE_LIMIT : int = 30

@onready var _card_inventory_container: GridContainer = %CardInventoryContainer
@onready var _player_deck_container: GridContainer = %PlayerDeckContainer
@onready var _deck_amount_label: RichTextLabel = %DeckAmountLabel
@onready var _card_builder_button: Button = %CardBuilderButton
@onready var _go_to_battle_button: Button = %GoToBattleButton
@onready var _add_random_30_button: Button = %AddRandom30Button
@onready var _save_deck_button: Button = %SaveDeckButton
@onready var _deck_name_line_edit: LineEdit = $DeckNameLineEdit

@onready var deck_saver: DecklistSaver = %DeckSaver

func _ready() -> void:
	_reload_card_inventory()
	_reload_player_deck()
	_card_builder_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file('uid://dovn4gh1inc3n'))
	_go_to_battle_button.pressed.connect(func() -> void:
		if CardDatabaseManager.player_created_deck.size() >= DECK_SIZE_LIMIT:
			get_tree().change_scene_to_file("uid://eqqt3ry8xat7")
		else:
			print("fill your deck first!"))
	_add_random_30_button.pressed.connect(func() -> void:
		if CardDatabaseManager.player_created_cards.size() < 30:
			return
		for count in 30:
			var random_card = CardDatabaseManager.player_created_cards.pick_random()
			add_card_to_deck(random_card[0], random_card[1])
			)
	_save_deck_button.pressed.connect(_save_decklist_to_tres_file)


func _reload_card_inventory() -> void:
	for card in _card_inventory_container.get_children():
		card.queue_free()
	for card in CardDatabaseManager.player_created_cards:
		var new_card : CardbuilderCard = CARDBUILDER_CARD.instantiate() 
		new_card.upper_card_part = card[0]
		new_card.lower_card_part = card[1]
		_card_inventory_container.add_child(new_card)
		new_card._upper_card_image.texture = card[0].upper_card_image
		new_card._lower_card_image.texture = card[1].lower_card_image
		new_card.update_upper_part_information()
		new_card.update_lower_part_information()
		new_card.get_node('AddOrRemoveButton').pressed.connect(func() -> void:
			if CardDatabaseManager.player_created_deck.size() < DECK_SIZE_LIMIT:
				add_card_to_deck(new_card.upper_card_part, new_card.lower_card_part)
			else:
				print('Deck Full'))
		
	_deck_amount_label.text = str(CardDatabaseManager.player_created_deck.size()) + '/30'
	

func _reload_player_deck() -> void:
	for card in _player_deck_container.get_children():
		card.queue_free()
	for card in CardDatabaseManager.player_created_deck:
		var new_card : CardbuilderCard = CARDBUILDER_CARD.instantiate() 
		new_card.upper_card_part = card[0]
		new_card.lower_card_part = card[1]
		_player_deck_container.add_child(new_card)
		new_card._upper_card_image.texture = card[0].upper_card_image
		new_card._lower_card_image.texture = card[1].lower_card_image
		new_card.update_upper_part_information()
		new_card.update_lower_part_information()
		new_card.get_node('AddOrRemoveButton').pressed.connect(func() -> void:
			remove_card_from_deck(new_card.upper_card_part, new_card.lower_card_part))
	_deck_amount_label.text = str(CardDatabaseManager.player_created_deck.size()) + '/30'
	for i in 4:
		var blank_button = Button.new()
		blank_button.size = Vector2(250.0 , 250.0)
		blank_button.disabled = true
		_player_deck_container.add_child(blank_button)
	

func add_card_to_deck(upper_card_part, lower_card_part) -> void:
	var card_to_add = [upper_card_part, lower_card_part]
	for card in CardDatabaseManager.player_created_cards:
		if card == card_to_add:
			CardDatabaseManager.player_created_cards.erase(card)
			break
	CardDatabaseManager.player_created_deck.append(card_to_add)
	_reload_card_inventory()
	_reload_player_deck()
	

func remove_card_from_deck(upper_card_part, lower_card_part) -> void:
	var card_to_remove = [upper_card_part, lower_card_part]
	for card in CardDatabaseManager.player_created_deck:
		if card == card_to_remove:
			CardDatabaseManager.player_created_deck.erase(card)
			break
	CardDatabaseManager.player_created_cards.append(card_to_remove)
	_reload_card_inventory()
	_reload_player_deck()


func _save_decklist_to_tres_file() -> void:
	var deck_name = _deck_name_line_edit.text
	if deck_name == null or "":
		return
	
	if ResourceLoader.exists(deck_saver.SAVE_PATH + deck_name + deck_saver.SAVE_EXTENSION):
		deck_saver.saved_deck = ResourceLoader.load(deck_saver.SAVE_PATH + deck_name + deck_saver.SAVE_EXTENSION, "", 
			ResourceLoader.CACHE_MODE_IGNORE)
		deck_saver.saved_deck.deck_list.clear()
	else:
		deck_saver.saved_deck = SavedDeck.new()
	
	for card in CardDatabaseManager.player_created_deck:
		deck_saver.saved_deck.deck_list.append(card)
	deck_saver.save_deck(deck_name)
	
