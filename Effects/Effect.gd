extends AnimatedSprite

func _ready():
	frame = 0
	play("Animate")
	self.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")


func _on_AnimatedSprite_animation_finished():
	queue_free()
