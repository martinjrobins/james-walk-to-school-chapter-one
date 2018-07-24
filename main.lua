
local sti = require "third-party.Simple-Tiled-Implementation.sti"

function love.load()
	-- Grab window size
	windowWidth  = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()

	-- Load a map exported to Lua from Tiled
	map = sti("gfx/level_1.lua")


    -- Get player spawn object
    local player
    for k, object in pairs(map.objects) do
        if object.name == "spawn point" then
            player = object
            break
        end
    end


	-- Create a Custom Layer
	local spriteLayer = map:addCustomLayer("Sprite Layer", 5)

	-- Add data to Custom Layer
	spriteLayer.sprites = {
        player = newCharacter(love.graphics.newImage("gfx/character.png"),player.x,player.y)
	}

	-- Update callback for Custom Layer
	function spriteLayer:update(dt)
		for _, sprite in pairs(self.sprites) do
	        sprite:update(dt)
		end
	end

	-- Draw callback for Custom Layer
	function spriteLayer:draw()
		for _, sprite in pairs(self.sprites) do
            sprite:draw()
		end
	end
end

function love.update(dt)
	map:update(dt)
end

function love.draw()
    -- Scale world
    local scale = 2
    local screen_width = love.graphics.getWidth() / scale
    local screen_height = love.graphics.getHeight() / scale

    -- Translate world so that player is always centred
	local spriteLayer = map.layers["Sprite Layer"]
    local player = spriteLayer.sprites.player

    local tx = math.floor(player.x - screen_width / 2)
    local ty = math.floor(player.y - screen_height / 2)

    -- Transform world
    love.graphics.scale(scale)
    love.graphics.translate(-tx, -ty)

    -- Draw world
    map:draw()

end

function newCharacter(image, x, y)
    local character = {}

    character.anims = {
        down = newAnimation(image,0,0,16,16,4),
        right = newAnimation(image,0,1,16,16,4),
        up = newAnimation(image,0,2,16,16,4),
        left = newAnimation(image,0,3,16,16,4)
    }

    character.current_anim = character.anims.down
    character.x = x 
    character.y = y
    
    function character:update(dt)
        print('update character',self,dt)
		for key, anim in pairs(self.anims) do
            if love.keyboard.isDown(key) then
                print(key,"is down")
                if (self.current_anim == anim) then
                    self.current_anim.time = self.current_anim.time + dt
                else
                    self.current_anim.time = 0
                    self.current_anim = anim
                end
            end
        end
	end

	-- Draw callback for Custom Layer
	function character:draw()
        print('draw character',self)
		for key, anim in pairs(self) do
            print(key,anim)
        end
        self.current_anim:draw(x,y)
	end
 
    return character
end

function newAnimation(image, x_start, y_start, width, height, frames, duration)
    local animation = {}
    animation.quads = {};
    animation.spriteSheet = image;

    y = y_start*height
    for x = x_start*width, (x_start + frames)*width, width do
        print("inserting frame at ",x,y,width,height)
        table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
    end
 
    animation.time = 0.0
    animation.duration = duration or 1


	-- Draw callback for Custom Layer
	function animation:draw(x,y)
        local index = math.floor(self.time/self.duration * #self.quads)
        print("index=",index)
		love.graphics.draw(self.spriteSheet,self.quads[index], x, y)
	end
 
    return animation
end
