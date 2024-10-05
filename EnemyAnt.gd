extends CharacterBody2D

# Declare enemy properties
var health = 120
var move_speed = 500
var sprint_speed = 2000
var is_sprinting = false
var can_attack = true
var attack_count = 0
var max_misses = 3
var player = null
var is_dead = false
var spear_damage_modifier = 1.0  # Modifies spear damage
var base_spear_damage = 30
var is_jaw_attacking = false
var jaw_attack_range = 100  # Set the range in which the jaw attack can happen
var jaw_attack_windup_time = 0.5  # Time before the jaw attack triggers
var jaw_attack_damage = 20  # Damage dealt by the jaw attack

var can_spear_attack = true
# Signal to notify the player when a miss happens SAM ADD THIS IN
signal spear_miss

# Called when the node enters the scene
func _ready():
	player = get_node("/root/" + get_tree().current_scene.name + "/Player")
	player.connect("playerAttack", Callable(self, "_on_Player_attack"))
	# Connect spear collision signals (using Callable syntax in Godot 4)
	var spear = $Spear
	
	
	spear.connect("body_entered", Callable(self, "_on_spear_hit"))
	
	await player.playerAttack
	# Connect the response from the player for the miss check
	spear.connect("body_entered", Callable(self, "_on_spear_hit"))

# Called every frame, use to process player detection and movement
func _process(delta):
	if is_dead:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	# If the spear has been thrown, the ant can only sprint and use jaw attacks
	if has_thrown_spear:
		if is_sprinting:
			move_toward_player()  # The ant can still sprint toward the player
			# Logic for jaw attack goes here
			perform_jaw_attack()  # Call this when the ant performs the jaw attack
	else:
		# Normal attack behavior when spear hasn't been thrown
		if distance_to_player < 1280:
			move_toward_player()
		if distance_to_player < 100 and can_spear_attack:
			spear_attack()
			can_spear_attack = false
			$SpearAttackTimer.start()

# Move towards the player
func move_toward_player():
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed 
	move_and_slide()

# Signal-based attack detection, called when the player attacks
func _on_Player_attack(type, player):
	if $Hitbox.shape.collide(transform, player.get_node("CollisionShape2D").shape, player.transform):  # Assuming you have a defined hitbox for the ant
		take_damage(player.attack_power)
		print("successful player attack")

# Take damage and apply knockback
func take_damage(damage):
	var final_damage = damage - player.defense
	health -= final_damage
	knockback()  # Apply knockback based on hit direction
	
	if health <= 0:
		start_death_sequence()

# Knockback logic
func knockback():
	var knockback_force = (global_position - player.global_position).normalized() * 200
	velocity = knockback_force
	move_and_slide()
# Declare a flag to track if the spear has been thrown
var has_thrown_spear = false

# Throw spear when the attack misses 3 times
func throw_spear():
	if has_thrown_spear:
		return  # Prevents spear throwing if it has already been thrown

	var spear_instance = $Spear
	spear_instance.global_position = global_position  # Set position to enemy's position before throw
	spear_instance.apply_impulse((player.global_position - global_position).normalized() * 800)
	attack_count = 0  # Reset the attack count after throwing the spear
	
	# Mark that the spear has been thrown
	has_thrown_spear = true
	can_attack = false  # Disable normal attacks after the spear is thrown

# Response from the player about the miss
func _on_enemy_spear_miss_response(should_count_as_miss: bool):
	if should_count_as_miss == false:
		attack_count += 1  # Increment the miss counter
		if attack_count >= max_misses:
			throw_spear()

# Function to reduce player health based on defense
func apply_damage_to_player(spear_damage):
	var final_damage = spear_damage - player.defense
	player.health -= final_damage

# Jaw attack logic
func perform_jaw_attack():
	if is_jaw_attacking:
		return  # Prevent attacking if the attack is already in progress
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if the player is in range for the jaw attack
	if distance_to_player <= jaw_attack_range:
		is_jaw_attacking = true
		$AnimationPlayer.play("jaw_windup")  # Play windup animation
		await get_tree().create_timer(jaw_attack_windup_time).timeout # Wait for the windup time

		# Check again if the player is still in range after windup
		distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= jaw_attack_range:
			$AnimationPlayer.play("jaw_attack")  # Play the attack animation
			player.take_damage(jaw_attack_damage)  # Apply damage to the player

		is_jaw_attacking = false

func spear_attack():
	var tween = create_tween().set_parallel()
	var original_position = $Spear_position
	tween.tween_property($Spear, "position", $Spear.position - Vector2(30, -30), 0.1)
	tween.tween_callback(spear_attack_collide)
	tween.chain().tween_property($Spear, "position", $Spear.position, 0.1)

func spear_attack_collide():
	print("spear attack collide called")
	_on_enemy_spear_miss_response(false)
	if not $Spear/CollisionShape2D.shape.collide($Spear.transform, player.get_node("CollisionShape2D").shape, player.transform):
		pass #_on_enemy_spear_miss_response(true) #emit_signal("spear_miss")
	
# Start death sequence and animation
func start_death_sequence():
	is_dead = true
	$AnimationPlayer.play("death")
	queue_free()  # Destroy the enemy after the animation

# Allow the enemy to take damage from player
func _on_enemy_hit(damage):
	take_damage(damage)


func _on_spear_attack_timer_timeout() -> void:
	can_spear_attack = true
