extends Node

export (int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

signal no_health
signal health_changed(h)
signal max_health_changed(h)

func set_health(h):
	health = h
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_max_health(h):
	max_health = h
	self.health = min(max_health, health)
	emit_signal("max_health_changed", h)
	
func _ready():
	self.health = max_health
