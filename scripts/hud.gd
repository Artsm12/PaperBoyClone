extends CanvasLayer

## HUD construído por código: basta anexar este script a um nó CanvasLayer
## na cena principal. Mostra vidas, pontos, entregas e a tela de fim de jogo.

const RESTART_DELAY_MS: int = 800

var _lives_label: Label
var _score_label: Label
var _deliveries_label: Label
var _end_center: CenterContainer
var _end_title: Label
var _end_info: Label
var _end_time_ms: int = 0

func _ready() -> void:
	# Precisa funcionar com o jogo pausado (tela de fim de jogo)
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10

	_build_ui()

	GameEvents.lives_changed.connect(_on_lives_changed)
	GameEvents.score_changed.connect(_on_score_changed)
	GameEvents.deliveries_changed.connect(_on_deliveries_changed)
	GameEvents.game_won.connect(_on_game_won)
	GameEvents.game_lost.connect(_on_game_lost)

	_on_lives_changed(GameManager.lives)
	_on_score_changed(GameManager.score)
	_on_deliveries_changed(GameManager.deliveries, GameManager.target_deliveries)

func _build_ui() -> void:
	# --- Painel superior esquerdo ---
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	add_child(margin)

	var box := VBoxContainer.new()
	margin.add_child(box)

	_lives_label = _make_label(26)
	_score_label = _make_label(26)
	_deliveries_label = _make_label(26)
	box.add_child(_lives_label)
	box.add_child(_score_label)
	box.add_child(_deliveries_label)

	# --- Tela de fim de jogo ---
	_end_center = CenterContainer.new()
	_end_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_center.visible = false
	add_child(_end_center)

	var panel := PanelContainer.new()
	_end_center.add_child(panel)

	var panel_margin := MarginContainer.new()
	panel_margin.add_theme_constant_override("margin_left", 40)
	panel_margin.add_theme_constant_override("margin_right", 40)
	panel_margin.add_theme_constant_override("margin_top", 24)
	panel_margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(panel_margin)

	var end_box := VBoxContainer.new()
	end_box.add_theme_constant_override("separation", 12)
	panel_margin.add_child(end_box)

	_end_title = _make_label(48)
	_end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_info = _make_label(26)
	_end_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hint := _make_label(22)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.text = "Pressione ENTER para jogar novamente"

	end_box.add_child(_end_title)
	end_box.add_child(_end_info)
	end_box.add_child(hint)

func _make_label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	return label

# ---------------------------------------------------------------- Atualizações

func _on_lives_changed(lives: int) -> void:
	_lives_label.text = "Vidas: %d" % lives

func _on_score_changed(score: int) -> void:
	_score_label.text = "Pontos: %d" % score

func _on_deliveries_changed(delivered: int, target: int) -> void:
	_deliveries_label.text = "Entregas: %d / %d" % [delivered, target]

func _on_game_won() -> void:
	_show_end_screen("VITÓRIA!", Color.LIME_GREEN)

func _on_game_lost() -> void:
	_show_end_screen("FIM DE JOGO", Color.TOMATO)

func _show_end_screen(title: String, color: Color) -> void:
	_end_title.text = title
	_end_title.add_theme_color_override("font_color", color)
	_end_info.text = "Pontuação final: %d\nEntregas: %d / %d" % [
		GameManager.score, GameManager.deliveries, GameManager.target_deliveries
	]
	_end_center.visible = true
	_end_time_ms = Time.get_ticks_msec()

# ------------------------------------------------------------------ Reiniciar

func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.game_finished:
		return
	# Pequeno atraso para não reiniciar sem querer enquanto o jogador ainda aperta teclas
	if Time.get_ticks_msec() - _end_time_ms < RESTART_DELAY_MS:
		return

	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		GameManager.reset()
		get_tree().reload_current_scene()
