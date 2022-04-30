extends Node2D

onready var sprites = $Sprites
onready var gem := $Sprites/Gem
onready var area = $Area2D
onready var start_pos := position

var player = null
var is_collected := false
var is_follow := false

func _enter_tree():
	if Engine.editor_hint: return
	Shared.goal = self
	
	if !Shared.is_reload:
		Cutscene.is_show_goal = true
	
	CheatCode.connect("activate", self, "cheat_code")

func _ready():
	Cam.connect("turning", self, "turning")
	
	if Shared.goals_collected.has(Shared.csfn):
		#is_collected = true
		sprites.modulate.a = 0.25

func _physics_process(delta):
	# follow player
	if is_collected and player != null and is_follow:
		var target = player.position + player.rot(Vector2.UP * 20)
		position = position.linear_interpolate(target, 0.1)

func turning(angle):
	sprites.rotation = angle

func pickup(ply):
	if is_collected: return
	player = ply
	is_collected = true
	gem.z_as_relative = true
	area.set_deferred("monitorable", false)
	
	start_pos = position
	#area.monitorable = false
	
	Audio.play(Audio.gem_collect)

func cheat_code(cheat):
	if "collect" in cheat:
		pickup(Shared.player)
