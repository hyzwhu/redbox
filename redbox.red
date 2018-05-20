Red [
    Title: "Red-Box"
    Needs: 'View
]

ctx-redbox: context [
	tiles: [
		1	wall 
		2	floor 
		3	target
	]

	boxes: make block! 10
	map-img: make image! 480x420
	moves-file: %moves.ini
	maps: level: level-data: bg: madman: moves: best: best-list: f-goto: f-lev: go-lev: none
	man-pos: 0x0 
	load-bin: func [file][reduce bind load load decompress read/binary file 'self]

	maps: load-bin %data1.txt.gz

	;--load the imgs
	l1: load %images/man-l1.png
	l2: %images/man-l2.png
	r1: %images/man-r1.png
	r2: %images/man-r2.png
	d1: %images/man-d1.png
	d2: %images/man-d2.png
	u1: %images/man-u1.png
	u2: %images/man-u2.png
	floor: %images/floor.png
	wall: %images/wall.png
	target: %images/target.png
	box: %images/box.png
	credits: %images/credits.png
	;--load the imags

	;--tile-type
	tile-type?: function [pos [pair!]][
		pos: pos + 1x1
		to-integer pick pick level-data/map pos/y pos/x
	]
	;--

	;--decode-tile
	decode-tile: function [value [integer!]][
		any [reduce select tiles value 'unknown]
	]

	;--for-pair 
	for-pair: function [
		'word 
		start 	[pair!] 
		end 	[pair!] 
		body 	[block!] 
		/local
		do-body
		val 
	][
		do-body: func reduce [word] body
		val: start 
		while [val/y <= end/y][
			val/x: start/x
			while [val/x <= end/x][
				do-body val 
				val/x: val/x + 1 
			]
			val/y: val/y + 1
		]
	]
	;--

	;--layout: box-world
	box-world: layout [
		at 0x16 bg: image map-img
		at 0x16 mad-man: base 30x30 l1
	]

	box-world/actors: make object! [
    on-key-down: func [face [object!] event [event!]][
        switch event/key [
            up [mad-man/offset: mad-man/offset + 0x-30]
            down [mad-man/offset: mad-man/offset + 0x30]
            left [mad-man/offset: mad-man/offset + -30x0]
            right [mad-man/offset: mad-man/offset + 30x0]
        ]
    ]
]


	;--
	;--draw map
	draw-map: has [tile][
		level-data: maps/100
		for-pair pos 0x0 15x13 [
			tile: 0
			unless zero? tile: tile-type? pos [
				px: pos/x * 30
				py: pos/y * 30
				pos1: as-pair px py
				tile: decode-tile tile
				tile: load tile
				change-image tile map-img pos1  
			]
		]
	]
	;--draw map

	;--change-image
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
	;--change-image 

	
	;--
	start-rebox: function [][
		draw-map
		view box-world
	]

	start-rebox
]