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

# Move o amigo
func _move() -> void:
	# Tamanho dos tiles
	var tileWidth = get_parent().tileWidth
	var tileHeight = get_parent().tileHeight
	var rng = RandomNumberGenerator.new()

	# Tenta se mover na direção atual. Se não for possível, muda para um direção aleatória
	match currentDir:
		UP_DIR:
			if(get_parent().canMoveUp(index)):
				index += get_parent().mapWidth
				look_at(position + Vector3.RIGHT, Vector3.UP)
			else:
				currentDir = rng.randi_range(0, 3)
				moveTimer = -1	
		DOWN_DIR:
			if(get_parent().canMoveDown(index)):
				index -= get_parent().mapWidth
				look_at(position + Vector3.LEFT, Vector3.UP)
			else:
				currentDir = rng.randi_range(0, 3)
				moveTimer = -1
		RIGHT_DIR:
			if(get_parent().canMoveRight(index)):
				index += 1
				look_at(position + Vector3.BACK, Vector3.UP)
			else:
				currentDir = rng.randi_range(0, 3)
				moveTimer = -1
		LEFT_DIR:
			if(get_parent().canMoveLeft(index)):
				index -= 1
				look_at(position + Vector3.FORWARD, Vector3.UP)
			else:
				currentDir = rng.randi_range(0, 3)
				moveTimer = -1

	position = get_parent().getPositionFromIndex(index)

# Define o indice no mapa
func set_index(_index: int) -> void:
	index = _index
