extends Node3D

@export var speed : float
@export var width : float

func _process(delta: float) -> void:
	if position.x > width:
		position.x = -width
	elif position.x < -width:
		position.x = width
	else:
		position.x += delta * speed
