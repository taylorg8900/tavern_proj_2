# Global script that keeps track of signals across scenes

extends Node

signal rope_entered(node_entered: Node2D, self_node: Node2D, x_pos: int)
signal rope_exited(node_entered: Node2D, self_node: Node2D)

#func rope_entered() -> void:
	#print('hello')
