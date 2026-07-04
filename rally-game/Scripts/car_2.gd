extends PathFollow2D
@export var velocidad: float = 250
@export var avanzando: bool = true
@export var calculo_velocidad: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loop = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not avanzando:
		return

	progress += velocidad * calculo_velocidad * delta
