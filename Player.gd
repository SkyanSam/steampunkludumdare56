extends CharacterBody2D

# LOOK AT JONAS TYROLLER CHARACTER MOVEMENT TUTORIAL
# SEE IF YOU CAN MAKE MORE IMPROVEMENTS!!! YEAH!!!

# ALSO ENEMIES BY DEFAULT SHOULD HAVE SLIGHT KNOCKBACK
# MAKE A DUMMY ENEMY TO TEST FEELING OF COMBAT!!

@export var speed: int = 1200
@export var accel: int = 1000;
@export var decel: int = 2000;
@export var jump_speed: int = -3000
@export var ground_pound_speed: int = 5000
@export var gravity: int = 4000
@export var falling_gravity: int = 6000

@export var attack_cooldown: float = 0.01
@export var parry_window: float = 0.01

signal playerAttack

var is_ground_pound = false
var is_jump_last_frame = false
var can_attack = true
var can_parry = false
var mouse_health = 100
var max_health = 100
var ballin_lol: bool = true #Flag to see if player is DEAD

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
func _process(delta):
	pass

# stuff for y velocity
func _physics_process(delta):
	get_input(delta)
	
	if (is_on_floor()):
		vel.y = 0
	
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
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			vel.y = jump_speed
			is_jump_last_frame = true
	if Input.is_action_just_released("ui_up") and is_jump_last_frame:
		is_jump_last_frame = false
		if vel.y < 0.0:
			vel.y *= .2
	
	if Input.is_action_just_pressed("attack"):
		if can_parry:
			emit_signal("playerAttack", AttackType.PARRY, self)
			can_parry = false
		elif can_attack:
			$AttackTimer.start(attack_cooldown)
			can_attack = false
			emit_signal("playerAttack", AttackType.ONBEAT if rhythm_manager.is_within_timing_window(delta) else AttackType.NORMAL, self)
			print("player attack")
	velocity = vel
	set_up_direction(Vector2.UP)
	move_and_slide()

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_enemy_attack():
	if Input.is_action_just_pressed("attack"):
		emit_signal("playerAttack", AttackType.PARRY, self)
	else:
		can_parry = true
		$ParryTimer.start(parry_window)

func _on_parry_timer_timeout() -> void:
	can_parry = false

func _eat_shit():    #you eat shit
	ballin_lol = false
	emit_signal("player_died")

func take_damage(damage_amount: int):
	if ballin_lol:
		mouse_health -= damage_amount
		mouse_health = clamp(mouse_health, 0, max_health)  # Prevent negative health
		
		emit_signal("health_changed", mouse_health)  # Emit signal with mouse_health
		
		if mouse_health <= 0:
			_eat_shit()
