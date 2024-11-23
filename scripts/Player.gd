extends Node3D

var index = 0

# Chamada em cada frame
func _process(delta: float) -> void:
	_movement()
	get_parent().playerTileAction(index)

# Movimentação do jogador
func _movement() -> void:
	# Tamanho dos tiles
	var tileWidth = get_parent().tileWidth
	var tileHeight = get_parent().tileHeight
	
	# Se a tecla for pressionada, vira para a ireção desejada e verifica se pode se mover.
	# Em caso positivo, jogador é movido para a nova posição.
	if Input.is_action_just_pressed("up"):
		look_at(position + Vector3.RIGHT, Vector3.UP)
		if(get_parent().canMoveUp(index)):
			position.x -= tileWidth
			position.y += tileHeight
			index += get_parent().mapWidth
		
	if Input.is_action_just_pressed("down"):
		look_at(position + Vector3.LEFT, Vector3.UP)
		if(get_parent().canMoveDown(index)):
			position.x += tileWidth
			position.y -= tileHeight
			index -= get_parent().mapWidth
		
	if Input.is_action_just_pressed("right"):
		look_at(position + Vector3.BACK, Vector3.UP)
		if(get_parent().canMoveRight(index)):
			position.z -= tileWidth
			position.y += tileHeight
			index += 1
		
	if Input.is_action_just_pressed("left"):
		look_at(position + Vector3.FORWARD, Vector3.UP)
		if(get_parent().canMoveLeft(index)):
			position.z += tileWidth
			position.y -= tileHeight
			index -= 1

# Define o indice do jogador no mapa
func set_index(_index: int) -> void:
	index = _index
