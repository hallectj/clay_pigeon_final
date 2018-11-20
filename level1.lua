local composer = require( "composer" )
local physics = require ("physics")
local scene = composer.newScene()
local Trajectory = require( "dmc_trajectory.DMC-trajectory-basic.dmc_library.dmc_trajectory" )
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here
---------------------------------------------------------------------------------
local dashboardGroup = display.newGroup()
local masterGroup = display.newGroup()

local transition = false
local zone 

local LENGTH = 10
local scoreText
local stageText

local launcher1 
local launcher2
local launcherChannel	
local launcherChannel2

local sheet
local smoke_opt
local smoke_seq
local animSmoke

local topHalfArr, bottomHalfArr = {}, {}

local foreground
local clayPigeon1 = nil
local clayPigeon2 = nil 
local launchComplete = true 

local clay1ID = 0
local clay2ID = 0
local dashboard

local amountOfClayPigeons = 10
local scaleFactor = (speed / ((amountOfClayPigeons/2) * 100)) * 100
local levelExpireTimeSeconds = ((amountOfClayPigeons * clayPigeonIteration) + (clayPigeonIteration - math.floor((clayPigeonIteration/2)))) / 1000


local launchPadLeft
local launchPadRight
local padTopLeft 
local padTopRight

local squareHt = 10
local squareWd = 10
local textToAdvance

local squaresBottomLeftArray;
local squaresBottomRightArray;
local squaresTopLeftArray;
local squaresTopRightArray;

local option = {
  effect = "fade",
  time = 1300,
}

local launcher1Options = {
    channel = 1,
    duration = speed
}

local launcher2Options = {
    channel = 2,
    duration = speed
}

local soundTable = {
	explosionSound = audio.loadSound("explosion.wav"),
	launcherSound = audio.loadSound("launcher.wav")
}

function createSquares(orientation) 
	local blue = { 0.25, 0.25, 0.75 }
    local gray = { 0.50, 0.50, 0.50 }
	local squaresArry, offset, squareY, squareX, identifier = {}, 20, 0, 0, "";
	if(orientation == "bottom left") then 
		squareY = 220
		squareX = 0
	elseif(orientation == "bottom right") then 
		squareY = 220
		squareX = 340
	elseif(orientation == "top left") then
		squareY = 140
		squareX = 0
	elseif(orientation == "top right") then 
		squareY = 140
		squareX = 340 
	end

	for i = 1, LENGTH do 
		squareX = squareX + offset
		local square = display.newRect(squareX, squareY, squareHt, squareWd);
		if(orientation == "top left" or orientation == "bottom right") then 
		  square:setFillColor(unpack(blue))
		elseif(orientation == "top right" or orientation == "bottom left") then 
		  square:setFillColor(unpack(gray))
		end
		square.identifier = orientation
		square.xPos = square.x 
		square.alpha = 0.01;
		table.insert(squaresArry, square)
		masterGroup:insert(square)
	end
	return squaresArry
end

function selectRandomSquare(arr)
	local len = table.getn(arr)
    local randSquare = arr[1] 
	for i = 1, len do  
	  randSquare = arr[math.random(1, len)]
	end 
	return randSquare;
end 

function populateDashoardCircles()
	local upperHalfY = 280
	local lowerHalfY = 300
	local identifier = ""
	local offset, circleY, circleX = 15, upperHalfY, 0;
	for i = 1, 10 do 
		circleX = circleX + offset
		local circle1 = display.newCircle(circleX, upperHalfY, 5)
		local circle2 = display.newCircle(circleX, lowerHalfY, 5)
		circle1:setStrokeColor(0,0,0)
		circle1.strokeWidth = 3
		circle1.identifier = "top " .. i 
		table.insert(topHalfArr, circle1)

		circle2:setStrokeColor(0,0,0)
		circle2.strokeWidth = 3
		circle2.identifier = "bottom " .. i
		table.insert(bottomHalfArr, circle2)

		dashboardGroup:insert(circle1)
		dashboardGroup:insert(circle2)

	end
end

function readyBoxTextFunc() 
	physics.start()
	physics.setGravity(0, 0)
	
	readyBoxText = display.newText("You must shoot " .. advance+1 .. " clay pigeons to advance ", 0, 0, native.systemFont, 24)
	readyBoxText.x = 10
	readyBoxText.y = 100
	readyBoxText:setFillColor(0.25, 0.25, 0.10)
	
	physics.addBody(readyBoxText, "")
	readyBoxText.linearDamping = 0
	readyBoxText:applyForce(45.0,0.2,readyBoxText.x,readyBoxText.y);
