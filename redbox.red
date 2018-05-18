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
	map-img: make image! 400x420
	moves-file: %moves.ini
	maps: level: level-data: bg: madman: moves: best: best-list: f-goto: f-lev: go-lev: none
	
	load-bin: func [file][reduce bind load load decompress read/binary file 'self]

	maps: load-bin %data1.txt.gz

	;--load the imgs
	l1: %images/man-l1.png
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

]