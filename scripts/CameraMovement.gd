extends Marker3D

const LERP = 0.1

@export var player : Node3D
@export var yOffset : float

func _process(delta: float) -> void:
	position.x = lerpf(position.x, player.position.x, LERP)
	position.y = lerpf(position.y, player.position.y + yOffset, LERP)
	position.z = lerpf(position.z, player.position.z, LERP)