end

-- "scene:create()"
function scene:create( event )
	_G.levelFlag = true 

	intoLevelOneAtLeast = true 
	local sceneGroup = self.view

	smoke_opt = {
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

	smoke_seq = {
	    {name = "explode", frames = { 1, 2, 3, 4, 5, 6, 7, 8}, time = 250, loopCount = 1}
	}

	sheet = graphics.newImageSheet("smoke.png", smoke_opt);

	foreground = display.newImage("foreground.png")
	foreground.width = 640
	foreground.height = 320
	foreground.y = -55
	foreground.anchorX = 0
	foreground.anchorY = 0

	launchPadLeftBottom = display.newRect(130, 280, 245, 20)
	launchPadRightBottom = display.newRect(442, 280, 245, 20)
	padTopLeft = display.newRect(130, 150, 245, 20)
	padTopRight = display.newRect(442, 150, 245, 20)

	dashboard = display.newRect(285, 290, display.actualContentWidth-5, 50)
	dashboard:setStrokeColor(0,0,0)
	dashboard.strokeWidth = 3
	dashboard:setFillColor(0.11, 0.34, 0.71)

	stageText = display.newText("", 295, 290, native.systemFont, 24)
	stageText.text = "Level " .. stage
	stageText:setFillColor(0.30, 0.95, 0.45)
	stageText.strokeWidth = 5 

	masterGroup:insert(launchPadLeftBottom)
	masterGroup:insert(launchPadRightBottom)
	masterGroup:insert(padTopLeft)
	masterGroup:insert(padTopRight)

	populateDashoardCircles()

	scoreText = display.newText("score: " .. _G.score, 410, 290, native.systemFont, 24)
	scoreText:setFillColor(0.10, 0.95, 0.15)

	textToAdvance = display.newText("Continue On", 0, 0, native.systemFont, 16)
	textToAdvance.x = zone.x
	textToAdvance.y = zone.y
    textToAdvance.isVisible = false

	dashboardGroup:insert(dashboard)
	dashboardGroup:insert(scoreText)
	dashboardGroup:insert(stageText)

	launchPadLeftBottom.alpha = 0.01
	launchPadRightBottom.alpha = 0.01
	padTopLeft.alpha = 0.01 
	padTopRight.alpha = 0.01

	squaresBottomLeftArray = createSquares("bottom left", 10)
    squaresBottomRightArray = createSquares("bottom right", 10)
    squaresTopLeftArray = createSquares("top left", 10)
	squaresTopRightArray = createSquares("top right", 10)
	
	sceneGroup:insert(foreground)
	--sceneGroup:insert(launchPadLeftBottom)
	--sceneGroup:insert(launchPadRightBottom)
	--sceneGroup:insert(padTopLeft)
	--sceneGroup:insert(padTopRight)
	sceneGroup:insert(masterGroup)
	sceneGroup:insert(dashboard)	
	sceneGroup:insert(dashboardGroup)

	function cleanUpSmoke()
		animSmoke.isVisible = false
		--animSmoke:removeSelf()
		--animSmoke = nil 
	end
	
	function onTouchEventClay1(event) 
	  if(event.phase == "began") then 
		rawScore = rawScore + 1
		clayPigeon1.isVisible = false;
		animSmoke = display.newSprite (sheet, smoke_seq);
		animSmoke.isVisible = true 
		animSmoke.x = clayPigeon1.x 
		animSmoke.y = clayPigeon1.y
		masterGroup:insert(animSmoke)
		animSmoke:setSequence("explode")
		animSmoke:play()
		timer.performWithDelay(400, cleanUpSmoke, 1)
		audio.play(soundTable["explosionSound"])
		audio.stop(launcherChannel1)
		_G.score = _G.score + 10 
		scoreText.text = "score " .. _G.score 
		for i = 1, table.getn(topHalfArr) do 
			if(topHalfArr[i].identifier == clayPigeon1.identifier) then 
				topHalfArr[i]:setFillColor(1, 0, 0)
			end
		end
	  end
	end
	
	function onTouchEventClay2(event) 
		if(event.phase == "began") then 
		  rawScore = rawScore + 1
		  clayPigeon2.isVisible = false;
		  animSmoke = display.newSprite (sheet, smoke_seq);
		  animSmoke.isVisible = true 
		  animSmoke.x = clayPigeon2.x 
		  animSmoke.y = clayPigeon2.y
		  masterGroup:insert(animSmoke)
		  animSmoke:setSequence("explode")
		  animSmoke:play()
		  timer.performWithDelay(400, cleanUpSmoke, 1)
		  audio.play(soundTable["explosionSound"])
		  audio.stop(launcherChannel2)
		  _G.score = _G.score + 10 
		  scoreText.text = "score " .. _G.score 
		  for i = 1, table.getn(topHalfArr) do 
			if(bottomHalfArr[i].identifier == clayPigeon2.identifier) then 
				bottomHalfArr[i]:setFillColor(1, 0, 0)
			end
		  end
		end
	  end
		
	function reduceScale(  )
	  local reduceScaleBy = 0.20
	  local count = 0 
	  local scaleStart = 1.0
	  --local divideSpeedBy = 20

	  return function()
		scaleStart = scaleStart - reduceScaleBy
		clayPigeon1.xScale = scaleStart
		clayPigeon1.yScale = scaleStart
		clayPigeon2.xScale = scaleStart
		clayPigeon2.yScale = scaleStart
	  end
	end
		
    function setupTransition()	
		clayPigeon1 = display.newCircle( 0, 0, 25 )
		clayPigeon1.x, clayPigeon1.y = 1000, -1100
		clayPigeon1.strokeWidth = 3
		clayPigeon1:setStrokeColor( 0, 0, 0 )
		clayPigeon1.name = "clay pigeon1"
		clayPigeon1:addEventListener("touch", onTouchEventClay1)
		clayPigeon1.isVisible = false
	
		clayPigeon2 = display.newCircle( 0, 0, 25 )
		clayPigeon2.x, clayPigeon1.y = 1000, -1100
		clayPigeon2.strokeWidth = 3
		clayPigeon2:setStrokeColor( 0, 0, 0 )
		clayPigeon2.name = "clay pigeon2"
		clayPigeon2:addEventListener("touch", onTouchEventClay2)
		clayPigeon2.isVisible = false
	
	end
	
	
	function doTransition()
	
		clay1ID = clay1ID + 1
		clay2ID = clay2ID + 1
		local heightArr = {60, 80, 100, 120, 140, 150}
		local randHeight = 0 
		local len = table.getn(heightArr)
		for i = 1, len do 
			randHeight = heightArr[math.random(1, len)]
			randHeight2 = heightArr[math.random(1, len)]
		end 
		
		clayPigeon1.isVisible = true
		clayPigeon2.isVisible = true
		
		clayPigeon1.identifier = "top " .. clay1ID
		clayPigeon2.identifier = "bottom " .. clay2ID
	
		local onCompleteCallback = function()
			launchComplete = true
			clayPigeon1:removeSelf()
			clayPigeon2:removeSelf()
			setupTransition() 
		end
	
		if(launchComplete) then 
			--print ("clayPigeon1 launched")
			projectileTimer = timer.performWithDelay(scaleFactor, reduceScale(), math.ceil(amountOfClayPigeons/2))
			launcher1 = audio.loadStream("launcher.wav")
			launcher2 = audio.loadStream("launcher.wav")
			launcherChannel1 = audio.play(launcher1, launcher1Options)
			launcherChannel2 = audio.play(launcher2, launcher2Options)

			--launcherChannel1 = audio.play(launcher1, {channel = 1})
			--launcherChannel2 = audio.play(launcher2, {channel = 2})

			clayPigeon1.xScale = 1 
			clayPigeon1.yScale = 1
			clayPigeon2.xScale = 1
			clayPigeon2.yScale = 1

		end 
	
		local params1 = {
			time = speed,
			pBegin= {selectRandomSquare(squaresBottomLeftArray).x, selectRandomSquare(squaresBottomLeftArray).y},
			pEnd= {selectRandomSquare(squaresTopRightArray).x, selectRandomSquare(squaresTopRightArray).y},
			height= randHeight,
			onComplete=onCompleteCallback
		}
	
		local params2 = {
			time = speed,
			pBegin= {selectRandomSquare(squaresBottomRightArray).x, selectRandomSquare(squaresBottomRightArray).y},
			pEnd= {selectRandomSquare(squaresTopLeftArray).x, selectRandomSquare(squaresTopLeftArray).y},
			height= randHeight2,
			onComplete=onCompleteCallback		
		}
	
	
		Trajectory.move( clayPigeon1, params1 )
		Trajectory.move( clayPigeon2, params2 )
		launchComplete = false
	end
	
    function launchFunc() 
		timer.performWithDelay(clayPigeonIteration, doTransition, amountOfClayPigeons)
	end

	function timerFunc(event)
        if (transition == true) then
            timer.cancel( event.source )
		end

		if(levelExpireTimeSeconds == event.count) then 
			if(rawScore <= advance) then 
			  composer.gotoScene("intermediate", option)
			  zone.isVisible = false 
			  _G.score = 0 
			  return 
		    end 
			zone.isVisible = true
			textToAdvance.isVisible = true 
			zone:addEventListener("tap", zoneHandler)
		end

		print(event.count)

	end

	theTimer = timer.performWithDelay(1000, timerFunc, levelExpireTimeSeconds)
	
	--determines what happens in terms of speed and what not
	function stageDeterminer() 
		if(stage == 1) then 
			speed = 5000
		elseif(stage == 2) then
			speed = 4500
			advance = 7
		elseif(stage == 3) then
			speed = 4000
			advance = 9
		elseif(stage == 4) then
			speed = 3500
			advance = 11
		elseif(stage == 5) then
			speed = 3000
			advance = 13
		elseif(stage == 6) then
			speed = 2500
			advance = 13 
		elseif(stage == 7) then
			speed = 2000
			advance = 13
		elseif(stage == 8) then 
			speed = 1500 
			advance = 13
		end
	end

	stageDeterminer()

	readyBoxTextFunc()
	launchFunc()
	setupTransition()

	--  Initialize the scene here.
	-- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

-- "scene:show()"
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		stageDeterminer()
		-- Called when the scene is still off screen (but is about to come on screen).
	elseif ( phase == "did" ) then
		-- Called when the scene is now on screen.
		-- Insert code here to make the scene come alive.
		-- Example: start timers, begin animation, play audio, etc.
		transition = false
	end
end

-- "scene:hide()"
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		transition = false
		-- Called when the scene is on screen (but is about to go off screen).
		-- Insert code here to "pause" the scene.
		-- Example: stop timers, stop animation, stop audio, etc.
	elseif ( phase == "did" ) then
		if(stage == 1) then 
			sceneGroup:insert(zone)
		end
		-- Called immediately after scene goes off screen.
	end
end

-- "scene:destroy()"
function scene:destroy( event )
	local sceneGroup = self.view
	textToAdvance.isVisible = false 
	zone.isVisible = false 
	clayPigeon1 = nil 
	clayPigeon2 = nil 
	rawScore = 0
	advance = 5

	dashboardGroup:removeSelf()
	dashboardGroup = nil 

	masterGroup:removeSelf()
	masterGroup = nil
	--score = _G.score 
	-- Called prior to the removal of scene's view ("sceneGroup").
	-- Insert code here to clean up the scene.
	-- Example: remove display objects, save state, etc.
end


zone = display.newRect (display.contentCenterX-10, display.contentCenterY-100 + 100, 140, 30);
zone.strokeWidth = 2;
zone:setFillColor(0,0,0);
zone.isSensor = true;
zone.isVisible = false

function zoneHandler(event)
	local x, y = event.target:contentToLocal(event.x, event.y); 
	x = x + 150;
	y = y + 100;
	x = math.ceil(x/60);
	y = math.ceil(y/50);

	print("Stage is ", stage)
	print("rawScore is ", rawScore)
	print("score is", _G.score)
	print("speed is", speed)

	if (checkValid(x, y)) then
	  return;
	end   
end

function checkValid(x,y) 
	local _x, _y = zone:localToContent((x*60)-180, (y*50)-125);
	if (rawScore > advance) then
		print("stage is ", stage)
	  stage = stage + 1
	  composer.gotoScene("intermediate", option)
	  clayPigeon1.isVisible = false 
	  clayPigeon2.isVisible = false
	end 
	 
	return;
 end


---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
--zone:addEventListener("tap", zoneHandler)

--Runtime:addEventListener( "enterFrame", tmp )
---------------------------------------------------------------------------------

return scene