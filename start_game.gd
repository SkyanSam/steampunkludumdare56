extends Node2D  # or the appropriate base class for your title screen

@onready var start_game_button = $StartGame  # Reference to your StartGame button

func _ready():
	start_game_button.pressed.connect(_on_start_game_pressed)

func _on_start_game_pressed():
	# Prepare for the fade-out effect
	var game_scene = load("res://Scenes/LabScene.tscn")
	print("YEA")
	get_tree().change_scene_to_file("res://Scenes/LabScene.tscn")
