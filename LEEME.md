# Salir del silencio (versión 7)

Juego de aventura 2D en Godot 4.7 (renderer GL Compatibility), basado en lo que vimos en el proyecto del Zelda.

## Cómo abrirlo
1. Descomprime el .zip.
2. Abre Godot 4.7 → **Importar** → selecciona `project.godot`.
3. La primera vez Godot importa las imágenes (tarda unos segundos).
4. Presiona **F5**. Empieza en el menú principal. Para detenerlo desde el editor: **F8**.

## Flujo del juego
Menú → **Trivia inicial** (6 preguntas) → Juego → Pantalla final → **Trivia final** (6 preguntas distintas sobre los mismos temas) → **Tu progreso** (resultado inicial vs final, tema por tema) → Menú. No se guarda ningún dato.


## Controles
| Acción | Teclas |
|---|---|
| Moverse | Flechas o WASD |
| Atacar con la espada de luz | Espacio o J |
| Hablar / continuar diálogo | E o Enter |
| Elegir respuesta | Flechas + Enter, o clic |
| Mapa | M |
| Pausa (continuar, instrucciones, menú, salir) | Esc |

## Qué cambió en la versión 7
- Se quitó la coevaluación y el guardado de resultados: al final el jugador solo ve **Tu progreso** (trivia inicial vs final por tema). La calificación del juego la hace el profesor.
- Se ensanchó el paso entre el puente del Santuario y las escaleras de El Apoyo, y el paso de La Ansiedad al puente de la salida.
- **Vale**, nueva NPC en La Ansiedad: Alex le enseña a respirar (inhalar 4, sostener 4, exhalar 4). Al ayudarla, Alex recupera toda la vida. **Es obligatoria:** la salida solo se abre con los 3 fragmentos **y** después de ayudar a Vale.

Recorrido completo: La Voz → El Apoyo (Sam) → Nico → La Esperanza → Vale → Salida.

## Qué cambió en la versión 6
- Todos los **puentes y escaleras** se pueden cruzar de punta a punta (se revisaron los 14 con una prueba automática). Se abrió el paso de la fogata de El Apoyo al puente del este, la bajada a La Esperanza y el camino del lado este de La Esperanza.
- La **trivia final** tiene preguntas **distintas** a la inicial, sobre los mismos 6 temas y en el mismo orden. La comparación en "Tu progreso" y en Resultados es **por tema**.
- En la versión web, Resultados permite **descargar el CSV**.
- Guía para publicar en GitHub y Vercel: `docs/PUBLICAR_WEB.md`.

## Qué cambió en la versión 5
- **Música** (menú, bosque, tensión en El Aislamiento y La Ansiedad, final) con cambio suave entre canciones (`scripts/audio.gd`).
- **Efectos de sonido:** espada, golpe, enemigo vencido (destello), aparición de enemigos, daño, respiro, fragmento, diálogos, botones, trivia y salida.
- **Personajes nuevos** del paquete Ninja Adventure (CC0). Ver `CREDITOS.md`.
- **Nico**, en la niebla de El Aislamiento: hablar con él es **obligatorio**, porque La Esperanza solo aparece después de acompañarlo.
- **Trivia final**, comparación con la inicial, **coevaluación** y registro en CSV.

## Qué cambió en la versión 3
- Los NPCs ya no bloquean el paso (no tienen colisión) y Lía está a un lado del camino.
- Las luces de respiro están en lugares a los que se puede llegar. Hay una nueva dentro de la puerta de La Culpa.
- Se puede entrar a la puerta de La Culpa y subir por el frente de los pedestales de los fragmentos.

