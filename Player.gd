extends CharacterBody2D

# LOOK AT JONAS TYROLLER CHARACTER MOVEMENT TUTORIAL
# SEE IF YOU CAN MAKE MORE IMPROVEMENTS!!! YEAH!!!
# BET

# ALSO ENEMIES BY DEFAULT SHOULD HAVE SLIGHT KNOCKBACK
# MAKE A DUMMY ENEMY TO TEST FEELING OF COMBAT!!
# DID THAT

@export var speed: int = 1200
@export var accel: int = 1000;
@export var decel: int = 2000;
@export var jump_speed: int = -3000
@export var ground_pound_speed: int = 5000
@export var gravity: int = 4000
@export var falling_gravity: int = 6000

@export var attack_cooldown: float = 0.01
@export var parry_window: float = 0.01

signal playerAttack(mode, body)

var is_ground_pound = false
var is_jump_last_frame = false
var can_attack = true
var can_parry = true
var mouse_health = 100
var max_health = 100
var ballin_lol: bool = true #Flag to see if player is DEAD
var jumps_left: int = 0
var last_parry_timestamp: float = 0.0
var last_hurt_timestamp: float = 0.0

# is there an attack pending that we are waiting on the parry for
var attack_pending: bool = false

signal health_changed(mouse_health)  # Signal updated to use mouse_health

signal player_died() #lol u know, to trigger a game over screen

@onready var rhythm_manager = get_tree().get_root().get_node(NodePath(get_tree().current_scene.name)).get_node("RhythmManager")
#later apply a timer so that if the character is slightly off the ledge, they can still jump

var vel = Vector2.ZERO

enum AttackType {
	NORMAL,
	ONBEAT,
	PARRY
}

# stuff for x velocity
func get_input(delta: float):
	if Input.is_action_pressed("ui_right"):
		var cel = decel if vel.x < 0 else accel
		vel.x += cel * delta
	elif Input.is_action_pressed("ui_left"):
		var cel = decel if vel.x > 0 else accel
		vel.x -= cel * delta
	elif vel.x > 0:
		vel.x -= decel * delta
		if (vel.x < 0): vel.x = 0
	elif vel.x < 0:
		vel.x += decel * delta
		if (vel.x > 0): vel.x = 0
	if (vel.x > speed):
		vel.x = speed
	if (vel.x < -speed):
		vel.x = -speed

func is_within_parry_window():
	return abs(last_hurt_timestamp - last_parry_timestamp) < parry_window
func _process(delta):
	# .....
	can_parry = true # NOTE DEBUG TO DISREGARD PARRY TIMER
	# .....
	
	if attack_pending:
		if (Time.get_ticks_msec() / 1000.0) - last_hurt_timestamp > parry_window:
			attack_pending = false
			take_damage(1)
		
	if Input.is_action_just_pressed("parry"):
		if can_parry:
			last_parry_timestamp = Time.get_ticks_msec() / 1000.0
			$AnimationPlayer.play("parry")
			$ParryTimer.start(parry_window / 2.0)
			can_parry = false
			if is_within_parry_window() and attack_pending:
				emit_signal("playerAttack", AttackType.PARRY, self)
				attack_pending = false
	if Input.is_action_just_pressed("attack"):
		if can_attack:
			$AnimationPlayer.play("attack")
			$AttackTimer.start(attack_cooldown)
			can_attack = false
			emit_signal("playerAttack", AttackType.ONBEAT if rhythm_manager.is_within_timing_window(delta) else AttackType.NORMAL, self)
			print("player attack")
	
	"""if $AnimationPlayer.current_animation == "parry" and $AnimationPlayer.animation_finished:
		$AnimationPlayer.play("idle")
	if $AnimationPlayer.current_animation == "attack" and $AnimationPlayer.animation_finished:
		$AnimationPlayer.play("idle")"""
		

# stuff for y velocity
func _physics_process(delta):
	get_input(delta)
	
	if (is_on_floor()):
		vel.y = 0
		jumps_left = 2
	
	if (vel.y > 0):
		vel.y += gravity * delta
	elif (not is_on_floor()):
		vel.y += falling_gravity * delta
	
	if (Input.is_action_just_pressed("groundpound") and (not is_on_floor())):
		is_ground_pound = true
		
	if (is_ground_pound):
		if (is_on_floor()):
			is_ground_pound = false
			vel.y = 0
		else:
			vel.y = ground_pound_speed
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() || jumps_left > 0:
			vel.y = jump_speed
			jumps_left -= 1
			is_jump_last_frame = true
			$AnimationPlayer.play("jump")
	if Input.is_action_just_released("jump") and is_jump_last_frame:
		is_jump_last_frame = false
		if vel.y < 0.0:
			vel.y *= .2
	
	velocity = vel
	set_up_direction(Vector2.UP)
	move_and_slide()
	
	# x animation stuff
	if (is_on_floor() and $AnimationPlayer.current_animation != "attack" and $AnimationPlayer.current_animation != "parry"):
		if (vel.x != 0 and $AnimationPlayer.current_animation != "run"):
			$AnimationPlayer.play("run")
		if (vel.x == 0 and $AnimationPlayer.current_animation != "idle"):
			$AnimationPlayer.play("idle")
	if vel.x > 0:
		$Character.flip_h = false
	elif vel.x < 0:
		$Character.flip_h = true
			

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_enemy_attack():
	last_hurt_timestamp = Time.get_ticks_msec() / 1000.0
	if Input.is_action_just_pressed("parry"):
		emit_signal("playerAttack", AttackType.PARRY, self)
	else:
		attack_pending = true
		if is_within_parry_window():
			emit_signal("playerAttack", AttackType.PARRY, self)

func _on_parry_timer_timeout() -> void:
	can_parry = true

func _eat_shit():    #you eat shit
	ballin_lol = false
	emit_signal("player_died")

func take_damage(damage_amount: int):
	$HurtSound.play()
	if ballin_lol:
		mouse_health -= damage_amount
		mouse_health = clamp(mouse_health, 0, max_health)  # Prevent negative health
		
		emit_signal("health_changed", mouse_health)  # Emit signal with mouse_health
		
		if mouse_health <= 0:
			_eat_shit()


func _on_player_attack(mode, body) -> void:
	if (mode == AttackType.PARRY):
		$ParrySound.play()
