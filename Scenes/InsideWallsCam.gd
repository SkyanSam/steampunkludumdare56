extends Camera2D

@export var player : NodePath
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	global_position.y = get_node(player).global_position.y
	# note, add some drag...
