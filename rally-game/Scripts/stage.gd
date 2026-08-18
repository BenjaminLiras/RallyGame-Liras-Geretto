extends Path2D

var gestor: GestorMultijugador = null

func _ready() -> void:
	gestor = get_tree().root.get_node_or_null("Main/MultiplayerManager")
	if gestor == null:
		push_error("No se encontro GestorMultijugador")
		return
	
	var auto_1 = get_node_or_null("prota")
	var auto_2 = get_node_or_null("Car2")

	if auto_1 and auto_2:
		gestor.inicializar_jugadores([auto_1, auto_2])
	else:
		push_error("No se encontraron los autos")

func _process(_delta: float) -> void:
	pass