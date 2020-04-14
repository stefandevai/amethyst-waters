;; title:  Amethyst Waters
;; author: Stefan Devai
;; desc:   Explore deep sea caverns with your submarine!
;; script: fennel

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Utils                                                                                        ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

;; Shortcut for increment. Increments a by n
(macros {:inc (fn [a ?n]
                `(set ,a (+ ,a (or ,?n 1))))

;; Shortcut for decrement Decrements a by n
         :dec (fn [a ?n]
                `(set ,a (- ,a (or ,?n 1))))

;; Shortcut for global decrement. Decrements a by n
         :decg (fn [a ?n]
                 `(global ,a (- ,a (or ,?n 1))))

;; Shortcut for global increment. Increments a by n
         :incg (fn [a ?n]
                 `(global ,a (+ ,a (or ,?n 1))))})

;; Returns true if the object is outsite the screen boundaries
(fn out-of-bounds? [object]
  (or (< object.x 0)
      (< object.y 0)
      (> (+ object.x object.w) +width+)
      (> (+ object.y object.h) +height+)))

;; Shortcut for math.random
(fn r [a b]
  (math.random a b))

;; Returns sign of a number
(fn sign [x] (if (> x 0) 1 (< x 0) -1 0))

;; Returns true if objects a and b collide
(fn bcollides? [a b]
  (and (< a.x (+ b.x b.w))
       (> (+ a.x a.w) b.x)
       (< a.y (+ b.y b.h))
       (> (+ a.y a.h) b.y)))

