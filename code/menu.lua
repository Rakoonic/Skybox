--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local __G        = require( "libs.globals" )
local storyboard = require( "storyboard" )
local scene      = storyboard.newScene()

-- Prototypes
local newButton

--------------------------------------------------------------
-- MISC ------------------------------------------------------

function newbutton( params )

	-- Create rect for the button
	local self = display.newGroup()
	self.x     = params.x or 0
	self.y     = params.y or 0

	-- Create rect
	local rect       = display.newRect( self, 0, 0, params.width or 200, params.height or 50 )
	rect.strokeWidth = 2
	rect:setStrokeColor( 1, 1, 1, 1 )
	rect:setFillColor( 0, 0, 0, 0.5 )

	-- Create text
	if params.label then
		local text = display.newText( self, params.label, 0, 0, nil, params.labelSize or 20 )
	end

	-- Insert into parent if supplied
	if params.parent then params.parent:insert( self ) ; end

	-- Create the touch listeners
	if params.onRelease then

		local function onTap( event )
			rect:setFillColor( 1, 1, 0, 0.5 )
			timer.performWithDelay( 200,
				function()
					rect:setFillColor( 0, 0, 0, 0.5 )
					params.onRelease()
				end
			)
		end

		-- Add the event listener
		rect:addEventListener( "tap", onTap )
	end

	-- Return button
	return self

end

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	local group = self.view

--[[
	-- Create help
	local text            = display.newText( group, "Top left button = Return to menu.\nBottom left buttons = steer.\nBottom right buttons = accelerate/brake.\nTop right button = toggle view rotation on/off.", 0, 0, 500 , 0, nil, 20  )
	text.x                = __G.screenWidth / 2
	text.y                = 75 

	-- Create blur buttons
	xScale                = -250
	local text            = display.newText( group, "1) Blur (top speed only):", 0, 0, nil, 20 )
	text.x                = __G.screenWidth / 2 + xScale 
	text.y                = 200 
	local pixelateOptions = { { "None", 0 }, { "0.5", 0.5 }, { "0.65", 0.65 }, { "0.8", 0.8 } }
	for i = 1, #pixelateOptions do
		local option = pixelateOptions[ i ]
		local button = newbutton{
			parent    = group,
			x         = __G.screenWidth / 2 + xScale,
			y         = ( 300 + ( i - 1 ) * 75 ),
			width     = 200 ,
			height    = 60 ,

			label     = option[ 1 ],
			labelSize = 25 ,
			onRelease = function() blur = option[ 2 ] ; end,
		}
	end

	-- Create pixelate buttons
	xScale                = 0
	local text            = display.newText( group, "2) Pixelation:", 0, 0, nil, 20  )
	text.x                = __G.screenWidth / 2 + xScale 
	text.y                = 200 
	local pixelateOptions = { { "0.5", 0.5 }, { "None", 1 }, { "Pixelate x2", 2 }, { "Pixelate x3", 3 }, { "Pixelate x4", 4 } }
	for i = 1, #pixelateOptions do
		local option = pixelateOptions[ i ]
		local button = newbutton{
			parent    = group,
			x         = __G.screenWidth / 2 + xScale,
			y         = ( 300 + ( i - 1 ) * 75 ),
			width     = 200 ,
			height    = 60 ,

			label     = option[ 1 ],
			labelSize = 25 ,
			onRelease = function() pixelSize = option[ 2 ] ; end,
		}
	end
--]]

	-- Create object quantity buttons
	xScale                = 250
	local text            = display.newText( group, "3) Objects quantity:", 0, 0, nil, 20  )
	text.x                = __G.screenWidth / 2 + xScale 
	text.y                = 200 
	local pixelateOptions = { { "x1", 0 }, { "x2", 1 }, { "x3", 2 }, { "x4", 3 } }
	for i = 1, #pixelateOptions do
		local option = pixelateOptions[ i ]
		local button = newbutton{
			parent    = group,
			x         = __G.screenWidth / 2 + xScale,
			y         = ( 300 + ( i - 1 ) * 75 ),
			width     = 200 ,
			height    = 60 ,

			label     = option[ 1 ],
			labelSize = 25 ,
			onRelease = function()
				__G.sbFade.params = { blur = blur, pixelSize = pixelSize, objQuantity = option[ 2 ] }
				storyboard.gotoScene( "code.game", __G.sbFade )
			end,
		}
	end

end
function scene:didExitScene( event )

	storyboard.purgeScene( "code.menu" )

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "didExitScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
