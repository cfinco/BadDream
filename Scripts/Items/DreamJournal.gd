extends Item

class_name DreamJournal

var itemName : String
var description : String

func _ready():
	itemName = "Dream Journal"
	description = "An ancient tome chronicling the wild adventures that take place in your subconscious... \nand also your 'naked at school' dreams. Increases your level by 1."
	spritePath = load("res://Sprites/Book_Find.png")
	mapSpritePath = load("res://Sprites/Book_Map.png")
	type = "Booster"

func use(player):
	player.level_up()
	player.xp = 0
	if self in player.inv.get_children():
		player.inv.remove_child(self)
	return null

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	spritePath = item.spritePath