;; Returns true if a object collides with a tile in the map
(fn mcollides? [x y w h]
  (or (> (mget (// (% x 1920) 8) (// y 8)) 127)                       ; top-left
      (> (mget (// (+ (% x 1920) (- w 1)) 8) (// y 8)) 127)           ; top-right
      (> (mget (// (% x 1920) 8) (// (+ y (- h 1)) 8)) 127)                 ; bottom-left
      (> (mget (// (+ (% x 1920) (- w 1)) 8) (// (+ y (- h 1)) 8)) 127)))   ; bottom-right

;; Returns map collisions in a body
(fn mcollisions [obj]
  (let [x (- (+ obj.x obj.vx) (math.ceil *cam*.x))
        y (- (+ obj.y obj.vy) *cam*.y)
        w obj.w
        h obj.h]
  (values (> (mget (// (% x 1920) 8) (// y 8)) 127)                       ; top-left
          (> (mget (// (+ (% x 1920) (- w 1)) 8) (// y 8)) 127)           ; top-right
          (> (mget (// (% x 1920) 8) (// (+ y (- h 1)) 8)) 127)                 ; bottom-left
          (> (mget (// (+ (% x 1920) (- w 1)) 8) (// (+ y (- h 1)) 8)) 127))))  ; bottom-right

;; Resolves collision between an object and the map
(fn rcollision [obj]
  (let [(tl tr bl br) (mcollisions obj)]
   (local ox (- (+ obj.x obj.vx) (math.ceil *cam*.x)))
   (local oy (- (+ obj.y obj.vy) (math.ceil *cam*.y)))
   (local ow (- (+ obj.x obj.vx obj.w) (math.ceil *cam*.x)))
   (local oh (- (+ obj.y obj.vy obj.h) *cam*.y))

   (var sy 0) ; sign of y movement
   (var ix 0) ; intersection in the x axis
   (var iy 0) ; intersection in the y axis
   (var in 0) ; number of sides with intersection

   (when tl (inc in))
   (when tr (inc in))
   (when bl (inc in))
   (when br (inc in))

   ;; Calculate intersections
   (if (or tr br)
       (set ix (math.abs (- ow (* 8 (// ow 8)))))
       (or tl bl)
       (set ix (math.abs (- ox (* 8 (// (+ ox 8) 8))))))

   (if (or br bl)
         (do (set iy (math.abs (- oh (* (// oh 8) 8))))
             (set sy -1))
       (or tr tl)
             (do (set iy (math.abs (- (* (+ (// oy 8) 1) 8) oy)))
                 (set sy 1)))

   ;; When intersection is 100%
   (when (and (= ix 0) (or tl tr bl br)) (set ix 8))
   (when (and (= iy 0) (or tl tr bl br)) (set iy 8))

   ;; Resolve collisions
   (if (and (or tl tr) (> ix iy)) (set obj.vy (+ obj.vy iy)) ; top
       (and (or br tr) (> iy ix)) (set obj.vx (- obj.vx ix)) ; right
       (and (or bl br) (> ix iy)) (set obj.vy (- obj.vy iy)) ; bottom
       (and (or tl bl) (> iy ix)) (set obj.vx (+ obj.vx ix)) ; left
       (and (> in 2) (= iy ix)) (do (set obj.vx 0) (set obj.vy 0)) ; 3+ sides colliding
       (and (= iy ix)) (do (set obj.vy (+ obj.vy (* iy sy)))) ; border 1px x 1px collision
       (do (trace "here") (set obj.vx 0) (set obj.vy 0))))) 

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

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Perlin noise                                                                                 ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;; Source: https://gist.github.com/AnastasiaDunbar/d1ec3f0f678a00ddc5947b1a3fdd10ea 

(fn mix [a b t] (+ (* t (- b a)) a))
;(fn mod [a b] (% (+ (% a b) b) b))
(fn fract [x] (- x (math.floor x)))
;(fn clamp [a b c] (math.min (math.max a b) c))
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

(fn perlinf [x y]
  (local iterations 4)
  (var sum 0)
  (for [i 0 iterations 1]
    (set seed.a (+ 500 (* (fract (math.sin (* (+ i 0.512) 512 725.63))) 1000)))
    (set sum (+ sum (perlin (* x (+ i 1)) (* y (+ i 1))))))
  (/ sum iterations))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Cave wall1                                                                                   ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

;; Minimum height of a wall
(global ymin 0)

;; Maximum height of a wall
(global ymax 1)

;; Perlin noise
(fn pn [y]
  (math.round (+ ymin (*  (perlinf y ymax) (- ymax ymin)))))

;; Simple noise
(fn sn [y]
  (r ymin ymax))

;; Generate cave walls
(fn generate-cave-walls [from to f]
  (local dspl (r 3 100)) ; Displacement factor
  (for [i from to 1]
    (let [h (f i)
          h2 (f (+ i dspl))]
      ;; Set bottom walls
      (local bottom-head (r 137 141))
      ;(local bottom-head 137)
      (mset i (- 16 h) bottom-head)
      (for [j (- 17 h) 16 1]
        (mset i j 128))
      
      ;; Set top walls
      (local top-head (r 144 150))
      ;(local top-head 144)
      (mset i (- ymax (- h2 1)) top-head)
      (for [j 0 (- ymax (- h2 0)) 1]
        (mset i j 128)))))

;; Sets all map tiles from block to 0
(fn clear-map-block [block]
  (for [i (* block 30) (- (* (+ block 1) 30) 1) 1]
    (for [j 0  16]
      (mset i j 0))))

;; Generates cave walls if needed
(fn update-cave-walls []
  ;; Generate walls for next block
  (local current-block (// (math.abs *cam*.x) 240))
  (local from (+ current-block 1))
  ;; Generate 4 blocks if cam is 2 blocks away from last generated block
  (when (< *last-block-generated* from)
    ;; Increase wall height
    (when (and (< ymax 6)
               (= (% *last-block-generated* 2) 0))
      (incg ymax))
    ;(global ymax (math.round (* (perlinf *last-block-generated* *cam*.x) 6)))
    ;(global ymax (r 1 7))
    ;(trace ymax)

    ;; Select a noise function
    (var noisef sn)
    (when (= (r 0 1) 0)
          (set noisef pn))

    (global *last-block-generated* from)
    (when (> from 7) (clear-map-block (% from 8)))
    (generate-cave-walls (* (% from 8) 30)
                         (- (* (+ (% from 8) 1) 30) 1)
                         noisef)))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Animation                                                                                    ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

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

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Shots                                                                                        ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

;; List of shot types and their respective sprites
(global *shot-types* { :shot-player 5 :shot-fish 6 })

;; Draws shot with a specific sprite and position
(fn draw-shot [shot]
  (let [spr-id (. *shot-types* shot.type)]
    (spr spr-id shot.x shot.y 0)))

;; Updates a shot. Returns true if it's out of bounds, returns nil otherwise
(fn update-shot [shot]
  (inc shot.x shot.speed)
  (out-of-bounds? shot))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Player                                                                                       ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

;; Player table object
(global *player* {
         :x 40 :y 68
         :w 8   :h 8
         :vx 0  :vy 0
         :shots []
         :health 100
         :state :none
         :hurt-timer 0
       })

;; Player animations
(tset *player*
      :animator {
        :current-animation :moving
        :current-index 1
        :elapsed 0
        :speed 100
        :animations {
          :moving [ 257 258 259 260 ]
          :hurt [ 257 256 258 256 259 256 260 256 ]
        }
      })

;; Updates player and player's shots (called on TIC)
(tset *player*
      :update (fn [self]
                ;; States
                (if (= self.state :hurt)
                    (do (when (< self.hurt-timer 0)
                          (do (set self.state :none)
                              (set self.animator.current-animation :moving)))
                        (dec self.hurt-timer)))

                ;; Movement
                (set self.vx 0)
                (set self.vy 0)
                (when (btn 2) (set self.vx -1))
                (when (btn 3) (set self.vx 1))
                (when (btn 1) (set self.vy 1))
                (when (btn 0) (set self.vy -1))

                ;; Map collision
                (var fx (- (+ self.x self.vx) (math.ceil *cam*.x)))
                (var fy (- (+ self.y self.vy) *cam*.y))
                (var ni 0) ; Number of times we tried to resolve collisions
                (while (and (< ni 5) (mcollides? fx fy self.w self.h))
                  (rcollision self)
                  (set ni (+ ni 1))
                  (set fx (- (+ self.x self.vx) (math.ceil *cam*.x)))
                  (set fy (- (+ self.y self.vy) *cam*.y)))

                ;; Shoot if Z is pressed
                (when (btnp 4 10 10)
                  (sfx 3 50 -1 3 7)
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

;; Hurts player 
(tset *player*
      :hurt (fn [self damage]
              (if (not= self.state :hurt)
                  (do (sfx 4 12 -1 3 88)
                      (global *shake* 10)
                      (dec self.health damage)
                      (set self.animator.current-animation :hurt)
                      (set self.state :hurt)
                      (set self.hurt-timer 90)))))

;; Destroys shot with a certain index from *player*.shots
(fn destroy-shot [index]
  (table.remove *player*.shots index))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Enemies                                                                                      ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

;; List of enemy types 
(global *enemy-types* [ :simple-fish :stronger-fish ])

(global *simple-fish* { :w 7.0 :h 3.0 :speed 50.0 :damage 2.0 })

;; Modyfies position according to a function
(tset *simple-fish*
      :pos-modifier
      (fn [self]
        (inc self.y (* 0.5 (math.sin (* 0.05 (+ *tick* self.y)))))))

(tset *simple-fish*
      :animator {
        :current-animation :moving
        :current-index 1
        :elapsed 0
        :speed 150
        :animations {
          ;:moving [ 273 274 275 276 275 274 ]
          :moving [ 292 293 294 293 292 295 296 295 ]
        }
      })

(global *stronger-fish* { :w 8.0 :h 8.0 :speed 30.0 :damage 5.0 })

;; Modyfies position according to a function
(tset *stronger-fish*
      :pos-modifier
      (fn [self]
        (inc self.y (* 0.5 (math.sin (* 0.05 (+ *tick* self.y)))))))

(tset *stronger-fish*
      :animator {
        :current-animation :moving
        :current-index 1
        :elapsed 0
        :speed 150
        :animations {
          :moving [ 273 274 275 276 275 274 ]
        }
      })

;; Pool containing all enemies
(global *enemy-pool* {})

;; Spawns a single enemy given a type and an optional y position value
(fn spawn-enemy [type ?y]
  (let [enemy (if (= type :simple-fish)    (deepcopy *simple-fish*)
                  (= type :stronger-fish)  (deepcopy *stronger-fish*))]
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
    (dec enemy.x (* enemy.speed *dt*))

    (enemy:pos-modifier)
    (animate enemy)
    (spr (get-animation-frame enemy.animator) enemy.x enemy.y 0)

    ;; Deal with player-enemy collision
    (when (bcollides? *player* enemy)
      (*player*:hurt enemy.damage))

    ;; Deal with shot-enemy collision
    (each [shot-index shot (pairs *player*.shots)]
      (when (bcollides? shot enemy) (do (destroy-enemy index)
                                        (destroy-shot shot-index)
                                        (when (= *shake* 0) (global *shake* 5)))))

    ;; Destroy enemy if it's to the left of the screen
    (when (< (+ enemy.x enemy.w) -8.0) (destroy-enemy index))))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Background                                                                                   ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

;; Applies a parallax with a factor and a initial position p0
(fn parallax [p0 factor axis]
  (if (= axis :x) (+ p0 (* *cam*.x factor))
      (= axis :y) (+ p0 (* *cam*.y factor))))

;; Draws a sprite that loops in the x and y axis
(fn loop-spr [id x y w h pfactor]
  (spr id (- (% (parallax x pfactor :x) (+ 240 (* w 8))) (* w 8))
          (- (% (parallax y pfactor :y) (+ 136 (* h 8))) (* h 8)) 0 1 0 0 w h))

;; Draws cave background with a parallax factor pfactor
(fn draw-cave-bg [pfactor]
  (loop-spr 11 230 120 2 4 pfactor)
  (loop-spr 8 180 40 1 2 pfactor)
  (loop-spr 11 100 70 5 5 pfactor)
  (loop-spr 9 50 100 4 4 pfactor)
  (loop-spr 8 100 110 1 2 pfactor)
  (loop-spr 9 190 100 7 5 pfactor)
  (loop-spr 8 140 100 1 2 pfactor)
  (loop-spr 11 280 70 5 5 pfactor)
  (loop-spr 9 120 68 2 3 pfactor))

;; Draws background decoration
(fn draw-bg []
  (draw-cave-bg 0.1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Game                                                                                       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn update-game-debug []
  (when (and (> *tick* 30) (= (% *tick* 60) 0))
    ;; Spawn a random enemy
    (spawn-enemy (. *enemy-types* (r 1 (length *enemy-types*)))))

  (when (btnp 5)
    (spawn-enemy :simple-fish)))

(fn draw-healthbar [x y n]
  ;; Health icon
  (spr 387 x (+ y 3) 0)

  ;; Health bar
  (spr 384 (+ x 3) y 0 1 0 0 2 1)
  (spr 385 (+ x 16 3) y 0 1 0 0 1 1)
  (spr 385 (+ x 24 3) y 0 1 0 0 1 1)
  (spr 385 (+ x 32 3) y 0 1 0 0 1 1)
  (spr 385 (+ x 40 3) y 0 1 0 0 1 1)
  (spr 385 (+ x 42 3) y 0 1 0 0 2 1)

  (spr 384 (+ x 3) (+ y 4) 0 1 2 0 2 1)
  (spr 385 (+ x 16 3) (+ y 4) 0 1 2 0 1 1)
  (spr 385 (+ x 24 3) (+ y 4) 0 1 2 0 1 1)
  (spr 385 (+ x 32 3) (+ y 4) 0 1 2 0 1 1)
  (spr 385 (+ x 40 3) (+ y 4) 0 1 2 0 1 1)
  (spr 385 (+ x 42 3) (+ y 4) 0 1 2 0 2 1)

  ;; Filling
  ;; Only draw if we have life
  (when (> n 0)
    (var fill-color 1)
    (when (< n 10) (set fill-color 9))
    (for [j y (+ y 3) 1]
      (for [i (+ x 3) (+ x 3 n -1) 1]
        (pix (+ i 4) (+ j 4) fill-color)))))

(fn draw-hud []
  ;(print (.. "camx " *cam*.x) 8 26 12)
  ;(print (.. "lastgen " *last-block-generated*) 8 17 12)
  ;(spr 384 100 13 0 1 2 0 3 1)
  (draw-healthbar 5 5 (// *player*.health 2)))
  ;(print (.. "Energy: " *player*.health) 8 18 12))

(fn draw-game []
  (cls)

  ;(draw-bg)

  (local txcam (// (math.abs *cam*.x) 8))
  (local tycam (// (math.abs *cam*.y) 8))
  (map txcam tycam 31 17 (- 0 (% (math.abs *cam*.x) 8)) (- 0 (% (math.abs *cam*.y) 8)) 0)

  (update-enemies)
  (*player*:draw)
  (draw-hud))

(fn update-camera []
  ;;; Increase camera speed
  ;(when (= (% *tick* 100) 0)
    ;(trace "up")
    ;(inc *cams*.x))

  ;; Move camera
  (set *cam*.x (- *cam*.x (* *cams*.x *dt*))))

(fn update-game []
  (update-cave-walls)
  (update-camera)

  ;; Shake screen if receives damage
  (when (> *shake* 0)
    (poke 0x3FF9 (r 0 1))
    (poke (+ 0x3FF9 1) (r 0 1))
    (decg *shake*)
    (when (= *shake* 0) (memset 0x3FF9 0 2)))

  (*player*:update)
  (update-game-debug))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Menu                                                                                         ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

(fn update-menu []
  (cls 5)
  (print "AMETHYST WATERS" (* 4 8) (* 3 8) 12 true 2)
  (print "Press Z to play the game" (* 7 8) (* 12 8) 12)

  (when (btnp 4)
    (global *game-state* "game")))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Main functions                                                                               ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

(fn init []
  ;(load-palette "699fad3a708e2b454f111215151d1a1d3230314e3f4f5d429a9f87ede6cbf5d893e8b26fb6834c704d2b40231e151015")

  ;(music 0 0 0 true)
  
  ;; Set border color
  (poke 0x03FF8 5)

  (global +width+ 240.0)
  (global +height+ 136.0)

  (global *dt* 0.0)
  (global *previous-time* (time))
  (global *tick* 0)

  (global *cams* { :x 20 :y 0 })
  (global *cam* { :x 0 :y 0 })

  (global *last-block-generated* 0)
  (global *max-wall-y* 6)
  (generate-cave-walls 0 29 pn)

  (global *shake* 0)

  (global *game-state* "menu"))

;(fn update-music []
  ;(trace (peek (+ 0x13e64 408 1))))
  ;(when (= (peek 0x13FFC) 255)
    ;(music 0 0 0 true)))

(global TIC ; Function called once every frame
  (fn []
    ;; Calculate delta time
    (global *dt* (/ (- (time) *previous-time*) 1000.0))
    (global *previous-time* (time))
    (incg *tick*)
    ;(global *tick* (+ *tick* 1))

    (if
      (= *game-state* "menu")
      (update-menu)

      (= *game-state* "game")
      ;(update-game))))
      (do (update-game)
          (draw-bg)))))

(global OVR
  (fn []
    (when (= *game-state* "game")
      (draw-game))))

(global scanline
 (fn [row]
     (when (= *game-state* "game")
       (poke 0x3ff9 (* (math.sin (/ (time) (+ 300 row) 5)) 10)))))

;wavelimit = 136/2
;function scanline(row)
	;-- skygradient
	;poke(0x3fc0,190-row)
	;poke(0x3fc1,140-row)
	;poke(0x3fc2,0)
	;-- screen wave
	;if row>wavelimit then
		;poke(0x3ff9,math.sin((time()/200+row/5))*10)
	;else
		;poke(0x3ff9,0)
	;end
;end

;(global OVR ; Function called once every frame and called after TIC
  ;(fn []
    ;(when
      ;(= *game-state* "game") 
      ;(draw-game))))

(init)

;(global scanline
  ;(fn [row]
    ;(when
      ;(= *game-state* "game") 
      ;(poke 0x3ff9 (- (% (* 0.2 *tick*) 240) 113)))))

;; <TILES>
;; 005:622cc00000000000000000000000000000000000000000000000000000000000
;; 008:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 009:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 010:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 011:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 012:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 024:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 025:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 026:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 027:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 028:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 029:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 030:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 031:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 041:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 042:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 043:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 044:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 045:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 046:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 047:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 059:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 060:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 061:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 062:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 063:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 077:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 078:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 079:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 128:5555555555555555555555555555555555555555555555555555555555555555
;; 129:0077665505555555007765555555555500776655055555550077665555555555
;; 130:5555555555667700555555505566770055555555555677005555555055667700
;; 131:0077665505555555007765550005555500575655000057560005675700000050
;; 132:5555555055667000555555005556700056565500557500005757500000500000
;; 133:0000050000057575000057550055656500076555005555550007665505555555
;; 134:0500000075765000657500005565750055555000555677005555555055667700
;; 135:5555555555555555655565656565656575757575757575750505050500050005
;; 136:5000500050505050575757575757575756565656565655565555555555555555
;; 137:0005000000550000055550000555550005555550555555555555555555555555
;; 138:0000500000055000000555000055550000555550005555500555555555555555
;; 139:0005000000555000005555500555555055555555555555555555555555555555
;; 140:0000050000005500000555500055555500555555055555555555555555555555
;; 141:0000500000005500000555500055555005555550555555555555555555555555
;; 144:5555555555555555555555550555555005555500055550000055000000050000
;; 145:5555555555555555055555500055555000555500000555000005500000005000
;; 146:5555555555555555555555555555555505555550005555500055500000050000
;; 147:5555555555555555055555550055555500555555000555500000550000000500
;; 148:5555555555555555555555555555555505555550055555000005550000005000
;; 149:5555555555555555555555500555555000555550005555000005500000005000
;; 150:5555555555555555555555550555555005555500005550000055500000055000
;; </TILES>

;; <SPRITES>
;; 000:0000900000009000000999900099999999999999999999990099999900099990
;; 001:000020000000a00000022220202222882a2228aa2a2228882022222200022220
;; 002:000020000000a00000022220002222882a2228aa2a2228880022222200022220
;; 003:000020000000a00000022220002222880a2228aa2a2228880022222200022220
;; 004:000020000000a00000022220002222882a2228aa0a2228880022222200022220
;; 005:622cc00000000000000000000000000000000000000000000000000000000000
;; 006:00f0000007670000f6f6f0000767000000f00000000000000000000000000000
;; 007:677ff00000000000000000000000000000000000000000000000000000000000
;; 008:7170000019100000717000000000000000000000000000000000000000000000
;; 009:00000000000ff00000f77f000f7778f00f7788f000f88f00000ff00000000000
;; 010:0000001000000190000011600009999000111960099966900212196006666600
;; 017:0000000000000000001010000111111012111110111111001000000000000000
;; 018:0000000000000000001010100111111012111110111111101000000000000000
;; 019:0000000000000000001010010111111112111111111111111000000100000000
;; 020:0000000000000000001010100111111012111110111111100100001000000000
;; 021:fff77000fff77000000000000000000000000000000000000000000000000000
;; 022:ff000000ff000000000000000000000000000000000000000000000000000000
;; 023:000000000000000000f0f0000f777f77f70000f0000000000000000000000000
;; 024:1119900011199000000000000000000000000000000000000000000000000000
;; 026:0606600006060000060600000006000006000000000600000000000000000000
;; 036:717777f077770000077000000000000000000000000000000000000000000000
;; 037:7177770077770000077000000000000000000000000000000000000000000000
;; 038:7177700077770000077000000000000000000000000000000000000000000000
;; 039:71777f0077770000077000000000000000000000000000000000000000000000
;; 040:7777f00077770000077000000000000000000000000000000000000000000000
;; 044:00000000000000060000066000006000000ff000000ff0000000000000000000
;; 045:0000000066666660000000660000000000000000000000000000000000666666
;; 046:0000000000000000600000006600000006000000066000000660000066660000
;; 047:0000000000000000000000000000000000000000000000000000000000000660
;; 048:0000000000000000070550700775577005755750055555500500005000000000
;; 060:0000000000000006000000660000066600a0666600a6666600a66a6600a66a66
;; 061:6666666666666666666666666666666666666166a6661111a6666166a6666666
;; 062:6666600066666600666666666666666666666666666666666666666666666666
;; 063:0000666000666660666666606666666066666660666666606666666066666660
;; 064:000077000ff777007ff7f7707777777007777877077888770778877000077000
;; 076:0066666600666666006666660066666600666666000666660006666600006666
;; 077:a66a6666666a66a6666666a66666666666666666666666666666666666666666
;; 078:66666666666666666a6666606666660066666600666666006666660066666000
;; 079:6666666000006660000006600000000000000000000000000000000000000000
;; 080:0000000000005550000555560006666500055555000555550000555500007000
;; 081:00000000000000000000000050000110550001105700007050f0007070070070
;; 092:0000666600000666000000660000000000000000000000000000000000000000
;; 093:6666666666666666666666666666666600000000000000000000000000000000
;; 094:6666600066660000666000006000000000000000000000000000000000000000
;; 096:000f0000000700000000700000000f0001100070011000700077770000000000
;; 097:0f00f70000700000007000000007110000001100000000000000000000000000
;; 112:0000000000000000000000110020011101211110111111000000000000000000
;; 113:0000000000000000110000111110011101111110001111000000000000000000
;; 114:0000000000000000110000021110002001111200001110000000000000000000
;; 128:000000000000000000000000000a222200028888000288880002888800028888
;; 129:0000000000000000000000002222222288888888888888888888888888888888
;; 130:0000000000000000000000002222a00088882000888820008888200088882000
;; 131:0220000022220000a22a0000a22a0000a22a0000222200000000000000000000
;; </SPRITES>

;; <WAVES>
;; 000:00000000ffffffff00000000ffffffff
;; 001:00012456789acdfffeecbba987643221
;; 002:024567889aabcdef12345667899abcef
;; 004:89acdeefffeedca98653211000112356
;; 005:8dffffeb866678888777899974100002
;; 006:8fffc99ab989bcba8543467655663000
;; 007:8ffd8bea88aabcb98643455785147200
;; 008:1ef6158556225646a87acbcda68dc831
;; 009:ffffffffffffffff0000000000000000
;; 010:ffffffffffffffff0000000000000000
;; 011:ffffffffffffffff0000000000000000
;; 012:ffffffffffffffff0000000000000000
;; 013:ffffffffffffffff0000000000000000
;; 014:ffffffff000000000000000000000000
;; 015:ffff0000000000000000000000000000
;; </WAVES>

;; <SFX>
;; 000:6400440024001400040004001400240024003400540064007400840084009400a400b400c400c400c400c400c400c400c400c400c400b400a400a400460000ff0000
;; 001:52002200120032005200720082009200b200b200a200a200c200c200c200c200d200d200d200e200e200f200f200f200f200f200f200f200f200f200570000000000
;; 002:41000100110021002100310041005100710071007100810091009100a100a100b100b100c100d100d100e100e100e100e100e100e100e100e100e100460000000000
;; 003:0009101a300d501e601080019012b002b014c025c026d027d047e037e017e037e037f047f057f067f077f087f096f0a6f0b6f0a6f0b6f0c6f0d6f0e6315000000000
;; 004:0390435083509330a330c330c320a330b340b350c340c310c300d300d300e300e300e300f300f300f300f300f300f300f300f300f300f300f300f300100000000000
;; 005:050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500309000000000
;; 006:060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600309000000000
;; 007:070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700389000000000
;; 008:080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800309000000000
;; 009:090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900304000000000
;; 010:0a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a00300000000000
;; 011:0b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b00300000000000
;; 012:0c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c00309000000000
;; 013:0d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d00300000000000
;; 014:0e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e00309000000000
;; 015:0f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f00309000000000
;; </SFX>

;; <PATTERNS>
;; 000:d22106000000000000000000023600000000000000000000043600000000000000000000d22006000000000000000000803406000000000000000000023600000000000000000000043600000000000000000000b00006000000000000000000403408000000000000000000023600000000000000000000043600000000000000000000b00408000000000000000000403408000000000000000000043600000000000000000000408408000000000000000000043600000000000000000000
;; 001:46611a02460000000000000060001a00000000000000000080001a00000000000000000090001a00000080001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040001a00000000000000000060001a00000000000000000080001a00000000000000000090001a00000080001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 002:44411a02460000000000000060001a00000000000000000080001a00000000000000000090001a00000080001a00000000000000000000000000000090001a000000000000000000b0001a00000090001a00000000000000000080001a00000000000000000060001a00000000000000000040001a00000000000000000060001a00000080001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 003:000000811106000000000000000000023600000000000000000000043600000000000000000000800006000000911006000000b03406000000000000000000023600000000000000000000043600000000000000000000b00006000000000000000000403406000000000000000000023600000000000000000000043600000000000000000000606406000000000000000000803406000000000000000000043600000000000000000000b08406000000000000000000043600000000000000
;; 004:daa128000000000000000000023600000000000000000000043600000000000000000000b000280000000000000000008000280000000000000000000000000000000000000000008ff028011100444128600028800028011100944128011100844128000000000000000000000000000000000000000000000000000000000000000000400028000000000000000000600028000000000000000000000000000000000000000000800028000000000000000000000000000000000000000000
;; 005:833128000000000000000000023600000000000000000000643628000000000000000000000000000000000000000000400028000000000000000000000000000000000000000000000000000000000000000000b00026000000000000000000d00026000000000000000000000000000000000000000000400028000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; </PATTERNS>

;; <TRACKS>
;; 000:500400640400540400640400240400340400141200181300101000101000000000000000000000000000000000000000ce0000
;; 001:180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; </TRACKS>

;; <PALETTE>
;; 000:1a1a38fa0c36bbcc5204fa0400ff000c0c10202d518e2e913c405591142c5d816104ff00f2f4f60cff08551881f661ba
;; </PALETTE>

