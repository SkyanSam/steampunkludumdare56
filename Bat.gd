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
var last_circle : Node2D = null

var circles: Array = []
var Player = load("res://Player.gd")
# This is the beat time when we started playing this pattern
var beattime_pattern_instanced : float = 0.0
# This is the index to the curr timestamp in the pattern we are on.
var curr_index : int = 0
var curr_att_index : int = 0

enum Mode {
	BatScream,
	BatAttack
}
var mode : Mode = Mode.BatScream

func _ready() -> void:
	rhythm_manager.connect("onBeat", Callable(self, "_on_beat"))
	player.connect("playerAttack", Callable(self, "_on_Player_attack"))
func _on_beat():
	if (curr_pattern == null):
		instance_new_pattern()

func _process(delta: float) -> void:
	# Update the current beat and the time since the pattern began (in beats)
	rhythm_manager.update_curr_beat()
	if (curr_pattern == null):
		return
	var time_since_pattern = rhythm_manager.curr_beat - beattime_pattern_instanced
	
	# Handle if the player missed the parry
	if mode == Mode.BatAttack and curr_att_index < len(curr_pattern.beatstamps):
		var target_time = (curr_pattern.beatstamps[curr_att_index] + beattime_pattern_instanced) * rhythm_manager.beat_time
		var curr_time = rhythm_manager.get_playback_position()
		var miss_time = target_time + rhythm_manager.timing_window
		if (curr_time >= miss_time):
			print("player owie " + str(curr_att_index) + ", " + str(curr_time) + ", " + str(miss_time))
			curr_att_index += 1
			player.take_damage(1)
	
	# Scream or Attack depending on the circumstance, this is timed to the beat.
	if curr_index < len(curr_pattern.beatstamps):
		match(mode):
			Mode.BatScream:
				if (time_since_pattern >= curr_pattern.beatstamps[curr_index]):
					#print("echo" + str(curr_pattern.beatstamps[curr_index]) + ", " + str(time_since_pattern))
					$PopSound.pitch_scale = 1
					$PopSound.play()
					curr_index += 1
			Mode.BatAttack:
				if (time_since_pattern >= curr_pattern.beatstamps[curr_index] - reaction_time):
					#print("kill" + str(curr_pattern.beatstamps[curr_index]) + ", " + str(time_since_pattern))
					instance_circle(curr_pattern.beatstamps[curr_index])
					var tween = create_tween()
					#tween.tween_callback(debug_pop).set_delay(reaction_time * rhythm_manager.beat_time)
					curr_index += 1
	else:
		# once the pattern finishes go to the next phase.
		var t = rhythm_manager.curr_beat + (curr_pattern.pattern_length - time_since_pattern)
		match mode:
			Mode.BatScream:
				reset_pattern_with_time(Mode.BatAttack, t)
			Mode.BatAttack:
				if (curr_att_index >= len(curr_pattern.beatstamps)):
					instance_new_pattern_with_time(t)
	if (Input.is_action_just_pressed("attack")):
		if (is_on_beat()):
			health -= 1
		else:
			player.take_damage()
			

func instance_new_pattern():
	curr_pattern = patterns[randi_range(0, len(patterns) - 1)]
	reset_pattern(Mode.BatScream)

func instance_new_pattern_with_time(t):
	curr_pattern = patterns[randi_range(0, len(patterns) - 1)]
	reset_pattern_with_time(Mode.BatScream, t)

func debug_pop():
	$PopSound.pitch_scale = 2
	$PopSound.play()

func reset_pattern(_mode):
	beattime_pattern_instanced = round(rhythm_manager.curr_beat)
	curr_index = 0
	curr_att_index = 0
	mode = _mode

func reset_pattern_with_time(_mode, t):
	beattime_pattern_instanced = round(t)
	curr_index = 0
	curr_att_index = 0
	mode = _mode

func instance_circle(beat):
	var circle = bat_circle_packed_scene.instantiate()
	circle.beat = beat + beattime_pattern_instanced
	circle.reaction_time = reaction_time
	add_child(circle)
	circles.append(circle)
	last_circle = circle

func is_on_beat():
	for circle in circles:
		if (abs(rhythm_manager.curr_beat - circle.beat) * rhythm_manager.beat_time <= rhythm_manager.timing_window):
			return true
	return false

func _on_Player_attack(_type, _player):
	# I MAY WANT TO HAVE THIS PARRY LOGIC ON THE PLAYER AND NOT EACH ENEMY
	print("player att")
	if (_type == Player.AttackType.PARRY and mode == Mode.BatAttack):
		if (curr_att_index < len(curr_pattern.beatstamps)):
			var target_time = (curr_pattern.beatstamps[curr_att_index] + beattime_pattern_instanced) * rhythm_manager.beat_time
			var curr_time = rhythm_manager.get_playback_position()
			if abs(target_time - curr_time) < rhythm_manager.timing_window:
				player.get_node("ParrySound").play()
				bat_hurt()
				curr_att_index += 1
func bat_hurt():
	print("bat hurt owie :(")
	
