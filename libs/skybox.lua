--------------------------------------------------------------
-- SKYBOX ----------------------------------------------------

-- Set up 
local class = {}

local mFloor, mSin, mCos = math.floor, math.sin, math.cos
local mDegToRad          = math.pi / 180

--------------------------------------------------------------
-- CLASS FUNCTIONS -------------------------------------------

function class.new( params )

	-- Get the window
	local width  = params.width or display.contentWidth
	local height = params.height or display.contentHeight
	local x, y
	if params.x then        x = params.x
	elseif params.left then x = params.left + mFloor( width / 2 )
	else                    x = mFloor( width / 2 ) ; end
	if params.y then       y = params.y
	elseif params.top then y = params.top + mFloor( height / 2 )
	else                   y = mFloor( height / 2 ) ; end

	-- Create 'self' (what type of object is it?)
	local self
	local objType = params.objType or "group"
	if objType == "snapshot" then
		self           = display.newSnapshot( width, height )
		self.anchorX   = 0.5
		self.anchorY   = 0.5
		self._snapshot = true

	elseif objType == "container" then
		self         = display.newContainer( width, height )
		self.anchorX = 0.5
		self.anchorY = 0.5
		self._snapshot = false

	else
		self           = display.newGroup()
		self._snapshot = false
		objType        = "group"
	end
	local snapshot = self._snapshot
	if params.parent then params.parent:insert( self ) ; end
	self.x       = x
	self.y       = y
	self.objType = objType

	-- Add in functions
	self.update         = class.update
	self.setFieldOfView = class.setFieldOfView

	-- Set up values
	self.xAngle     = params.xAngle or 0
	self.yAngle     = params.yAngle or 0
	self._subdivide = params.subdivide or 4
	self._zCull     = params.zCull or 0.001
	self._zOffset   = params.zOffset or 0

	-- Set up face values
	self._faces = {}
	local faces = {
		up    = { face = { start = { -1, 1, -1 }, offsets = { x = { 2, 0, 0 },  y = { 0, 0, 2 } } },  suffix = "-up" },
		down  = { face = { start = { -1, -1, 1 }, offsets = { x = { 2, 0, 0 },  y = { 0, 0, -2 } } },  suffix = "-down" },
		front = { face = { start = { -1, 1, 1 },  offsets = { x = { 2, 0, 0 },  y = { 0, -2, 0 } } }, suffix = "-front" },
		back  = { face = { start = { 1, 1, -1 },  offsets = { x = { -2, 0, 0 }, y = { 0, -2, 0 } } }, suffix = "-back" },
		left  = { face = { start = { -1, 1, -1 },  offsets = { x = { 0, 0, 2 },  y = { 0, -2, 0 } } }, suffix = "-left" },
		right = { face = { start = { 1, 1, 1 },  offsets = { x = { 0, 0, -2 },  y = { 0, -2, 0 } } }, suffix = "-right" },
	}

	-- Remove any faces that haven't been supplied (assuming a list of valid faces has been supplied)
	if params.images.faces then
	
		-- How was the data supplied? List or key/values?
		local facesData = params.images.faces
		if #facesData > 0 then

			-- Create list of valid faces
			local validFaces = {}
			for i = 1, #facesData do
				validFaces[ facesData[ i ] ] = true
			end

			-- Loop through the faces and nil any that aren't in the supplied list
			for k, _ in pairs( faces ) do
				if validFaces[ k ] == nil then faces[ k ] = nil ; end
			end 
		else

			-- Loop through the faces and nil any that aren't in the supplied list
			for k, _ in pairs( faces ) do
				if facesData[ k ] == nil then faces[ k ] = nil
				else                          faces[ k ].suffix = facesData[ k ] ; end
			end 
		end
	end

	-- Set up images values
	local imagesPath      = ( params.images.path or "" ) .. ( params.images.file or "" )
	local imagesExtension = ""
	if params.images.extension then imagesExtension = "." .. ( params.images.extension or "jpg" ) ; end
	local imagesWidth     = params.images.width
	local imagesHeight    = params.images.height
	local subdivide       = self._subdivide
	local cellWidth       = mFloor( imagesWidth / subdivide )
	local cellHeight      = mFloor( imagesHeight / subdivide )

	self._cellWidth  = cellWidth
	self._cellHeight = cellHeight

	-- Create each face, inluding relevant sprites
	for k, v in pairs( faces ) do
		local face  = { dir = k, cells = {} }
		local cells = face.cells

		-- Create the sprite sheet from the image for this face
		local options = {

			-- Frame values
			width     = cellWidth,
			height    = cellHeight,
			numFrames = subdivide * subdivide,

			-- Size of original image
			sheetContentWidth  = imagesWidth,
			sheetContentHeight = imagesHeight,
		}
		local sheet = graphics.newImageSheet( imagesPath .. v.suffix .. imagesExtension, options )
		face.sheet  = sheet

		-- Create sprites
		local start                        = v.face.start
		local startX, startY, startZ       = start[ 1 ], start[ 2 ], start[ 3 ]
		local offsetX                      = v.face.offsets.x
		local offsetX1, offsetX2, offsetX3 = offsetX[ 1 ], offsetX[ 2 ], offsetX[ 3 ]
		local offsetY                      = v.face.offsets.y
		local offsetY1, offsetY2, offsetY3 = offsetY[ 1 ], offsetY[ 2 ], offsetY[ 3 ]
		for cellX = 1, subdivide do
			local xRatio1 = ( cellX - 1 ) / subdivide
			local xRatio2 = 1 / subdivide
			for cellY = 1, subdivide do
				local cell = {}

				-- Create corners for this cell - no they don't share points, lazy I know!
				local yRatio1 = ( cellY - 1 ) / subdivide
				local yRatio2 = 1 / subdivide

				-- Point 1
				local left   = startX + offsetX1 * xRatio1 + offsetY1 * yRatio1
				local top    = startY + offsetX2 * xRatio1 + offsetY2 * yRatio1
				local back   = startZ + offsetX3 * xRatio1 + offsetY3 * yRatio1
				cell.corners = { { left, top, back } }

				-- Point 2
				local x           = left + offsetY1 * yRatio2
				local y           = top  + offsetY2 * yRatio2
				local z           = back + offsetY3 * yRatio2
				cell.corners[ 2 ] = { x, y, z }

				-- Point 3
				local x           = x + offsetX1 * xRatio2
				local y           = y + offsetX2 * xRatio2
				local z           = z + offsetX3 * xRatio2
				cell.corners[ 3 ] = { x, y, z }

				-- Point 4
				local x           = left + offsetX1 * xRatio2
				local y           = top  + offsetX2 * xRatio2
				local z           = back + offsetX3 * xRatio2
				cell.corners[ 4 ] = { x, y, z }

				-- Create image for this cell
				local cellImage = display.newImageRect( sheet, ( cellY - 1 ) * subdivide + cellX, cellWidth, cellHeight )
				if snapshot == true then self.group:insert( cellImage )
				else                     self:insert( cellImage ) ; end
				cellImage.x         = 0
				cellImage.y         = 0
				cellImage.anchorX   = 0
				cellImage.anchorY   = 0
				cellImage.isVisible = false
				cell.image          = cellImage

				-- Store the cell in 
				cells[ #cells + 1 ] = cell
			end
		end

		-- Store face
		self._faces[ k ] = face
	end

	-- Set the field of view (which also forces an intial update)
	self._width = width
	self:setFieldOfView( params.fov or 90 )

	-- Return the object	
	return self

end

function class:setFieldOfView( angle )

	-- Calculate scale based on field of view angle and width of window
	self.fov          = math.min( math.max( 1, angle ), 170 )
	self._screenScale = self._width / 2 / math.tan( self.fov / 2 * mDegToRad )

	-- Set up
	return self:update()

end

function class:update( yAngle, xAngle )

	-- Get angles (if none supplied it means force a redraw)
	local refresh = false
	if yAngle and xAngle then
		refresh     = ( xAngle ~= self.xAngle or yAngle ~= self.yAngle )
		self.xAngle = xAngle
		self.yAngle = yAngle
	else
		xAngle  = self.xAngle
		yAngle  = self.yAngle
		refresh = true
	end


	-- Stop here if not needing a refresh
	if refresh == false then return false ; end

	-- Precalculate the rotation values
	local ySin = mSin( -yAngle * mDegToRad )
	local yCos = mCos( -yAngle * mDegToRad )

	local xSin = mSin( xAngle * mDegToRad )
	local xCos = mCos( xAngle * mDegToRad )

	-- Redraw the skybox - weeeeee!
	local zOffset    = self._zOffset
	local zCull      = self._zCull
	local scale      = self._screenScale
	local cellWidth  = self._cellWidth
	local cellHeight = self._cellHeight
	for k, v in pairs( self._faces ) do

		-- Calculate the points for the cells in this face
		local cells = v.cells
		for i = 1, #cells do
			local cell          = cells[ i ]
			local points        = {}
			local sourceCorners = cell.corners
			local drawCell      = true
			for j = 1, 4 do
				local sourceCorner = sourceCorners[ j ]
				local x            = sourceCorner[ 1 ]
				local y            = sourceCorner[ 2 ]
				local z            = sourceCorner[ 3 ]

				-- Rotate in Y axis
				x, z = x * yCos - z * ySin, z * yCos + x * ySin

				-- Rotate in X axis
				y, z = y * xCos - z * xSin, z * xCos + y * xSin + zOffset

				-- Stop this cell if it is behind the view plane
				if z <= zCull then
					drawCell = false
					break
				end

				-- Store points
				points[ j ] = {
					x / z * scale,
					y / -z * scale,
				}
			end

			-- Draw the image if not culled
			local image = cell.image
			if drawCell == true then
				local path = image.path

				path.x1 = points[ 1 ][ 1 ]
				path.x2 = points[ 2 ][ 1 ]
				path.x3 = points[ 3 ][ 1 ] - cellWidth
				path.x4 = points[ 4 ][ 1 ] - cellWidth

				path.y1 = points[ 1 ][ 2 ]
				path.y2 = points[ 2 ][ 2 ] - cellHeight
				path.y3 = points[ 3 ][ 2 ] - cellHeight
				path.y4 = points[ 4 ][ 2 ]

				image.isVisible = true
			else
				image.isVisible = false
			end
		end
	end

	-- Invalidate if it is a snapshot
	if self._snapshot == true then self:invalidate() ; end

	-- Mark as redrawn
	return true

end

--------------------------------------------------------------
-- RETURN CLASS ----------------------------------------------

-- Return value
return class