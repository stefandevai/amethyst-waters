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
(fn collide? [a b]
  (and (< a.x (+ b.x b.w))
       (> (+ a.x a.w) b.x)
       (< a.y (+ b.y b.h))
       (> (+ a.y a.h) b.y)))

;; Rounds a float number to its closest integer
(fn math.round [n]
  (math.floor (+ n 0.5)))

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
         :x 120 :y 68
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
                (tset shot-obj :y (+ self.y 4))
                (table.insert self.shots (+ (length self.shots) 1) shot-obj))))

;; Destroys shot with a certain index from *player*.shots
(fn destroy-shot [index]
  (table.remove *player*.shots index))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Enemies                                                                                      ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

;; List of enemy types and their respective sprites
(global *enemy-types* { :simple-fish 3 :stronger-fish 4 })

;; Pool containing all enemies
(global *enemy-pool* {})

;; Spawns a single enemy given a type and an optional y position value
(fn spawn-enemy [type ?y]
  (let [enemy (if (= type :simple-fish)    { :w 8.0 :h 8.0 :speed 50.0  :damage 2.0 }
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
    (spr (. *enemy-types* enemy.type) enemy.x enemy.y 0)

    ;; Deal with player-enemy collision
    (when (collide? *player* enemy) (tset *player* :health (- *player*.health enemy.damage)))

    ;; Deal with shot-enemy collision
    (each [shot-index shot (pairs *player*.shots)]
      (when (collide? shot enemy) (do (destroy-enemy index)
                                      (destroy-shot shot-index))))

    ;; Destroy enemy if it's to the left of the screen
    (when (< (+ enemy.x enemy.w) -8.0) (destroy-enemy index))))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Game                                                                                         ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn update-game-debug []
  (when (btnp 5)
    (spawn-enemy :simple-fish)))

(fn draw-hud []
  (print (.. "Energy: " *player*.health) (* 12 8) 8 12))

(fn update-bg []
  (cls)
  (map))

(fn draw-game []
  (update-enemies)
  (*player*:draw)
  (draw-hud))

(fn update-game []
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

  (global *game-state* "menu"))

(global TIC ; Function called once every frame
  (fn []
    ;; Calculate delta time
    (global *dt* (/ (- (time) *previous-time*) 1000.0))
    (global *previous-time* (time))
    (global *tick* (+ *tick* 1))
    (sync 32)

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

(global scanline
  (fn [row]
    (when
      (= *game-state* "game") 
      (poke 0x3ff9 (- (% (* 1 *tick*) 240) 113)))))

