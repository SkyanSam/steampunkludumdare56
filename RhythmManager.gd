extends AudioStreamPlayer2D

@export var BPM = 148
@export var offset_seconds = 0.0
@export var timing_window = 0.07
var beat_time = 0.0
var can_signal = true
var signal_timer = 0.0
var curr_beat = 0.0
var last_beat : int = 0
signal onBeat

@onready var player = get_parent().get_node("Player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beat_time = compute_beat_time()
	play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = player.global_position
	update_curr_beat()
	if (floor(curr_beat) != last_beat):
		emit_signal("onBeat")
		last_beat = floor(curr_beat)
	"""
	if (is_within_x_timing_window(delta, delta) and signal_timer <= 0.0):
		emit_signal("onBeat")
		signal_timer = 5 * delta
	signal_timer -= delta"""

func compute_beat_time():
	return (60.0 / BPM)

func update_curr_beat():
	curr_beat = (get_playback_position() - offset_seconds) / beat_time

func is_within_x_timing_window(delta: float, tw: float):
	var seconds_to_beat = abs(fmod(get_playback_position() - offset_seconds, beat_time))
	var seconds_to_beat_2 = abs(seconds_to_beat - beat_time)
	if (seconds_to_beat_2 < seconds_to_beat):
		seconds_to_beat = seconds_to_beat_2
	#print(str(seconds_to_beat < timing_window) + ", " + str(seconds_to_beat))
	return (seconds_to_beat <= tw || seconds_to_beat <= 1.5 * delta)

func is_within_timing_window(delta: float):
	return is_within_x_timing_window(delta, timing_window)
