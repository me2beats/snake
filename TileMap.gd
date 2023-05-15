extends TileMap

var field_size = Vector2(23,16)

var snake = [Vector2(4,4), Vector2(3,4), Vector2(2,4)]

var dir = Vector2(1,0)

onready var timer = $Timer
onready var bonus_food_timer = $BonusFood


onready var music_sound: = $"../Audio/Music"
onready var eat_sound: = $"../Audio/Eat"
onready var game_end_sound: = $"../Audio/GameEnd"

onready var score_label = $"../CanvasLayer/Score"
onready var bonus_food_label = $"../CanvasLayer/BonusFood"

var bonus_food_pos:Vector2
var bonus_food_icon_pos = Vector2(19, -3)
var bonus_food_time_left = 0

var speed_mult = 0.99

var score = 0 setget set_score


enum Tiles{
	BORDER = 1,
	FOOD = 2,
	TAIL = 3,
	BODY = 4,
	HEAD = 5,
	BONUS_FOOD1 = 6,
	BONUS_FOOD2 = 7
}

func set_score(val):
	score = val
	score_label.text = str(val)
	
func draw_bonus_food_icon(tile):
	var draw_pos = bonus_food_icon_pos
	if tile == Tiles.BONUS_FOOD2: draw_pos.y+=1
	set_cellv(draw_pos, tile)
	

func remove_bonus_food_icon():
	set_cellv(bonus_food_icon_pos, -1)
	set_cellv(bonus_food_icon_pos+Vector2(0,1), -1) 
	

func _ready():
	randomize()

	music_sound.play()

	timer.start()
	
	OS.window_size = Vector2(1024, 600)


func eat_food():
	self.score+=1
	eat_sound.play()
	timer.wait_time*=speed_mult
	spawn_food()
	
	if !score%5 and not bonus_food_label.visible:
		spawn_bonus_food()

func eat_bonus_food():
	self.score+=10
	eat_sound.play()
	hide_bonus_food_controls()
	set_cellv(bonus_food_pos, -1)
#	spawn_food() 


func spawn_food():
	var empty_cell = get_random_empty_cell()
	set_cellv(empty_cell, Tiles.FOOD)

func spawn_bonus_food():

	var empty_cell = get_random_empty_cell()
	var food = [Tiles.BONUS_FOOD1, Tiles.BONUS_FOOD2][randi()%2]
	bonus_food_pos = empty_cell
	set_cellv(empty_cell, food)
	draw_bonus_food_icon(food)
	bonus_food_label.text = str(20)
	bonus_food_label.visible = true
	
	for i in 20:
		if !bonus_food_label.visible: return
		bonus_food_timer.start()
		yield(bonus_food_timer, "timeout")
		bonus_food_label.text = str(20-i)
	hide_bonus_food_controls()
	set_cellv(bonus_food_pos, -1)

func hide_bonus_food_controls():
	bonus_food_label.visible = false
	remove_bonus_food_icon()

func get_random_empty_cell():
	var empty_cells: = get_empty_cells()
	return empty_cells[randi()%empty_cells.size()]
	

func get_empty_cells()->Array:
	var empty: = []
	for x in field_size.x:
		for y in field_size.y:
			if get_cell(x, y) == -1:
				empty.push_back(Vector2(x,y))
	return empty

func move_head():
	# bool(dir.y) = set head rotation
	set_cellv(snake[0]+dir, Tiles.HEAD, false, false, bool(dir.y))

func get_opposite_border_pos()->Vector2:
	var pos:Vector2
	var snake_head_pos = snake[0]
	match dir:
		Vector2(0,-1):
			pos = Vector2(snake_head_pos.x, field_size.y)
		Vector2(0,1):
			pos = Vector2(snake_head_pos.x, 0)
		Vector2(1,0):
			pos = Vector2(0, snake_head_pos.y)
		Vector2(-1,0):
			pos = Vector2(field_size.x, snake_head_pos.y)
	return pos

func move_body():
	for i in snake.size()-1:
		var cell = snake[i]
		var next_cell = snake[i+1]
		set_cellv(cell, get_cellv(next_cell))

func move():
	var new_head_pos = snake[0]+dir
	match get_cellv(new_head_pos):
		Tiles.BORDER: # field border
			var oposite_border_pos = get_opposite_border_pos()
			match get_cellv(oposite_border_pos):
				Tiles.TAIL,Tiles.BODY:
#					return # test immortal snake
					game_over()
					return
			move_body()




			set_cellv(snake[-1], -1)
			snake.pop_back()


			set_cellv(oposite_border_pos, Tiles.HEAD, false, false, bool(dir.y))
			set_cellv(snake[0], Tiles.BODY)
			snake.push_front(oposite_border_pos)
			return

		Tiles.FOOD: # food
			move_head()
			set_cellv(snake[0], Tiles.BODY)
			snake.push_front(new_head_pos)
			eat_food()
			return
			
		Tiles.TAIL,Tiles.BODY:
#			return # test immortal snake
			game_over()
		Tiles.BONUS_FOOD1,Tiles.BONUS_FOOD2:
			move_head()
			set_cellv(snake[0], Tiles.BODY)
			snake.push_front(new_head_pos)
			eat_bonus_food()
			return



	move_head()
	move_body()

	set_cellv(snake[-1], -1)

	snake.push_front(new_head_pos)
	snake.pop_back()


func game_over():
	music_sound.stop()
	game_end_sound.play()
	get_tree().paused = true
	yield(game_end_sound,"finished")
	get_tree().paused = false
	get_tree().reload_current_scene()


# this timer controls move speed
func _on_Timer_timeout():
	move()
	
func _input(event):
	if !(Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left")): return
	var new_dir:Vector2

	if Input.is_action_just_pressed("ui_down"):
		new_dir = Vector2(0,1)
	elif Input.is_action_just_pressed("ui_up"):
		new_dir = Vector2(0,-1)
	elif Input.is_action_just_pressed("ui_left"):
		new_dir = Vector2(-1,0)
	elif Input.is_action_just_pressed("ui_right"):
		new_dir = Vector2(1,0)

#	if new_dir == dir or new_dir ==-dir: return	
	if new_dir ==-dir: return	
	dir = new_dir

	
	timer.stop()
	timer.emit_signal("timeout")
	timer.start()
