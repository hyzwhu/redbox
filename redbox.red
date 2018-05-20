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
	lx: ly: 0
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
	box: load %images/box.png
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

	dir-to-pos: func [value [word!]][
		select [up 0x-30 down 0x30 left -30x0 right 30x0] value
	]
	can-move?: func [value [word!] /local new1 new nx ny][
		new1: mad-man/offset - 0x16 + dir-to-pos value 
		probe new1
		nx: new1/x / 30
		ny: new1/y / 30
		new1: as-pair nx ny
		probe new1
		new: tile-type? new1 
		find [2 3] new 
	]
	;--layout: box-world
	box-world: layout [
		at 0x16 bg: image map-img
		at man-pos mad-man: base 30x30 l1
	]

	turn: function [value [word!] /local box c-pos b-pos][
		c-pos: mad-man/offset + dir-to-pos value
		if can-move? value [
			;--some function
		]
	]

	box-world/actors: make object! [
    on-key-down: func [face [object!] event [event!]][
        switch event/key [
            up [turn 'up]
            down [turn 'down]
            left [turn 'left]
            right [turn 'right]
        ]
    ]
	]



	;--
	;--draw map
	draw-map: has [tile lx ly][
		level-data: maps/1
		lx: level-data/start/x * 30
		ly: level-data/start/y * 30 + 16
		man-pos: as-pair lx ly 
		box-world/pane/2/offset: man-pos
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

	;--draw boxes
	draw-boxes: has [bx pos xb yb pb][
		foreach pos level-data/boxes [
			xb: pos/x * 30 
			yb: pos/y * 30 + 16 
			pb: as-pair xb yb 
			append box-world/pane bx: make face![type: 'base size: 30x30 offset: pb image: box]
		]
	]
	;--draw boxes

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
		draw-boxes
		view box-world
	]

	start-rebox
]