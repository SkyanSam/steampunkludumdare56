extends Area2D

@export var speed = 500
@export var phase_min_sec = 3.0
@export var phase_max_sec = 5.0
@export var attack_cooldown = 1.0
var is_attacking = false
var can_attack = true
var speed_mod : int = 0
var is_colliding_with_player = false
@onready var player = get_node("/root/" + get_tree().current_scene.name + "/Player")
var Player = load("res://Player.gd")
func _ready() -> void:
	player.connect("playerAttack", Callable(self, "_on_Player_attack"))
	choose_phase()

func _process(delta: float) -> void:
	if not is_attacking:
		get_parent().progress += speed * delta * speed_mod
		if speed_mod < 0:
			$AnimatedSprite2D.flip_h = true
		elif speed_mod > 0:
			$AnimatedSprite2D.flip_h = false
	
func choose_phase():
	$Timer.start(randf_range(phase_min_sec, phase_max_sec))
	if not is_attacking:
		speed_mod = randi_range(-1, 1)
		if (speed_mod == 0):
			$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("walk")
	else:
		if $AnimatedSprite2D.animation_finished:
			is_attacking = false

func attack():
	if (can_attack):
		is_attacking = true
		can_attack = false
		$AttackTimer.start(attack_cooldown)
		$AnimatedSprite2D.play("attack")
		player.take_damage(1)
	
func _on_timer_timeout() -> void:
	choose_phase()

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		is_colliding_with_player = true
		if body.global_position.x - global_position.x > 0 and not $AnimatedSprite2D.flip_h:
			attack()
		if body.global_position.x - global_position.x < 0 and $AnimatedSprite2D.flip_h:
			attack()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_colliding_with_player = false

func _on_Player_attack(_type, _player):
	if is_colliding_with_player and (_type == Player.AttackType.NORMAL or _type == Player.AttackType.ONBEAT):
		$HP.take_damage()
