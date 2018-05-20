Red[]
x: make image!  100x100
box-world: layout [
		at 0x16 bg: image x
]
wall: load %images/wall.png
floor: load %images/floor.png
change-image: function [src [image!] dst [image!] pos [integer!]][
	sx: src/size/x
	dx: dst/size/x 
    sy: src/size/y
	repeat y sy[
		xs: y - 1 * sx  + 1 
        xd: y - 1 * dx  + 1
        repeat l sx[
            dst/:xd: src/:xs
            xd: xd + 1
            xs: xs + 1
        ] 
	]
]

change-image wall x 1
probe x 
view box-world
