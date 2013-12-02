Skybox
======

Self-contained skybox module for Corona SDK
Latest update features:
------
* Can now be a group, container or snapshot.
* More options for specifying the faces of the skybox (including omitting faces you don't want).
* No longer does a full redraw if the angles don't change (unless you wish to force it).
How to create a skybox:
======
Step 1: Include the skybox lib:
------
```lua
local skyboxClass = require( "libs.skybox" )
```
where 'libs.skybox' is the path to my library, wherever you installed it.
 Step 2: Create a skybox object:
------
 At its most basic you could do the following:

```Lua
local skyboxObj = skyboxClass.new{
    images = {
       file = "sky",
       width = 512,
       height = 512,
    }
}
```

This is the minimum to get up and running and would assume the following 6 images are all located in the root of your project folder and each are 512 x 512 pixels in size:

* sky-front.jpg
* sky-back.jpg
* sky-left.jpg
* sky-right.jpg
* sky-up.jpg
* sky-down.jpg

There are various parameters that you can change or supply, broken down into various related functionality:
 
**General object properties:**

* objType = What type of object is used as the base. This value can be either 'group', 'container', or 'snapshot'. Defaults to 'group'.
* parent = A group (or similar) that this skybox object will be inserted into automatically upon creation. Defaults to nothing.

**View properties:**

* fov = Field of view, measured in degrees along the horizontal axis. Defaults to 90.
* xAngle = Starting X angle. Defaults to 0.
* yAngle = Starting Y angle. Defaults to 0.

**Window properties\*:**

* left = Left edge of the window\*
* top = Top edge of the window*\*
* width = Width of the window\*
* height = Height of the window\*

\*Only containers and snapshots will actually clip to these values. Groups will have some of the skybox poking out, but the values used will be the same as if it were clipped.
 
**Images properties:**
 
The images property is a table that itself can contain various properties, including:

* path = The optional path to where the images reside. Defaults to "".
* file = The optional shared root of the file name for the images. Defaults to "".
* extension = The optional file extension of the images. Can be "png" or "jpg". Defaults to "jpg" if needed.
* faces = An optional table that can either be a list of faces to include (IE any not mention are not drawn), or a table containing key/value pairs listing both the faces to include, and their file. In either case, the faces are 'front', 'back', 'left', 'right', 'up' and 'down'.
Individual file names normally are built up using:

	filename = images.path .. images.file .. <face_identifier> .. "." .. images.extension

where <face_identifier> is '-front', '-back', '-left', '-right', '-up' or '-down'.
The exception to this is if the images.faces property is supplied as a set of key/value pairs.
In this case, for each face in this table, the filename is built up using:

filename = images.path .. images.file .. images.faces[ <face> ]

In this case, images.extension is appended only if set.
This last way of specifying the faces is the most powerful, and in fact can be used as an entire replacement for the general path, file and extension properties, or alternatively can be used to specify the face identifiers, if they are different from the defaults.

**Miscellaneous properties:**

* subdivide = How many times to subdivide each face along both axes. This means you will end up with subdivide * subdivide cells per faces, so keep this value as low as possible. Defaults to 4.
* zCull = At what point to cull faces based on any of their corners being closer than this value. The nearer to zero it is, the less likely you are to see holes. Defaults to 0.001.
* zOffset = How far to push the skybox further away from the camera. Can help to remove 'holes', but with the added price of creating more distortion the larger the value. Ideally tweaked only as a last resort. Defaults to 0.
Optional step 3: Update the skybox object
------ 
If you wish to change the angles, then you do so using the following code:
```lua
skyboxObj:update( yAngle, xAngle )
```
Where yAngle is the rotation around the Y axis (IE left and right) and xAngle is the rotation around the X axis (IE up and down).
	 
Note that if, for whatever reason, you wish to force a redraw then simply call the :update() function without any parameters like so:
```lua
skyboxObj:update()
```
Note that snapshots automatically get invalidated upon successful redraw.

If you wish to know whether a redraw call was actually processed or not, then capture the result from the :update() function - true means the skybox was actually updated, while false means it wasn't (this happens if you call the :update() feature with the same angle values as the previous time it was updated).
```lua
local didReallyUpdate = skyboxObj:update()
```Changing the field of view dynamically:
======
Simply call :setFieldOfView( angle ) as follows:
```lua
skyboxObj:setFieldOfView( angle )
```
where angle is a value between 1 and 170. Note that increasing the field of view may cause more errors at the edges, so always make sure you set up your skybox to work correctly under the widest field of view you intend to use.