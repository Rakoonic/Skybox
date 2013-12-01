--------------------------------------------------------------
-- UTILITIES LIBRARY -----------------------------------------

-- Set up 
local class = {}

--------------------------------------------------------------
-- PRINT - OVERRIDE ------------------------------------------

-- Override print() function to improve performance when running on device
local _print = print
if ( system.getInfo("environment") == "device" ) then
	print = function() end
else
	print = function( ... )

		-- Parse through the items
		local printStr = ""
		local args     = arg.n
		if args == 0 then args = 1 ; end
		for i = 1, args do
			local value = arg[ i ]
			if value == nil then value = "nil" ; end

			if type( value ) == "table" then
				local tableStr = false
				for k, v in pairs( value ) do
					if tableStr == false then tableStr = "\t" .. tostring( k ) .. " = " .. tostring( v )
					else                      tableStr = tableStr .. "\n\t" .. tostring( k ) .. " = " .. tostring( v ) ; end
				end
				if tableStr == false then tableStr = tostring( value ) .. "\n\t<empty>"
				else                      tableStr = tostring( value ) .. "\n" .. tostring( tableStr ) ; end
				if i == 1 then printStr = tableStr
				else           printStr = printStr .. "\n" .. tableStr ; end
				if i < args then printStr = printStr .. "\n" ; end
			else
				printStr = printStr .. tostring( value )
				if i < args then printStr = printStr .. "\t" ; end
			end
		end

		_print( "\r                                                   \r" .. printStr )
	end
end

--------------------------------------------------------------
-- STRING - EXTEND FUNCTIONS ---------------------------------

-- Extend string library to include catalisation
function string.capitalise( str )

	return (str:gsub("^%l", string.upper))

end

-- Extend string library to include other bits I use a lot
function string.keyValues( str, pat )

	pat         = pat or '[;:]'
	local pos   = str:find( pat, 1 )
	if not pos then return false, str ; end

	local key   = str:sub( 1, pos - 1 )
	local value = str:sub( pos + 1 )

	return key, value		

end
function string.trim( str )

   return ( str:gsub("^%s*(.-)%s*$", "%1") )
   
end
function string.replaceChar( pos, str, r )

    return str:sub(1, pos-1) .. r .. str:sub(pos+1)

end
function string.replaceStr( pos, str, r )

    return str:sub(1, pos-1) .. r .. str:sub(pos+r:len())

end

--------------------------------------------------------------
-- MATHS - EXTEND FUNCTIONS ----------------------------------

