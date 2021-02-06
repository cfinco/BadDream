extends Node2D

onready var tilePre = preload("res://Scenes/Tile.tscn")
onready var playerPre = preload("res://Scenes/Player.tscn")

onready var milkPre = preload("res://Scenes/Items/Potions/Milk.tscn")
onready var warmMilkPre = preload("res://Scenes/Items/Potions/WarmMilk.tscn")
onready var dreamPre = preload("res://Scenes/Items/Potions/Dreams.tscn")
onready var sweetPre = preload("res://Scenes/Items/Potions/SweetDreams.tscn")
onready var keyPre = preload("res://Scenes/Items/MiscItems/Key.tscn")

onready var syrupPre = preload("res://Scenes/Items/Antidotes/CoughSyrup.tscn")
onready var incensePre = preload("res://Scenes/Items/Antidotes/Incense.tscn")
onready var coffeePre = preload("res://Scenes/Items/Antidotes/Coffee.tscn")
onready var sheetPre = preload("res://Scenes/Items/Antidotes/DryerSheet.tscn")
onready var bandagePre = preload("res://Scenes/Items/Antidotes/Bandage.tscn")
onready var waterPre = preload("res://Scenes/Items/Antidotes/Water.tscn")

onready var lightPre = preload("res://Scenes/Items/MapItems/NightLight.tscn")
onready var dollPre = preload("res://Scenes/Items/BattleItems/DecoyDoll.tscn")
onready var journalPre = preload("res://Scenes/Items/MiscItems/DreamJournal.tscn")

onready var flashPre = preload("res://Scenes/Items/Weapons/Flashlight.tscn")
onready var darkPre = preload("res://Scenes/Items/Weapons/BlackLight.tscn")
onready var candlePre = preload("res://Scenes/Items/Weapons/Candle.tscn")
onready var megaflashPre = preload("res://Scenes/Items/Weapons/MegaFlashlight.tscn")
onready var laserPre = preload("res://Scenes/Items/Weapons/LaserPointer.tscn")
onready var lighterPre = preload("res://Scenes/Items/Weapons/FlintLighter.tscn")
onready var gunPre = preload("res://Scenes/Items/Weapons/NyarfGun.tscn")
onready var lampPre = preload("res://Scenes/Items/Weapons/Lamp.tscn")
onready var lavaPre = preload("res://Scenes/Items/Weapons/LavaLamp.tscn")
onready var oilPre = preload("res://Scenes/Items/Weapons/OilLamp.tscn")

onready var itemMenu = preload("res://Scenes/Menus/ItemFind.tscn")
onready var battleMenu = preload("res://Scenes/Menus/Battle.tscn")
onready var doorMenu = preload("res://Scenes/Menus/Door.tscn")
onready var gameOverPre = preload("res://Scenes/Menus/GameOver.tscn")

onready var monPre = preload("res://Scenes/Monsters/BasicMonsters/BasicMonster.tscn")
onready var batPre = preload("res://Scenes/Monsters/BasicMonsters/Screamer.tscn")
onready var sleeperPre = preload("res://Scenes/Monsters/BasicMonsters/Sleepwalker.tscn")
onready var teddyPre = preload("res://Scenes/Monsters/BasicMonsters/BigTeddy.tscn")
onready var bedbugPre = preload("res://Scenes/Monsters/BasicMonsters/Bedbug.tscn")
onready var foodPre = preload("res://Scenes/Monsters/StatusMonsters/FoodPuddle.tscn")
onready var phantPre = preload("res://Scenes/Monsters/StatusMonsters/Phantasm.tscn")
onready var sheepPre = preload("res://Scenes/Monsters/StatusMonsters/SleepySheepy.tscn")
onready var terrorPre = preload("res://Scenes/Monsters/StatusMonsters/NightTerror.tscn")
onready var closetPre = preload("res://Scenes/Monsters/MiscMonsters/BoneCloset.tscn")
onready var teethPre = preload("res://Scenes/Monsters/SwarmMonsters/FairyTeeth.tscn")
onready var rugPre = preload("res://Scenes/Monsters/BasicMonsters/RugSlinker.tscn")
onready var dustPre = preload("res://Scenes/Monsters/SwarmMonsters/DustMiteLarge.tscn")
onready var lightningPre = preload("res://Scenes/Monsters/StatusMonsters/LightningBug.tscn")

