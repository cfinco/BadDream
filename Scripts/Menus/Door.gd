extends Node2D

onready var dialogueBox = $DialogueBox/RichTextLabel
onready var buttons = $Buttons.get_children()

var selectedButton
var buttonIndex = 0

func _ready():
	match Game.player.key:
		true:
			dialogueBox.changeText("It's a grandfather clock with what looks like a key hole in the front. \nInsert the key and continue to the next floor?")
			selectedButton = buttons[0]
		false:
			dialogueBox.changeText("It's a grandfather clock with what looks like a key hole in the front.")
			selectedButton = $ExitButton

func _process(delta):
	if dialogueBox.textScrolled():
		match Game.player.key:
			true:
				buttons[0].visible = true
				buttons[2].visible = true
				buttons[1].disabled = true
			false:
				$ExitButton.visible = true
				$ExitButton.color = Color(0.9, 0.8, 0)
				buttonIndex = -1
		selectedButton.color = Color(0.9, 0.8, 0)

func _input(event):
	if dialogueBox.textScrolled():
		if event.is_action_pressed("ui_accept"):
			match buttonIndex:
				-1:
					Game.inMenu = false
					Game.tileTemp.discover()
					queue_free()
				0:
					Game.level += 1
					Game.player.key = false
					Game.illuminated = false
					Game.generateNewMap()
					Game.inMenu = false
					queue_free()
				2:
					Game.inMenu = false
					Game.tileTemp.discover()
					queue_free()
		elif event.is_action_pressed("ui_left") && buttonIndex != -1:
			selectButton(-1)
		elif event.is_action_pressed("ui_right") && buttonIndex != -1:
			selectButton(1)

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
