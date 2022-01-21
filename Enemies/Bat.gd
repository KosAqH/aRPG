extends KinematicBody2D

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var TARGET_WANDER_THRESHOLD = 1

onready var sprite = $BatSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController


const DeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

onready var state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			check_for_new_state()
		WANDER:
			seek_player()
			check_for_new_state()
			var direction = global_position.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			
			if global_position.distance_to(wanderController.target_position) <= TARGET_WANDER_THRESHOLD:
				update_wander()
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = player.global_position - global_position
				velocity = velocity.move_toward(direction.normalized() * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
	sprite.flip_h = velocity.x < 0 #obraca nietoperza w prawo-lewo
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
		
	velocity = move_and_slide(velocity)
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 150;
	stats.health -= area.damage
	hurtbox.create_hit_effect()
	#queue_free()

func _on_Stats_no_health():
	var enemyDeathInstance = DeathEffect.instance()
	get_parent().add_child(enemyDeathInstance)
	enemyDeathInstance.global_position = self.global_position
	queue_free()

func check_for_new_state():
	if wanderController.get_time_left() == 0:
		update_wander()

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_time(rand_range(1,3))
