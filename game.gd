extends Node2D

onready var paused_label = $CanvasLayer/Paused

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		var paused = get_tree().paused
		get_tree().paused = !paused
		paused_label.visible = !paused
		if !paused:
			paused_label.get_node("AnimationPlayer").play("blink")
		else:
			paused_label.get_node("AnimationPlayer").stop()
