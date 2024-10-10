extends CharacterBody2D

@export var speed = 300
@export var phase_min_sec = 3.0
@export var phase_max_sec = 5.0
@export var attack_cooldown = 0.7

var is_attacking = false
var can_attack = true
var speed_mod : int = 0
var tongue_speed = 200  # How fast the tongue moves
var max_tongue_length = 300  # Max distance the tongue can extend
var tongue_extended = false  # Whether the tongue is currently extended

# gabe implement hp.gd please and thanks. Its in HP/hp.gd
@onready var tongue = $CollarGun/CollisionShape2D
@onready var tongue_shape = tongue.shape

func _ready() -> void:
	$AnimationPlayer.play("idle")
	choose_phase()

func _process(delta: float) -> void:
	if not is_attacking:
		get_parent().progress += speed * delta * speed_mod
		if speed_mod < 0:
			#$AnimatedSprite2D.flip_h = true need sprites
			pass
		elif speed_mod > 0:
			#$AnimatedSprite2D.flip_h = false need sprites
			pass
	
	if tongue_extended:
		extend_tongue(delta)
	else:
		retract_tongue(delta)

func choose_phase():
	$Timer.start(randf_range(phase_min_sec, phase_max_sec))
	if not is_attacking:
		speed_mod = randi_range(-1, 1)
		if (speed_mod == 0):
			#$AnimatedSprite2D.play("idle") add sprites!
			pass
		else:
			#$AnimatedSprite2D.play("walk") add sprites!!!
			pass
			print("FUCK")
	else:
		if $AnimatedSprite2D.animation_finished:
			is_attacking = false
			
func attack():
	if (can_attack):
		is_attacking = true
		can_attack = false
		$AttackTimer.start(attack_cooldown)
		#$AnimatedSprite2D.play("attack")
	
func _on_timer_timeout() -> void:
	choose_phase()

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_body_entered(body: Node2D) -> void:
	#if (body.name == "Player"):
		#if body.global_position.x - global_position.x > 0 and not $AnimatedSprite2D.flip_h:
			#attack()
		#if body.global_position.x - global_position.x < 0 and $AnimatedSprite2D.flip_h:
			#attack()
	pass #NEED SPRITES AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	
func extend_tongue(delta):
	# Extend the tongue by scaling the collision box
	if tongue_shape.extents.y < max_tongue_length:
		tongue_shape.extents.y += tongue_speed * delta
	else:
		tongue_extended = false  # Stop extending when reaching max length
		
func retract_tongue(delta):
	# Retract the tongue by reducing the collision box size
	if tongue_shape.extents.y > 0:
		tongue_shape.extents.y -= tongue_speed * delta
	else:
		tongue_shape.extents.y = 0  # Ensure it doesn't go below 0
