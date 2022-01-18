extends KinematicBody2D

var knockback = Vector2.ZERO

onready var stats = $Stats

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 100;
	stats.health -= area.damage
	if stats.health <= 0:
		queue_free()
	#queue_free()


func _on_Stats_no_health():
	queue_free()
