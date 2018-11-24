--Travis Halleck and Jackson Lawrence
--CS 371 Mobile Computing App Final Project

--The intermediate scene simply manages what to each level
--should do in terms of speed and clay pigeon iterations
--this file also manages start and gameover screens


local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()
 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here

---------------------------------------------------------------------------------
 
local intermediateText
local stageNum;
local listener
local button
local button1
local options
local speedMsg
_G.levelFlag = false  
_G.FINALLEVEL = 8


-- "scene:create()"
function scene:create( event )
   local sceneGroup = self.view
 
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   -- intermdeiate stage text 
   stageNum = display.newText(" ", display.contentCenterX + 80, display.contentCenterY, native.systemFont, 48)
   stageNum.text = stage
   intermediateText = display.newText( "Stage  " .. " ", display.contentCenterX, display.contentCenterY, native.systemFont, 48)
   speedMsg = display.newText( "Speed increases after every level ", display.contentCenterX+40, 225, native.systemFont, 32)
   speedMsg.isVisible = false 

   options = {
      effect = "fade",
      time = 500,
   }
    -- button events and initialization.  This event handler handles normal
    -- transitions from stage to stage
    local function handleTransitionEvent(event)
        if(event.phase=="ended") then
            composer.removeScene("level1")
            composer.gotoScene("level1", options)
        end
    end

    -- This event handler handles for any game over or if player wins the whole game
    local function handleRestartEvent(event)
        if(event.phase=="ended") then
            stage = 1
            composer.removeScene("level1")
            composer.gotoScene("startScreen", options)
        end
    end

    -- button is for normal transitions, stage to stage
    button = widget.newButton(
		{
			x = display.contentCenterX,
			y = 80,
      id = "button",
			shape = "roundedRect",
			width = 130,
			height = 50,
      label = "Next",
      labelColor = {default={0,0,0}},
			fillColor = {default={1,0,0,1},over={1,0,0,1}},
			onEvent = handleTransitionEvent
		}
  )
  
  --button1 is for restart transitions, game overs and winning entire game
  button1 = widget.newButton(
		{
			x = display.contentCenterX,
			y = 80,
      id = "button1",
			shape = "roundedRect",
			width = 130,
			height = 50,
      label = "Restart",
      labelColor = {default={0,0,0}},
			fillColor = {default={1,0,0,1},over={1,0,0,1}},
			onEvent = handleRestartEvent
		}
	)

   sceneGroup:insert(button)
   sceneGroup:insert(button1)
   sceneGroup:insert(intermediateText);
   sceneGroup:insert(stageNum);
   sceneGroup:insert(speedMsg)

   button.isVisible = false
   button1.isVisible = false
   
  
   function listener( event )
     composer.gotoScene("level1", options)
   end

   timer.performWithDelay(3000, listener);
   
end
 
-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   --if the level flag tells me if the player at least made it to the level one screen
   --that way I can check raw score without worring about the initial zero raw score
   --without that flag, it would game over as soon as intermediate.lua loads.


   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
      -- the various conditons for the intermidate stage 
      if (stage == 1 and _G.levelFlag == false) then
        speedMsg.isVisible = true 
        button1.isVisible = false
        intermediateText.text = "Stage  "
        stageNum.text = stage
        timer.performWithDelay(3000, listener);

      --I use compuser.removeScene() that way the destroy method will recreate create each time
      elseif(stage == 1 and _G.levelFlag == true and rawScore < advance) then 
        speedMsg.isVisible = false 
        print("you lost the game")
        button.isVisible = false
        intermediateText.text = "Game Over!"
        stageNum.text = ""
        button1.isVisible = true
        composer.removeScene("level1")
        _G.levelFlag = false 
        rawScore = 0
        

      elseif (stage > 1 and rawScore > advance and stage < _G.FINALLEVEL) then
        speedMsg.isVisible = true 
        intermediateText.text = "Stage  "
        stageNum.text = stage
        button.isVisible = true
        composer.removeScene("level1")
        _G.levelFlag = false 
        rawScore = 0
      
      elseif (rawScore <= advance) then
        speedMsg.isVisible = false 
        print("you lost the game")
        button.isVisible = false
        intermediateText.text = "Game Over!"
        stageNum.text = ""
        button1.isVisible = true
        composer.removeScene("level1")
        _G.levelFlag = false 
        rawScore = 0

      elseif (stage == _G.FINALLEVEL) then
        speedMsg.isVisible = false 
        print("you beat the game")
        intermediateText.text = "You Win!"
        stageNum.text = ""
        button.isVisible = false
        button1.isVisible = true
        composer.removeScene("level1")
        _G.levelFlag = false 
        rawScore = 0
      end

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
   speedMsg.isVisible = true 
 
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