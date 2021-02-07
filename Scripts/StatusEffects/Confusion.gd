extends Resource

class_name Confusion

func inflict(target):
	if target.hasGear() && target.gear.get_child(0).status == Game.status.Confusion:
		pass
	else:
		target.status = Game.status.Confusion
