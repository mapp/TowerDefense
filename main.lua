require('level')
require('tiles')
require('tower')
require('enemy')
require('shader')

function love.load()
	local tileSize = 30
	local boardSize = 15
	level = new_level(150,50,tileSize,boardSize,boardSize,"l1.txt")
	local px,py = level["tiles"].getPixelCoord(5,4)	
	local imgd = love.image.newImageData(10,10)
	for i = 0, 9 do
		for j = 0, 9 do
			imgd:setPixel(i,j,255,0,0,255)
		end
	end
	grid_spriteBatch = new_grid('full',tileSize,boardSize,boardSize,150,50)
	shader = get_shader()
	red_image = love.graphics.newImage('red_tower.png')
	blue_image = love.graphics.newImage('blue_tower.png')
	green_image = love.graphics.newImage('green_tower.png')
	tower_type = {}
	tower_type["color"] = {1,0,0,1}
	tower_type["image"] = red_image
	lights = false
	curr_level_file = "l1.txt"
	love.graphics.setNewFont(24)
	draw_circle = false
end

function love.update(dt)
	level.update(dt)
	if level.noHealth() then
		level = new_level(150,50,30,15,15,curr_level_file)
	elseif level.enemyRemaining() == 0 and #level["enemies"] == 0 then
		curr_level_file = "l2.txt"
		level = new_level(150,50,30,15,15,"l2.txt")
	end
end

function love.draw()
	love.graphics.print(love.timer.getFPS(),10,10)
	love.graphics.print(tostring(level["money"]),10,50)	
	if lights then
		love.graphics.setShader(shader)
		local color = {}
		local power = {}
		local position = {}
		table.insert(power,50)
		table.insert(color,{1,1,1,1})
		table.insert(position,{love.mouse.getX(),600 - love.mouse.getY()})
		for i=1,#level["towers"] do
			table.insert(color,level["towers"][i]["color"])
			table.insert(power,100)
			table.insert(position,{level["towers"][i]["position"][1] + 15,600 - level["towers"][i]["position"][2] - 15})
		end
		for i=1,#level["enemies"] do
			table.insert(color,{1,1,1,1})
			table.insert(power,25)
			table.insert(position,{level["enemies"][i]["position"][1] + 7.5,600 - level["enemies"][i]["position"][2] - 7.5})
		end
		shader:send("num_lights",1 + #level["towers"] + #level["enemies"])
		shader:send("light_pos",unpack(position))
		shader:send("light_power",unpack(power))
		shader:send("light_color",unpack(color))
	end	
	love.graphics.draw(grid_spriteBatch)	
	love.graphics.setShader()
	level.draw()
	if draw_circle then
		love.graphics.circle("line",love.mouse.getX(),love.mouse.getY(),100,100)
	end
end

function love.keypressed(key)
	if key == "1" then
		tower_type["color"] = {1,0,0,1}
		tower_type["image"] = red_image
	elseif key == "2" then
		tower_type["color"] = {0,1,0,1}
		tower_type["image"] = green_image
	elseif key == "3" then
		tower_type["color"] = {0,0,1,1}
		tower_type["image"] = blue_image
	end
end

function love.keyreleased(key)
	if key == "r" then
		table.insert(level["enemies"],new_enemy(level,1,math.random(50,255),math.random(50,255),math.random(50,255)))	
	elseif key == "l" then
		lights = not lights
	elseif key == "s" then
		level["started"] = true
	elseif key == "f1" then
		curr_level_file = "l1.txt"
		level = new_level(150,50,30,15,15,curr_level_file)
	elseif key == "f2" then
		curr_level_file = "l2.txt"
		level = new_level(150,50,30,15,15,curr_level_file)
	elseif key == "f3" then
		curr_level_file = "l3.txt"
		level = new_level(150,50,30,15,15,curr_level_file)
	end
end

function love.mousepressed(x,y,button)
	if button == "r" then
		draw_circle = true
	end
end

function love.mousereleased(x,y,button)
	local tx,ty = level["tiles"].getTileCoord(x,y)
	if button == "l" and tx ~= -1 and ty ~= -1 then
		level.addTower(tx,ty,tower_type["image"],tower_type["color"])		
	elseif button == "r" then
		draw_circle = false
	end
end

function dist(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end