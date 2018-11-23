module (..., package.seeall)

local smoke_opt = {
    frames = {
        {x = 0, y = 0, width = 15, height = 15},
        {x = 18, y = 0, width = 15, height = 15},
        {x = 35, y = 0, width = 15, height = 15},
        {x = 50, y = 0, width = 15, height = 15},
        {x = 0, y = 16, width = 15, height = 15},
        {x = 18, y = 16, width = 15, height = 15},
        {x = 35, y = 16, width = 15, height = 15},
        {x = 50, y = 16, width = 15, height = 15}
    }
}

local smoke_seq = {
    {name = "explode", frames = { 1, 2, 3, 4, 5, 6, 7, 8}, time = 250, loopCount = 1}
}

local sheet = graphics.newImageSheet("smoke.png", smoke_opt);

local soundTable = {
	explosionSound = audio.loadSound("explosion.wav"),
}

--OOP clay pigeon creation
 function new()

    local pigeon = display.newCircle(0, 0, 25)

	function pigeon:createPigeon()
		self.x, self.y = 1000, -1100
		self.strokeWidth = 3
		self:setStrokeColor( 0, 0, 0 )
		self.name = "clay pigeon1"
        --self:addEventListener("touch", self:touch())
		self.isVisible = false
    end
    
    function pigeon:animateSmoke()
        animSmoke = display.newSprite (sheet, smoke_seq);
		animSmoke.isVisible = true 
		animSmoke.x = pigeon.x 
		animSmoke.y = pigeon.y
        animSmoke:setSequence("explode")
        animSmoke:play()
        audio.play(soundTable["explosionSound"])
        timer.performWithDelay(400, cleanUpSmoke, 1)
    end

    function cleanUpSmoke()
		animSmoke.isVisible = false
	end
 
	return pigeon
 
 end