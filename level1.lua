local composer = require( "composer" )
local scene = composer.newScene()
local Trajectory = require( "dmc_trajectory.DMC-trajectory-basic.dmc_library.dmc_trajectory" )
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here
---------------------------------------------------------------------------------
local LENGTH = 10

local foreground
local clayPigeon1 = nil
local launchComplete = true 

local clayPigeonIteration = 8000
local speed = 5000
local amountOfClayPigeons = 10
local scaleFactor = (speed / ((amountOfClayPigeons/2) * 100)) * 100

local launchPadLeft
local launchPadRight
local padTopLeft 
local padTopRight

local squareHt = 10
local squareWd = 10


local squaresBottomLeftArray;
local squaresBottomRightArray;
local squaresTopLeftArray;
local squaresTopRightArray;


function createSquares(orientation) 
	local blue = { 0.25, 0.25, 0.75 }
    local gray = { 0.50, 0.50, 0.50 }
	local squaresArry, offset, squareY, squareX, identifier = {}, 20, 0, 0, "";
	if(orientation == "bottom left") then 
		squareY = 280
		squareX = 0
	elseif(orientation == "bottom right") then 
		squareY = 280
		squareX = 340
	elseif(orientation == "top left") then
		squareY = 150
		squareX = 0
	elseif(orientation == "top right") then 
		squareY = 150 
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
		table.insert(squaresArry, square)
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




function onTouchEvent(event) 
  if(event.phase == "began") then 
    print("you touched me")
  end
end
	
local function reduceScale( reduceScaleBy )
  local scaleStart = 1.0
  return function()
    scaleStart = scaleStart - reduceScaleBy
    clayPigeon1.xScale = scaleStart
    clayPigeon1.yScale = scaleStart
  end
end
	
local function setupTransition()	 
	clayPigeon1 = display.newCircle( 0, 0, 25 )
	clayPigeon1.x, clayPigeon1.y = 1000, -1100
	clayPigeon1.strokeWidth = 3
    clayPigeon1:setStrokeColor( 0, 0, 0 )
	clayPigeon1.name = "clay pigeon1"
	clayPigeon1:addEventListener("touch", onTouchEvent)
	clayPigeon1.isVisible = false
end


local function doTransition()

	local heightArr = {60, 80, 100, 120, 140, 160, 165}
	local randHeight = 0 
	local len = table.getn(heightArr)
	for i = 1, len do 
		randHeight = heightArr[math.random(1, len)]
	end 
	
	clayPigeon1.isVisible = true
	local onCompleteCallback = function()
	    launchComplete = true
		clayPigeon1:removeSelf()
		setupTransition() 
		
	end

	if(launchComplete) then 
		print ("clayPigeon1 launched")
		projectileTimer = timer.performWithDelay(scaleFactor, reduceScale(0.20), math.ceil(amountOfClayPigeons/2))
	end 

	local params = {
		time = speed,
		pBegin= {selectRandomSquare(squaresBottomLeftArray).x, selectRandomSquare(squaresBottomLeftArray).y},
		pEnd= {selectRandomSquare(squaresTopRightArray).x, selectRandomSquare(squaresTopRightArray).y},
		height= randHeight,
		onComplete=onCompleteCallback
	}
	Trajectory.move( clayPigeon1, params )
	launchComplete = false
end

local function launchFunc() 
	timer.performWithDelay(clayPigeonIteration, doTransition, amountOfClayPigeons)
end 

-- next scene
local function levelEventListener( event )
   local myParams = {
      param1 = "param1",
      param2 = "param2"
   }

   composer.gotoScene("level1", {effect="fade", time=500, params=myParams })
end

-- "scene:create()"
function scene:create( event )
	local sceneGroup = self.view
	foreground = display.newImage("foreground.png")
	foreground.width = 640
	foreground.height = 320
	foreground.anchorX = 0
	foreground.anchorY = 0
	

	launchPadLeftBottom = display.newRect(130, 280, 245, 20)
	launchPadRightBottom = display.newRect(442, 280, 245, 20)
	padTopLeft = display.newRect(130, 150, 245, 20)
	padTopRight = display.newRect(442, 150, 245, 20)

	squaresBottomLeftArray = createSquares("bottom left", 10)
    squaresBottomRightArray = createSquares("bottom right", 10)
    squaresTopLeftArray = createSquares("top left", 10)
	squaresTopRightArray = createSquares("top right", 10)
	
	sceneGroup:insert(foreground)
	sceneGroup:insert(launchPadLeftBottom)
	sceneGroup:insert(launchPadRightBottom)
	sceneGroup:insert(padTopLeft)
	sceneGroup:insert(padTopRight)

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
		-- Called when the scene is still off screen (but is about to come on screen).
	elseif ( phase == "did" ) then
		-- Called when the scene is now on screen.
		-- Insert code here to make the scene come alive.
		-- Example: start timers, begin animation, play audio, etc.
	end
end

-- "scene:hide()"
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		-- Called when the scene is on screen (but is about to go off screen).
		-- Insert code here to "pause" the scene.
		-- Example: stop timers, stop animation, stop audio, etc.
	elseif ( phase == "did" ) then
		-- Called immediately after scene goes off screen.
	end
end

-- "scene:destroy()"
function scene:destroy( event )
	local sceneGroup = self.view
	-- Called prior to the removal of scene's view ("sceneGroup").
	-- Insert code here to clean up the scene.
	-- Example: remove display objects, save state, etc.
end
---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

--Runtime:addEventListener( "enterFrame", tmp )
---------------------------------------------------------------------------------

return scene