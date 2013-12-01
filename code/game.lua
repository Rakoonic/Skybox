--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local __G         = require( "libs.globals" )
local skyboxClass = require( "libs.skybox" )
local storyboard  = require( "storyboard" )
local scene       = storyboard.newScene()

local skybox

local xAngle, yAngle = 40, 0

--------------------------------------------------------------
-- SET UP ----------------------------------------------------

function setUp( group )

	local border = 25

	-- Create a sky box
	skybox = skyboxClass.new{

		-- Object properties
		objType = "snapshot",
		parent  = group,

		-- View
--		fov    = 50,
		xAngle = xAngle,
		yAngle = yAngle,

		-- Window - clipping only occurs with 'snapshot' and 'container' objTypes
		left   = border,
		top    = border,
		width  = display.contentWidth - border * 2,
		height = display.contentHeight - border * 2,

		-- Skybox images
		images = {

			-- Where the images live
			path      = "gfx/",
			file      = "sky",
			extension = "png",

			-- Size of each image - must be the same
			width  = 512,
			height = 512,

--[[
			-- Optional list of faces to use
			faces = { "front", "back", "left", "right" },
--]]

--[[
			-- Optional list of faces and their images
			faces = {
				front = "-front",
				back  = "-back",
				left  = "-left",
				right = "-right",
			},
--]]
		},

		-- Misc
--		subdivide = 10,
--		zCull     = 0.1,
--		zOffset   = 0.2,
	}

	-- If you chose snapshot, then apply a filter
	if skybox.objType == "snapshot" then
--		skybox.fill.effect          = "filter.crystallize"
--		skybox.fill.effect.numTiles = 64

--		skybox.fill.effect = "filter.frostedGlass"

--		skybox.fill.effect           = "filter.zoomBlur"
--		skybox.fill.effect.intensity = 2

		skybox.fill.effect = "filter.vignette"

--		skybox.fill.effect = "filter.bloom"

--		skybox.fill.effect = "filter.sobel"
	end

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
	
	setUp( self.view )
	
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

	storyboard.purgeScene( "code.game" )

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
