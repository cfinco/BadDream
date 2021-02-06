extends Resource

class_name Bleed

func inflict(target):
	target.status = Game.status.Bleed
