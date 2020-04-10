(fn init []
  (load-palette "699fad3a708e2b454f111215151d1a1d3230314e3f4f5d429a9f87ede6cbf5d893e8b26fb6834c704d2b40231e151015")
  (global MODE "menu")
  (global p { :x 120 :y 68 :vx 0 :vy 0 }))

(fn update-menu []
  (cls 3)
  (print "AQUATICOS" (* 12 8) (* 3 8) 2)
  (print "Press A to play the game" (* 7 8) (* 12 8) 2)
  (when (btnp 4)
    (global MODE "game")))

(fn update-game []
  (if (btn 2) (set p.vx -1)
    (btn 3) (set p.vx 1)
    (btn 1) (set p.vy 1)
    (btn 0) (set p.vy -1)
    (do (set p.vx 0) (set p.vy 0)))

  (set p.x (+ p.x p.vx))
  (set p.y (+ p.y p.vy))
  (cls 3)
  (spr 1 p.x p.y 0))

(global TIC ; Function called once every frame
  (fn []
    (if
      (= MODE "menu")
      (update-menu)

      (= MODE "game") 
      (update-game))))

(init)
