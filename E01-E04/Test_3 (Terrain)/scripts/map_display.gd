tool
extends Node

const WIDTH:float = 200.0
const HEIGHT:float = 200.0

# noise parameters
export (int) var seed_val:int setget set_seed_val
export (int, 0, 9) var octaves:int = 3 setget set_octaves
export (float, 0.0, 256.0) var period:float = 64.0 setget set_period
export (float, 0.0, 1.0) var persistance:float = 0.5 setget set_persistance
export (float, 0.1,4.0) var lacunarity:float = 2.0 setget set_lacuranity
export (float, -9999.0, 9999.0, 1.0) var x_offset:float = 0 setget set_x_offset
export (float, -9999.0, 9999.0, 1.0) var y_offset:float = 0 setget set_y_offset
export (bool) var render_color:bool = false setget set_render_color

# other export params
export (Array, Resource) var regions:Array setget set_regions
export (String) var mi_path:String setget set_mi_path

onready var meshInstance:MeshInstance
onready var TextureGenerator = $TextureGenerator.T_Generator.new()
onready var MeshGenerator = $MeshGenerator.M_Generator.new()
onready var terrain:MeshInstance = $Terrain

# initiating the noise
var noise = OpenSimplexNoise.new()


func _ready():
	meshInstance = get_tree().get_nodes_in_group("floor")[0]
	display_noiseMap()


func display_noiseMap():
	
	# Making sure I have the meshInstance or something
	if(!meshInstance):
		return
	
	# Generating the noise
	noise = TextureGenerator.generateNoise(
		seed_val,
		octaves,
		period,
		persistance,
		lacunarity)
	
	# Generating the texture from the noise
	var imgTexture:ImageTexture = TextureGenerator.generateTexture(
		HEIGHT,
		WIDTH,
		x_offset,
		y_offset,
		noise,
		render_color,
		regions)
	
	# applying the texture
	meshInstance.material_override.albedo_texture = imgTexture
	
	
	# Generating the mesh
	var meshData = MeshGenerator.generateTerrainMesh(
		noise,
		imgTexture.get_data(),
		x_offset,
		y_offset)

	var mat:SpatialMaterial = SpatialMaterial.new()
	terrain.mesh = meshData.createMesh()

	terrain.set_material_override(mat)
	terrain.material_override.albedo_texture = imgTexture
	
########### Setters ###########
func set_seed_val(new_val:int):
	seed_val = new_val
	display_noiseMap()

func set_octaves(new_octave:int):
	octaves = new_octave
	display_noiseMap()

func set_period(new_period:float):
	period = new_period
	display_noiseMap()

func set_persistance(new_persistance:float):
	persistance = new_persistance
	display_noiseMap()

func set_lacuranity(new_lacunarity:float):
	lacunarity = new_lacunarity
	display_noiseMap()

func set_regions(new_region:Array):
	regions = new_region
	display_noiseMap()

func set_mi_path(new_path:String):
	mi_path = new_path
	display_noiseMap()

func set_x_offset(new_offset:float):
	x_offset = new_offset
	display_noiseMap()

func set_y_offset(new_offset:float):
	y_offset = new_offset
	display_noiseMap()

func set_render_color(render:bool):
	render_color = render
	display_noiseMap()
