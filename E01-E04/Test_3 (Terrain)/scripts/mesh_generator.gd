extends Node

## HEIGHTMAP = COLOURED NOISE_IMAGE ##

# generates the terrain
class M_Generator:
	
	func generateTerrainMesh(
		noise:OpenSimplexNoise,
		heightMap:Image,
		x_offset:float,
		y_offset:float
		) -> MeshData:
		
		# getting height and width from the Image
		# that is used as texture
		var width = heightMap.get_width()
		var height = heightMap.get_height()
		
		# centering the whole landmass
		var topleftX:float = float((width - 1) / -2)
		var topleftZ:float = float((height - 1) / -2)
		
		# instantiating the MeshData class
		var meshData:MeshData = MeshData.new(width, height)
		var vertexIndex = 0
		
		for y in height:
			for x in width:
				x += x_offset
				y += y_offset

				var current_height = noise.get_noise_2d(x,y)
				
				# if we center each vertex then the whole 
				# landmass would get centered (probably)
				meshData.vertices[vertexIndex] = Vector3(
					topleftX + x,
					current_height ,
					topleftZ + y)
				meshData.uvs[vertexIndex] = Vector2(x/width, y/height)
				
				# we do this to leave out vertices from the right edge and
				# the bottom edge from being added
				"""
				  (i)   (i+1)
					.-----.----
					|\\   |
					| \\  |
					|  \\ |
					.-----.----
				  (i+w)   (i+w+1)
				"""
				if ((x < (width - 1)) && (y < (height - 1))):
					meshData.addTriangle(
						vertexIndex,
						vertexIndex + width + 1,
						vertexIndex+width)
					
					meshData.addTriangle(
						vertexIndex + width + 1,
						vertexIndex,
						vertexIndex + 1)
				
				vertexIndex += 1
		return meshData

# takes the mesh data to generate terrain
class MeshData:
	var mesh_arr:Array
	var vertices:PoolVector3Array
	var triangles:PoolIntArray
	var uvs:PoolVector2Array
	
	var triangle_index:int = 0
	
	# Resizing the arrays so that the indices are accessible
	func _init(meshWidth:float, meshHeight:float):
		mesh_arr.resize(Mesh.ARRAY_MAX)
		vertices.resize(int(round(meshWidth * meshHeight)))
		uvs.resize(int(round(meshWidth * meshHeight)))
		triangles.resize(int(round((meshWidth-1) * (meshHeight-1) * 6)))
	
	func addTriangle(a:int, b:int, c:int):
		triangles[triangle_index] = a
		triangles[triangle_index + 1] = b
		triangles[triangle_index + 2] = c
		
		triangle_index += 3
	
	func createMesh() -> ArrayMesh:
		var mesh:ArrayMesh = ArrayMesh.new()
		mesh_arr[Mesh.ARRAY_VERTEX] = vertices
		mesh_arr[Mesh.ARRAY_INDEX] = triangles
		mesh_arr[Mesh.ARRAY_TEX_UV] = uvs
		
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arr)
		return mesh
