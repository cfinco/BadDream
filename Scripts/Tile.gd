extends Position2D

onready var sprite = $Sprite
onready var litSprite = preload("res://Sprites/Empty_Map.png")
onready var doorSprite = preload("res://Sprites/Door_Map.png")
onready var monsters = $Monsters
var mapPosition = Vector2()
var discovered = false
var loot
var door = false

func discover():
	if hasLoot():
		sprite.texture = loot.mapSpritePath
		if discovered == false:
			loot.discover()
	elif hasMonster():
		sprite.texture = monsters.get_child(0).mapSprite
	elif door == true:
		sprite.texture = doorSprite
	else:
		sprite.texture = litSprite
	discovered = true

func hasLoot() -> bool:
	if loot != null:
		return true
	else:
		return false

func hasMonster() -> bool:
	if monsters.get_children().size() > 0:
		return true
	else:
		return false

func hasPlayer() -> bool:
	if Game.player.map_position == mapPosition:
		return true
	else:
		return false

func removeMonsters():
	for m in monsters.get_children():
		monsters.remove_child(m)
		m.queue_free()

func show():
	sprite.visible = true
func hide():
	sprite.visible = false

func empty() -> bool:
	if hasLoot():
		return false
	elif hasMonster():
		return false
	elif door == true:
		return false
	elif hasPlayer():
		return false
	else:
		return true
