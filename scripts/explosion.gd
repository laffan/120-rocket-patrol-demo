extends AnimatedSprite2D


func _on_animation_finished() -> void:
	if animation == 'explode':
		queue_free()
