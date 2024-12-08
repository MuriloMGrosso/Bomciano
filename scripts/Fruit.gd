extends Node3D

var index = 0
var destroy = false

func _process(delta: float) -> void:
	if destroy:
		if get_node("AnimationPlayer"):
			get_node("AnimationPlayer").queue_free()
		if scale.x < 0.01:
			queue_free()
		else:
			scale -= Vector3.ONE * delta * 4

# Define o indice no mapa
func set_index(_index: int) -> void:
	index = _index
