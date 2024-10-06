extends StaticBody2D

@export var key_ref: NodePath 
func _ready() -> void:
	get_node(key_ref).connect("keyPickup", Callable(self, "_on_key_pickup"))

func _on_key_pickup():
	queue_free()
	
