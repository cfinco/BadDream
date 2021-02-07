extends Node2D

onready var buttons = $Buttons.get_children()
onready var dialogueBox = $DialogueBox/RichTextLabel
onready var selector = $Selector
onready var inv = $Inv.get_children()
onready var exitButton = $ExitButton
onready var shockEffect = $ShockEffect
onready var bleedBar = $PlayerStats/Health/BleedBar
onready var health = $EnemyStats/HealthBars/Health

onready var gameOverPre = preload("res://Scenes/Menus/GameOver.tscn")
onready var enemyPosPre = preload("res://Scenes/Resources/EnemyPos.tscn")

var selectedButton
var selectedFoe
var selectedItem

var buttonIndex = 0
var foeIndex = 0
var itemIndex = 0

var earnedXp = 0

var monsters = []
var formation = [Vector2(1280, 448), Vector2(1576, 506), Vector2(1380, 650), Vector2(1280, 420)]

signal health_changed(health, maxHealth, tempHealth)
signal health_obscured()
signal enemy_health_changed(health, maxHealth, index)
signal game_over()
signal shock_trigger()
signal flash_trigger()

func _ready():
	for m in range(Game.tileTemp.monsters.get_child_count()):
		monsters.append(Game.tileTemp.monsters.get_child(m))
		monsters[m].position = formation[m]
		monsters[m].sprite.visible = true
		
		$EnemyStats/HealthBars.get_child(m).visible = true
		$EnemyStats/HealthBars.get_child(m).index = m
		$EnemyStats/HealthBars.get_child(m).start()
	selectedButton = buttons[0]
	if monsters[0].monster_class == "Swarm":
		dialogueBox.changeText("A swarm of " + monsters[0].monster_name + " attacked!")
	else:
		dialogueBox.changeText("A " + monsters[0].monster_name + " attacked!")
	$PlayerStats/Name.text = Game.player.player_name
	$EnemyStats/Name.text = monsters[0].monster_name
	$PlayerStats/Health.start()
	if Game.player.status == Game.status.Poison:
		$PoisonTimer.start()
	elif Game.player.status == Game.status.Bleed:
		$BleedTimer.start()
	
	buttons[0].changeText("Fight!")
	buttons[1].changeText("Inspect!")
	buttons[2].changeText("Use Item!")
	buttons[3].changeText("Flee!")
	updateStats()

func _process(delta):
	if dialogueBox.textScrolled():
		if buttonIndex >= 0:
			exitButton.visible = false
			for b in buttons:
				b.visible = true
				b.color = Color(0.2, 0.2, 0.2)
			if Game.player.status == Game.status.Paralysis:
				buttons[3].disabled = true
				buttons[3].color = Color(0.5, 0.5, 0.5)
			else:
				buttons[3].disabled = false
				buttons[3].color = Color(0.2, 0.2, 0.2)
		elif buttonIndex == -1:
			exitButton.visible = true
			for b in buttons:
				b.visible = false
				b.color = Color(0.2, 0.2, 0.2)
		selectedButton.color = Color(0.9, 0.8, 0)
	var clear = true
	for m in monsters:
		if m != null:
			clear = false
	if clear == true:
		monsters = []

func _input(event):
	if dialogueBox.textScrolled():
		if event.is_action_pressed("ui_left"):
			if buttonIndex >= 0:
				selectButton(-1)
			elif buttonIndex == -2 || buttonIndex == -4:
				selectFoe(-1)
			elif buttonIndex == -3:
				selectItem()
		elif event.is_action_pressed("ui_right"):
			if buttonIndex >= 0:
				selectButton(1)
			elif buttonIndex == -2 || buttonIndex == -4:
				selectFoe(1)
			elif buttonIndex == -3:
				selectItem()
		elif event.is_action_pressed("ui_accept"):
			match buttonIndex:
				-4:
					for b in buttons:
						b.visible = false
					inspect(foeIndex)
					buttonIndex = 1
					selector.visible = false
					updateStats()
				-3:
					useItem(itemIndex)
				-2:
					if(selectedFoe.defeated != true):
						doBattle(selectedFoe)
						checkVictory()
				-1:
					if Game.player.status == Game.status.Paralysis:
						Game.player.status = Game.status.None
					if monsters.size() > 0:
						for m in monsters:
							m.sprite.visible = false
					Game.inMenu = false
					Game.tileTemp.discover()
					queue_free()
				0:
					if selectedButton.disabled == false:
						if monsters.size() <= 1:
							doBattle(monsters[0])
							checkVictory()
						elif Game.player.hasWeapon() && Game.player.weapon.get_child(0).aoe == true:
							battleAll()
							checkVictory()
						else:
							summonSelector("Monsters")
							buttonIndex = -2
				1:
					if selectedButton.disabled == false:
						if monsters.size() <= 1:
							for b in buttons:
								b.visible = false
							inspect(0)
							updateStats()
						else:
							summonSelector("Monsters")
							buttonIndex = -4
				2:
					if selectedButton.disabled == false:
						if Game.player.inv.get_child_count() > 0:
							summonSelector("Items")
							buttonIndex = -3
				3:
					if selectedButton.disabled == false:
						flee()
		elif event.is_action_pressed("ui_back") && buttonIndex <= -2:
			inv[0].texture = null
			inv[1].texture = null
			inv[0].value.text = ""
			inv[1].value.text = ""
			buttonIndex = 0
			selectedButton = buttons[0]
			selector.visible = false
			

