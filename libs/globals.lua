--------------------------------------------------------------
-- GLOBALS REPLACEMENT ---------------------------------------

-- Set up 
local class = {}

-- Display all globals
function class:show()

	for k, v in pairs( self ) do
		print( k, v )
	end
	
end

-- Return value
return class