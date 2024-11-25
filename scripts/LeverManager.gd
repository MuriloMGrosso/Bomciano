extends Node3D

@export var pelinNoise: FastNoiseLite
@export var mapImage: CompressedTexture2D
@export var tileScene: PackedScene
@export var tileWidth: float
@export var tileHeight: float
@export var friend: PackedScene
@export var enemy: PackedScene
@export var fruit: PackedScene
@export var spawn: PackedScene

var tileMap = []
var heightMap = []
var mapWidth = 0
var mapHeight = 0

var enemies = []
var friends = []
var fruits = []

var life = 3
var score = 0

const EMPTY_TILE_COLOR = Color.BLACK
const DEFAULT_TILE_COLOR = Color.WHITE
const PLAYER_SPAWN_COLOR = Color.GREEN
const FRIEND_SPAWN_COLOR = Color.BLUE
const ENEMY_SPAWN_COLOR = Color.RED
const FRUIT_SPAWN_COLOR = Color.YELLOW

const EMPTY_TILE = -1
const DEFAULT_TILE = 0
const PLAYER_SPAWN = 1
const FRIEND_SPAWN = 2
const ENEMY_SPAWN = 3
const FRUIT_SPAWN = 4

var enemyRate = 10
var friendRate = 2
var fruitRate = 5
var emptyRate = 100

var rng

# Primeira chamada
func _ready() -> void:
	rng = RandomNumberGenerator.new()
	
	#_load_tilemap_from_image(mapImage.get_image())
	_load_random_tilemap()
	_create_terrain()

# Transforma cada pixel da imagem em valores inteiros representando cada tile
func _load_tilemap_from_image(image: Image) -> void:
	var rng = RandomNumberGenerator.new()
	
	# Tamanho do mapa
	mapWidth = image.get_width()
	mapHeight = image.get_height()
	
	# Para cada pixel na imagem
	for w in mapWidth:
		tileMap.append([])
		heightMap.append([])
		for h in mapHeight:
			heightMap[w].append((h + w) / 2 + 10)
			match image.get_pixel( w, mapHeight - h):
				DEFAULT_TILE_COLOR: # Tile padrão
					tileMap[w].append(DEFAULT_TILE)
				PLAYER_SPAWN_COLOR: # Tile de spawn do jogador
					tileMap[w].append(PLAYER_SPAWN)
				FRIEND_SPAWN_COLOR: # Tile de spawn do Bomciano
					tileMap[w].append(FRIEND_SPAWN)
				ENEMY_SPAWN_COLOR: # Tile de spawn do Mauciano
					tileMap[w].append(ENEMY_SPAWN)
				FRUIT_SPAWN_COLOR: # Tile de spawn da fruta
					tileMap[w].append(FRUIT_SPAWN)
				_: # Caso contrário, tile vazio
					tileMap[w].append(EMPTY_TILE)
					
# Cria um mapa aleatório
func _load_random_tilemap() -> void:
	# Tamanho do mapa
	mapWidth = 10
	mapHeight = 100
	for w in mapWidth:
		tileMap.append([])
		heightMap.append([])
		for h in mapHeight:
			heightMap[w].append((h + w) / 2 + 10)
			tileMap[w].append(EMPTY_TILE)
	
	_random_walk(0,0, 100)	
	_random_walk(0,0, 100)	
	_random_walk(0,0, 100)	
	tileMap[0][0] = PLAYER_SPAWN
	
func _random_walk(w : int, h : int, left : int) -> void:	
	var dir = rng.randi_range(1, 100)
	var type = rng.randi_range(1, 100)

	if type < 2:
		tileMap[w][h] = FRIEND_SPAWN
	elif type < 7:
		tileMap[w][h] = FRUIT_SPAWN
	elif type < 17:
		tileMap[w][h] = ENEMY_SPAWN
	else:		
		tileMap[w][h] = DEFAULT_TILE
	
	if dir < 10:
		h -= 1
	elif dir < 40:
		w += 1
	elif dir < 70:
		w -= 1
	else:
		h += 1
	
	w = clamp(w, 0, mapWidth - 1)
	h = clamp(h, 0, mapHeight - 1)
	
	if tileMap[w][h] < 0:
		left -= 1
	if left > 0:
		_random_walk(w, h, left)

