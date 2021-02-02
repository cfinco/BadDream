extends Item

class_name DecoyDoll

var itemName : String
var description : String

func _ready():
	itemName = "Decoy Doll"
	description = "A cute plush doll. Monsters can't tell it apart from a real person.\nAllows guaranteed escape from battle once."
	spritePath = load("res://Sprites/Doll_Find.png")
	mapSpritePath = load("res://Sprites/Doll_Map.png")
	type = "Battle"

func use(battle, player):
	battle.dialogueBox.changeText(Game.player.player_name + " threw the decoy doll at the " + battle.monsters[0].monster_name + " and fled.\n" + Game.player.player_name + " got away safely!")
	battle.updateStats()
	battle.selectedButton = battle.exitButton
	battle.buttonIndex = -1
	
	if self in player.inv.get_children():
		player.inv.remove_child(self)

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	spritePath = item.spritePath
