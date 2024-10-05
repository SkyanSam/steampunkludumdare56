extends Area2D

# Declare properties
var damage: int = 30  # Base damage dealt by the spear
var damage_modifier: float = 1.0  # Modifies spear damage

# Signal for when the spear hits a target
signal hit(body)

# This method will be called when the node is added to the scene
@onready var collision_shape = $CollisionShape2D  # Reference to the collision shape

func _ready():
	# Start monitoring collisions
	collision_shape.disabled = false  # Enable collision detection

# Handle body entering the spear's area
func _on_body_entered(body: Node):
	if body.is_in_group("players"):  # Adjust this check according to your player group
		emit_signal("hit", body)  # Emit signal with the hit body
		body.take_damage(damage * damage_modifier)  # Apply damage to the player
		queue_free()  # Remove the spear after hitting the target
	else:
		# Remove the spear if it hits something else
		queue_free()

# Called when the area detects a body
func _on_area_entered(area: Area2D):
	_on_body_entered(area)  # Redirect to the body hit handler