onready var milkMimicPre = preload("res://Scenes/Items/Mimics/MilkMimic.tscn")
onready var warmMilkMimicPre = preload("res://Scenes/Items/Mimics/WarmMilkMimic.tscn")
onready var dollMimicPre = preload("res://Scenes/Items/Mimics/DollMimic.tscn")

onready var emptySprite = preload("res://Sprites/Empty_Map.png")

signal shock_trigger()
signal game_over()

var mapWidth = 15
var mapHeight = 7
var map = []
var items = []
var monsters = []
var weapons = []

func _ready():
	Game.map = self
	Game.player = playerPre.instance()
	add_child(Game.player)
	create_map(mapWidth, mapHeight)

func create_map(width, height):
	map = []
	for x in range(width):
		map.append([])
		map[x].resize(height)
		
		for y in range(height):
			var tile = tilePre.instance()
			tile.position = Vector2(260 + (100 * x), 160 + (100 * y))
			tile.mapPosition = Vector2(x, y)
			add_child(tile)
			map[x][y] = tile

	randomize()
	var playerPosX = randi() % mapWidth
	var playerPosY = randi() % mapHeight
	Game.player.position = Vector2(260 + (100 * playerPosX), 160 + (100 * playerPosY))
	Game.player.map_position = Vector2(playerPosX, playerPosY)
	
	generateDoor()
	generateKey()
	generateItems()
	generateWeapons()
	generateMonsters()
	
	for row in map:
		for tile in row:
			if tile.empty(): 
				randomize()
				var roll = randi() % 30
				if roll <= 1:
					var itemRoll = randi() % items.size()
					var loot = items[itemRoll].instance()
					tile.loot = loot
					tile.add_child(loot)
				elif roll <= 3:
					var monsterRoll = randi() % monsters.size()
					var monster = monsters[monsterRoll].instance()
					tile.monsters.add_child(monster)
					if monster.monster_class == "Swarm":
						tile.monsters.add_child(monster.copy())
						tile.monsters.add_child(monster.copy())
				elif roll <= 4:
					var itemRoll = randi() % weapons.size()
					var loot = weapons[itemRoll].instance()
					tile.loot = loot
					tile.add_child(loot)

	checkTile()
	updateStats()

func _input(event):
	if Game.inMenu == false:
		if event.is_action_pressed("ui_up") && Game.player.map_position.y > 0:
			Game.player.move(Vector2(0, -1), 1)
			checkTile()
		elif event.is_action_pressed("ui_down") && Game.player.map_position.y < mapHeight - 1:
			Game.player.move(Vector2(0, 1), 1)
			checkTile()
		elif event.is_action_pressed("ui_right") && Game.player.map_position.x < mapWidth - 1:
			Game.player.move(Vector2(1, 0), 1)
			checkTile()
		elif event.is_action_pressed("ui_left") && Game.player.map_position.x > 0:
			Game.player.move(Vector2(-1, 0), 1)
			checkTile()
		elif event.is_action_pressed("ui_use") && Game.player.hasItem():
			if Game.player.inv.get_child(0).type != "Antidote" && Game.player.inv.get_child(0).type != "Battle" || Game.player.inv.get_child(0).type == "Antidote" && Game.player.inv.get_child(0).status == Game.player.status || Game.player.inv.get_child(0).type == "Antidote" && Game.player.inv.get_child(0).status == Game.status.All:
				if Game.player.inv.get_child(0).type != "Potion" && Game.player.inv.get_child(0).type != "Antidote":
					checkStatic()
				Game.player.inv.get_child(0).use(Game.player)
		elif event.is_action_pressed("ui_use_2") && Game.player.inv.get_child_count() == 2:
			if Game.player.inv.get_child(1).type != "Antidote" && Game.player.inv.get_child(1).type != "Battle" || Game.player.inv.get_child(1).type == "Antidote" && Game.player.inv.get_child(1).status == Game.player.status:
				if Game.player.inv.get_child(1).type != "Potion" && Game.player.inv.get_child(1).type != "Antidote":
					checkStatic()
				Game.player.inv.get_child(1).use(Game.player)
		updateStats()
		checkLight()

