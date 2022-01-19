extends KinematicBody2D

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

onready var stats = $Stats

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
			velocity.move_toward(Vector2.ZERO, 200 * FRICTION)
		WANDER:
			pass
		CHASE:
			pass

func seek_player():
	pass
	
func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 100;
	stats.health -= area.damage
	if stats.health <= 0:
		queue_free()
	#queue_free()


func _on_Stats_no_health():
	var enemyDeathInstance = DeathEffect.instance()
	get_parent().add_child(enemyDeathInstance)
	enemyDeathInstance.global_position = self.global_position
	queue_free()