func flee():
	for m in monsters:
		if m.spd >= Game.player.getSpeed() && m.defeated == false:
			if Game.player.hp > 1:
				m.attack(Game.player, true)
			else:
				m.attack(Game.player, false)
			if Game.player.status == Game.status.Paralysis:
				dialogueBox.changeText(Game.player.player_name + " tried to flee, but the " + m.monster_name + " was too fast and caught them!\n" + Game.player.player_name + " became petrified with fear!")
			else:
				dialogueBox.changeText(Game.player.player_name + " fled, but the " + m.monster_name + " was too fast and got a hit in!")
			if(Game.player.hp <= 0):
				emit_signal("game_over")
				queue_free()
		else:
			dialogueBox.changeText(Game.player.player_name + " got away without a scratch.")
	
	updateStats()
	
	for b in buttons:
		b.visible = false
	
	if Game.player.status == Game.status.Paralysis:
		selectedButton = buttons[0]
		buttonIndex = 0
	else:
		selectedButton = exitButton
		buttonIndex = -1

func doBattle(target):
	dialogueBox.changeText("")
	var prevStatus = Game.player.status

	for m in monsters:
		if m.defeated == false && m.spd > Game.player.getSpeed():
			m.attack(Game.player, false)

	if rollDrowsy():
		dialogueBox.changeText("")
		dialogueBox.addColorText(Game.player.player_name + " dozed off!", Color(0.7, 0.5, 1))
	else:
		attackMonster(target, 1)

	for m in monsters:
		if m.defeated == false && m.spd <= Game.player.getSpeed():
			m.attack(Game.player, false)

	if prevStatus != Game.player.status:
		match Game.player.status:
			Game.status.Poison:
				dialogueBox.changeText(Game.player.player_name + " was poisoned!")
				$PoisonTimer.start()
				$PlayerStats/Status.text = "Poisoned"
			Game.status.Confusion:
				dialogueBox.changeText(Game.player.player_name + " became confused!")
				$PlayerStats/Status.text = "Confusion"
			Game.status.Paralysis:
				dialogueBox.changeText(Game.player.player_name + " became petrified with terror!")
				$PlayerStats/Status.text = "Sleep\nParalysis"
			Game.status.Drowsy:
				dialogueBox.changeText(Game.player.player_name + " became drowsy! They may doze off in battle!")
				$PlayerStats/Status.text = "Drowsy"
			Game.status.Static:
				dialogueBox.changeText(Game.player.player_name + " became charged with static! Touching items will shock them!")
				$PlayerStats/Status.text = "Static"
			Game.status.Bleed:
				dialogueBox.changeText(Game.player.player_name + " started bleeding! Most healing will leak away!")
				$PlayerStats/Status.text = "Bleed"
				$BleedTimer.start()
	buttonIndex = 0
	if(Game.player.hp <= 0):
		emit_signal("game_over")
		queue_free()
	selector.visible = false
	updateStats()

