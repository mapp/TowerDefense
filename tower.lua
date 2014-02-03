--[[

towers have tile coord, color,image

]]

function new_tower(level,pixel_x,pixel_y,radius,color,image)
	local tower = {}
	tower["position"] = {pixel_x,pixel_y}
	tower["color"] = color
	tower["image"] = image
	tower["radius"] = radius
	tower["target"] = nil
	tower.draw = 
	function()
		if tower["target"] ~= nil then
			love.graphics.setColor(255*tower["color"][1],255*tower["color"][2],255*tower["color"][3],255)
			love.graphics.setLineWidth(3)
			love.graphics.line(tower["position"][1] + 15,tower["position"][2] + 15,tower["target"]["position"][1] + 7.5,tower["target"]["position"][2] + 7.5)
			love.graphics.setLineWidth(1)
			love.graphics.setColor(255,255,255,255)
		end
		love.graphics.draw(image,tower["position"][1],tower["position"][2])
	end
	tower.update = 
	function(dt)
		if tower["target"] ~= nil then
			if tower["target"].isDead() or dist(tower["target"]["position"][1] + 7.5,tower["target"]["position"][2] + 7.5,tower["position"][1] + 15,tower["position"][2] + 15) > tower["radius"] then
				tower["target"] = nil
			end
		end
		
		local mindist = tower["radius"]
		for i = 1,#level["enemies"] do
			local e_pos = level["enemies"][i]["position"]
			local t_pos = tower["position"]
			local t_dist = dist(e_pos[1] + 7.5,e_pos[2] + 7.5,t_pos[1] + 15,t_pos[2] + 15)
			local canDamageColor = false
			if tower["color"][1] ~= 0 and level["enemies"][i]["color"][1] ~= 0 then
				canDamageColor = true
			elseif tower["color"][2] ~= 0 and level["enemies"][i]["color"][2] ~= 0 then
				canDamageColor = true
			elseif tower["color"][3] ~= 0 and level["enemies"][i]["color"][3] ~= 0 then
				canDamageColor = true
			end
			if t_dist < tower["radius"] and t_dist < mindist and canDamageColor then
				mindist = t_dist
				tower["target"] = level["enemies"][i]
			end
		end
		
		if tower["target"] ~= nil then
			local color = {60*dt*tower["color"][1],60*dt*tower["color"][2],60*dt*tower["color"][3]}
			tower["target"].damage(color)
		end
	end
	return tower
end