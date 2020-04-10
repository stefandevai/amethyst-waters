;;; -------------------------------------------------------------------------------------------- ;;;
;;; Shots                                                                                        ;;;
;;; -------------------------------------------------------------------------------------------- ;;;
;; List of shot types and their respective sprites
(global SHOT_TYPES { :SHOT_PLAYER 5 :SHOT_FISH 6 })

;; Default shot
(global *player-shot* { :angle 0 :type :SHOT_PLAYER :speed 3 })

;;; -------------------------------------------------------------------------------------------- ;;;
;;; Player                                                                                       ;;;
;;; -------------------------------------------------------------------------------------------- ;;;

(global *player* {
         :x 120 :y 68
         :vx 0 :vy 0
         :shots []
       })

(tset *player*
      :update (fn [self]
               (if (btn 2) (set self.vx -1)
                 (btn 3) (set self.vx 1)
                 (btn 1) (set self.vy 1)
                 (btn 0) (set self.vy -1)
                 (do (set self.vx 0) (set self.vy 0)))

               (set self.x (+ self.x self.vx))
               (set self.y (+ self.y self.vy))
               (spr 1 self.x self.y 0)))

(tset *player*
      :shot (fn [self]
              (let [shot-obj *player-shot*]
                (table.insert self.shots (+ #self.shots 1) shot-obj))))

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
  (global MODE "menu"))

(global TIC ; Function called once every frame
  (fn []
    (if
      (= MODE "menu")
      (update-menu)

      (= MODE "game") 
      (update-game))))

(init)

