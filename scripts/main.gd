extends Node2D

var roza := Vector2(430, 470)
var pet := Vector2(360, 500)
var coins := 120
var stars := 7
var mission_done := false
var t := 0.0

func _ready():
    queue_redraw()

func _process(delta):
    t += delta
    var dir := Vector2.ZERO
    if Input.is_action_pressed("move_left"): dir.x -= 1
    if Input.is_action_pressed("move_right"): dir.x += 1
    if Input.is_action_pressed("move_up"): dir.y -= 1
    if Input.is_action_pressed("move_down"): dir.y += 1
    if dir.length() > 0:
        dir = dir.normalized()
        roza += dir * 220.0 * delta
        roza.x = clamp(roza.x, 120.0, 1160.0)
        roza.y = clamp(roza.y, 300.0, 610.0)
    pet = pet.lerp(roza + Vector2(-72, 30), min(1.0, delta * 4.0))
    queue_redraw()

func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var p = event.position
        if Rect2(1030, 28, 210, 58).has_point(p):
            mission_done = true
            coins += 25
            stars += 1
        elif Rect2(850, 650, 120, 42).has_point(p):
            coins += 10
        elif Rect2(990, 650, 120, 42).has_point(p):
            stars += 1
        queue_redraw()

func _draw():
    # Sky
    draw_rect(Rect2(0, 0, 1280, 720), Color("#9edcff"))
    draw_circle(Vector2(1090, 110), 58, Color("#fff3a6"))
    # clouds
    _cloud(Vector2(170, 120), 1.0)
    _cloud(Vector2(700, 90), 0.8)
    _cloud(Vector2(980, 210), 0.65)
    # distant hills
    var hill := PackedVector2Array([Vector2(0,410),Vector2(170,300),Vector2(320,390),Vector2(520,260),Vector2(760,390),Vector2(930,280),Vector2(1280,390),Vector2(1280,720),Vector2(0,720)])
    draw_colored_polygon(hill, Color("#86c88d"))
    # grass
    draw_rect(Rect2(0, 390, 1280, 330), Color("#79bd72"))
    # paths
    draw_colored_polygon(PackedVector2Array([Vector2(430,720),Vector2(610,720),Vector2(610,500),Vector2(550,470),Vector2(500,500)]), Color("#e9cf9b"))
    # water area
    draw_rect(Rect2(970, 430, 310, 290), Color("#62bde6"))
    for x in range(1000, 1260, 70):
        draw_line(Vector2(x, 520), Vector2(x+38, 520), Color("#a8e4f5"), 3)
    # house
    _house(Vector2(280, 365))
    # trees
    for p in [Vector2(90,390),Vector2(180,430),Vector2(760,410),Vector2(850,370),Vector2(900,450)]: _tree(p)
    # castle silhouette
    _castle(Vector2(1110, 355))
    # HUD
    draw_rect(Rect2(24, 22, 330, 72), Color("#ffffffd9"), true)
    draw_string(ThemeDB.fallback_font, Vector2(45, 54), "ROZA'S WORLD", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("#5b4a82"))
    draw_string(ThemeDB.fallback_font, Vector2(45, 80), "A tiny magical adventure", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#7d7391"))
    _pill(Rect2(375, 24, 130, 50), "★  %d" % stars, Color("#fff1a8"))
    _pill(Rect2(520, 24, 145, 50), "●  %d" % coins, Color("#ffe0a8"))
    # mission card
    draw_rect(Rect2(1030, 28, 220, 58), Color("#ffffffed"), true)
    draw_string(ThemeDB.fallback_font, Vector2(1048, 53), "DAILY MISSION", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#7a638f"))
    draw_string(ThemeDB.fallback_font, Vector2(1048, 74), "✓ Complete task +25" if mission_done else "Do a good deed! +25", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#4b7654"))
    # character and pet
    _pet(pet)
    _roza(roza)
    # bottom controls
    _button(Rect2(700, 650, 130, 42), "PLAY", Color("#f5a7c7"))
    _button(Rect2(850, 650, 120, 42), "+ COINS", Color("#ffd47d"))
    _button(Rect2(990, 650, 120, 42), "+ STAR", Color("#b9e2ff"))
    draw_string(ThemeDB.fallback_font, Vector2(40, 690), "WASD / Arrow keys to explore  •  Click buttons to play", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ffffff"))

func _cloud(p, s):
    draw_circle(p, 28*s, Color("#ffffffd9")); draw_circle(p+Vector2(30*s,-8*s), 36*s, Color("#ffffffd9")); draw_circle(p+Vector2(62*s,4*s), 25*s, Color("#ffffffd9"))

func _tree(p):
    draw_rect(Rect2(p.x-10,p.y,20,70), Color("#815a43"), true)
    draw_circle(p+Vector2(0,-20), 45, Color("#4f9d62")); draw_circle(p+Vector2(-30,-4), 32, Color("#62ad6b")); draw_circle(p+Vector2(28,-2), 34, Color("#5aa566"))
    draw_circle(p+Vector2(-15,-28), 5, Color("#f7d27a"))

func _house(p):
    draw_rect(Rect2(p.x-105,p.y+55,210,130), Color("#fff1d0"), true)
    draw_colored_polygon(PackedVector2Array([p+Vector2(-125,65),p+Vector2(0,-55),p+Vector2(125,65)]), Color("#e98e91"))
    draw_rect(Rect2(p.x-25,p.y+110,50,75), Color("#8b654d"), true)
    draw_rect(Rect2(p.x-82,p.y+92,45,42), Color("#8ed4e8"), true)
    draw_rect(Rect2(p.x+37,p.y+92,45,42), Color("#8ed4e8"), true)
    draw_circle(p+Vector2(0,-12), 18, Color("#fff4d5"))

func _castle(p):
    draw_rect(Rect2(p.x-90,p.y+40,180,150), Color("#f1e4ef"), true)
    for dx in [-75, 0, 75]:
        draw_rect(Rect2(p.x+dx-30,p.y-15,60,205), Color("#ead9eb"), true)
        draw_colored_polygon(PackedVector2Array([Vector2(p.x+dx-38,p.y-15),Vector2(p.x+dx,p.y-60),Vector2(p.x+dx+38,p.y-15)]), Color("#9c7fc2"))
    draw_rect(Rect2(p.x-18,p.y+115,36,75), Color("#7d5a82"), true)

func _roza(p):
    var bob = sin(t*5.0)*3.0
    draw_circle(p+Vector2(0,-62+bob), 30, Color("#f5c6a8"))
    draw_circle(p+Vector2(0,-73+bob), 31, Color("#6b4635"))
    draw_circle(p+Vector2(-25,-70+bob), 12, Color("#6b4635")); draw_circle(p+Vector2(25,-70+bob), 12, Color("#6b4635"))
    draw_circle(p+Vector2(-10,-62+bob), 3, Color("#3d3444")); draw_circle(p+Vector2(10,-62+bob), 3, Color("#3d3444"))
    draw_arc(p+Vector2(0,-54+bob), 9, 0.2, 2.9, 12, Color("#b85d70"), 2)
    draw_colored_polygon(PackedVector2Array([p+Vector2(-31,-34),p+Vector2(31,-34),p+Vector2(48,42),p+Vector2(-48,42)]), Color("#f18bb1"))
    draw_line(p+Vector2(-25,42),p+Vector2(-32,78),Color("#63485d"),8); draw_line(p+Vector2(25,42),p+Vector2(32,78),Color("#63485d"),8)
    draw_line(p+Vector2(-38,-5),p+Vector2(-68,20),Color("#f5c6a8"),8); draw_line(p+Vector2(38,-5),p+Vector2(68,20),Color("#f5c6a8"),8)

func _pet(p):
    var bob = sin(t*6.0+1.0)*4.0
    draw_circle(p+Vector2(0,0+bob), 25, Color("#a77bea"))
    draw_colored_polygon(PackedVector2Array([p+Vector2(-19,-17),p+Vector2(-33,-42),p+Vector2(-8,-27)]),Color("#8b62d2"))
    draw_colored_polygon(PackedVector2Array([p+Vector2(19,-17),p+Vector2(33,-42),p+Vector2(8,-27)]),Color("#8b62d2"))
    draw_circle(p+Vector2(-8,-2+bob),4,Color.WHITE); draw_circle(p+Vector2(8,-2+bob),4,Color.WHITE)
    draw_circle(p+Vector2(-8,-2+bob),2,Color("#44395b")); draw_circle(p+Vector2(8,-2+bob),2,Color("#44395b"))
    draw_arc(p+Vector2(0,5+bob),8,0,PI,10,Color("#5d426e"),2)

func _pill(r, text, bg):
    draw_rect(r,bg,true); draw_string(ThemeDB.fallback_font, r.position+Vector2(18,32), text,HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("#6b5870"))

func _button(r,text,bg):
    draw_rect(r,bg,true); draw_string(ThemeDB.fallback_font,r.position+Vector2(18,28),text,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#5b4a63"))
