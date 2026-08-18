extends Area2D

@export var tipo_punto: int = 0  # 0=decision, 1=recuperacion
@export var velocidad_objetivo: float = 1.0
@export var mostrar_menu: bool = true

var manager: MultiplayerManager = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	manager = get_tree().root.get_node("Main/MultiplayerManager")

func _on_area_entered(area: Area2D) -> void:
	if manager == null or manager.players.is_empty():
		return
	
	# Detectar cual jugador entró
	for p in manager.players:
		if p.pathfollow == area.get_parent():
			p.ya_proceso_zona = false
			break
