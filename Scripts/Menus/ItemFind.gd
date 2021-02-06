extends Node2D

onready var buttons = $Buttons.get_children()
onready var dialogueBox = $DialogueBox/RichTextLabel
onready var inv = $Inv.get_children()
onready var selector = $Selector
var selectedButton
var selectedItem
var buttonIndex = 0
var itemIndex
var item

# Called when the node enters the scene tree for the first time.
func _ready():
	item = Game.tileTemp.loot
	$Sprite.texture = Game.tileTemp.loot.spritePath
	
	selectedButton = buttons[0]
	dialogueBox.changeText("You found a " + item.itemName + "!")
	buttons[2].changeText("Pocket it")
	match item.type:
		"Weapon":
			buttons[1].changeText("Equip it")
		"Key":
			buttons[1].changeText("Use it")
			buttons[1].disabled = true
		"Antidote":
			buttons[1].changeText("Use it")
			if item.status != Game.player.status:
				buttons[1].disabled = true
		"Battle":
			buttons[1].changeText("Use it")
			buttons[1].disabled = true
		"Map":
			buttons[1].changeText("Use it")
		"Booster":
			buttons[1].changeText("Use it")
		"Potion":
			buttons[1].changeText("Use it")

func _process(delta):
	if dialogueBox.textScrolled() && buttonIndex >= 0:
		for b in buttons:
			b.visible = true
			if b.disabled:
				b.color = Color(0.5, 0.5, 0.5)
			else:
				b.color = Color(0.2, 0.2, 0.2)
		selectedButton.color = Color(0.9, 0.8, 0)

func _input(event):
	if dialogueBox.textScrolled():
		if event.is_action_pressed("ui_left"):
			if buttonIndex == -1:
				selectItem()
			else:
				selectButton(-1)
				inv[0].texture = null
				inv[1].texture = null
				inv[0].value.text = ""
				inv[1].value.text = ""
				$Weapon.texture = null
				$Weapon.value.text = ""
		elif event.is_action_pressed("ui_right"):
			if buttonIndex == -1:
				selectItem()
			else:
				selectButton(1)
				inv[0].texture = null
				inv[1].texture = null
				inv[0].value.text = ""
				inv[1].value.text = ""
				$Weapon.texture = null
				$Weapon.value.text = ""
		elif event.is_action_pressed("ui_accept") && selectedButton.disabled == false:
			match buttonIndex:
				-1:
					stowItem(itemIndex)
				0:
					for b in buttons:
						b.visible = false
					if Game.player.status == Game.status.Confusion:
						dialogueBox.push_color(Color(1, 0.5, 1))
						dialogueBox.changeText("")
						dialogueBox.addColorText("Where am I?", Color(1, 0.5, 1))
					else:
						match item.type:
							"Potion":
								dialogueBox.changeText(item.description + "\nHeals " + String(item.healAmount) + " hp.")
								for i in Game.player.inv.get_children():
									if i.type == "Potion":
										inv[i.get_index()].texture = i.spritePath
										inv[i.get_index()].value.text = String(i.healAmount) + "hp"
							"Key":
								dialogueBox.changeText(item.description)
							"Antidote":
								dialogueBox.changeText(item.description + "\nCures " + item.statusName + ".")
							"Weapon":
								if item.aoe:
									dialogueBox.changeText(item.description + "\n" + String(item.atkMod) + " Damage, -" + String(item.spdMod) + " Speed, x" + String(item.typeMult) + " " + item.weaponType + " Damage. Hits all monsters in battle.")
								elif item.weaponType != "None":
									dialogueBox.changeText(item.description + "\n" + String(item.atkMod) + " Damage, -" + String(item.spdMod) + " Speed, x" + String(item.typeMult) + " " + item.weaponType + " Damage.")
								else:
									dialogueBox.changeText(item.description + "\n" + String(item.atkMod) + " Damage, -" + String(item.spdMod) + " Speed")
								if Game.player.hasWeapon():
									$Weapon.texture = Game.player.weapon.get_child(0).spritePath
									$Weapon.value.text = "Atk: " + String(Game.player.weapon.get_child(0).atkMod)
								for i in Game.player.inv.get_children():
									if i.type == "Weapon":
										inv[i.get_index()].texture = i.spritePath
										inv[i.get_index()].value.text = "Atk: " + String(i.atkMod)
							"Map":
								dialogueBox.changeText(item.description)
							"Battle":
								dialogueBox.changeText(item.description)
							"Booster":
								dialogueBox.changeText(item.description)
							"Mimic":
								dialogueBox.changeText(item.description)
				1:
					if item.type != "Potion" || item.type != "Antidote":
						checkStatic()
					useItem()
				2:
					if item.type == "Key" || item.type == "Mimic":
						useItem()
					elif Game.player.inv.get_child_count() <= 1:
						stowItem(-1)
					else:
						selector.visible = true
						$Selector/AnimationPlayer.play("bob")
						selectedItem = inv[0]
						inv[0].texture = Game.player.inv.get_child(0).spritePath
						inv[1].texture = Game.player.inv.get_child(1).spritePath
						itemIndex = 0
						for b in buttons:
							b.visible = false
						selector.position = inv[itemIndex].anchor.global_position
						buttonIndex = -1
				3:
					Game.inMenu = false
					Game.tileTemp.discover()
					queue_free()
		elif event.is_action_pressed("ui_back") && buttonIndex == -1:
			selector.visible = false
			inv[0].texture = null
			inv[1].texture = null
			buttonIndex = 2
			selectedButton = buttons[2]

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

func selectItem():
	if itemIndex == 0:
		itemIndex = 1
	else:
		itemIndex = 0
	selectedItem = inv[itemIndex]
	selector.position = inv[itemIndex].anchor.global_position

func useItem():
	var loot = item
	item.get_parent().remove_child(item)
	var newItem
	if loot.type == "Mimic":
		newItem = loot.use(Game.tileTemp, Game.player)
		Game.tileTemp.loot = newItem
		if newItem != null:
			Game.tileTemp.add_child(newItem)
	else:
		newItem = loot.use(Game.player)
		Game.tileTemp.loot = newItem
		if newItem != null:
			Game.tileTemp.add_child(newItem)
		Game.inMenu = false
	
	Game.tileTemp.discover()
	queue_free()

func stowItem(index):
	var loot = item
	item.get_parent().remove_child(item)
	var newItem = Game.player.stow(loot, index)
	Game.tileTemp.loot = newItem
	if newItem != null:
		Game.tileTemp.add_child(newItem)
	
	Game.inMenu = false
	Game.tileTemp.discover()
	queue_free()

func checkStatic():
	if Game.player.status == Game.status.Static:
		Game.player.damage(Game.player.max_hp / 2)
		get_parent().shockTrigger()
		if(Game.player.hp <= 0):
			emit_signal("game_over")
			queue_free()
		Game.player.status = Game.status.None
