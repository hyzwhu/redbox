Red [
    Title:	 "red-box"
	Author:  "Huang Yongzhao"
	File: 	 %redbox.red
	Tabs:	 4
	Version: "Alpha"
	Purpose: "Famous BoxWorld! game ported to red"
	Rights:  "Copyright (C) 2015-2018 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

ctx-redbox: context [
	tiles: [
		1	wall 
		2	floor 
		3	target
	]
	boxes: make block! 10
	man-img: make block! 2
	map-img: make image! 480x420
	targets: make block! 10
	moves-file: load %moves.ini
	maps: none 
	level: 1
	lx: ly: 0
	man-pos: 0x0
	undo-box: undo-man: 0x0
	box-index: 0
	load-bin: func [file][reduce bind load load decompress read/binary file 'self]
	judge: true
	box-move-num: 0
	maps: load-bin %data1.txt.gz
	all-image: load %all-image.png
	extrat: function [offset [integer!] size [pair!]][
		copy/part skip all-image offset size 
	]
	l1: extrat 0 30x30 
	l2: extrat 30 30x30
	r1: extrat 60 30x30
	r2: extrat 90 30x30
	d1: extrat 120 30x30
	d2: extrat 150 30x30
	u1: extrat 180 30x30
	u2: extrat 210 30x30
	box1: extrat 240 30x30
	wall: extrat 270 30x30
	floor: extrat 300 30x30
	target: extrat 330 30x30
	credits: extrat 378 * 30 378x292

	append man-img l1 
	append man-img l2 

	tile-type?: function [pos [pair!]][
		pos: pos + 1x1
		to-integer pick pick level-data/map pos/y pos/x
	]

	decode-tile: function [value [integer!]][
		any [reduce select tiles value 'unknown]
	]

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

	dir-to-pos: func [value [word!]][
		select [up 0x-30 down 0x30 left -30x0 right 30x0] value
	]

	can-move?: func [value [word!] pos [pair!]/local new1 new nx ny][
		new1: pos - 0x20 + dir-to-pos value 
		nx: new1/x / 30
		ny: new1/y / 30
		new1: as-pair nx ny
		new: tile-type? new1 
		find [2 3] new 
	]

	box-world: layout/tight [
		title "red-box"
		style btn: button bold 40x20
		at 0x0 btn"Goto" [view level-choose ]
		at 40x0 btn "Undo" [
			if 0x0 <> undo-box [
				box-world/pane/:box-index/offset: undo-box
				move-txt/data: move-txt/data - 1
				poke boxes (:box-index - 12) undo-box  
				undo-box: 0x0]
			mad-man/offset: undo-man
		]
		at 80x0 btn "Retry" [init-world]
		at 120x0 btn "About" [view about-win]	
		at 0x20 base map-img
		mad-man: base transparent 30x30 rate 6 now on-time [
			judge: not judge
			mad-man/image: pick man-img judge
		]  
		style txt: text 85x20 black font-size 10 font-color white bold
		style num: text 15x20 black font-size 10 font-color white bold 
		at 0x420  txt "your move: "
		at 85x420 move-txt: num "0"
		at 100x420 txt "   best move: "
		at 185x420 best-move-txt: num "0"
		at 200x420 txt "   your level: "
		at 285x420 level-txt: num "1"
	]

	is-best?: func [/local bt mt][
		mt: move-txt/data 
		bt: best-move-txt/data
		either bt = 0 [
			poke moves-file :level mt
		][
			if bt > mt [
				poke moves-file :level mt 
			]
		]
		write %moves.ini mold moves-file
	]

	turn: func [value [word!] /local box c-pos b-pos bp pb next-box][
		undo-box: 0x0
		undo-man: mad-man/offset
		c-pos: mad-man/offset + dir-to-pos value
		b-pos: find boxes c-pos
	 	either b-pos [
			bp: index? b-pos 
			pb: bp + 12
			box-index: :pb 
			undo-box: c-pos
			next-box: c-pos + dir-to-pos value 
			if all [can-move? value c-pos  next-is-box? next-box][
				move-txt/data: 1 + move-txt/data
				box-world/pane/:pb/offset: next-box
				poke boxes bp box-world/pane/:pb/offset
				mad-man/offset: c-pos
				if check-win? [
					if :level = 100 [
						alert-win/pane/1/text: "Victory!"
					]
					view/flags alert-win 'modal
					level: level + 1
					init-world
				]
			] 
		][
			if can-move? value mad-man/offset [
				mad-man/offset: c-pos
			]
		]
	]

	level-choose: layout [
		title "red-box"
		text bold "please enter the level that you want" return
		pad 60x0 fld: field 60x20 return 
		pad 60x0 button bold "ok" [
			level: to-integer fld/text
			init-world
			unview]
	] 

	next-is-box?: func [pos [pair!]][
		none? find boxes pos
	]

	init-world: func [][
		undo-box: 0x0
		move-txt/data: 0
		system/view/auto-sync?: no
		clear boxes 
		clear targets 
		clear skip box-world/pane 12
		draw-map
		draw-boxes
		show box-world
		system/view/auto-sync?: yes 
	]

	alert-win: layout [
		title "red-box"
		text center 200x20 "you have done a good job!" return 
		pad 70x0 button  "ok" [
			is-best?
			unview 
		]
	]

	about-win: layout [
		title "red-box"
		image center credits return
		text center 400x20	bold "Original game by Jeng-Long Jiang (1992)" return
		text center 400x20	bold "Rebol port done by Nenad Rakocevic (2001)" return 
		text center 400x20 	bold "Red port done by Yongzhao Huang (2018)" return 
	]

	box-world/actors: make object! [
    on-key-down: func [face [object!] event [event!]][
        switch event/key [
            up	  [man-img/1: u1 man-img/2: u2 turn 'up ]
            down  [man-img/1: d1 man-img/2: d2 turn 'down]
            left  [man-img/1: l1 man-img/2: l2 turn 'left]
            right [man-img/1: r1 man-img/2: r2 turn 'right]
        ]
    ]
	]

	check-win?: has [win? box a][
		win?: yes 
		foreach box boxes [win?: all [win? find targets box]]
		win? 
	]

	draw-map: has [tile lx ly][
		map-img/rgb: black
		level-data: maps/:level
		level-txt/data: :level
		best-move-txt/data: pick moves-file :level
		man-pos: undo-man: mad-man/offset: level-data/start * 30 + 0x20
		for-pair pos 0x0 15x13 [
			tile: 0
			unless zero? tile: tile-type? pos [
				if 3 = tile [
					append targets pos * 30 + 0x20 
				]
				tile: decode-tile tile
				change-image tile map-img pos * 30  
			]
		]
	]

	draw-boxes: has [bx pos pb][
		foreach pos level-data/boxes [
			pb: pos * 30 + 0x20
			append box-world/pane bx: make face![type: 'base size: 30x30 offset: pb image: box1]
			append boxes pb
		]
	]

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

	start-rebox: function [][
		draw-map
		draw-boxes
		view box-world
	]

	start-rebox
]