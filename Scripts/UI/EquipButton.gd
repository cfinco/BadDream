extends Polygon2D

var disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func changeText(txt):
	$Label.text = txt
