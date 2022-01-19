extends Area2D

onready var hitEffect = preload("res://Effects/HitEffect.tscn")

export var show_hit = true

func _on_Hurtbox_area_entered(area):
	if show_hit:
		var effect = hitEffect.instance()
		var main = get_tree().current_scene
		main.add_child(effect)
		effect.global_position = global_position
