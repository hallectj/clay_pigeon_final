local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here
---------------------------------------------------------------------------------

local startScreen
local startText
_G.score = 0 
_G.stage = 1
stage = _G.stage 


function determineIteration()
	local iter = 1000
	if(stage == 1 or stage == 2) then 
		iter = 10000
	elseif(stage == 3 or stage == 4 or stage == 5) then 
		iter = 8000
	elseif(stage == 6 or stage == 7 or stage == 8) then
		iter = 6000
	else
		iter = 5000
	end
	return iter 
end

-- next scene
local function levelEventListener( event )
   local myParams = {
      param1 = "param1",
      param2 = "param2"
   }

   composer.removeScene("intermediate")   
   composer.gotoScene("level1", {effect="fade", time=500, params=myParams })
end

-- "scene:create()"
function scene:create( event )
	local sceneGroup = self.view
	startScreen = display.newImage("startScreen1.png")
	--startText = display.newText( "START", display.contentCenterX+74, display.contentCenterY-10, native.systemFont, 28 )
	--startText:setFillColor( 1, 1, 0 )
	startScreen.width = 640
	startScreen.height = 320
	startScreen.anchorX = 0
	startScreen.anchorY = 0

	local NameText = display.newText("Travis Halleck", 320, 250)
	local NameText2 = display.newText("Jackson Lawrence", 320, 275)

	NameText:setFillColor(0, 0, 0)
	NameText2:setFillColor(0, 0, 0)
	
	local options = {
		effect = "fade",
		time = 800
	}

	local function sceneListener(event)
        if(event.phase=="ended") then
            composer.gotoScene("intermediate",options)
        end
	end
	
	local buttonOpts = {
		x = display.contentCenterX+78,
		y = display.contentCenterY-10,
		id = "button1",
		shape = "roundedRect",
		width = 100,
		height = 50,
		label = "Start",
		labelColor = {default={0,0,0}},
		fillColor = {default={1,0,0,1},over={1,0,0,1}},
		onEvent = sceneListener
	}

    local button = widget.newButton(buttonOpts)


	sceneGroup:insert(startScreen)
	sceneGroup:insert(button)
	sceneGroup:insert(NameText)
	sceneGroup:insert(NameText2)
	-- Initialize the scene here.
	-- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

-- "scene:show()"
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		-- Called when the scene is still off screen (but is about to come on screen).
		rawScore = 0 
		advance = 5
		speed = 4000
		clayPigeonIteration = determineIteration()

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
---------------------------------------------------------------------------------

return scene