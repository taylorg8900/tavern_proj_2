extends Node2D

func _on_body_entered(body: Node2D) -> void:
	Signals.rope_entered.emit(get_parent().position.x)
