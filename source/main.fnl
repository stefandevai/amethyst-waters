;;; -------------------------------------------------------------------------------------------- ;;;
;;; Utils                                                                                        ;;;
;;; -------------------------------------------------------------------------------------------- ;;;
(fn out-of-bounds? [object]
  (or (< object.x 0)
      (< object.y 0)
      (> (+ object.x object.w) WIDTH)
      (> (+ object.y object.h) HEIGHT)))

(fn r [a b]
  (math.random a b))
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
       })

;; Updates player and player's shots
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
                (if (> (+ self.x self.w) WIDTH) (set self.x (- WIDTH self.w))
                  (< self.x 0) (set self.x 0))
                (if (> (+ self.y self.h) HEIGHT) (set self.y (- HEIGHT self.h))
                  (< self.y 0) (set self.y 0))

                ;; Update shots
                (each [index shot (pairs self.shots)]
                  (let [should-delete? (update-shot shot)]
                    (draw-shot shot)
                    (when should-delete? (table.remove self.shots index))))

                ;; Drawing
                (self:draw)))

;; Draws player
(tset *player*
      :draw (fn [self]
              (spr 1 self.x self.y 0)))

;; Performs player shoot action
(tset *player*
      :shoot (fn [self]
              (let [shot-obj { :w 5 :h 1 :speed 3 :angle 0 :type :shot-player }]
                (tset shot-obj :x self.x)
                (tset shot-obj :y (+ self.y 4))
                (table.insert self.shots (+ (length self.shots) 1) shot-obj))))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Enemies                                                                                      ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

;; List of enemy types and their respective sprites
(global *enemy-types* { :simple-fish 3 :stronger-fish 4 })

;; Pool containing all enemies
(global *enemy-pool* {})

;; Spawns a single enemy given a type and an optional y position value
(fn spawn-enemy [type ?y]
  (let [enemy (if (= type :simple-fish) { :w 8 :h 8 :speed 2 }
               (= type :stronger-fish) { :w 8 :h 8 :speed 2 })]
    
    (tset enemy :type type)
    (tset enemy :x (+ WIDTH 8))
    (if (not ?y)
        (tset enemy :y (r 0 (- HEIGHT enemy.h)))
        (tset enemy :y ?y))
    (table.insert *enemy-pool* enemy)))

(fn update-enemies []
  ;; Update enemy position
  (each [index enemy (pairs *enemy-pool*)]
    (set enemy.x (- enemy.x enemy.speed))
    (spr (. *enemy-types* enemy.type) enemy.x enemy.y 0)

    ;; Destroy enemy if it's to the left of the screen
    (when (< (+ enemy.x enemy.w) 0) (table.remove *enemy-pool* index))))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Game                                                                                         ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn update-game-debug []
  (when (btnp 5)
    (spawn-enemy :simple-fish)))

(fn update-game []
  (cls 3)
  (update-enemies)
  (*player*:update)
  (update-game-debug))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Menu                                                                                         ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn update-menu []
  (cls 3)
  (print "AQUATICOS" (* 12 8) (* 3 8) 2)
  (print "Press A to play the game" (* 7 8) (* 12 8) 2)
  (when (btnp 4)
    (global *game-state* "game")))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Main functions                                                                               ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn init []
  (load-palette "699fad3a708e2b454f111215151d1a1d3230314e3f4f5d429a9f87ede6cbf5d893e8b26fb6834c704d2b40231e151015")
  (global WIDTH 240)
  (global HEIGHT 136)
  (spawn-enemy :simple-fish)
  (global *game-state* "menu"))

(global TIC ; Function called once every frame
  (fn []
    (if
      (= *game-state* "menu")
      (update-menu)

      (= *game-state* "game") 
      (update-game))))

(init)

