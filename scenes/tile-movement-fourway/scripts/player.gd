extends CharacterBody2D

#enum Directions {
	#UP = -16,
	#DOWN = +16,
	#LEFT = -16,
	#RIGHT = +16,
#}

@onready var obstacles: TileMapLayer = null;

@onready var raycast: RayCast2D = $RayCast2D;

const TILE_SIZE: int = 16;
var move_speed: float = 100;
var is_moving: bool = false;
var target_position: Vector2 = Vector2.ZERO;
var direction: Vector2 = Vector2.ZERO;

const INTERACTIVE_TILES: Dictionary[String, Vector2i] = {
	'Green_Tile': Vector2i(8, 1),
	'Blue_Tile': Vector2i(8, 2),
	'Red_Tile': Vector2i(8, 3),
	'Orange_Tile': Vector2i(8, 4)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#position = position.snapped(Vector2.ONE * TILE_SIZE);
	target_position = position;
	obstacles = get_parent().get_node("Obstacles");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;

#func _unhandled_input(event: InputEvent) -> void:
	#if is_moving:
		#position = position.move_toward(target_position, move_speed * 0.1);
		#if position == target_position:
			#is_moving = false;
	#else:
		#handle_input(event);

func _physics_process(delta: float) -> void:
	if is_moving:
		position = position.move_toward(target_position, move_speed * delta);
		if position == target_position:
			is_moving = false;
	else:
		handle_input();


# FIX: document it with my own words
func handle_input() -> void:
	# Reset the direction here
	direction = Vector2.ZERO;
	
	# Check which button was pressed (movement) and sets the direction
	if Input.is_action_pressed("walk_up"):
		direction = Vector2.UP;
	if Input.is_action_pressed("walk_down"):
		direction = Vector2.DOWN;
	if Input.is_action_pressed("walk_left"):
		direction = Vector2.LEFT;
	if Input.is_action_pressed("walk_right"):
		direction = Vector2.RIGHT;
		
	# Checks if any direction was pressed
	if direction != Vector2.ZERO:
		
		# Check if the raycast node exists
		# I'm not sure if this line below is really necessary, but
		#let's leave it here for now for safety purposes.
		if raycast:
			# Sets the target_position of the raycast based on the direction
			#pressed and the size of the tile
			raycast.target_position = direction * TILE_SIZE;
			# Force an update of the collision information of the raycast,
			#removing the need to wiat for the next iteration of _physics_process()
			raycast.force_raycast_update();
			
			# Check if the raycast is colliding with something
			if raycast.is_colliding():
				# If the raycast is colliding, get the collider information
				var collider = raycast.get_collider();
				
				# Check if the collider is a TileMapLayer object
				if collider is TileMapLayer:
					
					var collision_point = raycast.get_collision_point();
					var collision_normal = raycast.get_collision_normal();
					var inside_tile_point = collision_point - (collision_normal * 1.0);
					
					var local_point = collider.to_local(inside_tile_point);
					
					var map_position = collider.local_to_map(local_point);
					
					# So, the input is being triggered just once, great.
					# Still unable to check which tile is being interacted with
					if Input.is_action_just_pressed("interact"):
						var cell = collider.get_cell_atlas_coords(map_position);
						match cell:
							INTERACTIVE_TILES.Blue_Tile:
								print('blue one');
							INTERACTIVE_TILES.Red_Tile:
								print('red one');
							INTERACTIVE_TILES.Green_Tile:
								print('green one');
							INTERACTIVE_TILES.Orange_Tile:
								print('orange one');
				return;
		
		target_position = position + direction * TILE_SIZE;
		is_moving = true;
