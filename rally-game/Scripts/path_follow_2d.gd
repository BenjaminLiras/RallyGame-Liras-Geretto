extends PathFollow2D

@export var velocidad: float = 300
@export var avanzando: bool = true
@export var calculo_velocidad: float = 1.0

@onready var menu_decision = $"../../CanvasLayer/Cartel"

var _curva_actual: Area2D = null


func _ready() -> void:
	loop = true
	$Area2D.area_entered.connect(_on_zona_curva_detectada)
	menu_decision.get_node("Button").pressed.connect(_on_acelerar)
	menu_decision.get_node("Button2").pressed.connect(_on_frenar)
	menu_decision.get_node("Button3").pressed.connect(_on_segunda)
				

func _process(delta: float) -> void:
	if not avanzando:
		return
	progress += velocidad * calculo_velocidad * delta
	

func _on_zona_curva_detectada(area: Area2D) -> void:
	if _curva_actual == null:
		_curva_actual = area
		avanzando = false
		menu_decision.visible = true
	

func tomar_decision(modificador_velocidad: float) -> void:
	calculo_velocidad = modificador_velocidad
	_curva_actual = null
	avanzando = true
	menu_decision.visible = false


func _on_acelerar() -> void:
	tomar_decision(1.3)


func _on_frenar() -> void:
	tomar_decision(0.7)


func _on_segunda() -> void:
	tomar_decision(0.5)
