tool
extends Node2D

onready var area : Area2D = $Area2D
onready var arrow := $Arrow
onready var gems := $Gems
onready var gem := $Gems/Gem

export var dir := 0 setget set_dir
export var scene_path := ""
export var is_gem := false
export var gem_count := 1
export var gem_radius := 60.0

var is_active := false
var player = null

var gems_collected := 0
var is_locked := false

var arrow_clock = 0.0
var arrow_time = 0.3

func _enter_tree():
	if Engine.editor_hint: return
	if scene_path != "" and Shared.last_scene == scene_path:
		Shared.door_destination = self
	
	if is_gem:
		Shared.door_goal = self

func _ready():
	if Engine.editor_hint: return
	
	CheatCode.connect("activate", self, "cheat_code")
	
	player = Shared.player
	
	if is_gem:
		
		# gems collected
		gems_collected = Shared.slabs_completed.size()
		
		# create gems
		for i in gem_count:
			var g = gem
			if i > 0:
				g = gem.duplicate()
				gems.add_child(g)
				g.owner = self
			var angle = (float(i) / float(gem_count)) * TAU
			g.position = Vector2(0, gem_radius).rotated(angle)
			g.rotation = angle
		
		# color gems
		for i in gem_count:
			if i < gems_collected:
				gems.get_child(i).set_color()
		
		is_locked = gems_collected < gem_count
	else:
		gems.visible = false

func _input(event):
	if Engine.editor_hint: return
	
	if is_active:
		if event.is_action_pressed("up"):
			enter_door()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# arrow
	arrow_clock = clamp(arrow_clock + (delta if (is_active and !is_locked) else -delta), 0, arrow_time)
	arrow.modulate.a = smoothstep(0, 1, arrow_clock / arrow_time)

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

# unlock cheat
func unlock():
	is_locked = false
	arrow.visible = true
	print(name, " unlocked")

func _on_Area2D_body_entered(body):
	if body is Player:
		if player == null : player = body
		if player.dir == dir:
			is_active = true

func _on_Area2D_body_exited(body):
	is_active = false

func enter_door():
	if!is_locked and player != null and !player.is_hold and player.is_floor:
		if scene_path != "":
			Shared.wipe_scene(scene_path)

func cheat_code(cheat):
	if "konami" in cheat and is_locked and area.overlaps_body(player):
		unlock()

