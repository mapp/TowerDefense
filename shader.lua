function get_shader()
	local pixelcode = [[
		extern vec2 light_pos[128];
		extern number light_power[128];
		extern vec4 light_color[128];
		extern number num_lights;
		
		vec4 effect(vec4 color,Image texture,vec2 texture_coords, vec2 screen_coords)
		{
			number dist = 0;
			number dlf = 0;
			vec4 colors = vec4(0,0,0,0);
			for(int i = 0;i < num_lights;i++)
			{
				dlf = 0;
				dist = length(screen_coords - light_pos[i]);
				if(dist < light_power[i])		
					dlf = 1- dist/light_power[i];
				colors += light_color[i] * dlf;
			}
			return Texel(texture,texture_coords) * colors * color;
		}
	]]
	local vertexcode = [[
		vec4 position(mat4 transform_projection,vec4 vertex_position)
		{			
			return transform_projection * vertex_position;
		}
	]]
	return love.graphics.newShader(pixelcode,vertexcode)
end