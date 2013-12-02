--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local __G        = require( "libs.globals" )
local storyboard = require( "storyboard" )
local scene      = storyboard.newScene()

-- Prototypes
local setup

--------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------

function setup( params )

	-- Set background to a nicer colour
	display.setDefault( "background", 0, 0.1, 0.1, 0 )
	
	-- Go to menu
	storyboard.gotoScene( "code.menu", __G.sbFade )

end

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	local group = self.view

	-- BG
	local bg = display.newImageRect( group, "gfx/pl_logo.png", __G.screenWidth, __G.screenHeight )
	bg.x     = __G.screenWidth / 2
	bg.y     = __G.screenHeight / 2
	
	-- Randomise the randomness
	math.randomseed( system.getTimer() )

end
function scene:enterScene( event )

	-- Set up timer
	if __G.isSimulator then timer.performWithDelay( 1, setup )
	else                        timer.performWithDelay( 2000, setup ) ; end

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
