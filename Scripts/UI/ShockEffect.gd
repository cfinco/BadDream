extends Node2D

func _ready():
	$AnimationPlayer.play("Idle")

func _on_Battle_shock_trigger():
	$AnimationPlayer.play("Trigger")

func _on_Map_shock_trigger():
	$AnimationPlayer.play("Trigger")

func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.play("Idle")
