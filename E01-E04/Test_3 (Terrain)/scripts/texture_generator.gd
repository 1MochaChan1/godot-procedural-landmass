extends Node


class T_Generator:
	# initiating the noise
	var noise = OpenSimplexNoise.new()
	
	
	# generating the noise
	func generateNoise(
		seed_val:int,
		octaves:float,
		period:float,
		persistance:float,
		lacunarity:float) -> OpenSimplexNoise:
		# creating the noise
			noise.seed = seed_val
			noise.octaves = octaves
			noise.period = period
			noise.persistence = persistance
			noise.lacunarity = lacunarity
			return noise

	# generate the texture
	func generateTexture(
		height:float,
		width:float,
		x_offset,
		y_offset,
		g_noise:OpenSimplexNoise,
		render_color:bool,
		regions:Array) -> ImageTexture:
			
			# creating an image from the noise
			var noise_img = g_noise.get_image(
				width,
				height,
				Vector2(x_offset, y_offset))
			
			# converting the image to RGBA format
			if(noise_img.get_format() == 0):
				noise_img.convert(Image.FORMAT_RGBA8)
			
			
			if(render_color):
				noise_img.lock()
				# color the image based on the heights of regions
				for y in height:
					for x in width:
						var _x = x + x_offset
						var _y = y + y_offset
						var currentHeight = g_noise.get_noise_2d(_x, _y)
						for reg in regions:
							if(currentHeight <= reg.height):
								noise_img.set_pixel(x, y, reg.col)
								break
				
				noise_img.unlock()
			
			# creating a texture from the above image
			var imgTexture = ImageTexture.new()
			imgTexture.create_from_image(noise_img,1)
			
			return imgTexture
