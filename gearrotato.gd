extends Node2D

# Variables for gear rotation speed and direction
var rotation_speed: float = 1.0
var direction: int = 1 # 1 for clockwise, -1 for counterclockwise

func _process(delta: float) -> void:
    # Rotate the gear sprite
    $Gear.rotation += direction * rotation_speed * delta