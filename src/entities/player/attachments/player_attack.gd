extends attack

func set_facing(should_face_right :bool):
	if should_face_right:
		$sprite.flip_h = false
		$collider/CollisionShape2D.position = Vector2(+5,-3)
	else:
		$sprite.flip_h = true
		$collider/CollisionShape2D.position = Vector2(-5,-3)

func _on_collider_body_entered(body):
	if body.is_damagable():
		body.damage(1)

func _on_ap_animation_finished(_anim_name):
	$collider/CollisionShape2D.disabled = true
	queue_free()
