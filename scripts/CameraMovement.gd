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
	
	var i = 0
	for child in $Background.get_children():
		child.position.y = lerp(child.position.y, i * (position.y - (target.position.y + yOffset)), lerp)
		i += 1.0/$Background.get_child_count()