func checkLight():
	var currentTile = map[Game.player.map_position.x][Game.player.map_position.y]
	
	if Game.illuminated:
		if currentTile.mapPosition.x > 0:
			map[currentTile.mapPosition.x - 1][currentTile.mapPosition.y].discover()
			if currentTile.mapPosition.y > 0:
				map[currentTile.mapPosition.x - 1][currentTile.mapPosition.y - 1].discover()
				map[currentTile.mapPosition.x][currentTile.mapPosition.y - 1].discover()
			if currentTile.mapPosition.y < mapHeight - 1:
				map[currentTile.mapPosition.x - 1][currentTile.mapPosition.y + 1].discover()
				map[currentTile.mapPosition.x][currentTile.mapPosition.y + 1].discover()
		if currentTile.mapPosition.x < mapWidth - 1:
			map[currentTile.mapPosition.x + 1][currentTile.mapPosition.y].discover()
			if currentTile.mapPosition.y > 0:
				map[currentTile.mapPosition.x + 1][currentTile.mapPosition.y - 1].discover()
				map[currentTile.mapPosition.x][currentTile.mapPosition.y - 1].discover()
			if currentTile.mapPosition.y < mapHeight - 1:
				map[currentTile.mapPosition.x + 1][currentTile.mapPosition.y + 1].discover()
				map[currentTile.mapPosition.x][currentTile.mapPosition.y + 1].discover()

func checkStatic():
	if Game.player.status == Game.status.Static:
		Game.player.damage(Game.player.max_hp / 2)
		emit_signal("shock_trigger")
		if(Game.player.hp <= 0):
			emit_signal("game_over")
			queue_free()
		Game.player.status = Game.status.None
		updateStats()

func checkTile():
	var currentTile = map[Game.player.map_position.x][Game.player.map_position.y]
	
	if currentTile.hasLoot():
		Game.tileTemp = currentTile
		Game.inMenu = true
		var popUp = itemMenu.instance()
		add_child(popUp)
	elif currentTile.hasMonster():
		Game.tileTemp = currentTile
		Game.inMenu = true
		var popUp = battleMenu.instance()
		add_child(popUp)
	elif currentTile.door == true:
		Game.tileTemp = currentTile
		Game.inMenu = true
		var popUp = doorMenu.instance()
		add_child(popUp)
		
	if currentTile.discovered == false:
		currentTile.discover()
	

