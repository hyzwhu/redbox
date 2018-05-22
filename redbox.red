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

	l1: load %images/man-l1.png
	l2: load %images/man-l2.png
	r1: load %images/man-r1.png
	r2: load %images/man-r2.png
	d1: load %images/man-d1.png
	d2: load %images/man-d2.png
	u1: load %images/man-u1.png
	u2: load %images/man-u2.png
	box: load %images/box.png
	credits: load %images/credits.png
	floor: %images/floor.png
	wall: %images/wall.png
	target: %images/target.png

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
		new1: pos - 0x16 + dir-to-pos value 
		nx: new1/x / 30
		ny: new1/y / 30
		new1: as-pair nx ny
		new: tile-type? new1 
		find [2 3] new 
	]

	box-world: layout/tight [
		title "red-box"
		at 0x0 button "Goto" bold 33x16 [view level-choose ]
		at 33x0 button "Undo" bold 33x16 [
			if 0x0 <> undo-box [
				box-world/pane/:box-index/offset: undo-box
				move-txt/text: to string! (-1 + to integer! move-txt/text)
				poke boxes (:box-index - 12) undo-box  
				undo-box: 0x0]
			mad-man/offset: undo-man
		]
		at 66x0 button "Retry" bold 33x16 [init-world]
		at 99x0 button "About" bold 33x16 [view about-win]	
		at 0x16 image map-img
		mad-man: base 30x30 rate 6 now on-time [
			judge: not judge
			mad-man/image: pick man-img judge
		]  
		at 0x405  text 70x30 black font-size 10 font-color white bold "your move:"
		at 70x405 move-txt: text 15x30 black font-size 10 font-color white bold "0"
		at 85x405 text 70x30 black font-size 10 font-color white bold "best move:"
		at 150x405 best-move-txt: text 15x30 black font-size 10 font-color white bold "0"
		at 165x405 text 70x30 black font-size 10 font-color white bold "your level:"
		at 230x405 level-txt: text 15x30 black font-size 10 font-color white bold "1"
	]

	is-best?: func [/local bt mt][
		mt: to integer! move-txt/text
		bt: to integer! best-move-txt/text
		either bt = 0 [
			poke moves-file :level mt
		][
			if bt < mt [
				poke mvoes-file :level bt 
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
				move-txt/text: to string! (1 + to integer! move-txt/text) 
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

	next-is-box?: func[pos [pair!]][
		either find boxes pos [return false][return true]
	]

	init-world: func[][
		undo-box: 0x0
		move-txt/text: to string! 0
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
		text center "you have done a good job!" return 
		pad 40x0 button "ok" [
			is-best?
			unview 
		]
	]

	about-win: layout [
		title "red-box"
		image center credits return
		text center 400x20	bold "Original game by Jeng-Long Jiang" return
		text center 400x20	bold "Rebol port done by Nenad Rakocevic" return 
		text center 400x20 	bold "Rebol port done by Vigil Huang" return 
	]

	box-world/actors: make object! [
    on-key-down: func [face [object!] event [event!]][
        switch event/key [
            up [poke man-img 1 u1 poke man-img 2 u2 turn 'up ]
            down [poke man-img 1 d1 poke man-img 2 d2 turn 'down]
            left [poke man-img 1 l1 poke man-img 2 l2 turn 'left]
            right [poke man-img 1 r1 poke man-img 2 r2 turn 'right]
        ]
    ]
	]

	p1-to-p2: function [pos [pair!] /local yb xb pb][
		xb: pos/x * 30 
		yb: pos/y * 30 + 16 
		pb: as-pair xb yb
		pb 
	]

	check-win?: has [win? box a][
		win?: yes 
		foreach box boxes [
			a: either find targets box [true][false]
			win?: win? and a ]
		win? 
	]

	draw-map: has [tile lx ly][
		map-img/rgb: black
		level-data: maps/:level
		level-txt/text: to string! :level
		best-move-txt/text: to string! pick moves-file :level
		lx: level-data/start/x * 30
		ly: level-data/start/y * 30 + 16
		man-pos: as-pair lx ly 
		mad-man/offset: man-pos
		undo-man: man-pos
		for-pair pos 0x0 15x13 [
			tile: 0
			unless zero? tile: tile-type? pos [
				px: pos/x * 30
				py: pos/y * 30
				pos1: as-pair px py
				if 3 = tile [
					append targets as-pair px (py + 16)
				]
				tile: decode-tile tile
				tile: load tile
				change-image tile map-img pos1  
			]
		]
	]

	draw-boxes: has [bx pos pb][
		foreach pos level-data/boxes [
			pb: p1-to-p2 pos
			append box-world/pane bx: make face![type: 'base size: 30x30 offset: pb image: box]
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