extends Resource
 
class_name BallStats
 
# --- Identity ---
@export var ball_name: String = "Standard"
@export var ball_color: Color = Color(1.0, 1.0, 1.0)  # Used for UI button tint
@export var ball_texture: Texture2D
 
# --- Base Stats ---
@export var base_damage: int = 25
@export var base_speed: float = 800.0
@export var base_max_bounces: int = 10
@export var currency_per_hit: int = 10