func updateStats():
	if Game.inMenu == false:
		$Stats/Name.text = Game.player.player_name + " the " + Game.player.title
		$Stats/LvLabel.text = "Lv. " + String(Game.player.level)
		$Stats/HpLabel.text = "Hp:" 
		$Stats/HealthBar.visible = true
		if Game.player.status == Game.status.Confusion:
			$Stats/HealthBar.value = $Stats/HealthBar.max_value
			$Stats/HealthBar.modulate = Color(1, 0.5, 1)
			$Stats/HpValue.text = "??/??"
			$Stats/HpValue.add_color_override("font_color", Color(1, 0.5, 1))
			$Stats/HpValue.add_color_override("font_outline_modulate", Color(1, 0.5, 1))
		else:
			$Stats/HealthBar.value = (Game.player.hp * 100) / Game.player.max_hp
			$Stats/BleedBar.value = ((Game.player.hp + Game.player.temp_hp) * 100) / Game.player.max_hp
			$Stats/HealthBar.modulate = Color(1, 1, 1)
			$Stats/HpValue.text = String(Game.player.hp + Game.player.temp_hp) + "/" + String(Game.player.max_hp)
			$Stats/HpValue.add_color_override("font_color", Color(1, 1, 1))
			$Stats/HpValue.add_color_override("font_outline_modulate", Color(1, 1, 1))
		$Stats/XpLabel.text = "Exp:"
		$Stats/XpBar.visible = true
		$Stats/XpBar.value = (Game.player.xp * 100) / Game.player.xp_to_next_lv
		$Stats/XpValue.text = String(Game.player.xp) + "/" + String(Game.player.xp_to_next_lv)
		if Game.player.hasWeapon():
			var wep = Game.player.weapon.get_child(0)
			$Inventory/Weapon.texture = wep.spritePath
			$Stats/StatValues.text = "Attack: " + String(Game.player.atk + Game.player.weapon.get_child(0).atkMod) + "     Speed: " + String(Game.player.spd - Game.player.weapon.get_child(0).spdMod) + "     Luck: " + String(Game.player.luck)
			$ColorRect3/WAtkLabel.text = "Atk"
			$ColorRect3/WAtk.text = String(Game.player.weapon.get_child(0).atkMod)
			$ColorRect3/WSpdLabel.text = "Spd"
			$ColorRect3/WSpd.text = "-" + String(Game.player.weapon.get_child(0).spdMod)
		else:
			$Inventory/Weapon.texture = null
			$Stats/StatValues.text = "Attack: " + String(Game.player.atk) + "     Speed: " + String(Game.player.spd) + "     Luck: " + String(Game.player.luck)
			$ColorRect3/WAtkLabel.text = ""
			$ColorRect3/WAtk.text = ""
			$ColorRect3/WSpdLabel.text = ""
			$ColorRect3/WSpd.text = ""
		$FloorLabel.text = "Floor: " + String(Game.level)
		
		if Game.player.hasItem():
			var inv1 = Game.player.inv.get_child(0)
			$Inventory/Item.texture = inv1.spritePath
			if Game.player.inv.get_child_count() > 1:
				var inv2 = Game.player.inv.get_child(1)
				$Inventory/Item2.texture = inv2.spritePath
			else:
				$Inventory/Item2.texture = null
		else:
			$Inventory/Item.texture = null
		
		if Game.player.key == true:
			$Inventory/Key.visible = true
		else:
			$Inventory/Key.visible = false
		
		match Game.player.status:
			Game.status.None:
				$Stats/Status.text = ""
			Game.status.Poison:
				$Stats/Status.text = "Poisoned"
				$Stats/Status.add_color_override("font_color", Color(0.5, 0.7, 0))
				$Stats/Status.add_color_override("font_outline_modulate", Color(0.5, 0.7, 0))
			Game.status.Confusion:
				$Stats/Status.text = "Confusion"
				$Stats/Status.add_color_override("font_color", Color(1, 0.5, 1))
				$Stats/Status.add_color_override("font_outline_modulate", Color(1, 0.5, 1))
			Game.status.Drowsy:
				$Stats/Status.text = "Drowsy"
				$Stats/Status.add_color_override("font_color", Color(0.7, 0.5, 1))
				$Stats/Status.add_color_override("font_outline_modulate", Color(0.7, 0.5, 1))
			Game.status.Static:
				$Stats/Status.text = "Static"
				$Stats/Status.add_color_override("font_color", Color(1, 1, 0.2))
				$Stats/Status.add_color_override("font_outline_modulate", Color(1, 1, 0.2))
			Game.status.Bleed:
				$Stats/Status.text = "Bleed"
				$Stats/Status.add_color_override("font_color", Color(0.8, 0, 0))
				$Stats/Status.add_color_override("font_outline_modulate", Color(0.8, 0, 0))
	else:
		$Stats/Name.text = ""
		$Stats/LvLabel.text = ""
		$Stats/HpLabel.text = ""
		$Stats/XpLabel.text = ""
		$Stats/HealthBar.visible = false
		$Stats/HpValue.text = ""
		$Stats/XpBar.visible = false
		$Stats/XpValue.text = ""
		$Stats/StatValues.text = ""
		$ColorRect3/WAtkLabel.text = ""
		$ColorRect3/WAtk.text = ""
		$ColorRect3/WSpdLabel.text = ""
		$ColorRect3/WSpd.text = ""
		$FloorLabel.text = ""
		$Stats/Status.text = ""

