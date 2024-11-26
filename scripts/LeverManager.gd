extends Node3D

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
var tiles = {}

var life = 3
var score = 0
var maxPlayerHeight = 0

const EMPTY_TILE = -1
const DEFAULT_TILE = 0
const PLAYER_SPAWN = 1
const FRIEND_SPAWN = 2
const ENEMY_SPAWN = 3
const FRUIT_SPAWN = 4

const MAX_TILE_WIDTH = 10
const MAX_MAP_HEIGHT = 50

var enemyRate = 10
var friendRate = 2
var fruitRate = 5
var emptyRate = 100

var lastH : int
var lastW : int

var rng

# Primeira chamada
func _ready() -> void:
	rng = RandomNumberGenerator.new()
	
	_load_random_tilemap()

func _getTileMap(w : int, h : int):
	h -= max(maxPlayerHeight - MAX_MAP_HEIGHT, 0)
	if w < 0 || h < 0:
		return EMPTY_TILE
	return tileMap[w][h]
func _getHeightMap(w : int, h : int):
	h -= max(maxPlayerHeight - MAX_MAP_HEIGHT, 0)
	if w < 0 || h < 0:
		return 0
	return heightMap[w][h]
func _setTileMap(w : int, h : int, value : int) -> void:
	h -= max(maxPlayerHeight - MAX_MAP_HEIGHT, 0)
	tileMap[w][h] = value
func _setHeightMap(w : int, h : int, value : int) -> void:
	h -= max(maxPlayerHeight - MAX_MAP_HEIGHT, 0)
	heightMap[w][h] = value

# Cria um mapa aleatório
func _load_random_tilemap() -> void:
	# Tamanho do mapa
	mapWidth = MAX_TILE_WIDTH
	for w in mapWidth:
		tileMap.append([])
		heightMap.append([])
	
	for h in MAX_MAP_HEIGHT:
		_createNextTerrainLine()
	
	_setTileMap(mapWidth/2, 0, PLAYER_SPAWN)
	_create_tile_at(mapWidth/2, 0)
	_random_walk(mapWidth/2, 0)
	
func _random_walk(w : int, h : int) -> void:	
	var dir = rng.randi_range(1, 100)
	var type = rng.randi_range(1, 100)
	
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
	
	if _getTileMap(w,h) > -1:
		pass
	elif type < 2:
		_setTileMap(w,h,FRIEND_SPAWN)
	elif type < 5:
		_setTileMap(w,h,FRUIT_SPAWN)
	elif type < 10:
		_setTileMap(w,h,ENEMY_SPAWN)
	else:		
		_setTileMap(w,h,DEFAULT_TILE)
	
	_create_tile_at(w, h)
	
	lastH = h
	lastW = w
	
	if h < mapHeight - 1:
		_random_walk(w, h)
func _createNextTerrainLine() -> void:
	for w in mapWidth:
		tileMap[w].append(EMPTY_TILE)	
		heightMap[w].append((mapHeight + w) / 2 + 10)
	mapHeight += 1
func _removeFirstTerrainLine() -> void:
	for w in mapWidth:
		tileMap[w].remove_at(0)
		heightMap[w].remove_at(0)
		
		_remove_tile_at(w, maxPlayerHeight - MAX_MAP_HEIGHT)

func _create_tile_at(w : int, h : int) -> void:
	if _getTileMap(w, h) < 0:
		return
	
	# Cria um tile na posição atual
	var tile = tileScene.instantiate()
	var pos = _getPositionFromCoords(w, h)
	var index = w + h * mapWidth
	tile.scale = Vector3(tileWidth, pos.y, tileWidth)
	tile.position = pos
	tile.name = 'Tile_' + str(index)
	tiles[str(index)] = tile
	add_child(tile)
	
	# Adições específicas de cada tile
	match _getTileMap(w, h):
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
func _remove_tile_at(w : int, h : int) -> void:
	if _getTileMap(w, h) < 0:
		return
	
	# Remove tile na posição atual
	var index = w + h * mapWidth
	if not str(index) in tiles.keys():
		print(index)
	else:
		var tile = tiles[str(index)]
		tile.queue_free()
		tiles.erase(str(index))
	
	# Remove objetos do tile
	for e in enemies:
		if e.index == index:
			e.queue_free()
			enemies.erase(e)
	for f in fruits:
		if f.index == index:
			f.queue_free()
			fruits.erase(f)
	for f in friends:
		if f.index == index:
			f.queue_free()
			friends.erase(f)

# Retorna a posição do indice ou coordenada desejados
func _getPositionFromCoords(w: int, h: int) -> Vector3:
	return Vector3(-h * tileWidth, _getHeightMap(w,h) * tileHeight, -w * tileWidth)
func getPositionFromIndex(index: int) -> Vector3:
	var w = fmod(index, mapWidth)
	var h = index / mapWidth
	return _getPositionFromCoords(w, h)

# Funções para verificar a validade do movimento em cada direção
func canMoveUp(index: int) -> bool:
	var w = fmod(index, mapWidth)
	var h = index / mapWidth + 1
	return h < mapHeight && _getTileMap(w,h) > -1 && _getHeightMap(w,h) * tileHeight - getPositionFromIndex(index).y <= 1
func canMoveDown(index: int) -> bool:
	var w = fmod(index, mapWidth)
	var h = index / mapWidth - 1
	return h > -1 && _getTileMap(w,h) > -1 && _getHeightMap(w,h) * tileHeight - getPositionFromIndex(index).y <= 1
func canMoveRight(index: int) -> bool:
	var w = fmod(index, mapWidth) + 1
	var h = index / mapWidth
	return w < mapWidth && _getTileMap(w,h) > -1 && _getHeightMap(w,h) * tileHeight - getPositionFromIndex(index).y <= 1
func canMoveLeft(index: int) -> bool:
	var w = fmod(index, mapWidth) - 1
	var h = index / mapWidth
	return w > -1 && _getTileMap(w,h) > -1 && _getHeightMap(w,h) * tileHeight - getPositionFromIndex(index).y <= 1

# Interações do jogador com os elementos
func playerTileAction(index: int) -> void:
	var h = index / mapWidth
	
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
			
	if h > maxPlayerHeight:
		_createNextTerrainLine()
		if fmod(h, (MAX_MAP_HEIGHT - 1)/2) == 0:
			_random_walk(lastW, lastH)
		if maxPlayerHeight >= MAX_MAP_HEIGHT:
			_removeFirstTerrainLine()
		maxPlayerHeight = h
