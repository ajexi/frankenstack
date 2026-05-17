@tool
class_name LowerCardPart extends Resource

##The name of the card part. This will be displayed second in the combined card;
##if the card name is two words, add a space before.
@export var lower_card_name : String = "" :
	set(new_name):
		lower_card_name = new_name
##The card part's creature type. This will be displayed second on the card tooltip.
@export_enum("Angel","Beast","Construct","Demon","Elemental","Fairy","Fish","Humanoid","Insect",
	"Kaiju","Knight","Plant","Reptile","Spellcaster","Spirit","Undead","Vampire") var lower_card_type : String
##The card part's defence points.
@export_range(0, 10000, 50) var defence_points : int
##The card part's image texture.
@export var lower_card_image : Texture = preload("uid://dho2pawq0baia")
