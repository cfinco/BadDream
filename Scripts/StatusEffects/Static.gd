extends Resource

class_name Static

func inflict(target):
	if target.hasGear() && target.gear.get_child(0).status == Game.status.Static:
		pass
	else:
		target.status = Game.status.Static
