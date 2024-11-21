extends Node3D

var index = 0

func _process(delta: float) -> void:
	var tileWidth = get_parent().tileWidth
	var tileHeight = get_parent().tileHeight
	
	if Input.is_action_just_pressed("up"):
		if(get_parent().canMoveUp(index)):
			position.x -= tileWidth
			position.y += tileHeight
			index += get_parent().mapWidth
		look_at(position + Vector3.RIGHT, Vector3.UP)
		
	if Input.is_action_just_pressed("down"):
		if(get_parent().canMoveDown(index)):
			position.x += tileWidth
			position.y -= tileHeight
			index -= get_parent().mapWidth
		look_at(position + Vector3.LEFT, Vector3.UP)
		
	if Input.is_action_just_pressed("right"):
		if(get_parent().canMoveRight(index)):
			position.z -= tileWidth
			position.y += tileHeight
			index += 1
		look_at(position + Vector3.BACK, Vector3.UP)	
		
	if Input.is_action_just_pressed("left"):
		if(get_parent().canMoveLeft(index)):
			position.z += tileWidth
			position.y -= tileHeight
			index -= 1
		look_at(position + Vector3.FORWARD, Vector3.UP)

func set_index(_index: int) -> void:
	index = _index
