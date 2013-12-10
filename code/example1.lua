--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local __G         = require( "libs.globals" )
local skyboxClass = require( "libs.skybox" )
local storyboard  = require( "storyboard" )
local scene       = storyboard.newScene()

local setUpSkybox, update

local skybox
local yAngle, xAngle

--------------------------------------------------------------
-- SET UP ----------------------------------------------------

function setUpSkybox( group )

	-- Create a sky box
	yAngle, xAngle = 0, 50
	skybox         = skyboxClass.new{

		-- Object properties
		parent  = group,

		-- View
		xAngle = xAngle,
		yAngle = yAngle,

		-- Skybox images
		images = {

			-- Where the images live
			path      = "gfx/",
			file      = "sky",
			extension = "png",

			-- Size of each image - must be the same
			width  = 512,
			height = 512,
		},
	}

end

--------------------------------------------------------------
-- UPDATE ----------------------------------------------------

function update( event )

	yAngle = yAngle + 0.1
	xAngle = math.max( xAngle - 0.04, 0 )

	skybox:update( yAngle, xAngle )

end

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	-- Set up the skybox
	setUpSkybox( self.view )
	
	-- Add in clickable area to return to menu
	local rect         = display.newRect( self.view, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )
	rect.isVisible     = false
	rect.isHitTestable = true
	rect:addEventListener( "tap", function()
			storyboard.gotoScene( "code.menu", __G.sbFade )
		end
	)

end
function scene:enterScene( event )

	-- Add in the frame event
	Runtime:addEventListener( "enterFrame", update )

end
function scene:exitScene( event )

	-- Add in the frame event
	Runtime:removeEventListener( "enterFrame", update )

end
function scene:didExitScene( event )

	storyboard.purgeScene( "code.example1" )

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "didExitScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
