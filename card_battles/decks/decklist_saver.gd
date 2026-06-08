class_name DecklistSaver extends Node

const SAVE_PATH : String = "res://card_battles/decks/"
const SAVE_EXTENSION : String = ".tres"

var saved_deck : SavedDeck 


func save_deck(deck_name : String) -> void:
	var error_code := ResourceSaver.save(saved_deck, SAVE_PATH + deck_name + SAVE_EXTENSION)
	if error_code != OK:
		push_error("Failed to save deck to file: " + error_string(error_code))
