extends Area2D

@export var health : int = 30
# List of patterns
@export var patterns : Array[Resource]
# How much time it takes for the echolocation to get from bat to player.
@export var reaction_time = 0.1
# Bat Circle
@export var bat_circle_packed_scene : PackedScene
# Rhythm Manager & Player singletons, self explanatory
@onready var rhythm_manager = get_tree().get_root().get_node(NodePath(get_tree().current_scene.name)).get_node("RhythmManager")
@onready var player = get_tree().get_root().get_node(NodePath(get_tree().current_scene.name)).get_node("Player")
# The current pattern
var curr_pattern : Resource = null

var circles: Array = []

# This is the beat time when we started playing this pattern
var beattime_pattern_instanced : float = 0.0
# This is the index to the curr timestamp in the pattern we are on.
var curr_index : int = 0

enum Mode {
	BatScream,
	BatAttack
}
var mode : Mode = Mode.BatScream

func _ready() -> void:
	rhythm_manager.connect("onBeat", Callable(self, "_on_beat"))

func _on_beat():
	if (curr_pattern == null):
		instance_new_pattern()

func _process(delta: float) -> void:
	if (curr_pattern == null):
		return
	var time_since_pattern = rhythm_manager.curr_beat - beattime_pattern_instanced
	
	#print(str(curr_index) + ", " + str(time_since_pattern))
	
	if curr_index < len(curr_pattern.beatstamps):
		match(mode):
			Mode.BatScream:
				if (time_since_pattern >= curr_pattern.beatstamps[curr_index]):
					print("echo")
					$PopSound.play()
					curr_index += 1
			Mode.BatAttack:
				if (time_since_pattern >= curr_pattern.beatstamps[curr_index] - reaction_time):
					print("kill")
					instance_circle(curr_pattern.beatstamps[curr_index])
					curr_index += 1
	else:
		if (time_since_pattern >= curr_pattern.pattern_length):
			match mode:
				Mode.BatScream:
					mode = Mode.BatAttack
					beattime_pattern_instanced = rhythm_manager.curr_beat
					curr_index = 0
				Mode.BatAttack:
					instance_new_pattern()
	
	if (Input.is_action_just_pressed("attack")):
		if (is_on_beat()):
			health -= 1
		else:
			player.take_damage()
			

func instance_new_pattern():
	curr_pattern = patterns[randi_range(0, len(patterns) - 1)]
	beattime_pattern_instanced = rhythm_manager.curr_beat
	curr_index = 0
	mode = Mode.BatScream

func instance_circle(beat):
	var circle = bat_circle_packed_scene.instantiate()
	circle.beat = beat + beattime_pattern_instanced
	circle.reaction_time = reaction_time
	add_child(circle)
	circles.append(circle)

func is_on_beat():
	for circle in circles:
		if (abs(rhythm_manager.curr_beat - circle.beat) * rhythm_manager.beat_time <= rhythm_manager.timing_window):
			return true
	return false
	
