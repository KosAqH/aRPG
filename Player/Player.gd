extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 125
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT

var stats = PlayerStats

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/Hitbox
onready var hurtbox = $Hurtbox

func _ready():
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true
	sword_hitbox.knockback_vector = roll_vector
	
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)	

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		sword_hitbox.knockback_vector = roll_vector
		# moving
		
		#animation stuff
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		
		animation_state.travel("Run")
		#moving stuff
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		#velocity += input_vector * ACCELERATION * delta
		#velocity = velocity.clamped(MAX_SPEED)
	else:
		# not moving
		
		#animation stuff
		animation_state.travel("Idle")
		
		#moving stuff
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	#move_and_collide(velocity * delta)
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("roll"):
		state = ROLL	
	
func attack_state(delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	velocity = velocity * 0.3
	state = MOVE
	
func roll_state(delta):
	velocity = ROLL_SPEED * roll_vector
	animation_state.travel("Roll")
	move()
	
func move():
	velocity = move_and_slide(velocity)


func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
