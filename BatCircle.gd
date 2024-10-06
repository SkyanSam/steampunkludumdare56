extends Node2D

# NOTE TO SELF, MAY WANT TO REVERSE THE DIRECTION OF THE RADIUS SO THAT IT CLOSES IN ON THE BAT
@export var sequences: PackedFloat32Array

var beat = 0.0
@export var reaction_time = 0.1 # this is the reaction time in beats
@onready var rhythm_manager = get_tree().get_root().get_node(NodePath(get_tree().current_scene.name)).get_node("RhythmManager")
@onready var player = get_tree().get_root().get_node(NodePath(get_tree().current_scene.name)).get_node("Player")
@onready var line2d : Line2D = $Line2D
@export var detail : int = 300
@onready var start_beat = rhythm_manager.curr_beat

var target_radius = 0.0
var radius = 0.0
func _ready() -> void:
	init_line2d(detail)
	update()

func _process(delta: float) -> void:
	update()

func update():
	# Getting the distance t, 0 means start, and 1 means hitting the player.
	var t = (beat - rhythm_manager.curr_beat) / (reaction_time)
	#if (t < 0.0):
		#t = 0.0
	# Computing the target radius based on how far the player is away
	if (radius <= target_radius):
		target_radius = (global_position - player.global_position).length()
	# Computing the radius based on t and target radius.
	#var radius = t * target_radius
	radius = lerp_unclamped(target_radius, 0, t)
	update_line2d(detail, radius)

func lerp_unclamped(A: float, B: float, t: float):
	return A + ((B - A) * t)
func init_line2d(num_points):
	var pts = line2d.points
	pts.resize(num_points)
	line2d.points = pts
	#for i in range(0, num_points):
		#line2d.points.append(Vector2.ZERO)

func update_line2d(num_points, rad):
	var pts = line2d.points
	for i in range(0, num_points):
		var rot = (float(i) / float(num_points)) * 2.0 * PI
		var pt = rad * Vector2(cos(rot), sin(rot))
		pts.set(i, pt)
	line2d.points = pts
