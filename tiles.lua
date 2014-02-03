function new_tileSet(sx,sy,tileSize,numx,numy)
	local tiles = {}
	tiles["sx"] = sx
	tiles["sy"] = sy
	tiles["tileSize"] = tileSize - 1
	tiles["numx"] = numx
	tiles["numy"] = numy
	for i = 1,numx do
		tiles[i] = {}
		for j = 1,numy do
			tiles[i][j] = false
		end
	end
	tiles.getTileCoord = 
	function(px,py) 
		for i = 1,tiles["numx"] do
			for j = 1, tiles["numy"] do
				if tiles["sx"] + tiles["tileSize"]*(i-1) <= px and px <= tiles["sx"] + tiles["tileSize"]*i
					and tiles["sy"] + tiles["tileSize"]*(j-1) <= py and py <= tiles["sy"] + tiles["tileSize"]*j then
					return i,j
				end
			end
		end	
		return -1,-1
	end
	tiles.getPixelCoord =
	function(tx,ty)
		return tiles["sx"] + (tx - 1) * tiles["tileSize"],tiles["sy"] + (ty - 1) * tiles["tileSize"]
	end
	tiles.validPosition = function(x,y) return 0 < x and x <= tiles["numx"] and 0 < y and y <= tiles["numy"] end
	return tiles
end


function new_grid(style,tileSize,numx,numy,sx,sy)
	local alpha = 255
	local imageData = love.image.newImageData(tileSize,tileSize)
	if style == 'dotted' then
		for x = 0, tileSize - 1,1 do
			for y = 0,tileSize - 1,1 do
				if ((x == 0 or x == tileSize - 1) and y % 4 < 2) or ((y == 0 or y == tileSize - 1) and x % 4 < 2)then
					imageData:setPixel(x,y,255,255,255,alpha)
				end
			end
		end
	elseif style == 'full' then
		for x = 0, tileSize - 1,1 do
			for y = 0,tileSize - 1,1 do
				if x == 0 or x == tileSize - 1 or y == 0 or y == tileSize - 1 then
					imageData:setPixel(x,y,255,255,255,alpha)
				end
			end
		end	
	end
	local grid_spriteBatch = love.graphics.newSpriteBatch(love.graphics.newImage(imageData),1000,"static")
	for x = 0,(numx - 1)*(tileSize - 1),tileSize - 1 do
		for y = 0,(numy - 1)*(tileSize -1),tileSize - 1 do
			grid_spriteBatch:add(sx + x,sy + y)
		end
	end
	return grid_spriteBatch
end