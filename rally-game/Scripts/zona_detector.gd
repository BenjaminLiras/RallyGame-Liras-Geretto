extends Area2D

@export var tipo_punto: int = 0
@export var velocidad_objetivo: float = 1.0
@export var mostrar_menu: bool = true

var gestor: GestorMultijugador = null

func _ready() -> void:
	area_entered.connect(_al_entrar_area)
	gestor = get_tree().root.get_node("Main/MultiplayerManager")

func _al_entrar_area(area: Area2D) -> void:
	if gestor == null or gestor.jugadores.is_empty():
		return
	for j in gestor.jugadores:
		if j.nodo == area.get_parent():
			j.zona_procesada = false
			break
