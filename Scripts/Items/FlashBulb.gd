extends Item

class_name FlashBulb

var itemName : String
var description : String

func _ready():
	itemName = "Flash Bulb"
	description = "A busted light bulb that explodes in a flash of light when turned on. \nDeals lots of damage to all monsters in battle once."
	spritePath = load("res://Sprites/Bulb_Find.png")
	mapSpritePath = load("res://Sprites/Bulb_Map.png")
	type = "Battle"

func use(battle, player):
	battle.dialogueBox.changeText(Game.player.player_name + " used the flash bulb!")
	for m in battle.monsters:
		battle.attackMonster(m, 3)
	battle.emit_signal("flash_trigger")
	battle.updateStats()
	battle.buttonIndex = 2
	battle.selectedButton = battle.buttons[2]
	battle.selector.visible = false
	battle.checkVictory()
	if self in player.inv.get_children():
		player.inv.remove_child(self)

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	spritePath = item.spritePath
