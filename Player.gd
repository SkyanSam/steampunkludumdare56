extends CharacterBody2D

@export var speed: int = 1200
@export var accel: int = 1000;
@export var decel: int = 2000;
@export var jump_speed: int = -3000
@export var gravity: int = 4000
@export var falling_gravity: int = 6000;
#later apply a timer so that if the character is slightly off the ledge, they can still jump

var vel = Vector2.ZERO

func get_input(delta: float):
	#if ui_right is pressed, velocity is increased to the right and sprite is flipped
	if Input.is_action_pressed("ui_right"):
		vel.x += accel * delta
		#$AnimatedSprite2D.flip_h = false
	#if ui_right is pressed, velocity is increased to the left and sprite is flipped
	elif Input.is_action_pressed("ui_left"):
		vel.x -= accel * delta
	elif vel.x > 0:
		vel.x -= decel * delta
	elif vel.x < 0:
		vel.x += decel * delta
		#$AnimatedSprite2D.flip_h = true
	if (vel.x > speed):
		vel.x = speed
	if (vel.x < -speed):
		vel.x = -speed

func _physics_process(delta):
	get_input(delta)
	
	if (vel.y > 0):
		vel.y += gravity * delta
	else:
		vel.y += falling_gravity * delta
	
	set_velocity(vel)
	set_up_direction(Vector2.UP)
	move_and_slide()
	vel = vel
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			vel.y = jump_speed
	if Input.is_action_just_released("ui_up"):
		if vel.y < 0.0:
			vel.y *= .2
