extends Node3D

@export var tilemap: CompressedTexture2D
@export var tileScene: PackedScene
@export var tileWidth: float
@export var tileHeight: float

var mapArray = []
var mapWidth = 0
var mapHeight = 0

func _ready() -> void:
	_load_terrain()

func _process(delta: float) -> void:
	pass

func _load_terrain() -> void:
	var image = tilemap.get_image()
	
	mapWidth = image.get_width()
	mapHeight = image.get_height()
	
	for w in mapWidth:
		mapArray.append([])
		for h in mapHeight:
			match image.get_pixel( w, mapHeight - h):
				Color(1,1,1,1):
					mapArray[w].append(0)
				Color(0,1,0,1):
					mapArray[w].append(1)
				_:
					mapArray[w].append(-1)
	
	for w in mapWidth:
		mapArray.append([])
		for h in mapHeight:
			if mapArray[w][h] < 0:  #Espaço vazio
				continue
				
			var tile = tileScene.instantiate()
			tile.scale = Vector3(tileWidth, tileHeight, tileWidth)
			tile.position = Vector3(-h * tileWidth, (w + h - 0.5) * tileHeight, -w * tileWidth)
			add_child(tile)
			
			match mapArray[w][h]:
				0: #Tile padrão
					pass
				1: #Spawn do player
					$Player.position = Vector3(-h * tileWidth, (w + h) * tileHeight, -w * tileWidth)
					$Player.set_index(w + h * mapWidth)

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