## Qué cambió en la versión 2
- **Colisiones nuevas:** se calcularon a partir del mapa (camino, pasto y piedra se pueden caminar; árboles, pilares, agua y acantilados no). Son 33 polígonos en `Colisiones` (CollisionPolygon2D en modo segmentos). Para ajustar uno: selecciónalo y mueve sus puntos en el editor.
- **Espada de luz:** el tajo sale hacia donde mira Alex. Al vencer a un enemigo aparece un **destello** (`escenas/efectos/destello.tscn`).
- **Frases:** cada tipo de enemigo tiene 7-8 frases negativas y 5 positivas en `scripts/frases.gd`. Cada enemigo las dice en orden distinto y al morir sale una positiva al azar.
- **NPCs con diálogo y respuestas:** Lía (Inicio, explica el juego), Rosa (Santuario, habla de la depresión y da pistas) y Sam (El Apoyo: el fragmento solo aparece si aceptas su compañía). Tienen un "!" cuando tienen algo nuevo que decir.
- **Guía:** objetivo escrito arriba a la izquierda, **flecha dorada** que apunta por el camino (usa AStarGrid2D con `scripts/mascara_caminable.gd`) y **mapa** con la tecla M.
- **Vida:** corazones arriba a la izquierda y pantalla roja al recibir daño.
- **Instrucciones:** se pueden bajar (rueda del mouse o flechas) y se cierran con Esc.
- **Pausa** con Esc: continuar, instrucciones, volver al menú o salir.
- **Ventana:** abre maximizada para que se vea la barra con la X.
- **Animaciones:** agua con ondas y brillos, cascadas que caen (`recursos/agua.gdshader` + `assets/mapa/agua_mascara.png`), niebla que se mueve (`recursos/niebla.gdshader`), faroles que parpadean y el fondo del menú más rápido.

## Estructura
```
assets/mapa/          mapa_bosque.png, agua_mascara.png (rojo = agua, verde = cascadas)
assets/sprites/       Alex, NPCs, enemigos, tajo, corazones, flecha, fragmentos, etc.
recursos/             luz_suave.tres, agua.gdshader, niebla.gdshader
escenas/              menu_principal, trivia, juego, final
escenas/jugador/      alex.tscn
escenas/enemigos/     sombra.tscn, arana.tscn (los dos usan pensamiento.gd)
escenas/objetos/      fragmento, respiro, salida
escenas/personajes/   npc.tscn (Lía, Rosa y Sam usan la misma escena)
escenas/efectos/      destello.tscn
escenas/ui/           hud.tscn, instrucciones.tscn
scripts/juego.gd      Autoload "Juego": vida, fragmentos, objetivo, trivia
scripts/frases.gd     Frases negativas y positivas de los enemigos
scripts/npc.gd        Conversaciones de los NPCs
scripts/trivia.gd     Preguntas de la trivia (lista PREGUNTAS)
docs/mapa_guia.png    Dónde está cada cosa (rojo = no caminable)
```

## Cómo cambiar cosas comunes
- **Preguntas de la trivia:** `scripts/trivia.gd`, lista `PREGUNTAS`.
- **Frases de los enemigos:** `scripts/frases.gd`.
- **Diálogos de los NPCs:** `scripts/npc.gd` (funciones `hablar_lia`, `hablar_rosa`, `hablar_sam`).
- **Tipo de un enemigo:** selecciónalo en `juego.tscn` y cambia `tipo` en el Inspector (voz, culpa, aislamiento, ansiedad).

## Qué viene del Zelda
| Zelda | Salir del silencio |
|---|---|
| `FV_player` (movimiento, `SwordHitbox`) | `alex.gd` (`EspadaHitbox` + tajo de luz) |
| Leever (se esconde y aparece) | `pensamiento.gd`: aparece cuando Alex se acerca |
| Tektite (salta) | Arañas de La Ansiedad (`se_mueve_a_saltos = true`) |
| `FV_heart` | `respiro.gd`: recupera 1 corazón |
| `fv_key` | `fragmento.gd` |
| `drop_random_item()` | `soltar_respiro()` |
| Efectos de muerte (`FV_death_expand`) | `destello.tscn` |
| Shaders de color | Shaders de agua y niebla + `CanvasModulate` y luces |

## Capas de colisión
1 = mundo · 2 = jugador · 3 = enemigos · 4 = objetos

## Pendiente
- Reemplazar los sprites provisionales por arte final
- Sonidos y música