func battleAll():
	dialogueBox.changeText("")
	var prevStatus = Game.player.status

	for m in monsters:
		if m.defeated == false && m.spd > Game.player.spd:
			m.attack(Game.player, false)

	if rollDrowsy():
		dialogueBox.changeText("")
		dialogueBox.addColorText(Game.player.player_name + " dozed off!", Color(0.7, 0.5, 1))
	else:
		for m in monsters:
			attackMonster(m, 1)

	for m in monsters:
		if m.defeated == false && m.spd < Game.player.spd:
			m.attack(Game.player, false)

	if prevStatus != Game.player.status:
		match Game.player.status:
			Game.status.Poison:
				dialogueBox.changeText(Game.player.player_name + " was poisoned!")
				$PoisonTimer.start()
				$PlayerStats/Status.text = "Poisoned"
			Game.status.Confusion:
				dialogueBox.changeText(Game.player.player_name + " became confused!")
				$PlayerStats/Status.text = "Confusion"
			Game.status.Paralysis:
				dialogueBox.changeText(Game.player.player_name + " became petrified with terror!")
				$PlayerStats/Status.text = "Sleep\nParalysis"
			Game.status.Drowsy:
				dialogueBox.changeText(Game.player.player_name + " became drowsy! They may doze off in battle!")
				$PlayerStats/Status.text = "Drowsy"
			Game.status.Static:
				dialogueBox.changeText(Game.player.player_name + " became charged with static! Using items will hurt!")
				$PlayerStats/Status.text = "Static"
			Game.status.Bleed:
				dialogueBox.changeText(Game.player.player_name + " started bleeding! Most healing will leak away!")
				$PlayerStats/Status.text = "Bleed"
	buttonIndex = 0
	if(Game.player.hp <= 0):
		emit_signal("game_over")
		queue_free()
	selector.visible = false
	updateStats()

func attackMonster(target, modifier):
	Game.player.attack(target, modifier)
	if Game.player.hasWeapon() && Game.player.weapon.get_child(0).weaponType == target.weakness && Game.player.weapon.get_child(0).weaponType != "None":
		$EnemyStats/Animator.stop()
		$EnemyStats/Animator.play("Crit")
	if target.hp <= 0:
		target.defeated = true
		awardXp(target)
		target.sprite.visible = false

func rollDrowsy():
	if Game.player.status != Game.status.Drowsy:
		return false
	else:
		randomize()
		var roll = randi() % 5
		if roll == 0:
			return true
		else:
			return false

func inspect(target):
	if Game.player.status == Game.status.Confusion:
		dialogueBox.push_color(Color(1, 0.5, 1))
		dialogueBox.changeText("")
		dialogueBox.addColorText("The heck is that!?", Color(1, 0.5, 1))
	else:
		if monsters[target].weakness != "None":
			dialogueBox.changeText(monsters[target].description + "\nAtk: " + str(monsters[target].atk) + ", Spd: " + str(monsters[target].spd) + ". Weak to " + monsters[target].weakness + " Damage.")
		else:
			dialogueBox.changeText(monsters[target].description + "\nAtk: " + str(monsters[target].atk) + ", Spd: " + str(monsters[target].spd))

func checkVictory():
	if allMonstersDefeated():
		if rollSpawn(monsters[0]):
			var index = 0
			var children = monsters[0].childFormation.duplicate()
			Game.tileTemp.removeMonsters()
			monsters = []
			for m in children:
				var childPre = load(m)
				var newMonster = childPre.instance()
				Game.tileTemp.monsters.add_child(newMonster)
				monsters.append(newMonster)
				newMonster.position = formation[index]
				newMonster.sprite.visible = true
					
				$EnemyStats/HealthBars.get_child(index).visible = true
				$EnemyStats/HealthBars.get_child(index).index = index
				$EnemyStats/HealthBars.get_child(index).start()
				emit_signal("enemy_health_changed", monsters[index].hp, monsters[index].max_hp, index)
				
				dialogueBox.changeText("A " + newMonster.monster_name + " appeared!")
				
				for b in buttons:
					b.visible = false
					
				index += 1
			monsters[0].activated = true
			updateStats()
		else:
			if Game.player.xp + earnedXp >= Game.player.xp_to_next_lv:
				dialogueBox.changeText(Game.player.player_name + " won the battle!" + "\n" + Game.player.player_name + " got " + String(earnedXp) + " exp! " + Game.player.player_name + " leveled up!")
			else:
				dialogueBox.changeText(Game.player.player_name + " won the battle!" + "\n" + Game.player.player_name + " got " + String(earnedXp) + " exp!")
			Game.player.award_xp(earnedXp)
			
			for b in buttons:
				b.visible = false
			
			selectedButton = exitButton
			buttonIndex = -1
			
			Game.tileTemp.removeMonsters()
			monsters = []
			updateStats()

