extends Area2D

@onready var path = $Path2D
@export var speed = 500
var last_position_x
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_parent().progress += speed * delta
	# add rotation of sprite
	# hhhhh
