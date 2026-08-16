# 🏎️ Sistema de Multijugador Local - RallyGame

## 📋 Resumen Ejecutivo

Sistema completo de multijugador local para RallyGame que permite a **2 jugadores competir simultáneamente** con controles independientes en tiempo real.

### Características Principales
✅ **2 Jugadores simultáneos**  
✅ **Controles independientes** (Flechas vs W/S)  
✅ **Ventana de decisión de 1.5 segundos**  
✅ **Sistema de daño y penalizaciones**  
✅ **UI en tiempo real** con información de ambos  
✅ **Desafíos cooperativos** en cada curva  

---

## 🎮 Controles

| Jugador | Función | Tecla |
|---------|---------|-------|
| **J1** | Atacar | ↑ |
| **J1** | Moderar | ↓ |
| **J2** | Atacar | **W** |
| **J2** | Frenar/Conservar | **S** |

---

## 📁 Archivos Nuevos

### Scripts
| Archivo | Descripción |
|---------|-------------|
| `multiplayer_manager.gd` | Gestor principal del sistema (230+ líneas) |
| `multiplayer_ui.gd` | Interfaz de usuario dinámica (170+ líneas) |
| `input_setup.gd` | Configuración de inputs W/S |
| `stage_multiplayer.gd` | Ejemplo de integración en Stage |
| `path_follow_2d_multijugador_referencia.gd` | Referencia de adaptación |

### Documentación
| Archivo | Contenido |
|---------|----------|
| `MULTIJUGADOR_GUIA.md` | Guía rápida de implementación |
| `MULTIJUGADOR_TECNICO.md` | Documentación técnica detallada |
| `MULTIJUGADOR_README.md` | Este archivo |

---

## 🚀 Instalación Rápida

### 1. Copiar Scripts
```bash
# Todos los archivos .gd nuevos están en Scripts/
rally-game/Scripts/
├── multiplayer_manager.gd (NUEVO)
├── multiplayer_ui.gd (NUEVO)
├── input_setup.gd (NUEVO)
└── path_follow_2d.gd (EXISTENTE - sin modificar por ahora)
```

### 2. Configurar la Escena Main.tscn
- Agregar nodo `MultiplayerManager` (Node) debajo de Main
- Agregar nodo `Control` como hijo de MultiplayerManager
- Asignar scripts correspondientes

### 3. Inicializar en stage.gd
```gdscript
func _ready() -> void:
	var multiplayer_manager = get_node("MultiplayerManager")
	var car_paths = [get_node("prota"), get_node("Car2")]
	multiplayer_manager.inicializar_jugadores(car_paths)
```

---

## 🎯 Cómo Funciona

### Fase 1: Juego Normal
```
Ambos autos avanzan en el circuito
    ↓
Controlados por el MultiplayerManager
```

### Fase 2: Punto de Decisión
```
Se detecta una zona crítica (curva peligrosa)
    ↓
Se inicia Timer de 1.5 segundos
    ↓
Se muestra el contador en pantalla
```

### Fase 3: Tomar Decisión
```
Jugador 1 presiona ↑ (ATACAR) o ↓ (MODERAR)
    ↓
Jugador 2 presiona W (ATACAR) o S (FRENAR)
    ↓
Si ambos deciden ANTES de tiempo:
    Se aplican inmediatamente
    
Si vence el tiempo:
    Se aplica penalización automática
```

### Fase 4: Resolver Efectos
```
Aplicar cambios de velocidad
    ↓
Aplicar daño según decisión
    ↓
Verificar descalificaciones
    ↓
Continuar con el juego
```

---

## 📊 Sistema de Decisiones

### Tipos y Efectos
```
ATACAR (↑/W)
├─ Velocidad: 1.2x
├─ Daño: 12 + (exceso_velocidad * 45)
└─ Riesgo: Alto

MODERAR (↓ J1)
├─ Velocidad: 0.7x
├─ Daño: 5
└─ Riesgo: Bajo

CONSERVAR (S J2)
├─ Velocidad: 0.6x
├─ Daño: 0
└─ Riesgo: Ninguno

TIMEOUT (No decide)
├─ Velocidad: 0.5x
├─ Daño: 10
└─ Riesgo: Penalización automática
```

### Tabla de Daño
| Decisión | Daño | Nota |
|----------|------|------|
| ATACAR | Variable | 12 base + 45 por exceso de velocidad |
| MODERAR | 5 | Fijo |
| CONSERVAR | 0 | Sin daño |
| TIMEOUT | 10 | Penalización por no decidir |

---

## 📱 Interfaz de Usuario

