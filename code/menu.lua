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

	-- Create examples buttons
	xScale                = 0
	local text            = display.newText( group, "Examples (they rotate automatically - click in view to return here):", 0, 0, nil, 14  )
	text.x                = __G.screenWidth / 2 + xScale 
	text.y                = 75 
	local pixelateOptions = { { "Simplest example", "example1" }, { "Container with border, lower field of view, no left or right faces", "example2" }, { "Snapshot with border and random filter", "example3" }, { "No top or bottom faces, high field of view and subdivide to help", "example4" } }
	for i = 1, #pixelateOptions do
		local option = pixelateOptions[ i ]
		local button = newbutton{
			parent    = group,
			x         = __G.screenWidth / 2 + xScale,
			y         = ( 125 + ( i - 1 ) * 40 ),
			width     = 400 ,
			height    = 30 ,
			label     = option[ 1 ],
			labelSize = 12 ,
			onRelease = function()
				storyboard.gotoScene( "code." .. option[ 2 ], __G.sbFade )
			end,
		}
	end

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
