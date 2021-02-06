extends Position2D

onready var inv = $Inventory
onready var weapon = $Weapon
onready var battleSprite = preload("res://Sprites/Player_Battle.png")

var player_name : String = "Kiddo"
var title : String = "Cool"
var status = Game.status.None

var hp : int
var max_hp : int
var temp_hp : int
var atk : int
var spd : int
var luck : int

var xp : int
var xp_to_next_lv : int
var level : int

var map_position : Vector2
var key = false


# Called when the node enters the scene tree for the first time.
func _ready():
	max_hp = 30
	hp = max_hp
	temp_hp = 0
	atk = 10
	spd = 50
	luck = 0
	xp = 0 
	xp_to_next_lv = 5
	level = 1

func attack(target, modifier):
	if hasWeapon() &&  weapon.get_child(0).weaponType == target.weakness:
		target.damage(getPower() * weapon.get_child(0).typeMult * modifier)
	else:
		target.damage(getPower() * modifier)

func damage(amount : int):
	if temp_hp > 0:
		if amount > temp_hp:
			hp -= (amount - temp_hp)
			temp_hp = 0
			if hp < 0:
				hp = 0
		else:
			temp_hp -= amount
	else:
		hp -= amount
		if hp < 0:
			hp = 0

func heal(amount : int):
	if status != Game.status.Bleed:
		hp += amount
		if hp > max_hp:
			hp = max_hp
	else:
		hp += amount * 0.25
		if hp > max_hp:
			hp = max_hp
		else:
			temp_hp += amount * 0.75
			if hp + temp_hp > max_hp:
				temp_hp = max_hp - hp

func move(direction : Vector2, distance : int):
	if direction.x > 0:
		$Sprite.flip_h = false
	elif direction.x < 0:
		$Sprite.flip_h = true
	map_position += (direction * distance)
	position += direction * distance * 100

func level_up():
	level += 1
	if level % 3 == 0:
		max_hp += 25
		heal(max_hp)
	else:
		max_hp += 10
		heal(10)
	
	atk += 5
	spd += 10
	if level % 2 == 0:
		luck += 1
	
	xp -= xp_to_next_lv
	xp_to_next_lv = 5 * (level) * (level)

func award_xp(amount):
	xp += amount
	check_xp()

func check_xp():
	if xp >= xp_to_next_lv:
		level_up()
		check_xp()

func stow(loot, index):
	var returnItem
	if index != -1:
		returnItem = inv.get_child(index)
		inv.remove_child(returnItem)
		inv.add_child(loot)
		inv.move_child(loot, index)
	else:
		inv.add_child(loot)
	return returnItem

func hasItem():
	if inv.get_child_count() > 0:
		return true
	else:
		return false

func hasWeapon():
	if weapon.get_child_count() > 0:
		return true
	else:
		return false

func getPower():
	if hasWeapon():
		return atk + weapon.get_child(0).atkMod
	else:
		return atk

func getSpeed():
	if hasWeapon():
		return spd - weapon.get_child(0).spdMod
	else:
		return spd
