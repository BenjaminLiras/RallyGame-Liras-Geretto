extends PathFollow2D

@export var velocidad: float = 300
@export_range(0.0, 2.0, 0.05) var velocidad_defaul: float = 1.0
@export_range(0.5, 8.0, 0.1) var suavizado_aceleracion: float = 2.5
@export_range(0.5, 8.0, 0.1) var suavizado_frenado: float = 4.0
@export var danio: float = 100

@onready var menu_decision = $"../../CanvasLayer/Cartel"

var curva_actual: Area2D = null
var factor_velocidad_actual: float = 1.0
var factor_velocidad_objetivo: float = 1.0

enum TipoDecision {
	ATACAR,
	MODERAR,
	CONSERVAR,
}

func _ready() -> void:
	loop = true
	factor_velocidad_actual = velocidad_defaul
	factor_velocidad_objetivo = velocidad_defaul
	menu_decision.visible = false
	$Area2D.area_entered.connect(_on_zona_curva_detectada)
	menu_decision.get_node("Button").pressed.connect(_on_acelerar)
	menu_decision.get_node("Button2").pressed.connect(_on_frenar)
	menu_decision.get_node("Button3").pressed.connect(_on_segunda)
				
	
func _process(delta: float) -> void:
	var suavizado_actual = suavizado_frenado
	if factor_velocidad_objetivo > factor_velocidad_actual:
		suavizado_actual = suavizado_aceleracion
	
	factor_velocidad_actual = move_toward(
		factor_velocidad_actual,
		factor_velocidad_objetivo,
		suavizado_actual * delta
	)
	
	
	progress += velocidad * factor_velocidad_actual * delta

	
func _on_zona_curva_detectada(area: Area2D) -> void:
	var tipo_punto = area.get("tipo_punto")
	if tipo_punto == null:
		return
	
	var nueva_velocidad_objetivo = area.get("velocidad_objetivo")
	if nueva_velocidad_objetivo == null:
		nueva_velocidad_objetivo = velocidad_defaul
	
	if tipo_punto == 1:
		factor_velocidad_objetivo = float(nueva_velocidad_objetivo)
		menu_decision.visible = false
		return
	
	if curva_actual == null:
		curva_actual = area
		factor_velocidad_objetivo = float(nueva_velocidad_objetivo)
		menu_decision.visible = true
	
	
func tomar_decision(modificador_velocidad: float) -> void:
	factor_velocidad_objetivo = modificador_velocidad
	curva_actual = null
	menu_decision.visible = false
	
	
func resolver_decision(tipo_decision: TipoDecision) -> void:
	match tipo_decision:
		TipoDecision.ATACAR:
			tomar_decision(0.9)
			danio -= 10
		TipoDecision.MODERAR:
			tomar_decision(0.7)
			danio -= 5
		TipoDecision.CONSERVAR:
			tomar_decision(0.6)
		

func _on_acelerar() -> void:
	resolver_decision(TipoDecision.ATACAR)
	
	

func _on_frenar() -> void:
	resolver_decision(TipoDecision.MODERAR)
	

func _on_segunda() -> void:
	resolver_decision(TipoDecision.CONSERVAR)