# Cria os objetos do terreno
func _create_terrain() -> void:
	# Para cada elemento da array
	for w in mapWidth:
		tileMap.append([])
		for h in mapHeight:
			# Se é espaço vazio, vai para próxima iteração
			if tileMap[w][h] < 0:
				continue
			
			# Cria um tile na posição atual
			var tile = tileScene.instantiate()
			var pos = _getPositionFromCoords(w, h)
			var index = w + h * mapWidth
			tile.scale = Vector3(tileWidth, pos.y, tileWidth)
			tile.position = pos
			add_child(tile)
			
			# Adições específicas de cada tile
			match tileMap[w][h]:
				DEFAULT_TILE: # Tile padrão
					pass
				PLAYER_SPAWN: # Spawn do player
					$Player.position = pos
					$Player.set_index(index)
					var obj = spawn.instantiate()
					obj.position = pos
					add_child(obj)
				FRIEND_SPAWN: # Spawn do Bomciano
					var obj = friend.instantiate()
					obj.position = pos
					obj.set_index(index)
					friends.append(obj)
					add_child(obj)
				ENEMY_SPAWN: # Spawn do Mauciano
					var obj = enemy.instantiate()
					obj.position = pos
					obj.set_index(index)
					enemies.append(obj)
					add_child(obj)
				FRUIT_SPAWN: # Spawn da fruta
					var obj = fruit.instantiate()
					obj.position = pos
					obj.set_index(index)
					fruits.append(obj)
					add_child(obj)

# Retorna a posição do indice ou coordenada desejados
func _getPositionFromCoords(w: int, h: int) -> Vector3:
	return Vector3(-h * tileWidth, heightMap[w][h], -w * tileWidth)
func getPositionFromIndex(index: int) -> Vector3:
	var w = fmod(index, mapWidth)
	var h = index / mapWidth
	return _getPositionFromCoords(w, h)

# Funções para verificar a validade do movimento em cada direção
func canMoveUp(index: int) -> bool:
	var w = fmod(index, mapWidth)
	var h = index / mapWidth + 1
	return h < mapHeight && tileMap[w][h] > -1 && heightMap[w][h] - getPositionFromIndex(index).y <= 1
func canMoveDown(index: int) -> bool:
	var w = fmod(index, mapWidth)
	var h = index / mapWidth - 1
	return h > -1 && tileMap[w][h] > -1 && heightMap[w][h] - getPositionFromIndex(index).y <= 1
func canMoveRight(index: int) -> bool:
	var w = fmod(index, mapWidth) + 1
	var h = index / mapWidth
	return w < mapWidth && tileMap[w][h] > -1 && heightMap[w][h] - getPositionFromIndex(index).y <= 1
func canMoveLeft(index: int) -> bool:
	var w = fmod(index, mapWidth) - 1
	var h = index / mapWidth
	return w > -1 && tileMap[w][h] > -1 && heightMap[w][h] - getPositionFromIndex(index).y <= 1

# Interações do jogador com os elementos
func playerTileAction(index: int) -> void:
	for e in enemies:
		if e.index == index:
			e.queue_free()
			enemies.erase(e)
			life -= 1
			#Reinicia a cena se a vida for 0
			if life < 1:
				get_tree().reload_current_scene()
	
	for f in fruits:
		if f.index == index:
			f.queue_free()
			fruits.erase(f)
			if life < 3:
				life += 1
	
	for f in friends:
		if f.index == index:
			f.queue_free()
			friends.erase(f)
			score += 1
