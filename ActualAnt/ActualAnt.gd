extends Area2D

@export var speed = 500
@export var phase_min_sec = 3.0
@export var phase_max_sec = 5.0
@export var attack_cooldown = 1.0
var is_attacking = false
var can_attack = true
var speed_mod : int = 0
func _ready() -> void:
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
	
func _on_timer_timeout() -> void:
	choose_phase()

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		if body.global_position.x - global_position.x > 0 and not $AnimatedSprite2D.flip_h:
			attack()
		if body.global_position.x - global_position.x < 0 and $AnimatedSprite2D.flip_h:
			attack()
