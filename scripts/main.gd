extends Node2D

# Roza's World - polished single-scene 2D adventure foundation
var roza := Vector2(410, 500)
var pet := Vector2(330, 530)
var coins := 120
var stars := 7
var level := 1
var xp := 35
var zone := 0
var menu := false
var mission_done := false
var minigame := false
var minigame_score := 0
var target := Vector2.ZERO
var target_time := 0.0
var t := 0.0
var save_path := "user://roza_world.save"

const W := 1280.0
const H := 720.0

func _ready():
    _load_game()
    target = Vector2(850, 470)
    queue_redraw()

func _process(delta):
    t += delta
    target_time += delta
    if not menu and not minigame:
        var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
        if dir.length() > 0:
            roza += dir.normalized() * 230.0 * delta
            roza.x = clamp(roza.x, 90.0, 1190.0)
            roza.y = clamp(roza.y, 310.0, 620.0)
        _check_zone()
        pet = pet.lerp(roza + Vector2(-62, 34), min(1.0, delta * 5.0))
    if minigame and target_time > 1.4:
        target = Vector2(randf_range(680, 1140), randf_range(330, 590))
        target_time = 0.0
    queue_redraw()

func _check_zone():
    var new_zone := 0
    if roza.x > 960: new_zone = 1
    elif roza.x < 230: new_zone = 2
    elif roza.y < 390: new_zone = 3
    if new_zone != zone:
        zone = new_zone
        if zone != 0:
            stars += 1
            xp += 10
            _level_check()
            _save_game()

func _input(event):
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        menu = not menu
        minigame = false
        queue_redraw()
        return
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var p := event.position
        if minigame:
            if p.distance_to(target) < 70:
                minigame_score += 1
                coins += 5
                xp += 4
                target = Vector2(randf_range(680,1140), randf_range(330,590))
                target_time = 0.0
                if minigame_score >= 10:
                    minigame = false
                    stars += 2
                    _level_check()
                    _save_game()
            queue_redraw()
            return
        if menu:
            if Rect2(450, 265, 380, 64).has_point(p):
                menu = false
            elif Rect2(450, 345, 380, 64).has_point(p):
                _reset_progress()
            queue_redraw()
            return
        if Rect2(1030, 24, 220, 72).has_point(p):
            if not mission_done:
                mission_done = true
                coins += 25
                stars += 1
                xp += 15
                _level_check()
                _save_game()
        elif Rect2(695, 650, 150, 44).has_point(p):
            minigame = true
            minigame_score = 0
            target_time = 0.0
            target = Vector2(850, 470)
        elif Rect2(860, 650, 150, 44).has_point(p):
            coins += 10
            xp += 5
            _level_check()
            _save_game()
        elif Rect2(1025, 650, 150, 44).has_point(p):
            stars += 1
            xp += 8
            _level_check()
            _save_game()
        queue_redraw()

func _level_check():
    while xp >= level * 60:
        xp -= level * 60
        level += 1
        coins += 30
        stars += 1

func _save_game():
    var f := FileAccess.open(save_path, FileAccess.WRITE)
    if f:
        f.store_var({"coins":coins,"stars":stars,"level":level,"xp":xp,"mission":mission_done})
        f.close()

func _load_game():
    if not FileAccess.file_exists(save_path): return
    var f := FileAccess.open(save_path, FileAccess.READ)
    if f:
        var d = f.get_var()
        if d is Dictionary:
            coins = int(d.get("coins", coins)); stars = int(d.get("stars", stars)); level = int(d.get("level", level)); xp = int(d.get("xp", xp)); mission_done = bool(d.get("mission", false))
        f.close()

func _reset_progress():
    coins = 120; stars = 7; level = 1; xp = 35; mission_done = false; roza = Vector2(410,500); zone = 0
    _save_game()

func _draw():
    _draw_background()
    if minigame:
        _draw_minigame()
    elif menu:
        _draw_menu()
    else:
        _draw_world()

