extends KinematicBody2D

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

onready var sprite = $BatSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox

const DeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * FRICTION)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * FRICTION)
			seek_player()
		WANDER:
			pass
		CHASE:
			var player = playerDetectionZone.player
			print(player)
			if player != null:
				var direction = player.global_position - global_position
				velocity = velocity.move_toward(direction.normalized() * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
	sprite.flip_h = velocity.x < 0 #obraca nietoperza w prawo-lewo
	velocity = move_and_slide(velocity)
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
	
func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 100;
	stats.health -= area.damage
	hurtbox.create_hit_effect()
	#queue_free()


func _on_Stats_no_health():
	var enemyDeathInstance = DeathEffect.instance()
	get_parent().add_child(enemyDeathInstance)
	enemyDeathInstance.global_position = self.global_position
	queue_free()
