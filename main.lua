------------------------------------------------------------------------------
-- Performance!
------------------------------------------------------------------------------

--[[
-- Performance meter
local performance = require( "libs.performance" )
performance:newPerformanceMeter()
--]]

--------------------------------------------------------------
-- SET UP EVERYTHING -----------------------------------------

display.setStatusBar( display.HiddenStatusBar )
system.activate("multitouch")

-- Only the bare minimum setup here, just enough to make this scene function - the rest is set up in 'setup'

local utils      = require( "libs.utils" )
local __G        = require( "libs.globals" )
local storyboard = require( "storyboard" )

-- What platform?
__G.isSimulator = ( system.getInfo( "environment" ) == "simulator" )
if __G.isSimulator then
	__G.platform = "apple"
--	__G.platform = "android"
else
	if system.getInfo( "platformName" ) == "iPhone OS" then __G.platform = "apple"
	else                                                    __G.platform = "android" ; end
end
__G.device = utils.deviceInfo( __G.platform, true ) -- true = lansscape mode

-- Set up some globals
__G.screenWidth  = __G.device.pixels.width
__G.screenHeight = __G.device.pixels.height

-- Set up storyboard effects
__G.sbFade     = { effect = "fade", time = 200 }
__G.sbMenuFade = { effect = "fade", time = 200 }

-- Set up groups 'sandwich'
__G.groups = {
	root       = display.newGroup(), 
	bg         = display.newGroup(), 
	storyboard = storyboard.stage, 
	menu       = display.newGroup()
}

-- Closure just to make sure the local variables get tidied up
if true == true then

	-- Offset the root group
	local xOffset     = __G.screenWidth / 2
	local yOffset     = __G.screenHeight / 2
	local rootGroup   = __G.groups.root
	rootGroup.x       = xOffset
	rootGroup.y       = yOffset
	
	-- Merge in the other groups
	local extraGroups = { "bg", "storyboard", "menu" }
	for i = 1, #extraGroups do
		local group      = __G.groups[ extraGroups[ i ] ]
		rootGroup:insert( group )
		group.x, group.y = -xOffset, -yOffset
	end
end

-- Start it all!
storyboard.gotoScene( "code.setup", __G.sbFade )