func _draw_background():
    draw_rect(Rect2(0,0,W,H), Color("#9bdcf4"))
    # soft sky bands
    draw_rect(Rect2(0,260,W,180), Color("#a9e1b1"))
    draw_circle(Vector2(1085,105), 55, Color("#fff1a8"))
    _cloud(Vector2(145,115), 1.0); _cloud(Vector2(675,95), 0.75); _cloud(Vector2(950,170), 0.65)
    # distant mountains
    draw_colored_polygon(PackedVector2Array([Vector2(0,350),Vector2(160,220),Vector2(280,330),Vector2(470,180),Vector2(650,330),Vector2(840,205),Vector2(1040,330),Vector2(1200,210),Vector2(1280,290),Vector2(1280,450),Vector2(0,450)]), Color("#78b98b"))

func _draw_world():
    # ground
    draw_rect(Rect2(0,380,W,340), Color("#72bd70"))
    # flower patches
    for p in [Vector2(70,520),Vector2(180,610),Vector2(630,410),Vector2(760,600),Vector2(920,390),Vector2(520,650)]:
        _flowers(p)
    # winding path
    draw_colored_polygon(PackedVector2Array([Vector2(390,720),Vector2(590,720),Vector2(610,585),Vector2(570,500),Vector2(505,450),Vector2(430,420),Vector2(375,380),Vector2(290,380),Vector2(365,470),Vector2(455,520),Vector2(485,590)]), Color("#efd39d"))
    # water / beach zone
    draw_rect(Rect2(980,405,300,315), Color("#56bde3"))
    for y in range(445,700,55):
        for x in range(1000,1260,95):
            draw_arc(Vector2(x,y),22,0.1,2.7,12,Color("#a8e8f4"),3)
    # forest
    for p in [Vector2(75,405),Vector2(155,430),Vector2(820,430),Vector2(900,410),Vector2(930,500)]: _tree(p)
    _house(Vector2(300,355))
    _castle(Vector2(1100,335))
    _sign(Vector2(620,455), "FOREST")
    _roza(roza)
    _pet(pet)
    _draw_hud()

