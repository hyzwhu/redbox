Red[]
x: make image!  100x100
box-world: layout [
		at 0x16 bg: image x
]
wall: load %images/wall.png
floor: load %images/floor.png
change-image: function [src [image!] dst [image!] pos [pair!]][
	sx: src/size/x
	dx: dst/size/x 
    sy: src/size/y
    px: pos/x
    py: pos/y
    
	repeat y sy[
		xs: y - 1 * sx  + 1 
        xd: y + py - 1 * dx  + 1 + px 
?? xs 
?? xd 
        repeat l sx[
            dst/:xd: src/:xs
            xd: xd + 1
            xs: xs + 1
        ] 
	]
]

change-image wall x 10x10
probe x 
view box-world
