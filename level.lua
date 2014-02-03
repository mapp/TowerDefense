--[[
level has player,waves of enemies,enemy path, tiles

level file has per line:
starting money
path
enemies
]]

function new_level(sx,sy,tileSize,numx,numy,file)
	local level = {}
	level["health"] = {255,255,255}
	level["tiles"] = new_tileSet(sx,sy,tileSize,numx,numy)
	level["waves"] = {}
	level["path"] = {}
	level["nextSpawn"] = {}
	
	local contents,size = love.filesystem.read(file,1000)
	local count,lineNum = 0,0
	local temp = {}
	local getNextSpawnTime = false
	for i in string.gmatch(contents,"%S+") do
		if lineNum == 0 then
			level["money"] = tonumber(i)			
		elseif i:sub(1,1) == "p" then
			count = 0
			table.insert(level["path"],{})
			table.insert(level["waves"],{})
			for j in string.gmatch(i:sub(3),"%P+") do
				if count % 2 == 0 then
					table.insert(level["path"][#level["path"]],{[1] = tonumber(j)})
				else
					level["path"][#level["path"]][#level["path"][#level["path"]]][2] = tonumber(j)
				end
				count = count + 1
			end
			getNextSpawnTime = true
		elseif getNextSpawnTime then
			table.insert(level["nextSpawn"],tonumber(i))
			getNextSpawnTime = false
		else
			temp = {}
			temp["color"] = {}
			temp["pathNum"] = #level["path"]
			count = 1
			for j in string.gmatch(i,"%P+") do
				if count < 4 then
					temp["color"][count] = tonumber(j)
				else
					temp["time"] = tonumber(j)
				end
				count = count + 1			
			end	
			table.insert(level["waves"][#level["path"]],temp)
		end
		lineNum = lineNum + 1
	end
	
	level["enemies"] = {}
	level["towers"] = {}	
	level["started"] = false
	level.update = 
	function (dt)
		for i = 1,#level["towers"] do
			level["towers"][i].update(dt)
		end
		
		for i = #level["enemies"],1,-1 do			
			level["enemies"][i].update(dt)
			if level["enemies"][i].isDead() then
				table.remove(level["enemies"],i)
				level["money"] = level["money"] + 20
			elseif #level["enemies"][i]["path"] == 0 then			
				if level["health"][1] ~= 0 then
					level["health"][1] = math.max(0,level["health"][1] - level["enemies"][i]["color"][1])
				end
				if level["health"][2] ~= 0 then
					level["health"][2] = math.max(0,level["health"][2] - level["enemies"][i]["color"][2])
				end
				if level["health"][3] ~= 0 then
					level["health"][3] = math.max(0,level["health"][3] - level["enemies"][i]["color"][3])
				end
				level["enemies"][i]["color"][1] = 0
				level["enemies"][i]["color"][2] = 0
				level["enemies"][i]["color"][3] = 0
			end
		end
		
		for i = 1, #level["nextSpawn"] do			
			if level["started"] then
				level["nextSpawn"][i] = level["nextSpawn"][i] - dt			
				if level["nextSpawn"][i] <= 0 and #level["waves"][i] > 0 then
					local e = table.remove(level["waves"][i],1)
					table.insert(level["enemies"],new_enemy(level,e["pathNum"],e["color"][1],e["color"][2],e["color"][3]))
					level["nextSpawn"][i] = e["time"]
				end
			end
		end
	end
	
	level.draw = 
	function ()
		for i = 1,#level["path"] do
			for j = 1,#level["path"][i] do
				local px,py = level["tiles"].getPixelCoord(level["path"][i][j][1],level["path"][i][j][2])
				love.graphics.setColor(255,255,255,127)
				love.graphics.rectangle("fill",px,py,tileSize,tileSize)
				love.graphics.setColor(255,255,255,255)
			end
		end
		for i = 1,#level["towers"] do
			level["towers"][i].draw()
		end
		for i = 1,#level["enemies"] do
			level["enemies"][i].draw()
		end

		local width = 267
		love.graphics.setColor(255,69,69,255)
		love.graphics.rectangle("fill",0,580,(level["health"][1] / 255) * 267,20)
		love.graphics.setColor(87,255,87,255)
		love.graphics.rectangle("fill",267,580,(level["health"][2] / 255) * 267,20)
		love.graphics.setColor(135,135,255,255)
		love.graphics.rectangle("fill",534,580,(level["health"][3] / 255) * 267,20)
		love.graphics.setColor(255,255,255,255)
	end
	level.getPath =
	function(num)
		local path = {}
		for i = 1, #level["path"][num] do
			table.insert(path,level["path"][num][i])
		end
		return path
	end
	
	level.addTower =
	function(tx,ty,image,color)
		valid = not level["tiles"][tx][ty]
		for num = 1, #level["path"] do
			for i = 1, #level["path"][num] - 1 do
				if level["path"][num][i][1] ~= level["path"][num][i + 1][1] then
					local t = level["path"][num][i][1] < level["path"][num][i+1][1] and 1 or -1
					for j = level["path"][num][i][1],level["path"][num][i+1][1],t do
						if tx == j and ty == level["path"][num][i][2] then
							valid = false
						end
					end
				else
					local t = level["path"][num][i][2] < level["path"][num][i+1][2] and 1 or -1
					for j = level["path"][num][i][2],level["path"][num][i+1][2],t do
						if tx == level["path"][num][i][1] and ty == j then
							valid = false
						end
					end
				end			
			end
		end
		if valid and level["money"] >= 33 then
			local px,py = level["tiles"].getPixelCoord(tx,ty)
			table.insert(level["towers"],new_tower(level,px,py,100,color,image))
			level["money"] = level["money"] - 33
			level["tiles"][tx][ty] = true
		end
	end
	level.noHealth = function() return level["health"][1] + level["health"][2] + level["health"][3] == 0 end
	level.enemyRemaining = function() local count = 0; for i = 1,#level["waves"] do count = count + #level["waves"][i] end return count end
	return level
end

function load_level()

end

function save_level()

end