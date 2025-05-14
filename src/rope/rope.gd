extends Node2D

func _on_body_entered(body: Node2D) -> void:
	Signals.rope_entered.emit(body, get_parent(), get_parent().position.x)

func _on_body_exited(body: Node2D) -> void:
	Signals.rope_exited.emit(body, get_parent())
