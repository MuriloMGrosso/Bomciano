extends Node3D

@export var timeToMove = 1.0

const UP_DIR = 0
const DOWN_DIR = 1
const RIGHT_DIR = 2
const LEFT_DIR = 3

var index = 0
var currentDir = LEFT_DIR
var moveTimer : float

# Primeira chamada
func _ready() -> void:
	moveTimer = timeToMove

# Chamada em cada frame
func _process(delta: float) -> void:
	if moveTimer < 0:
		moveTimer = timeToMove
		_move()
	else:
		moveTimer -= delta

# Move o inimigo
func _move() -> void:
	# Tamanho dos tiles
	var tileWidth = get_parent().tileWidth
	var tileHeight = get_parent().tileHeight
	var rng = RandomNumberGenerator.new()
	var player_position = _index_to_arr(get_parent().playerPosition())
	print("Player", player_position)
	print("Enemy", my_position())
	print(dist_manhattan(player_position, my_position()))
	# Tenta se mover na direção atual. Se não for possível, muda para um direção aleatória
	var bestMove = best_move(player_position)
	match bestMove:
		UP_DIR:
			if(get_parent().alienCanMoveUp(index)):
				index += get_parent().mapWidth
				look_at(position + Vector3.RIGHT, Vector3.UP)
				play_walk_sound()
			else:
				currentDir = rng.randi_range(0, 3)
				moveTimer = -1	
		DOWN_DIR:
			if(get_parent().alienCanMoveDown(index)):
				index -= get_parent().mapWidth
				look_at(position + Vector3.LEFT, Vector3.UP)
				play_walk_sound()
			else:
				currentDir = rng.randi_range(0, 3)
				moveTimer = -1
		RIGHT_DIR:
			if(get_parent().alienCanMoveRight(index)):
				index += 1
				look_at(position + Vector3.BACK, Vector3.UP)
				play_walk_sound()
			else:
				currentDir = rng.randi_range(0, 3)
				moveTimer = -1
		LEFT_DIR:
			if(get_parent().alienCanMoveLeft(index)):
				index -= 1
				look_at(position + Vector3.FORWARD, Vector3.UP)
				play_walk_sound()
			else:
				currentDir = rng.randi_range(0, 3)
				moveTimer = -1

	position = get_parent().getPositionFromIndex(index)


# Define o indice do inimigo no mapa
func set_index(_index: int) -> void:
	index = _index

func _abs(value: float) -> float:
	if value < 0:
		return -value
	return value
	
func dist_manhattan(first: Array, second: Array) -> float:
	return _abs(first[0]-second[0]) + _abs(first[1]-second[1])
	
func _index_to_arr(_index:int) -> Array:
	var x = float(_index % get_parent().mapWidth)
	var y = float((_index - x) / get_parent().mapWidth)
	return [x,y]
	
func my_position() -> Array:
	return _index_to_arr(index)


func best_move(player_position: Array) -> int:
	var dir = -1
	var actual_dist = dist_manhattan(my_position(), player_position)
	print(actual_dist)
	var _index = int(player_position[0] + player_position[1] * get_parent().mapWidth)
	var enemy_position = my_position()
	
	if(get_parent().alienCanMoveUp(_index)):
		var new_dist = dist_manhattan(player_position, [enemy_position[0], enemy_position[1]+ 1.0])
		if new_dist < actual_dist || dir == -1:
			dir = UP_DIR
			actual_dist = new_dist
	if(get_parent().alienCanMoveDown(_index)):
		var new_dist = dist_manhattan(player_position, [enemy_position[0], enemy_position[1]- 1.0])
		if new_dist < actual_dist || dir == -1:
			dir = DOWN_DIR
			actual_dist = new_dist
	if(get_parent().alienCanMoveRight(_index)):
		var new_dist = dist_manhattan(player_position, [enemy_position[0]+1.0, enemy_position[1]])
		if new_dist < actual_dist || dir == -1:
			dir = RIGHT_DIR
			actual_dist = new_dist
	if(get_parent().alienCanMoveLeft(_index)):
		var new_dist = dist_manhattan(player_position,[enemy_position[0]-1.0, enemy_position[1]] )
		if new_dist < actual_dist || dir == -1:
			dir = LEFT_DIR
			actual_dist = new_dist
	return dir

func play_walk_sound():
	$Audio.stream = load("res://sfxs/Passos/Passo_"+str(randi_range(1,8))+".wav")
	$Audio.play()
