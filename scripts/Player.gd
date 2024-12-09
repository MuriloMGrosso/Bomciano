extends Node3D

var index = 0
var timeToMove = 1
var dead = false
const SPEED = 3

# Chamada em cada frame
func _process(delta: float) -> void:
	if dead:
		return
	
	_movement(delta)
	get_parent().playerTileAction(index)
	
	var targetPos = get_parent().getPositionFromIndex(index)
	var dist = abs((targetPos - position).length())
	
	position.x = move_toward(position.x, targetPos.x, SPEED * (1 + dist) * delta)
	position.y = move_toward(position.y, targetPos.y, SPEED * (1 + dist) * delta)
	position.z = move_toward(position.z, targetPos.z, SPEED * (1 + dist) * delta)
	get_node("Pivot/Kaka_animado/AnimationPlayer").speed_scale = (1 + dist)
	
	if dist > 0.05:
		get_node("Pivot/Kaka_animado/AnimationPlayer").play("Andando - 29 frames")
	else:
		get_node("Pivot/Kaka_animado/AnimationPlayer").play("Idle - 50 frames")

# Movimentação do jogador
func _movement(delta : float) -> void:
	# Tamanho dos tiles
	var tileWidth = get_parent().tileWidth
	var tileHeight = get_parent().tileHeight
	
	# Se a tecla for pressionada, vira para a ireção desejada e verifica se pode se mover.
	# Em caso positivo, jogador é movido para a nova posição.
	if Input.is_action_just_pressed("up") || Input.is_action_pressed("up") && timeToMove < 0 :
		look_at(position + Vector3.RIGHT, Vector3.UP)
		if(get_parent().canMoveUp(index)):
			index += get_parent().mapWidth
			play_walk_sound()
		
	if Input.is_action_just_pressed("down") || Input.is_action_pressed("down") && timeToMove < 0:
		look_at(position + Vector3.LEFT, Vector3.UP)
		if(get_parent().canMoveDown(index)):
			index -= get_parent().mapWidth
			play_walk_sound()
		
	if Input.is_action_just_pressed("right") || Input.is_action_pressed("right") && timeToMove < 0:
		look_at(position + Vector3.BACK, Vector3.UP)
		if(get_parent().canMoveRight(index)):
			index += 1
			play_walk_sound()
		
	if Input.is_action_just_pressed("left") || Input.is_action_pressed("left") && timeToMove < 0:
		look_at(position + Vector3.FORWARD, Vector3.UP)
		if(get_parent().canMoveLeft(index)):
			index -= 1
			play_walk_sound()
	
	if  Input.is_action_pressed("up") ||  Input.is_action_pressed("down") ||  Input.is_action_pressed("left") ||  Input.is_action_pressed("right"):
		if timeToMove < 0:
			timeToMove = 0.15	
		else:
			timeToMove -= delta
	else:
		timeToMove = 0.3

# Define o indice do jogador no mapa
func set_index(_index: int) -> void:
	index = _index
	
func play_walk_sound():
	$Audio.stream = load("res://sfxs/Passos/Passo_"+str(randi_range(1,8))+".wav")
	$Audio.play()
	
func my_position() -> int:
	return index