func generateDoor():
	randomize()
	var doorX = randi() % mapWidth
	var doorY = randi() % mapHeight
	
	if map[doorX][doorY].empty():
		map[doorX][doorY].door = true
	else:
		generateDoor()

func generateKey():
	randomize()
	var keyX = randi() % mapWidth
	var keyY = randi() % mapHeight
	
	if map[keyX][keyY].empty():
		var key = keyPre.instance()
		map[keyX][keyY].loot = key
		map[keyX][keyY].add_child(key)
	else:
		generateKey()

func generateItems():
	items = []
	for i in range(30):
		items.append(milkPre)
	for i in range(20):
		items.append(warmMilkPre)
	for i in range(10):
		items.append(dreamPre)
	for i in range(2):
		items.append(sweetPre)
	for i in range(5):
		items.append(syrupPre)
	for i in range(5):
		items.append(incensePre)
	for i in range(5):
		items.append(coffeePre)
	for i in range(5):
		items.append(sheetPre)
	for i in range(5):
		items.append(bandagePre)
	for i in range(2):
		items.append(waterPre)
	for i in range(4):
		items.append(lightPre)
	for i in range(10):
		items.append(dollPre)
	for i in range(1):
		items.append(journalPre)
	for i in range(1):
		items.append(milkMimicPre)
	for i in range(1):
		items.append(warmMilkMimicPre)
	for i in range(1):
		items.append(dollMimicPre)

func generateWeapons():
	for i in range(5):
		weapons.append(flashPre)
	for i in range(5):
		weapons.append(darkPre)
	for i in range(5):
		weapons.append(candlePre)
	for i in range(5):
		weapons.append(megaflashPre)
	for i in range(5):
		weapons.append(laserPre)
	for i in range(5):
		weapons.append(lighterPre)
	for i in range(5):
		weapons.append(gunPre)
	for i in range(5):
		weapons.append(lampPre)
	for i in range(5):
		weapons.append(lavaPre)
	for i in range(5):
		weapons.append(oilPre)

func generateMonsters():
	monsters = []
	for i in range(20):
		monsters.append(monPre)
	for i in range(15):
		monsters.append(batPre)
	for i in range(10):
		monsters.append(sleeperPre)
	for i in range(5):
		monsters.append(rugPre)
	for i in range(2):
		monsters.append(teddyPre)
	for i in range(1):
		monsters.append(bedbugPre)
	for i in range(3):
		monsters.append(foodPre)
	for i in range(3):
		monsters.append(phantPre)
	for i in range(3):
		monsters.append(sheepPre)
	for i in range(3):
		monsters.append(terrorPre)
	for i in range(3):
		monsters.append(closetPre)
	for i in range(3):
		monsters.append(teethPre)
	for i in range(2):
		monsters.append(dustPre)
	for i in range(3):
		monsters.append(lightningPre)

func _on_Map_game_over():
	var popup = gameOverPre.instance()
	get_parent().add_child(popup)

func shockTrigger():
	emit_signal("shock_trigger")