func _draw_hud():
    draw_rect(Rect2(22,20,355,78),Color("#ffffffec"),true)
    draw_string(ThemeDB.fallback_font,Vector2(44,52),"ROZA'S WORLD",HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color("#594a7b"))
    draw_string(ThemeDB.fallback_font,Vector2(45,78),"Level %d   •   Magical Adventure" % level,HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#80738f"))
    _pill(Rect2(400,25,130,48),"★  %d" % stars,Color("#fff0a3"))
    _pill(Rect2(545,25,145,48),"●  %d" % coins,Color("#ffdda0"))
    draw_rect(Rect2(705,29,230,38),Color("#ffffffb8"),true)
    draw_rect(Rect2(710,34,220 * float(xp)/max(1,level*60),28),Color("#c79eea"),true)
    draw_string(ThemeDB.fallback_font,Vector2(790,55),"XP %d / %d" % [xp,level*60],HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#584568"))
    draw_rect(Rect2(1030,24,220,72),Color("#fffdf2ed"),true)
    draw_string(ThemeDB.fallback_font,Vector2(1048,49),"DAILY MISSION",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#7c6488"))
    draw_string(ThemeDB.fallback_font,Vector2(1048,75),"✓ Done +25" if mission_done else "Do a good deed +25",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#477353"))
    _button(Rect2(695,650,150,44),"🎮  PLAY",Color("#f3a6c4"))
    _button(Rect2(860,650,150,44),"+ COINS",Color("#ffd37a"))
    _button(Rect2(1025,650,150,44),"+ STAR",Color("#b7def8"))
    draw_string(ThemeDB.fallback_font,Vector2(28,690),"WASD / Arrow keys  •  ESC = menu",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)

func _draw_minigame():
    draw_rect(Rect2(70,120,1140,530),Color("#fff9e9"),true)
    draw_rect(Rect2(70,120,1140,530),Color("#d7a8d8"),false,5)
    draw_string(ThemeDB.fallback_font,Vector2(105,170),"STAR CATCHER",HORIZONTAL_ALIGNMENT_LEFT,-1,34,Color("#644d80"))
    draw_string(ThemeDB.fallback_font,Vector2(105,202),"Click the magical stars! Catch 10 to win.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#8a7890"))
    for i in range(8):
        var p := Vector2(170+i*125,330+sin(t*1.7+i)*35)
        draw_circle(p,4,Color("#ead58d"))
    _star(target,38)
    draw_string(ThemeDB.fallback_font,Vector2(1040,170),"%d / 10" % minigame_score,HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color("#c37b9c"))
    _button(Rect2(1050,590,170,42),"EXIT",Color("#e7c7d7"))

func _draw_menu():
    draw_rect(Rect2(0,0,W,H),Color("#6c5b86b8"),true)
    draw_rect(Rect2(400,145,480,420),Color("#fff9ec"),true)
    draw_rect(Rect2(400,145,480,420),Color("#d6a5d4"),false,5)
    draw_string(ThemeDB.fallback_font,Vector2(470,210),"ROZA'S WORLD",HORIZONTAL_ALIGNMENT_LEFT,-1,34,Color("#654b7d"))
    draw_string(ThemeDB.fallback_font,Vector2(475,240),"My magical adventure",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("#948398"))
    _button(Rect2(450,265,380,64),"CONTINUE ADVENTURE",Color("#f2a7c5"))
    _button(Rect2(450,345,380,64),"RESET SAVE",Color("#f0d1a0"))
    draw_string(ThemeDB.fallback_font,Vector2(485,455),"Level %d   ★ %d   ● %d" % [level,stars,coins],HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("#66556f"))
    draw_string(ThemeDB.fallback_font,Vector2(485,490),"Progress is saved automatically.",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#98899c"))
    draw_string(ThemeDB.fallback_font,Vector2(485,525),"ESC to close",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#b095ad"))

func _cloud(p,s):
    draw_circle(p,28*s,Color("#ffffffd9")); draw_circle(p+Vector2(30*s,-8*s),36*s,Color("#ffffffd9")); draw_circle(p+Vector2(62*s,4*s),25*s,Color("#ffffffd9"))

func _flowers(p):
    for i in range(5):
        var q=p+Vector2(i*12-24,sin(i*2)*8)
        draw_line(q,q+Vector2(0,15),Color("#4f985b"),2)
        draw_circle(q,4,Color("#f7d77d"))
        draw_circle(q+Vector2(4,0),3,Color("#f3a3bc"))

func _tree(p):
    draw_rect(Rect2(p.x-9,p.y,18,75),Color("#805842"),true)
    draw_circle(p+Vector2(0,-25),48,Color("#4d9960")); draw_circle(p+Vector2(-30,-8),34,Color("#62aa68")); draw_circle(p+Vector2(30,-8),35,Color("#5ba265"))
    draw_circle(p+Vector2(-14,-38),5,Color("#f7d27a"))

func _house(p):
    draw_rect(Rect2(p.x-110,p.y+55,220,135),Color("#fff0cf"),true)
    draw_colored_polygon(PackedVector2Array([p+Vector2(-132,65),p+Vector2(0,-65),p+Vector2(132,65)]),Color("#e88892"))
    draw_rect(Rect2(p.x-27,p.y+112,54,78),Color("#895f4c"),true)
    draw_rect(Rect2(p.x-88,p.y+94,48,44),Color("#8ed6e8"),true); draw_rect(Rect2(p.x+40,p.y+94,48,44),Color("#8ed6e8"),true)
    draw_rect(Rect2(p.x-4,p.y+112,8,78),Color("#6f4e42"),true)
    draw_circle(p+Vector2(0,-12),20,Color("#fff6da")); draw_circle(p+Vector2(0,-12),8,Color("#f3c9d5"))

func _castle(p):
    draw_rect(Rect2(p.x-90,p.y+45,180,145),Color("#f1e4ef"),true)
    for dx in [-75,0,75]:
        draw_rect(Rect2(p.x+dx-30,p.y-15,60,205),Color("#ead9eb"),true)
        draw_colored_polygon(PackedVector2Array([Vector2(p.x+dx-40,p.y-15),Vector2(p.x+dx,p.y-62),Vector2(p.x+dx+40,p.y-15)]),Color("#9b7bc0"))
    draw_rect(Rect2(p.x-18,p.y+115,36,75),Color("#79577f"),true)
    draw_circle(Vector2(p.x-6,p.y+145),3,Color("#f6d78a"))

func _sign(p,text):
    draw_rect(Rect2(p.x-6,p.y,12,75),Color("#815b45"),true)
    draw_rect(Rect2(p.x-70,p.y-35,140,45),Color("#d6a66d"),true)
    draw_string(ThemeDB.fallback_font,p+Vector2(-47,-6),text,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#664b3d"))

func _roza(p):
    var bob=sin(t*6.0)*3.0
    # shadow
    draw_ellipse(p+Vector2(0,78),Vector2(40,10),Color("#4e855566"))
    draw_circle(p+Vector2(0,-62+bob),31,Color("#f5c6a8"))
    # hair
    draw_circle(p+Vector2(0,-73+bob),33,Color("#684432")); draw_circle(p+Vector2(-28,-70+bob),14,Color("#684432")); draw_circle(p+Vector2(28,-70+bob),14,Color("#684432"))
    draw_circle(p+Vector2(-10,-62+bob),3,Color("#393044")); draw_circle(p+Vector2(10,-62+bob),3,Color("#393044"))
    draw_arc(p+Vector2(0,-53+bob),9,0.2,2.9,12,Color("#b85d70"),2)
    # dress
    draw_colored_polygon(PackedVector2Array([p+Vector2(-31,-34),p+Vector2(31,-34),p+Vector2(51,44),p+Vector2(-51,44)]),Color("#f08bb3"))
    draw_circle(p+Vector2(0,5),8,Color("#f7b6d0"))
    draw_line(p+Vector2(-25,43),p+Vector2(-33,79),Color("#62485b"),8); draw_line(p+Vector2(25,43),p+Vector2(33,79),Color("#62485b"),8)
    draw_line(p+Vector2(-38,-5),p+Vector2(-70,20),Color("#f5c6a8"),8); draw_line(p+Vector2(38,-5),p+Vector2(70,20),Color("#f5c6a8"),8)

func _pet(p):
    var bob=sin(t*7.0+1.0)*4.0
    draw_ellipse(p+Vector2(0,28),Vector2(28,8),Color("#4e855555"))
    draw_circle(p+Vector2(0,bob),26,Color("#a778e6"))
    draw_colored_polygon(PackedVector2Array([p+Vector2(-19,-15+bob),p+Vector2(-34,-42+bob),p+Vector2(-7,-26+bob)]),Color("#8d63d2"))
    draw_colored_polygon(PackedVector2Array([p+Vector2(19,-15+bob),p+Vector2(34,-42+bob),p+Vector2(7,-26+bob)]),Color("#8d63d2"))
    draw_circle(p+Vector2(-8,-2+bob),4,Color.WHITE); draw_circle(p+Vector2(8,-2+bob),4,Color.WHITE)
    draw_circle(p+Vector2(-8,-2+bob),2,Color("#44395b")); draw_circle(p+Vector2(8,-2+bob),2,Color("#44395b"))
    draw_arc(p+Vector2(0,6+bob),8,0,PI,10,Color("#5d426e"),2)

func _star(p,r):
    var pts:=PackedVector2Array()
    for i in range(10):
        var a=-PI/2+i*PI/5
        var rr=r if i%2==0 else r*0.42
        pts.append(p+Vector2(cos(a),sin(a))*rr)
    draw_colored_polygon(pts,Color("#ffd95f")); draw_polyline(pts,Color("#f1b84d"),3)

func _ellipse(center:Vector2,radius:Vector2):
    var pts:=PackedVector2Array()
    for i in range(32):
        var a=TAU*i/32.0
        pts.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y))
    return pts

func draw_ellipse(center:Vector2,radius:Vector2,color:Color):
    draw_colored_polygon(_ellipse(center,radius),color)

func _pill(r,text,bg):
    draw_rect(r,bg,true); draw_string(ThemeDB.fallback_font,r.position+Vector2(18,31),text,HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("#6b5870"))

func _button(r,text,bg):
    draw_rect(r,bg,true); draw_string(ThemeDB.fallback_font,r.position+Vector2(20,29),text,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#5b4a63"))
