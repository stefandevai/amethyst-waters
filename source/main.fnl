;;; -------------------------------------------------------------------------------------------- ;;;
;;; Utils                                                                                        ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

;; Returns true if the object is outsite the screen boundaries
(fn out-of-bounds? [object]
  (or (< object.x 0)
      (< object.y 0)
      (> (+ object.x object.w) +width+)
      (> (+ object.y object.h) +height+)))

;; Shortcut for math.random
(fn r [a b]
  (math.random a b))

;; Returns true if objects a and b collide
(fn bcollides? [a b]
  (and (< a.x (+ b.x b.w))
       (> (+ a.x a.w) b.x)
       (< a.y (+ b.y b.h))
       (> (+ a.y a.h) b.y)))

;; Returns true if a object collides with a tile in the map
(fn mcollides? [x y w h]
  (or (> (mget (// x 8) (// y 8)) 127)
      (> (mget (// (+ x w) 8) (// y 8)) 127)
      (> (mget (// x 8) (// (+ y h) 8)) 127)
      (> (mget (// (+ x w) 8) (// (+ y h) 8)) 127)))

;; Returns map collisions in a body
(fn mcollisions [x y w h]
  (values (> (mget (// x 8) (// y 8)) 127)
          (> (mget (// (+ x w) 8) (// y 8)) 127)
          (> (mget (// x 8) (// (+ y h) 8)) 127)
          (> (mget (// (+ x w) 8) (// (+ y h) 8)) 127)))

;; Rounds a float number to its closest integer
(fn math.round [n]
  (math.floor (+ n 0.5)))

;; Depp copies a table
(fn deepcopy [orig]
  (var orig-type (type orig))
  (var copy nil)
  
  (if (= orig-type "table")
      (do (set copy {})
          (each [key value (pairs orig)]
            (tset copy (deepcopy key) (deepcopy value)))
          (setmetatable copy (deepcopy (getmetatable orig))))
      (set copy orig))
  copy)

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Perlin noise                                                                                 ;;;
;;; -------------------------------------------------------------------------------------------- ;;;
;; Source: https://gist.github.com/AnastasiaDunbar/d1ec3f0f678a00ddc5947b1a3fdd10ea 

(fn mix [a b t] (+ (* t (- b a)) a))
;(fn mod [a b] (% (+ (% a b) b) b))
(fn fract [x] (- x (math.floor x)))
(fn clamp [a b c] (math.min (math.max a b) c))
(fn sign [x] (if (> x 0) 1 (< x 0) -1 0))
;(fn pow2 [a b] (* (math.pow (math.abs a) b) (sign a)))
(fn dot [a b]
  (var s 0)
  (for [i 1 (length a) 1]
    (set s (+ s (* (. a i) (. b i)))))
  s)

(global seed
  { :a (r 500 10000)
    :fx (r 500 10000)
    :fy (r 500 10000)
    :px (/ (r -500 500) 1000)
    :py (/ (r -500 500) 1000)})

(fn pseudor [x y] (fract (* (math.sin (dot [(+ x seed.px) (+ y seed.py)] [seed.fx seed.fy])) seed.a)))

(fn perlin [x y]
  (mix (mix (pseudor (math.floor x) (math.floor y))
            (pseudor (+ (math.floor x) 1) (math.floor y))
            (fract x))
       (mix (pseudor (math.floor x) (+ (math.floor y)))
            (pseudor (+ (math.floor x)) (+ (math.floor y)))
            (fract x))
       (fract y)))


;;; -------------------------------------------------------------------------------------------- ;;;
;;; Cave walls                                                                                   ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

;; Minimum height of a wall
(global ymin 0)

;; Maximum height of a wall
(global ymax 6)

;; Perlin noise
(fn pn [y]
  (math.ceil (+ ymin (*  (perlin y ymax) (- ymax ymin)))))

;; Generate first walls
(fn init-cave-walls []
  (for [i 0 60 1]
    (let [h (pn i)]
      ;; Set bottom walls
      (mset i (- 16 h) 136)
      (for [j (- 17 h) 16 1]
        (mset i j 128))
      
      ;; Set top walls
      (mset i (- ymax h) 135)
      (for [j 0 (- ymax 1 h) 1]
        (mset i j 128)))))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Animation                                                                                    ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

;; Gets next frame for the frames of an animation
(fn get-next-index [animation-length current-index]
  (+ 1 (% current-index animation-length)))

(fn get-animation-frame [animator]
  (. (. animator.animations animator.current-animation) animator.current-index))

;; Animates object with a animator property
(fn animate [object]
  (if (> object.animator.elapsed object.animator.speed)
      (do (tset object.animator :elapsed 0.0)
          (tset object.animator :current-index (get-next-index (length
                                                                 (. object.animator.animations
                                                                    object.animator.current-animation))
                                                               object.animator.current-index)))
      (tset object.animator :elapsed (+ object.animator.elapsed (* 1000.0 *dt*)))))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Shots                                                                                        ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

;; List of shot types and their respective sprites
(global *shot-types* { :shot-player 5 :shot-fish 6 })

;; Draws shot with a specific sprite and position
(fn draw-shot [shot]
  (let [spr-id (. *shot-types* shot.type)]
    (spr spr-id shot.x shot.y 0)))

;; Updates a shot. Returns true if it's out of bounds, returns nil otherwise
(fn update-shot [shot]
  (set shot.x (+ shot.x shot.speed))
  (out-of-bounds? shot))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Player                                                                                       ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

;; Player table object
(global *player* {
         :x 40 :y 68
         :w 8   :h 8
         :vx 0  :vy 0
         :shots []
         :health 100
       })

;; Player animations
(tset *player*
      :animator {
        :current-animation :moving
        :current-index 1
        :elapsed 0
        :speed 300
        :animations {
          :moving [ 1 2 ]
        }
      })

;; Updates player and player's shots (called on TIC)
(tset *player*
      :update (fn [self]
                ;; Movement
                (set self.vx 0)
                (set self.vy 0)
                (when (btn 2) (set self.vx -1))
                (when (btn 3) (set self.vx 1))
                (when (btn 1) (set self.vy 1))
                (when (btn 0) (set self.vy -1))

                ;; Map collision
                (let [fx (- (+ self.x self.vx) *cam*.x)
                      fy (- (+ self.y self.vy) *cam*.y)]
                  (when (mcollides? fx fy self.w self.h)
                    (set self.vx 0)
                    (set self.vy 0)))
                        ;(do (let [(tl tr bl br) (mcollisions fx fy self.w self.h)]
                             ;(trace (.. "tl " (tostring tl)))
                             ;(trace (.. "tr " (tostring tr)))
                             ;(trace (.. "bl " (tostring bl)))
                             ;(trace (.. "br " (tostring br)))
                             ;(trace "end")
                             
                             ;(when (and (< self.vx 0) (or tl bl)) (set self.vx 0))
                             ;(when (and (> self.vx 0) (or tr br)) (set self.vx 0))
                             ;(when (and (< self.vy 0) (or tl tr)) (set self.vy 0))
                             ;(when (and (> self.vy 0) (or bl br)) (set self.vy 0))))))

                ;; Shoot if Z is pressed
                (when (btnp 4)
                  (self:shoot))

                ;; Positioning
                (set self.x (+ self.x self.vx))
                (set self.y (+ self.y self.vy))

                ;; Check if out of bounds and reposition player
                (if (> (+ self.x self.w) +width+) (set self.x (- +width+ self.w))
                  (< self.x 0) (set self.x 0))
                (if (> (+ self.y self.h) +height+) (set self.y (- +height+ self.h))
                  (< self.y 0) (set self.y 0))))


;; Draws player (called on OVR)
(tset *player*
      :draw (fn [self]
              ;; Update/draw shots
              (each [index shot (pairs self.shots)]
                (let [should-delete? (update-shot shot)]
                  (draw-shot shot)
                  (when should-delete? (table.remove self.shots index))))

              (animate self)
              (spr (get-animation-frame self.animator) self.x self.y 0)))

;; Performs player shoot action
(tset *player*
      :shoot (fn [self]
              (let [shot-obj { :w 5 :h 1 :speed 3 :angle 0 :type :shot-player }]
                (tset shot-obj :x self.x)
                (tset shot-obj :y (+ self.y 4 (r -2 2)))
                (table.insert self.shots (+ (length self.shots) 1) shot-obj))))

;; Destroys shot with a certain index from *player*.shots
(fn destroy-shot [index]
  (table.remove *player*.shots index))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Enemies                                                                                      ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

;; List of enemy types and their respective sprites
(global *enemy-types* { :simple-fish 3 :stronger-fish 4 })

(global *simple-fish* { :w 8.0 :h 8.0 :speed 50.0 :damage 2.0 })

;; Modyfies position according to a function
(tset *simple-fish*
      :pos-modifier
      (fn [self]
        (set self.y (+ self.y (* 0.5 (math.sin (* 0.05 (+ *tick* self.y))))))))

(tset *simple-fish*
      :animator {
        :current-animation :moving
        :current-index 1
        :elapsed 0
        :speed 150
        :animations {
          :moving [ 3 4 ]
        }
      })

;; Pool containing all enemies
(global *enemy-pool* {})

;; Spawns a single enemy given a type and an optional y position value
(fn spawn-enemy [type ?y]
  (let [enemy (if (= type :simple-fish)    (deepcopy *simple-fish*)
                  (= type :stronger-fish)  { :w 8.0 :h 8.0 :speed 100.0 :damage 2.0 })]
    (tset enemy :type type)
    (tset enemy :x (+ +width+ 8.0))
    (if (not ?y)
        (tset enemy :y (r 0 (- +height+ enemy.h)))
        (tset enemy :y ?y))
    (table.insert *enemy-pool* enemy)))

;; Destroy enemy with a certain index from *enemy-pool*
(fn destroy-enemy [index]
  (table.remove *enemy-pool* index))

;; Updates enemies from *enemy-pool*
(fn update-enemies []
  ;; Update enemy position
  (each [index enemy (pairs *enemy-pool*)]
    (set enemy.x (- enemy.x (* enemy.speed *dt*)))

    (enemy:pos-modifier)
    (animate enemy)
    (spr (get-animation-frame enemy.animator) enemy.x enemy.y 0)

    ;; Deal with player-enemy collision
    (when (bcollides? *player* enemy) (tset *player* :health (- *player*.health enemy.damage)))

    ;; Deal with shot-enemy collision
    (each [shot-index shot (pairs *player*.shots)]
      (when (bcollides? shot enemy) (do (destroy-enemy index)
                                      (destroy-shot shot-index))))

    ;; Destroy enemy if it's to the left of the screen
    (when (< (+ enemy.x enemy.w) -8.0) (destroy-enemy index))))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Game                                                                                         ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn update-game-debug []
  (when (and (> *tick* 30) (= (% *tick* 60) 0))
    (spawn-enemy :simple-fish))

  (when (btnp 5)
    (spawn-enemy :simple-fish)))

(fn draw-hud []
  (print (.. "Energy: " *player*.health) 8 8 12))

(fn update-bg []
  (cls)
  (local txcam (// (math.abs *cam*.x) 8))
  (local tycam (// (math.abs *cam*.y) 8))
  (map txcam tycam 31 17 (- 0 (% (math.abs *cam*.x) 8)) (- 0 (% (math.abs *cam*.y) 8))))

(fn draw-game []
  (update-enemies)
  (*player*:draw)
  (draw-hud))

(fn update-game []
  (set *cam*.x (- *cam*.x (* 20 *dt*)))
  (*player*:update)
  (update-game-debug))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Menu                                                                                         ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn update-menu []
  (cls)
  (print "AQUATICOS" (* 12 8) (* 3 8) 12)
  (print "Press A to play the game" (* 7 8) (* 12 8) 12)
  (when (btnp 4)
    (global *game-state* "game")))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Main functions                                                                               ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn init []
  ;(load-palette "699fad3a708e2b454f111215151d1a1d3230314e3f4f5d429a9f87ede6cbf5d893e8b26fb6834c704d2b40231e151015")

  (global +width+ 240.0)
  (global +height+ 136.0)

  (global *dt* 0.0)
  (global *previous-time* (time))
  (global *tick* 0)

  (global *cam* { :x 0 :y 0 })

  (init-cave-walls)

  (global *game-state* "menu"))

(global TIC ; Function called once every frame
  (fn []
    ;; Calculate delta time
    (global *dt* (/ (- (time) *previous-time*) 1000.0))
    (global *previous-time* (time))
    (global *tick* (+ *tick* 1))

    (if
      (= *game-state* "menu")
      (update-menu)

      (= *game-state* "game")
      (do (update-bg)
          (update-game)))))

(global OVR ; Function called once every frame and called after TIC
  (fn []
    (when
      (= *game-state* "game") 
      (draw-game))))

(init)

;(global scanline
  ;(fn [row]
    ;(when
      ;(= *game-state* "game") 
      ;(poke 0x3ff9 (- (% (* 0.2 *tick*) 240) 113)))))

