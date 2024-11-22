extends Marker3D

@export var player : Node3D
@export var yOffset : float
@export var lerp: float

# Chamada em cada frame
func _process(delta: float) -> void:
	_follow_target(player)

# Segue alvo desejado
func _follow_target(target : Node3D) -> void:
	position = lerp(position, target.position + yOffset * Vector3.UP, lerp)
