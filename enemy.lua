--[[

enemies have health, tile coord, veloc, defense

]]

function new_enemy(level,pathNum,red,green,blue)
	local enemy = {}
	enemy["level"] = level
	local px,py = level["tiles"].getPixelCoord(level["path"][pathNum][1][1],level["path"][pathNum][1][2])
	enemy["position"] = {px + 10,py + 10}
	enemy["velocity"] = {0,0}
	enemy["color"] = {red,green,blue}
	enemy["path"] = level.getPath(pathNum)	
	enemy.update =
	function(dt)
		if #enemy["path"] ~= 0 then
			local ex_t,ey_b = enemy["level"]["tiles"].getTileCoord(enemy["position"][1],enemy["position"][2] + 15)
			local ex_b,ey_t = enemy["level"]["tiles"].getTileCoord(enemy["position"][1] + 15,enemy["position"][2])
			if ex_t == enemy["path"][1][1] and ey_t == enemy["path"][1][2] and
			ex_b == enemy["path"][1][1] and ey_b == enemy["path"][1][2] then
				table.remove(enemy["path"],1)
				if #enemy["path"] ~= 0 then
					enemy.assignVelocity()
				end
			end
			enemy["position"][1] = enemy["position"][1] + dt * enemy["velocity"][1]
			enemy["position"][2] = enemy["position"][2] + dt * enemy["velocity"][2]
		end
	end
	
	enemy.assignVelocity =
	function ()
		local ex,ey = enemy["level"]["tiles"].getTileCoord(enemy["position"][1],enemy["position"][2])
		local px,py = enemy["path"][1][1],enemy["path"][1][2]
		local angle = math.atan2(py - ey,px - ex)
		enemy["velocity"][1] = 30*math.cos(angle)
		enemy["velocity"][2] = 30*math.sin(angle)
	end
	enemy.assignVelocity()
	
	enemy.draw = 
	function ()
		local ex,ey = enemy["position"][1],enemy["position"][2]
		love.graphics.setColor(enemy["color"][1],enemy["color"][2],enemy["color"][3],255)
		love.graphics.rectangle("fill",enemy["position"][1],enemy["position"][2],15,15)
		love.graphics.setColor(255,255,255,255)
		love.graphics.line(ex,ey,ex,ey + 14,ex + 14,ey + 14,ex + 14,ey,ex,ey)
	end	
	enemy.isDead = function() return enemy["color"][1] == 0 and enemy["color"][2] == 0 and enemy["color"][3] == 0 end
	enemy.damage =
	function(color)
		if enemy["color"][1] ~= 0 then
			enemy["color"][1] = enemy["color"][1]  - color[1] <= 0 and 0 or enemy["color"][1]  - color[1]
		end
		if enemy["color"][2] ~= 0 then
			enemy["color"][2] = enemy["color"][2]  - color[2] <= 0 and 0 or enemy["color"][2]  - color[2]
		end
		if enemy["color"][3] ~= 0 then
			enemy["color"][3] = enemy["color"][3]  - color[3] <= 0 and 0 or enemy["color"][3]  - color[3]
		end
	end
	return enemy
end