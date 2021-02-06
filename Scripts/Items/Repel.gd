extends Item

class_name Repel

var itemName : String
var description : String

func _ready():
	itemName = "Monster B Gone"
	description = 'A spray bottle of "high grade monster repellent" from the dollar store.\nClears the floor of one type of monster.'
	spritePath = load("res://Sprites/Repel_Find.png")
	mapSpritePath = load("res://Sprites/Repel_Map.png")
	type = "Battle"

func use(battle, player):
	battle.dialogueBox.changeText(Game.player.player_name + " sprayed the Monster B Gone at the " + battle.monsters[0].monster_name + "! All " + battle.monsters[0].monster_name + "s were cleared from the floor!")
	battle.get_parent().clearMonsters(battle.monsters[0])
	if self in player.inv.get_children():
		player.inv.remove_child(self)
	battle.updateStats()
	battle.selectedButton = battle.exitButton
	battle.buttonIndex = -1

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	spritePath = item.spritePath
