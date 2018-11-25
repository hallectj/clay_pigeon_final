--Travis Halleck and Jackson Lawrence
--CS 371 Mobile Computing App Final Project

--Trajectory comes from the dmc-trajectory library.  This library is needed for parabolic curves only
--everything else is customized by us

	local composer = require( "composer" )
	local physics = require ("physics")
	local scene = composer.newScene()
	local Trajectory = require( "dmc_trajectory.DMC-trajectory-basic.dmc_library.dmc_trajectory" )
	
	--To satisfy the oop requirements of the project
	local claypigeon = require( "ClayPigeon" )
	
	local perfectText
	
	--custom event handler, checks if rawScore (number of claypigeons per round is max (perfect))
	local function onPerfectionHandler(event)
		if(event.raw == 20) then 
			perfectText.isVisible = true 
		elseif(event.raw < 20) then 
			perfectText.isVisible = false 
		end
	end


	---------------------------------------------------------------------------------
	-- All code outside of the listener functions will only be executed ONCE
	-- unless "composer.removeScene()" is called.
	---------------------------------------------------------------------------------
	
	-- local forward references should go here
	---------------------------------------------------------------------------------
	--I decided to put everything in groups so I can destroy them when intermediate scene is called.
	--without the groups, phantom objects remain.
	
	local dashboardGroup = display.newGroup()
	local masterGroup = display.newGroup()
	
	local transition = false
	local zone 
	
	--LENGTH is the number of squares I create for source and destination points for parabolic curves
	local LENGTH = 10
	local scoreText
	local stageText
	
	--launcher1 and launcher 2 are the audio assets for when the clay pigeon is launched.
	local launcher1 
	local launcher2
	local launcherChannel	
	local launcherChannel2
	
	--smoke sprite for when player touches the clay pigeon
	local sheet
	local smoke_opt
	local smoke_seq
	local animSmoke
	
	--duck sprite that is used as an obsticle
	local duck = nil
	local duck_sheet
	local duck_opt
	local duck_seq

	--arrays that hold the squares
	local topHalfArr, bottomHalfArr = {}, {}
	
	local foreground
	local clayPigeon1 = nil
	local clayPigeon2 = nil
	
	
	--launchComplete is needed so I know when to begin iterations and audio
	local launchComplete = true 
	
	--Used to identify which clay pigeon is what, used later
	local clay1ID = 0
	local clay2ID = 0
	
	--dashboard at bottom of screen that has scores and number of clay pigeons touched
	local dashboard
	
	--amount of clay pigeons per side.  10 on left and 10 on right
	local amountOfClayPigeons = 10
	
	--scaleFactor is used so I know how long a clay pigeon launch should be in order for xScale and yScale to work properly later
	local scaleFactor = (speed / ((amountOfClayPigeons/2) * 100)) * 100
	
	--this is used to say when the stage is over, so the timer can know
	local levelExpireTimeSeconds = ((amountOfClayPigeons * clayPigeonIteration) + (clayPigeonIteration - math.floor((clayPigeonIteration/2)))) / 1000
	
	--launchpads are only there to house the invisible squares to help me visualize souce and destination points
	local launchPadLeft
	local launchPadRight
	local padTopLeft 
	local padTopRight
	
	local squareHt = 10
	local squareWd = 10
	local textToAdvance
	
	--So after creating squares, I use the x cordinate of each square to launch to.  I need these arrays 
	--so I can pick a random square from them.  Basically top left is mapped to bottom right and top right
	--is mapped to bottom left, see function for code
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
	
	--This gives me the squares for the invisible launch pads so I can tell Trajectory.move where to 
	--launch to.  Orientation is given so I can easily place them on the launch pads
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
	
	--selects random square from the 4 square arrays.  Needed so I can launch to a random square
	--10 total on each orientation, to help with mapping
	function selectRandomSquare(arr)
		local len = table.getn(arr)
		local randSquare = arr[1] 
		for i = 1, len do  
		  randSquare = arr[math.random(1, len)]
		end 
		return randSquare;
	end 
	
	--popluate dashboard circles, creates circles that identify which clay pigeon was touched.
	--top represents left clay pigeons and bottom represents bottom clay pigeons.  As the user 
	--touches the clay pigeon, the circle will fill with red indicating a hit.  
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
	
	--This function creates a text that lets the user know how many clay pigeons he or she must touch
	--to advance to the next stage.  This acts as a marquee really.
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

			--duck frames
		duck_opt = {
			frames = {
    	       { x = 148, y = 22, width = 40, height = 37},
    	       { x = 191, y= 22, width = 41, height = 37}
    	   }
		}
		
		duck_seq = {
			{name = "wingsUp", frames = { 1, 2}, time = 250, loopCount = 1},
     		{name = "wingsDown", frames = {2, 1}, time = 250, loopCount = 1}

		}

		duck_sheet = graphics.newImageSheet("marioware.png", duck_opt)
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
	
		perfectText = display.newText("AMAZING\nPERFECT ROUND!!!", display.contentCenterX, 100, "Comic Sans MS", 32)
		perfectText:setFillColor(1, 0, 0)

		masterGroup:insert(launchPadLeftBottom)
		masterGroup:insert(launchPadRightBottom)
		masterGroup:insert(padTopLeft)
		masterGroup:insert(padTopRight)
		masterGroup:insert(perfectText)

		perfectText.isVisible = false
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
		sceneGroup:insert(masterGroup)
		sceneGroup:insert(dashboard)	
		sceneGroup:insert(dashboardGroup)
		
		--on touch, raw score goes up, smoke animation plays as well as poof animation
		--score gets updates and displayed also the corresponding circle on the dashboard
		--gets filled with red letting the user know which clay pigeon they hit.
	
	
		function onTouchEventClay1(event) 
		  if(event.phase == "began") then 
			rawScore = rawScore + 1

			--to satisfy custom event requirement
			Runtime:dispatchEvent({name = "perfection", raw = rawScore})
			Runtime:addEventListener("perfection", onPerfectionHandler)
			clayPigeon1.isVisible = false;
			clayPigeon1:animateSmoke()
	
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

			  --to satisfy custom event requirement
			  Runtime:dispatchEvent({name = "perfection", raw = rawScore})
			  Runtime:addEventListener("perfection", onPerfectionHandler)
			  clayPigeon2.isVisible = false;
			  clayPigeon2:animateSmoke()
	
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
			
		--reduceScale returns a function so the child anomynous function has what the parent has
		--in order to properly scale the clay pigeons while they get resetted when needed.
		function reduceScale(  )
		  local reduceScaleBy = 0.20
		  local count = 0 
		  local scaleStart = 1.0
	
		  return function()
			scaleStart = scaleStart - reduceScaleBy
			clayPigeon1.xScale = scaleStart
			clayPigeon1.yScale = scaleStart
			clayPigeon2.xScale = scaleStart
			clayPigeon2.yScale = scaleStart
		  end
		end
			
		--create the actual clay pigeon, set the touch listeners
		function setupTransition()	
			clayPigeon1 = claypigeon:new()
			clayPigeon1:createPigeon()
			clayPigeon1:addEventListener("touch", onTouchEventClay1)
			
			clayPigeon2 = claypigeon:new()
			clayPigeon2:createPigeon()
			clayPigeon2:addEventListener("touch", onTouchEventClay2)
		end
		
		function duckTouchEvent(event) 
			if(event.phase == "ended") then 
				if(_G.score <= 50) then 
					_G.score = 0
					scoreText.text = "score " .. _G.score
				else 
					_G.score = _G.score - 50
					scoreText.text = "score " .. _G.score
				end
			end
		end
		
		function doTransition()
			clay1ID = clay1ID + 1
			clay2ID = clay2ID + 1
			local heightArr = {60, 80, 100, 120, 140, 150}
			local randHeight = 0 
			local len = table.getn(heightArr)
			for i = 1, len do 
				-- heights are the heights of the curve, to further randomize the clay pigeon motion
				randHeight = heightArr[math.random(1, len)]
				randHeight2 = heightArr[math.random(1, len)]
			end 
			
			clayPigeon1.isVisible = true
			clayPigeon2.isVisible = true
			duckOdds = math.random(1, 10)
			if (duckOdds < 6) then
				print("fly duck")
				duckFly()
			end
			
			clayPigeon1.identifier = "top " .. clay1ID
			clayPigeon2.identifier = "bottom " .. clay2ID
		
			local onCompleteCallback = function()
				launchComplete = true
				clayPigeon1:removeSelf()
				clayPigeon2:removeSelf()
				setupTransition() 
			end
		
			if(launchComplete) then 
				print ("clayPigeon1 launched")
				projectileTimer = timer.performWithDelay(scaleFactor, reduceScale(), math.ceil(amountOfClayPigeons/2))
				launcher1 = audio.loadStream("launcher.wav")
				launcher2 = audio.loadStream("launcher.wav")
				launcherChannel1 = audio.play(launcher1, launcher1Options)
				launcherChannel2 = audio.play(launcher2, launcher2Options)
	
	
				--reset scale of clay pigeons, otherwise clay pigeon scales get wonky
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
		
			-- Use the DMC Trajectory library that helps with parabolic curve to a point
			Trajectory.move( clayPigeon1, params1 )
			Trajectory.move( clayPigeon2, params2 )
			launchComplete = false
		end
		
		function duckFly()
			physics.start()
			physics.setGravity(0, 0)
	
			duck = display.newSprite(duck_sheet, duck_opt)
   			duck.direction = "right"
   			duck.isVisible = true
			duck.x = 25
			duck.y = 100
	
			physics.addBody(duck, {density = 0.2 })
			duck.linearDamping = 0
			duck:applyForce(100,0.2,duck.x,duck.y);
			duck:addEventListener("touch", duckTouchEvent)
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
		perfectText.isVisible = false  
	
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
		print("Stage is ", stage)
		print("rawScore is ", rawScore)
		print("score is", _G.score)
		print("speed is", speed)
	
		if (checkValid()) then
		  return;
		end   
	end
	
	function checkValid() 
		if (rawScore > advance) then
			print("stage is ", stage)
		  stage = stage + 1
		  composer.gotoScene("intermediate", option)
		  clayPigeon1.isVisible = false 
		  clayPigeon2.isVisible = false
		  perfectText.isVisible = false 
		end
		return;
	 end
	
	
	---------------------------------------------------------------------------------
	
	-- Listener setup
	scene:addEventListener( "create", scene )
	scene:addEventListener( "show", scene )
	scene:addEventListener( "hide", scene )
	scene:addEventListener( "destroy", scene )
	---------------------------------------------------------------------------------
	
	return scene