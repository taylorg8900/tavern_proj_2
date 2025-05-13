# Global script that keeps track of signals across scenes

extends Node

signal rope_entered(x_pos: int, node: Node2D)
signal rope_exited(node: Node2D)

#func rope_entered() -> void:
	#print('hello')
