extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")
func play_effect():
	var grassEffect = GrassEffect.instance()
	var world = get_tree().current_scene
	grassEffect.global_position = global_position
	world.add_child(grassEffect)
	
func _on_Hurtbox_area_entered(area):
	play_effect()
	queue_free()