-- Extend math library to include power of 2 lookups
class._powersOf2 = {
	1,
	2,
	4,
	8,
	16,
	32,
	64,
	128,
	256,
	512,
	1024,
	2048,
}
function math.powerOf2( val, highest )

	-- Find the nearest power of 2
	local powersOf2 = class._powersOf2
	if highest == true then
		for i = 1, #powersOf2 do
			if val <= powersOf2[ i ] then return powersOf2[ i ] ; end
		end
	else
		for i = 2, #powersOf2 do
			if val < powersOf2[ i ] then return powersOf2[ i - 1 ] ; end
		end
	end

	-- Return last (largest) number if this place is reached
	return powersOf2[ #powersOf2 ]
	
end

--------------------------------------------------------------
-- NEW FUNCTIONS ---------------------------------------------

function class.freeMemory()

	local function garbage ( event )
		collectgarbage( "collect" )
	end
	garbage()
	timer.performWithDelay( 1, garbage )

end

--------------------------------------------------------------
-- PLATFORM FUNCTIONS ----------------------------------------

function class.deviceInfo( platform, landscapeMode )

	-- Get actual screen size
	local device
	local width, height = display.pixelWidth, display.pixelHeight
	if platform == "android" then
	
		-- Get sizes - in the simulator or when no values are available it defaults to a small phone
		local widthInches  = system.getInfo( "androidDisplayWidthInInches" ) or 3
		local heightInches = system.getInfo( "androidDisplayHeightInInches" ) or 0

		print( "INCHES", widthInches, heightInches )
		device             = {
			device = "android",
			inches = math.floor( math.sqrt( widthInches * widthInches + heightInches * heightInches ) * 10 ) / 10,
		}
	else

		-- Apple devices, long awkward list, right?
		local appleDevices = {
			[ "iPhone1,1" ] = { device = "iPhone", inches = 3.5 },
			[ "iPhone1,2" ] = { device = "iPhone", inches = 3.5 },
			[ "iPhone2,1" ] = { device = "iPhone", inches = 3.5 },
			[ "iPhone3,1" ] = { device = "iPhone retina", inches = 3.5 },
			[ "iPhone3,2" ] = { device = "iPhone retina", inches = 3.5 },
			[ "iPhone3,3" ] = { device = "iPhone retina", inches = 3.5 },
			[ "iPhone4,1" ] = { device = "iPhone retina", inches = 3.5 },
			[ "iPhone5,1" ] = { device = "iPhone 5", inches = 4 },
			[ "iPhone5,2" ] = { device = "iPhone 5", inches = 4 },

			[ "iPod1,1" ] = { device = "iPod", inches = 3.5 },
			[ "iPod2,1" ] = { device = "iPod", inches = 3.5 },
			[ "iPod3,1" ] = { device = "iPod", inches = 3.5 },
			[ "iPod4,1" ] = { device = "iPod retina", inches = 3.5 },
			[ "iPod5,1" ] = { device = "iPod 5", inches = 4 },

			[ "iPad1,1" ] = { device = "iPad", inches = 9.7 },
			[ "iPad1,2" ] = { device = "iPad", inches = 9.7 },
			[ "iPad2,1" ] = { device = "iPad", inches = 9.7 },
			[ "iPad2,2" ] = { device = "iPad", inches = 9.7 },
			[ "iPad2,3" ] = { device = "iPad", inches = 9.7 },
			[ "iPad2,4" ] = { device = "iPad", inches = 9.7 },
			[ "iPad2,5" ] = { device = "iPad mini", inches = 7.9 },
			[ "iPad2,6" ] = { device = "iPad mini", inches = 7.9 },
			[ "iPad2,7" ] = { device = "iPad mini", inches = 7.9 },
			[ "iPad3,1" ] = { device = "iPad retina", inches = 9.7 },
			[ "iPad3,2" ] = { device = "iPad retina", inches = 9.7 },
			[ "iPad3,3" ] = { device = "iPad retina", inches = 9.7 },
			[ "iPad3,4" ] = { device = "iPad retina", inches = 9.7 },
			[ "iPad3,5" ] = { device = "iPad retina", inches = 9.7 },
			[ "iPad3,6" ] = { device = "iPad retina", inches = 9.7 },
		}
		device = appleDevices[ system.getInfo( "architectureInfo" ) ]

		-- Failed - likely from bloody simulator
		if not device then
			device = appleDevices[ "iPad1,1" ]
			if width == 320 and height == 480 then       device = appleDevices[ "iPhone1,1" ]	-- iPhone
			elseif width == 768 and height == 1024 then  device = appleDevices[ "iPad1,1" ]		-- iPad
			elseif width == 1536 and height == 2048 then device = appleDevices[ "iPad3,1" ]		-- iPad retina
			elseif width == 640 then
				if height == 960 then device = appleDevices[ "iPhone3,1" ]			-- iPhone retina
				else                  device = appleDevices[ "iPhone5,1" ] ; end	-- iPhone 5
			end
		end
	end

	-- Calculate a few other values
	device.phone  = ( device.inches <= 5 )
	device.tablet = ( device.inches >= 7 )

	-- Real scales
	device.realPixels  = { width = width, height = height }
	local diagonal = math.floor( math.sqrt( width * width + height * height ) )
	device.realDpi     = diagonal / device.inches

	-- Content scaling sizes
	local width    = display.actualContentWidth
	local height   = display.actualContentHeight
	device.pixels  = { width = width, height = height }
	local diagonal = math.floor( math.sqrt( width * width + height * height ) )
	device.dpi     = diagonal / device.inches

	-- Flip values if in landscape orientation
	if landscapeMode == true then
		device.realPixels.width, device.realPixels.height = device.realPixels.height, device.realPixels.width
		device.pixels.width, device.pixels.height         = device.pixels.height, device.pixels.width
	end

	-- Store values
	class._device = device

	-- Return device values
	return device

end
function class.pixelsToInches( pixels )

	return pixels / class._device.dpi

end
function class.inchesToPixels( inches )

	return math.floor( inches * class._device.dpi )

end
function class.pixelsToCms( pixels )

	return pixels / class._device.dpi * 2.54

end
function class.cmsToPixels( cms )

	return math.floor( cms / 2.54 * class._device.dpi )

end
function class.cmToInches( cm )

	return cm / 2.54
	
end
function class.inchesToCm( inches )

	return inches * 2.54
	
end

--------------------------------------------------------------
-- RETURN CLASS DEFINITION -----------------------------------

return class