func updateStats():
	if Game.player.status == Game.status.Confusion:
		$PlayerStats/Hp.text = "??/??"
		emit_signal("health_obscured")
	else:
		$PlayerStats/Hp.text = String(Game.player.hp + Game.player.temp_hp) + "/" + String(Game.player.max_hp)
		emit_signal("health_changed", Game.player.hp, Game.player.max_hp, Game.player.temp_hp)
	
	if Game.player.hasWeapon():
		$PlayerStats/Atk/Label.text = "Atk: " + String(Game.player.atk + Game.player.weapon.get_child(0).atkMod)
		$PlayerStats/Spd/Label.text = "Spd: " + String(Game.player.spd - Game.player.weapon.get_child(0).spdMod)
	else:
		$PlayerStats/Atk/Label.text = "Atk: " + String(Game.player.atk)
		$PlayerStats/Spd/Label.text = "Spd: " + String(Game.player.spd)
	
	match Game.player.status:
		Game.status.None:
			$PlayerStats/Status.text = ""
			if !$PoisonTimer.is_stopped():
				$PoisonTimer.stop()
		Game.status.Poison:
			$PlayerStats/Status.text = "Poisoned"
			$PlayerStats/Status.add_color_override("font_color", Color(0.5, 0.7, 0))
			$PlayerStats/Status.add_color_override("font_outline_modulate", Color(0.5, 0.7, 0))
		Game.status.Confusion:
			$PlayerStats/Status.text = "Confusion"
			$PlayerStats/Status.add_color_override("font_color", Color(1, 0.5, 1))
			$PlayerStats/Status.add_color_override("font_outline_modulate", Color(1, 0.5, 1))
		Game.status.Paralysis:
			$PlayerStats/Status.text = "Sleep\nParalysis"
			$PlayerStats/Status.add_color_override("font_color", Color(1, 0.9, 0.2))
			$PlayerStats/Status.add_color_override("font_outline_modulate", Color(1, 0.9, 0.2))
		Game.status.Drowsy:
			$PlayerStats/Status.text = "Drowsy"
			$PlayerStats/Status.add_color_override("font_color", Color(0.7, 0.5, 1))
			$PlayerStats/Status.add_color_override("font_outline_modulate", Color(0.7, 0.5, 1))
		Game.status.Static:
			$PlayerStats/Status.text = "Static"
			$PlayerStats/Status.add_color_override("font_color", Color(1, 1, 0.2))
			$PlayerStats/Status.add_color_override("font_outline_modulate", Color(1, 1, 0.2))
		Game.status.Bleed:
			$PlayerStats/Status.text = "Bleed"
			$PlayerStats/Status.add_color_override("font_color", Color(0.8, 0, 0))
			$PlayerStats/Status.add_color_override("font_outline_modulate", Color(0.8, 0, 0))
	if monsters.size() > 0:
		$EnemyStats/Name.text = monsters[0].monster_name
		$EnemyStats/Hp.text = String(monsters[0].hp) + "/" + String(monsters[0].max_hp)
		for m in range(monsters.size()):
			$EnemyStats/HealthBars.get_child(m).visible = true
			emit_signal("enemy_health_changed", monsters[m].hp, monsters[m].max_hp, m)

func awardXp(monster):
	var xpToAward = monster.xp_award + (5 * (monster.level - Game.player.level))
	if xpToAward > monster.xp_award:
		earnedXp += xpToAward
	else:
		earnedXp += monster.xp_award

func _on_game_over():
	var popup = gameOverPre.instance()
	get_parent().add_child(popup)

func allMonstersDefeated() -> bool:
	for m in monsters:
		if m.defeated == false:
			return false
	return true

func selectButton(direction):
	selectedButton.color = Color(0.2, 0.2, 0.2)
	if buttonIndex <= 0 && direction < 0:
		buttonIndex = buttons.size() - 1 
	elif buttonIndex >= buttons.size() - 1 && direction > 0:
		buttonIndex = 0
	else:
		buttonIndex = buttonIndex + direction
	selectedButton = buttons[buttonIndex]
	selectedButton.color = Color(0.9, 0.8, 0)
	
	if selectedButton.disabled == true:
		selectButton(direction)

func selectFoe(direction):
	if foeIndex <= 0 && direction < 0:
		foeIndex = monsters.size() - 1 
	elif foeIndex >= monsters.size() - 1 && direction > 0:
		foeIndex = 0
	else:
		foeIndex = foeIndex + direction
	selectedFoe = monsters[foeIndex]
	
	selector.position = monsters[foeIndex].anchor.global_position 
	$EnemyStats/Hp.text = String(monsters[foeIndex].hp) + "/" + String(monsters[foeIndex].max_hp)
	if selectedFoe.defeated == true:
		selectFoe(direction)

