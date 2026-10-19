extends Node

# --- Sinais originais ---
signal delivery_made(points: int)
signal delivery_wrong_house(penalty: int)
signal player_crashed()
signal subscriber_status_updated(active_count: int)

# --- Sinais novos (HUD e fim de jogo) ---
signal lives_changed(lives: int)
signal score_changed(score: int)
signal deliveries_changed(delivered: int, target: int)
signal game_won()
signal game_lost()
