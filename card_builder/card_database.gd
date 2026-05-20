extends Node

const UPPER_CARD_RESOURCE_PATH : String = "res://cards/card_parts/upper_card_resources/"
const LOWER_CARD_RESOURCE_PATH : String = "res://cards/card_parts/lower_card_resources/"

@export var upper_card_parts : Array[UpperCardPart] = []
@export var lower_card_parts : Array[LowerCardPart] = []

var player_created_cards = []

var test_opponent_deck = []
