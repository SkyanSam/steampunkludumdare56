extends StaticBody2D

@export var rotate_time = 0.1
@export var rotate_amount = 45
@export var every_x_beats = 2
@onready var rhythm_manager = get_node("/root/" + get_tree().current_scene.name + "/RhythmManager")
var beats_left = 0

func _ready() -> void:
	rhythm_manager.connect("onBeat", Callable(self, "_on_beat"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_beat():
	if (beats_left == 0):
		var tween = create_tween()
		tween.tween_property(self, "rotation_degrees", rotation_degrees + rotate_amount, rotate_time).set_ease(Tween.EASE_OUT_IN)
		beats_left = every_x_beats
	beats_left -= 1
