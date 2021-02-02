extends RichTextLabel

var dialogue = ["placeholder"]
var page = 0

func _ready():
	bbcode_text = dialogue[page]
	visible_characters = 0
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		#if visible_characters > get_total_character_count() && page < dialogue.size() - 1:
		#	page = page + 1
		#	visible_characters = 0
		#	bbcode_text = dialogue[page]
		#	pass
		#else:
		if !textScrolled():
			visible_characters = get_total_character_count()

func _on_Timer_timeout():
	visible_characters = visible_characters + 1

func textScrolled() -> bool:
	if visible_characters > get_total_character_count():
		return true
	else:
		return false

func changeText(d : String):
	dialogue = [d]
	visible_characters = 0
	bbcode_text = dialogue[page]

func addColorText(d : String, color):
	dialogue = [d]
	visible_characters = 0
	bbcode_text = ""
	push_color(color)
	add_text(dialogue[page])
