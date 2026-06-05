@tool
class_name UpperCardPart extends Resource

##The first part of the card name.
@export var upper_part_name : String = ""
##The card's attribute. This affects synergies.
@export_enum("FIRE", "WATER", "EARTH", "AIR", "METAL", "VOID", "AURA") var attribute : String
##The card part's creature type. This will be displayed first on the card tooltip.
@export_enum("Angel","Beast","Construct","Demon","Elemental","Fairy","Fish","Humanoid","Insect",
	"Kaiju","Knight","Plant","Reptile","Spellcaster","Spirit","Undead","Vampire") var upper_card_type : String
##The attack points of the card part.
@export_range(0, 10000, 50) var attack_points : int
##The card part's image texture.
@export var upper_card_image : Texture = preload("uid://b5wv600nibtc8")
##The final CombinedCard supertype.
@export_enum("CREATURE", "MAGIC", "TERRAIN") var combined_card_supertype : String
