
local sti = require "third-party.Simple-Tiled-Implementation.sti"

function love.load()
    createMap()
    createSpriteLayer()
    createGameStates()
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
        walk_down = newAnimation(image, 0,0,16,32,4),
        walk_right = newAnimation(image,0,1,16,32,4),
        walk_up = newAnimation(image,   0,2,16,32,4),
        walk_left = newAnimation(image, 0,3,16,32,4),
        still = newAnimation(image, 0,0,16,32,1)
    }


    character.current_anim = character.anims.still

    character.x = x 
    character.y = y
    character.vx = 0
    character.vy = 0

    function character:startAnimation(anim)
        self.current_anim = self.anims[anim] 
        self.current_anim.time = 0
	end
    
    function character:update(dt)
        self.current_anim:update(dt)
        print(self.current_anim)
	end

	function character:draw()
        self.current_anim:draw(x,y)
	end
 
    return character
end

function newAnimation(image, x_start, y_start, width, height, frames, duration)
    local animation = {}
    animation.quads = {};
    animation.spriteSheet = image;

    y = y_start*height
    for x = x_start*width, (x_start + frames - 1)*width, width do
        print("inserting frame at ",x)
        table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
    end
     
    animation.time = 0.0
    animation.duration = duration or 1

    -- Draw callback for Custom Layer
	function animation:update(dt)
        self.time = self.time + dt
        if self.time >= self.duration then
           self.time = self.time  - self.duration
        end
	end

	-- Draw callback for Custom Layer
	function animation:draw(x,y)
        local index = math.floor(self.time / self.duration * #self.quads) + 1
		love.graphics.draw(self.spriteSheet,self.quads[index], x, y-height/2)
	end
 
    return animation
end

function createMap()
	-- Load a map exported to Lua from Tiled
	map = sti("gfx/level_1.lua")
end


function createSpriteLayer()

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

    map:removeLayer("spawn")

end



function createGameStates()
   local spriteLayer = map.layers["Sprite Layer"]
   local player = spriteLayer.sprites.player
   local gameStates = {}
   local state
    
    gameStates.gameLoop = {
        bindings = {
            up = function() player:startAnimation("walk_up") end,
            down = function() player:startAnimation("walk_down") end,
            left       = function() player:startAnimation("walk_left") end,
            right      = function() player:startAnimation("walk_right") end,
            still = function() player:startAnimation("still") end,
        },
        keys = {
            up = "up",
            down = "down",
            left   = "left",
            right  = "right",
        },
        keysReleased = {
            up = "still",
            down = "still",
            left = "still",
            right = "still",
        },
        buttons = {},
        buttonsReleased = {},
    }

    state = gameStates.gameLoop

    function inputHandler( input )
        local action = state.bindings[input]
        if action then  return action()  end
    end

    function love.keypressed( k )
        -- you might want to keep track of this to change display prompts
        INPUTMETHOD = "keyboard"
        local binding = state.keys[k]
        return inputHandler( binding )
    end
    function love.keyreleased( k )
        local binding = state.keysReleased[k]
        return inputHandler( binding )
    end
    function love.gamepadpressed( gamepad, button )
        -- you might want to keep track of this to change display prompts
        INPUTMETHOD = "gamepad"
        local binding = state.buttons[button]
        return inputHandler( binding )
    end
    function love.gamepadreleased( gamepad, button )
        local binding = state.buttonsReleased[button]
        return inputHandler( binding )
    end
end



