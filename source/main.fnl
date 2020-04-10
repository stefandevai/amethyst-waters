;;; -------------------------------------------------------------------------------------------- ;;;
;;; Utils                                                                                        ;;;
;;; -------------------------------------------------------------------------------------------- ;;;
(fn out-of-bounds? [object]
  (or (< object.x 0)
      (< object.y 0)
      (> (+ object.x object.w) WIDTH)
      (> (+ object.y object.h) HEIGHT)))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Shots                                                                                        ;;;
;;; -------------------------------------------------------------------------------------------- ;;;
;; List of shot types and their respective sprites
(global SHOT_TYPES { :SHOT_PLAYER 5 :SHOT_FISH 6 })

;; Draws shot with a specific sprite and position
(fn draw-shot [shot]
  (let [spr-id (. SHOT_TYPES shot.type)]
    (spr spr-id shot.x shot.y 0)))

;; Updates a shot. Returns true if it's out of bounds, returns nil otherwise
(fn update-shot [shot]
  (set shot.x (+ shot.x shot.speed))
  (out-of-bounds? shot))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Player                                                                                       ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(global *player* {
         :x 120 :y 68
         :w 8   :h 8
         :vx 0  :vy 0
         :shots []
       })

(tset *player*
      :update (fn [self]
                ;; Movement
                (if (btn 2) (set self.vx -1)
                  (btn 3) (set self.vx 1)
                  (btn 1) (set self.vy 1)
                  (btn 0) (set self.vy -1)
                  (do (set self.vx 0) (set self.vy 0)))

                ;; Shoot if Z is pressed
                (when (btnp 4)
                  (do (self:shot)
                      (trace (length self.shots))))

                ;; Positioning
                (set self.x (+ self.x self.vx))
                (set self.y (+ self.y self.vy))

                ;; Check if out of bounds and reposition player
                (if (> (+ self.x self.w) WIDTH) (set self.x (- WIDTH self.w))
                  (< self.x 0) (set self.x 0)
                  (> (+ self.y self.h) HEIGHT) (set self.y (- HEIGHT self.h))
                  (< self.y 0) (set self.y 0))

                ;; Update shots
                (each [key value (pairs self.shots)]
                  (let [should-delete? (update-shot value)]
                    (draw-shot value)
                    (when should-delete? (table.remove self.shots key))))

                ;; Drawing
                (self:draw)))

(tset *player*
      :draw (fn [self]
              (spr 1 self.x self.y 0)))

(tset *player*
      :shot (fn [self]
              (let [shot-obj { :w 5 :h 1 :speed 3 :angle 0 :type :SHOT_PLAYER }]
                (tset shot-obj :x self.x)
                (tset shot-obj :y (+ self.y 4))
                (table.insert self.shots (+ (length self.shots) 1) shot-obj))))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Game                                                                                         ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn update-game []
  (cls 3)
  (*player*:update))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Menu                                                                                         ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn update-menu []
  (cls 3)
  (print "AQUATICOS" (* 12 8) (* 3 8) 2)
  (print "Press A to play the game" (* 7 8) (* 12 8) 2)
  (when (btnp 4)
    (global MODE "game")))

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Main functions                                                                               ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(fn init []
  (load-palette "699fad3a708e2b454f111215151d1a1d3230314e3f4f5d429a9f87ede6cbf5d893e8b26fb6834c704d2b40231e151015")
  (global WIDTH 240)
  (global HEIGHT 136)
  (global MODE "menu"))

(global TIC ; Function called once every frame
  (fn []
    (if
      (= MODE "menu")
      (update-menu)

      (= MODE "game") 
      (update-game))))

(init)

