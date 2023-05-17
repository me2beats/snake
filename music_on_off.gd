extends Button

onready var music = $"../../Audio/Music"

func _ready():
	pressed = Global.play_music
	music.playing = pressed



func _on_MusicOnOff_toggled(button_pressed):
	music.playing = button_pressed
	Global.play_music = button_pressed
