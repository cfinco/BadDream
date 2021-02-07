extends Resource

class_name Poison

func inflict(target):
	if target.hasGear() && target.gear.get_child(0).status == Game.status.Poison:
		pass
	else:
		target.status = Game.status.Poison