func useItem(index):
	match Game.player.inv.get_child(index).type:
		"Antidote":
			if Game.player.inv.get_child(itemIndex).status == Game.player.status || Game.player.inv.get_child(itemIndex).status == Game.status.All:
				for b in buttons:
					b.visible = false
				dialogueBox.changeText(Game.player.player_name + " used the " + Game.player.inv.get_child(index).itemName + ".\n" + Game.player.player_name + " was cured of " + Game.player.inv.get_child(index).statusName + ".")
				Game.player.inv.get_child(index).use(Game.player)
				inv[0].texture = null
				inv[1].texture = null
				inv[0].value.text = ""
				inv[1].value.text = ""
				buttonIndex = 2
				selectedButton = buttons[2]
				selector.visible = false
		"Weapon":
			checkStatic()
			for b in buttons:
				b.visible = false
			dialogueBox.changeText(Game.player.player_name + " equipped the " + Game.player.inv.get_child(index).itemName)
			Game.player.inv.get_child(index).use(Game.player)
			inv[0].texture = null
			inv[1].texture = null
			inv[0].value.text = ""
			inv[1].value.text = ""
			buttonIndex = 2
			selectedButton = buttons[2]
			selector.visible = false
		"Battle":
			checkStatic()
			for b in buttons:
				b.visible = false
			Game.player.inv.get_child(index).use(self, Game.player)
			inv[0].texture = null
			inv[1].texture = null
			inv[0].value.text = ""
			inv[1].value.text = ""
			selector.visible = false
		"Potion":
			for b in buttons:
				b.visible = false
			dialogueBox.changeText(Game.player.player_name + " used the " + Game.player.inv.get_child(index).itemName)
			Game.player.inv.get_child(index).use(Game.player)
			inv[0].texture = null
			inv[1].texture = null
			inv[0].value.text = ""
			inv[1].value.text = ""
			buttonIndex = 2
			selectedButton = buttons[2]
			selector.visible = false
		"Booster":
			checkStatic()
			for b in buttons:
				b.visible = false
			dialogueBox.changeText(Game.player.player_name + " used the " + Game.player.inv.get_child(index).itemName)
			Game.player.inv.get_child(index).use(Game.player)
			inv[0].texture = null
			inv[1].texture = null
			inv[0].value.text = ""
			inv[1].value.text = ""
			buttonIndex = 2
			selectedButton = buttons[2]
			selector.visible = false
		"Gear":
			checkStatic()
			for b in buttons:
				b.visible = false
			dialogueBox.changeText(Game.player.player_name + " equipped the " + Game.player.inv.get_child(index).itemName)
			Game.player.inv.get_child(index).use(Game.player)
			inv[0].texture = null
			inv[1].texture = null
			inv[0].value.text = ""
			inv[1].value.text = ""
			buttonIndex = 2
			selectedButton = buttons[2]
			selector.visible = false
	updateStats()

func selectItem():
	if Game.player.inv.get_child_count() <= 1:
		itemIndex = 0
	elif itemIndex == 0:
		itemIndex = 1
	else:
		itemIndex = 0
	selectedItem = inv[itemIndex]
	selector.position = inv[itemIndex].anchor.global_position

func _on_PoisonTimer_timeout():
	if(Game.player.hp > 1):
		Game.player.damage(1)
	updateStats()
	if(Game.player.hp <= 0):
		emit_signal("game_over")
		queue_free()

func summonSelector(targets):
	if targets == "Monsters":
		selector.visible = true
		$Selector/AnimationPlayer.play("bob")
		for i in range(monsters.size()):
			if monsters[i].defeated == false:
				selectedFoe = monsters[i]
				foeIndex = i
				break
		for b in buttons:
			b.visible = false
		selector.position = monsters[foeIndex].anchor.global_position
		$EnemyStats/Hp.text = String(monsters[foeIndex].hp) + "/" + String(monsters[foeIndex].max_hp)
	elif targets == "Items":
		selector.visible = true
		$Selector/AnimationPlayer.play("bob")
		selectedItem = inv[0]
		for item in Game.player.inv.get_children():
			inv[item.get_index()].texture = item.spritePath
			if item.type == "Potion":
				inv[item.get_index()].value.text = String(item.healAmount) + "Hp"
		itemIndex = 0
		for b in buttons:
			b.visible = false
		selector.position = inv[itemIndex].anchor.global_position

func rollSpawn(monster):
	if monster.monster_class == "Parent" && monster.activated == false:
		randomize()
		var roll = randi() % monsters[0].childChance
		if roll == 0:
			return true
	return false

func checkStatic():
	if Game.player.status == Game.status.Static:
		Game.player.damage(Game.player.max_hp / 2)
		emit_signal("shock_trigger")
		if(Game.player.hp <= 0):
			emit_signal("game_over")
			queue_free()
		Game.player.status = Game.status.None
		updateStats()

func _on_BleedTimer_timeout():
	if Game.player.temp_hp > 0:
		Game.player.temp_hp -= 1
	updateStats()
