extends Area2D

# Signal that will be emitted when the player enters the area
signal player_entered

# Called when a body enters the area
func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):  # Check if the colliding body is the player
		emit_signal("player_entered")
		change_scene()

# Function to change the scene
func change_scene():
	get_tree().change_scene("res://path/to/InsideWallsScene.tscn")  # Change to your scene path
