extends Node2D

@export var start_hp = 20
@export var min_dmg = 1
@export var max_dmg = 3
@export var dmg_cooldown = 0.2
@export var sprite_path : NodePath
@export var hurt_visual_time = 0.1
@export var handle_death = true
@onready var hp = start_hp
var can_be_hurt = true


signal health_changed(new_hp)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_graphics()

func take_damage():
	take_x_damage(randi_range(min_dmg, max_dmg))

func take_x_damage(x_damage):
	if can_be_hurt:
		# Timer stuff
		can_be_hurt = false
		$Timer.start(dmg_cooldown)
		# Compute the damage
		hp -= x_damage
		emit_signal("health_changed", hp)
		# Hit visual
		get_node(sprite_path).self_modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(get_node(sprite_path), "self_modulate", Color.WHITE, hurt_visual_time)
		# Update HP amount graphics
		update_graphics()
		# Check if entity dead
		if (hp <= 0 and handle_death):
			if (get_parent().name == "Player"):
				get_parent()._eat_shit()
			else:
				get_parent().queue_free()

func update_graphics():
	var t = float(hp) / float(start_hp)
	if (t < 0): t = 0
	$Amount.scale.x = t * 0.9

func _on_timer_timeout() -> void:
	can_be_hurt = true
