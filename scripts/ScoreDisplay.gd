extends Node

func _process(delta: float) -> void:
	self.text = "Pontuação: " + str(get_parent().score) + '\n' + "Vida: " + str(get_parent().life)
