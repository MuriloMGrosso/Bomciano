extends Node3D

@export var mapImage: CompressedTexture2D
@export var tileScene: PackedScene
@export var tileWidth: float
@export var tileHeight: float
@export var enemy: PackedScene

var mapArray = []
var mapWidth = 0
var mapHeight = 0

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

# Primeira chamada
func _ready() -> void:
	_load_tilemap_from_image(mapImage.get_image())
	_create_terrain()

# Transforma cada pixel da imagem em valores inteiros representando cada tile
func _load_tilemap_from_image(image: Image) -> void:
	# Tamanho do mapa
	mapWidth = image.get_width()
	mapHeight = image.get_height()
	
	# Para cada pixel na imagem
	for w in mapWidth:
		mapArray.append([])
		for h in mapHeight:
			match image.get_pixel( w, mapHeight - h):
				DEFAULT_TILE_COLOR: # Tile padrão
					mapArray[w].append(DEFAULT_TILE)
				PLAYER_SPAWN_COLOR: # Tile de spawn do jogador
					mapArray[w].append(PLAYER_SPAWN)
				FRIEND_SPAWN_COLOR: # Tile de spawn do Bomciano
					mapArray[w].append(FRIEND_SPAWN)
				ENEMY_SPAWN_COLOR: # Tile de spawn do Mauciano
					mapArray[w].append(ENEMY_SPAWN)
				FRUIT_SPAWN_COLOR: # Tile de spawn da fruta
					mapArray[w].append(FRUIT_SPAWN)
				_: # Caso contrário, tile vazio
					mapArray[w].append(EMPTY_TILE)

# Cria os objetos do terreno
func _create_terrain() -> void:
	# Para cada elemento da array
	for w in mapWidth:
		mapArray.append([])
		for h in mapHeight:
			# Se é espaço vazio, vai para próxima iteração
			if mapArray[w][h] < 0:
				continue
			
			# Cria um tile na posição atual
			var tile = tileScene.instantiate()
			var pos = Vector3(-h * tileWidth, (w + h) * tileHeight, -w * tileWidth)
			var index = w + h * mapWidth
			tile.scale = Vector3(tileWidth, (w + h) * tileHeight, tileWidth)
			tile.position = pos
			add_child(tile)
			
			# Adições específicas de cada tile
			match mapArray[w][h]:
				DEFAULT_TILE: # Tile padrão
					pass
				PLAYER_SPAWN: # Spawn do player
					$Player.position = pos
					$Player.set_index(index)
				FRIEND_SPAWN: # Spawn do Bomciano
					pass
				ENEMY_SPAWN: # Spawn do Mauciano
					var mob = enemy.instantiate()
					mob.position = pos
					mob.set_index(index)
					add_child(mob)
				FRUIT_SPAWN: # Spawn da fruta
					pass

# Funções para verificar a validade do movimento em cada direção
func canMoveUp(index: int) -> bool:
	var w = fmod(index, mapWidth)
	var h = index / mapWidth + 1
	return h < mapHeight && mapArray[w][h] > -1	
func canMoveDown(index: int) -> bool:
	var w = fmod(index, mapWidth)
	var h = index / mapWidth - 1
	return h > -1 && mapArray[w][h] > -1
func canMoveRight(index: int) -> bool:
	var w = fmod(index, mapWidth) + 1
	var h = index / mapWidth
	return w < mapWidth && mapArray[w][h] > -1
func canMoveLeft(index: int) -> bool:
	var w = fmod(index, mapWidth) - 1
	var h = index / mapWidth
	return w > -1 && mapArray[w][h] > -1