### Paneles en Pantalla
```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║  JUGADOR 1 (↑↓)         TIEMPO: 1.5s   J2 (W/S)  ║
║  Daño: 100%                              Daño: 100%
║  Velocidad: 1.0x                         Velocidad: 1.0x
║  Decisión: -                             Decisión: -
║  Estado: OK                              Estado: OK
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

### Información Mostrada
- **Daño/Salud** de cada jugador
- **Velocidad actual** de cada auto
- **Última decisión** tomada
- **Estado** (OK/DESCALIFICADO)
- **Timer** de decisión en tiempo real

---

## 🔧 Configuración Exportable

### En el Inspector (MultiplayerManager)
```
Tiempo Decisión: 1.5 (segundos)
Velocidad Default: 1.0
Suavizado Aceleración: 2.5
Suavizado Frenado: 4.0
```

### En el Inspector (MultiplayerUI)
```
Mostrar Debug: false
```

---

## 🧪 Prueba Rápida

1. **Abre el proyecto** en Godot 4.7
2. **Ejecuta Main.tscn** (F5)
3. **Avanza hasta una curva crítica**
4. **Verás el timer** en la pantalla
5. **Prueba controles**:
   - Jugador 1: Usa ↑ y ↓
   - Jugador 2: Usa W y S
6. **Observa los cambios** de velocidad y daño

---

## 📊 Estado de Jugadores

Cada jugador tiene accesible:
```gdscript
{
    "id": 1,                      # 1 o 2
    "danio": 85.5,                # Salud (0-100)
    "velocidad": 0.95,            # Factor multiplicador
    "descalificado": false,       # ¿Fue eliminado?
    "decision_ultima": 0          # Enum TipoDecision
}
```

Obtener estado:
```gdscript
var estado = multiplayer_manager.obtener_estado_jugador(1)
var ambos = multiplayer_manager.obtener_estado_ambos()
```

---

## ⚠️ Requisitos

- **Godot 4.6+** (desarrollado en 4.7)
- **GDScript**
- **2 PathFollow2D** en la escena (prota y Car2)
- **Nodos de áreas** para detección de curvas

---

## 🔄 Flujo de Integración

```mermaid
1. Copiar scripts nuevos
   ↓
2. Crear nodo MultiplayerManager en escena
   ↓
3. Crear nodo Control hijo con UI
   ↓
4. Modificar stage.gd para inicializar
   ↓
5. Probar en editor
   ↓
6. Ajustar parámetros en inspector
   ↓
7. ¡A jugar!
```

---

## 📚 Documentación

- **MULTIJUGADOR_GUIA.md** → Implementación paso a paso
- **MULTIJUGADOR_TECNICO.md** → Detalles arquitectónicos
- **Scripts comentados** → Explicaciones inline

---

## 🎓 Conceptos Clave

### Clase Jugador Interna
```gdscript
class Jugador:
    var id: int
    var pathfollow: PathFollow2D
    var tecla_arriba: String
    var tecla_abajo: String
    # ... 8 atributos más
```

### Enum TipoDecision
```
TipoDecision.ATACAR = 0
TipoDecision.MODERAR = 1
TipoDecision.CONSERVAR = 2
TipoDecision.NINGUNA = 3
```

### Estados Principales
- **Esperando Decisiones** → Timer activo
- **Resolviendo** → Aplicando efectos
- **Normal** → Avanzando en pista

---

## 🐛 Solución de Problemas

| Problema | Solución |
|----------|----------|
| Inputs no funcionan | Verifica que input_setup.gd exista |
| MultiplayerManager no encuentra autos | Verifica nombres: "prota" y "Car2" |
| Decisiones no se aplican | Conecta zona_curva_detectada en stage.gd |
| UI no se ve | Asegúrate que Control sea hijo de MultiplayerManager |

---

## 🚀 Próximas Mejoras Sugeridas

- [ ] Sistema de puntuación competitiva
- [ ] Estadísticas finales (ganador, mejor tiempo)
- [ ] Efectos de sonido y música
- [ ] Animaciones de decisión
- [ ] Modo replay instantáneo
- [ ] Persistencia de datos
- [ ] Leaderboard local
- [ ] Controles personalizables

---

## 📝 Créditos

**Sistema de Multijugador Local**  
- Implementación: 2026
- Motor: Godot 4.7
- Lenguaje: GDScript

---

## 📞 Soporte

Para problemas o preguntas:
1. Revisa MULTIJUGADOR_TECNICO.md
2. Verifica los logs en Output
3. Habilita debug en MultiplayerManager
4. Consulta los scripts comentados

---

**¡Diviértete con el multijugador local! 🎮**
