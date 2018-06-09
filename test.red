Red[]
all-image: load %all-image.png
	extrat: function [offset [integer!] size [pair!]][
		copy/part skip all-image offset size 
	]
	wall: extrat 270 30x30
	floor: extrat 300 30x30
	target: extrat 330 30x30

change-image: function [src [image!] dst [image!] pos [pair!]][
		sx: src/size/x
		dx: dst/size/x 
		sy: src/size/y
		px: pos/x
		py: pos/y	
		repeat y sy [
			xs: y - 1 * sx  + 1 
			xd: y + py - 1 * dx  + 1 + px 
			repeat l sx [
				dst/:xd: src/:xs
				xd: xd + 1
				xs: xs + 1
			] 
		]
	]
pic: make image! 200x200
change-image wall pic 0x0
change-image floor pic 30x0
view [image pic image wall image floor]