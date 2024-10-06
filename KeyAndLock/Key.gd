extends Area2D


# Called when the node enters the scene tree for the first time.
signal keyPickup()
var is_key_pickup = false
	
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and !is_key_pickup:
		emit_signal("keyPickup")
		is_key_pickup = true
