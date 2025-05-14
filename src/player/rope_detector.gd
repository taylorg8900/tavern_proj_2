extends Area2D



func _on_area_entered(area: Area2D) -> void:
	if area is Rope:
		Signals.rope_entered.emit(area.get_parent(), area, area.position.x)


func _on_area_exited(area: Area2D) -> void:
	if area is Rope:
		Signals.rope_exited.emit(area.get_parent(), area)
