;; title:  Amethyst Waters
;; author: Stefan Devai
;; desc:   Explore deep sea caverns with your submarine!
;; script: fennel
;; input: keyboard
;; saveid: AmethystWaters

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

;; Shortcuts for trigonometric functions
(fn sin [a]
  (math.sin a))

(fn cos [a]
  (math.cos a))

;; Sets the palette indice i to specified rgb
;; or return the colors if no rgb values are declared.
;; See: <https://github.com/nesbox/TIC-80/wiki/code-examples-and-snippets#pal-function>
(fn pal [i r g b]
  (if (and (not r) (not g) (not b))
      (values (peek (+ 0x3fc0 (* i 3)))
              (peek (+ 0x3fc0 (* i 3) 1))
              (peek (+ 0x3fc0 (* i 3) 2)))
      (do (var rc r)
          (var gc g)
          (var bc b)
          (when (or (not rc) (< rc 0)) (set rc 0))
          (when (or (not gc) (< gc 0)) (set gc 0))
          (when (or (not bc) (< bc 0)) (set bc 0))
          (when (> rc 255) (set rc 255))
          (when (> gc 255) (set gc 255))
          (when (> bc 255) (set bc 255))
          (poke (+ 0x3fc0 (* i 3) 2) b)
          (poke (+ 0x3fc0 (* i 3) 1) g)
          (poke (+ 0x3fc0 (* i 3)) r))))

;; Returns true if the object is outsite the screen boundaries
(fn out-of-bounds? [object]
  (or (< object.x 0)
      (< object.y 0)
      (> (+ object.x object.w) +width+)
      (> (+ object.y object.h) +height+)))

;; Applies a parallax with a factor and a initial position p0
(fn parallax [p0 factor axis]
  (if (= axis :x) (+ p0 (* *cam*.x factor))
      (= axis :y) (+ p0 (* *cam*.y factor))))

;; Draws a sprite that loops in the x and y axis
(fn loop-spr [id x y w h pfactor ?colorkey ?flip]
  (spr id (- (% (parallax x pfactor :x) (+ 240 (* w 8))) (* w 8))
          (- (% (parallax y pfactor :y) (+ 136 (* h 8))) (* h 8)) 
          (or ?colorkey 0) 1 (or ?flip 0) 0 w h))

;; Shortcut for math.random
(fn r [a b]
  (math.random a b))

;; Get a random value from a list
(fn rvalue [l]
  (. l (r 1 (length l))))

;; Return true if list has a certain element
(fn has-element? [l e]
  (var found false)
  (each [k v (pairs l)]
    (when (= v e)
      (set found true)
      (lua :break)))
  found)

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
  (let [x (- (+ obj.x obj.vx) (math.ceil *cam*.ox))
        y (- (+ obj.y obj.vy) *cam*.oy)
        w obj.w
        h obj.h]
  (values (> (mget (// (% x 1920) 8) (// y 8)) 127)                       ; top-left
          (> (mget (// (+ (% x 1920) (- w 1)) 8) (// y 8)) 127)           ; top-right
          (> (mget (// (% x 1920) 8) (// (+ y (- h 1)) 8)) 127)                 ; bottom-left
          (> (mget (// (+ (% x 1920) (- w 1)) 8) (// (+ y (- h 1)) 8)) 127))))  ; bottom-right

;; Resolves collision between an object and the map
(fn rcollision [obj]
  (let [(tl tr bl br) (mcollisions obj)]
   (local ox (- (+ obj.x obj.vx) (math.ceil *cam*.ox)))
   (local oy (- (+ obj.y obj.vy) (math.ceil *cam*.oy)))
   (local ow (- (+ obj.x obj.vx obj.w) (math.ceil *cam*.ox)))
   (local oh (- (+ obj.y obj.vy obj.h) *cam*.oy))

   (var sy 0) ; sign of y movement
   (var ix 0) ; intersection in the x axis
   (var iy 0) ; intersection in the y axis
   (var in 0) ; number of sides with intersection

   (when tl (inc in))
   (when tr (inc in))
   (when bl (inc in))
   (when br (inc in))

   ;; Deal with all sides collision if obj has a crush method
   (when (and (= in 4) (<= obj.x 1) obj.crush) (obj:crush))

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
       (do (trace "bad collision") (set obj.vx 0) (set obj.vy 0))))) 

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

(fn pseudor [x y] (fract (* (sin (dot [(+ x seed.px) (+ y seed.py)] [seed.fx seed.fy])) seed.a)))

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
    (set seed.a (+ 500 (* (fract (sin (* (+ i 0.512) 512 725.63))) 1000)))
    (set sum (+ sum (perlin (* x (+ i 1)) (* y (+ i 1))))))
  (/ sum iterations))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Particles                                                                                    ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

(fn init-emitters []
  (global *particle* { :x 0 :y 0
                       :scale 1
                       :lifetime 0 ; Time left alive
                       :sprite 0   ; Sprite id
                       :dspl 0 ; Random displacement
                       :speed { :x 0 :y 0 } } )

  (tset *particle*
        :update
        (fn [self]
            (inc self.x (* self.speed.x *dt*))
            (inc self.y (* self.speed.y *dt*))
            (spr self.sprite self.x self.y 0 self.scale)))

  (global *bubble-particle* (deepcopy *particle*))
  (tset *bubble-particle*
        :update
        (fn [self]
            (inc self.x (* self.speed.x (sin (+ (* *tick* 0.1) self.dspl)) 3 *dt*))
            (inc self.y (* (- self.speed.y *cam*.speedy) *dt*))

            (var id 19)
            (if (< self.lifetime 700)
                (set id 17)
                (< self.lifetime 1600)
                (set id 18))
            (loop-spr id self.x self.y 1 1 0.8 15)))

  (global *pixel-particle* (deepcopy *particle*))
  (tset *pixel-particle*
        :update
        (fn [self]
            (var color 11)
            (if (< self.lifetime 300)
                (set color 6)
                (< self.lifetime 600)
                (set color 8))
            (inc self.x (* (- self.speed.x *cam*.speedx) *dt*))
            (inc self.y (* (- self.speed.y *cam*.speedy) *dt*))
            (pix self.x self.y color)))

  (global *bexplosion-particle* (deepcopy *particle*))
  (tset *bexplosion-particle*
        :update
        (fn [self]
            (var color 11)
            (if (< self.lifetime 600)
                (set color 6))
            (inc self.x (+ (* (- self.speed.x *cam*.speedx) *dt*) (sin (* 0.4 (+ *tick* self.speed.y)))))
            (inc self.y (* (+ self.speed.y *cam*.speedy) *dt*))
            (pix self.x self.y color)))

  (global *pexplosion-particle* (deepcopy *particle*))
  (tset *pexplosion-particle*
        :update
        (fn [self]
            (var color 11)
            (if (< self.lifetime 600)
                (set color 6))
            (inc self.x (+ (* (- self.speed.x *cam*.speedx) *dt*) (sin (* 0.4 (+ *tick* self.speed.y)))))
            (inc self.y (* (+ self.speed.y *cam*.speedy) *dt*))
            (pix self.x self.y color)))

  (global *bcexplosion-particle* (deepcopy *particle*))
  (tset *bcexplosion-particle*
        :update
        (fn [self]
            ;(trace self.lifetime)
            (var color 15)
            (if (< self.lifetime 200)
                (set color 6)
                (< self.lifetime 400)
                (set color 7)
                (< self.lifetime 650)
                (set color 7))
            (when (= (% *tick* 4) 0)
              (dec self.scale 2))
            (dec self.x (* *cam*.speedx *dt*))

            (circ self.x self.y self.scale color)))

  (global *cexplosion-particle* (deepcopy *particle*))
  (tset *cexplosion-particle*
        :update
        (fn [self]
            ;(trace self.lifetime)
            (var color 12)
            (if (< self.lifetime 200)
                (set color 6)
                (< self.lifetime 400)
                (set color 8)
                (< self.lifetime 650)
                (set color 11))
            (when (= (% *tick* 4) 0)
              (dec self.scale 2))
            (dec self.x (* *cam*.speedx *dt*))

            (circ self.x self.y self.scale color)))

  (global *particle-types* { :bcexplosion *bcexplosion-particle* :bexplosion *bexplosion-particle* :cexplosion *cexplosion-particle* :bubble *bubble-particle* :pixel *pixel-particle* :pexplosion *pexplosion-particle* })

  (global *emitters* [])
  (global *emitter* { :x 0 :y 0 ; Emitter position
                      :sprites [ 0 ] ; Which sprites use for particles
                      :emition-delay 10 ; At which rate particles are emitted (miliseconds)
                      :elapsed-since-emition 0 ; How much time has passed since last emission
                      :pos-range { :xmin 0 :xmax 0 :ymin 0 :ymax 0 } ; Variation of particle position in relation to the emiter's
                      :speed-range { :xmin -100 :xmax 100 :ymin -100 :ymax 100 } ; Variation of particle speed
                      :scale-range { :min 1 :max 1 } ; Variation of particle scale
                      :lifetime-range { :min 500 :max 1000 } ; Variation of particle's lifetime in ms
                      :type :bubble ; Particle type
                      :modifier nil ; Optional emitter modifier function
                      :particle-modifier nil ; Optional particle modifier function
                      :num-particles nil ; Optional number of particles value
                      :particles [] }) ; Table to hold particles
  
  (tset *emitter*
        :emit
        (fn [self ?type]
          (var particle (deepcopy (. *particle-types* (or ?type self.type))))
          (set particle.x (+ self.x (r self.pos-range.xmin self.pos-range.xmax)))
          (set particle.y (+ self.y (r self.pos-range.ymin self.pos-range.ymax)))
          (set particle.speed.x (r self.speed-range.xmin self.speed-range.xmax))
          (set particle.speed.y (r self.speed-range.ymin self.speed-range.ymax))
          (set particle.sprite (. self.sprites (r 1 (length self.sprites))))
          (set particle.lifetime (r self.lifetime-range.min self.lifetime-range.max))
          (set particle.scale (r self.scale-range.min self.scale-range.max))

          (when self.particle-modifier
            (self:particle-modifier particle))
          
          (table.insert self.particles (+ (length self.particles) 1) particle)))

  (tset *emitter*
        :update
        (fn [self]
          (if (>= self.elapsed-since-emition self.emition-delay)
              (do (self:emit)
                  (set self.elapsed-since-emition 0))
              (inc self.elapsed-since-emition (* *dt* 1000)))

          ;; Optional emitter modifier function
          (when self.modifier (self:modifier self))

          (each [i particle (ipairs self.particles)]
            (particle:update)
            (if (<= particle.lifetime 0)
                (table.remove self.particles i)
                (dec particle.lifetime (* *dt* 1000))))))

  ;; Delete all particles in the emitter
  (tset *emitter*
        :clear
        (fn [self]
          (each [k (pairs self.particles)]
            (tset self.particles k nil))))

  ;; Circle explosion
  (global *cexplosion-emitter* (deepcopy *emitter*))
  (set *cexplosion-emitter*.type :cexplosion)

  ;; Boss explosion
  (global *bexplosion-emitter* (deepcopy *emitter*))
  (set *bexplosion-emitter*.type :bexplosion)
  (set *bexplosion-emitter*.num-particles 7)
  (set *bexplosion-emitter*.lifetime-range { :min 700 :max 1000 })
  (set *bexplosion-emitter*.scale-range { :min 3 :max 6 })
  (set *bexplosion-emitter*.pos-range { :xmin 0 :xmax 6 :ymin 2 :ymax 8 })
  (set *bexplosion-emitter*.speed-range { :xmin -5 :xmax 5 :ymin -50 :ymax -40 })
  (tset *bexplosion-emitter*
        :update
        (fn [self]
          (when (> self.num-particles 0)
            (self:emit)
            (when (> self.num-particles 4)
              (self:emit :bcexplosion))
            (dec self.num-particles))

          (dec self.x (* *cam*.speedx *dt*))

          (each [i particle (ipairs self.particles)]
            (particle:update)
            (if (<= particle.lifetime 0)
                (table.remove self.particles i)
                (dec particle.lifetime (* *dt* 1000))))))

  ;; Pixel explosion
  (global *pexplosion-emitter* (deepcopy *emitter*))
  (set *pexplosion-emitter*.type :pexplosion)
  (set *pexplosion-emitter*.num-particles 7)
  (set *pexplosion-emitter*.lifetime-range { :min 700 :max 1000 })
  (set *pexplosion-emitter*.scale-range { :min 3 :max 6 })
  (set *pexplosion-emitter*.pos-range { :xmin 0 :xmax 6 :ymin 2 :ymax 8 })
  (set *pexplosion-emitter*.speed-range { :xmin -5 :xmax 5 :ymin -50 :ymax -40 })
  (tset *pexplosion-emitter*
        :update
        (fn [self]
          (when (> self.num-particles 0)
            (self:emit)
            (when (> self.num-particles 4)
              (self:emit :cexplosion))
            (dec self.num-particles))

          (dec self.x (* *cam*.speedx *dt*))

          (each [i particle (ipairs self.particles)]
            (particle:update)
            (if (<= particle.lifetime 0)
                (table.remove self.particles i)
                (dec particle.lifetime (* *dt* 1000))))))

  (global *bubble-emitter* (deepcopy *emitter*))
  (set *bubble-emitter*.emition-delay 300)
  (set *bubble-emitter*.type :bubble)
  (set *bubble-emitter*.lifetime-range { :min 3300 :max 3800 })
  (set *bubble-emitter*.speed-range { :xmin -30 :xmax 30 :ymin -40 :ymax -20 })
  (set *bubble-emitter*.particle-modifier
       (fn [particle]
         (set particle.dspl (r 0 100))))
  
  (global *bg-bubbles* (deepcopy *bubble-emitter*))
  (set *bg-bubbles*.x 120)
  (set *bg-bubbles*.y 136)
  (set *bg-bubbles*.pos-range { :xmin -120 :xmax 120 :ymin 0 :ymax 0 })

  (global *motor-emitter* (deepcopy *emitter*))
  (set *motor-emitter*.pos-range { :xmin 0 :xmax 0 :ymin 2 :ymax 4 })
  (set *motor-emitter*.speed-range { :xmin -50 :xmax -10 :ymin -2 :ymax 2 })
  (set *motor-emitter*.type :pixel)
  (set *motor-emitter*.modifier
       (fn [emitter]
         (set emitter.x (+ *player*.x 1))
         (set emitter.y (+ *player*.y 2)))))

(fn update-emitters []
  (each [k emitter (ipairs *emitters*)]
    (emitter:update)
    (when (and (<= emitter.num-particles 0) (= (length emitter.particles) 0))
          (table.remove *emitters* k))))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Cave walls                                                                                   ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

(fn init-cave-walls []
  ;; Displacement for perlin noise generation
  (global *pdspl* {:h1 (r 0 1000) :h2 (r 0 1000)})

  ;; Last top wall height
  (global last-h2 0)

  ;; Last bottom wall height
  (global last-h1 0)

  ;; Sprite ids for sprites used in map generation
  (global *stalagmites* [136 137 138 139 140 141])
  (global *stalagtites* [135 144 145 146 147 148 149 150])

  ;; Minimum height of a wall
  (global ymin 0)

  ;; Maximum height of a wall
  (global ymax 5))

;; Perlin noise height generation
(fn pn [y]
  (math.round (+ ymin (* (perlinf y ymax) (- ymax ymin)))))

;; Simple noise height generation
(fn sn [y]
  (r ymin ymax))

;; Generate cave walls
(fn generate-cave-walls [from to f]
  (for [i from to 1]
    (let [h1 (math.min (- 15 last-h2) (f (+ i *pdspl*.h1 *last-block-generated*)))
          h2 (math.min (- 15 last-h1) (- 14 h1) (f (+ i *pdspl*.h2 *last-block-generated*)))]
      (global last-h1 h1)
      (global last-h2 h2)

      ;; Set bottom walls
      ;(local bottom-head (r 137 141))
      ;(mset i (- 17 h1) bottom-head)
      (for [j (- 17 h1) 17 1]
        (mset i j 128))
      
      ;; Set top walls
      ;(local top-head (r 144 150))
      ;(mset i (- h2 1) top-head)
      (for [j 0 (- h2 1) 1]
        (mset i j 128)))))

;; Sets all map tiles from block to 0
(fn clear-map-block [block]
  (for [i (* block 30) (- (* (+ block 1) 30) 1) 1]
    (for [j 0  16]
      (mset i j 0))))

;; Gets surroundings if block at x y is collidable.
;; For this game I chose arbitrarily that every tile
;; with id > 127 is collidable.
(fn get-surroundings-if-collidable [x y]
  (let [v (mget x y)]
    (when (> v 127)
      (values v                           ; value
              (mget x (- y 1))            ; top
              (mget (+ x 1) (- y 1))      ; top-right
              (mget (+ x 1) y)            ; right
              (mget (+ x 1) (+ y 1))      ; bottom-right
              (mget x (+ y 1))            ; bottom
              (mget (- x 1) (+ y 1))      ; bottom-left
              (mget (- x 1) y)            ; left
              (mget (- x 1) (- y 1))))))  ; top-left

;; Adds decoration to a map block
(fn decorate-block [from to]
  (for [j 0 17 1]
    (for [i from to 1]
      (let [(v t tr r br b bl l tl) (get-surroundings-if-collidable i j)]
        (when (= v 128)
              ;; Add stalagmites
              (if (and (= l t r 0) (> j 0))
              ;(mset i j (rvalue *stalagmites*))
              (mset i j 136)
              ;; Add spiky top right border
              (and (= r t 0) (> j 0))
              (mset i j 134)
              ;; Add spiky top left border
              (and (= l t 0) (> j 0))
              (mset i j 133)
              ;; Add top spiky border
              (and (= t 0) (= l 133) (= r 134) (> j 0))
              (mset i j 136)
              ;; Add top-right normal border
              (and (= t 0) (= r 0) (not= l 0) (not= b 0) (> j 0))
              (mset i j 156)
              ;; Add top-left normal border
              (and (= t 0) (= l 0) (not= r 0) (not= t 0) (> j 0))
              (mset i j 157)
              ;; Middle entrance border
              (and (= t 0) (not= l 0) (not= r 0) (not= tr 0) (not= tl 0) (> j 0))
              (mset i j 142)
              ;; Add normal top border
              (and (= t 0) (> j 0))
              (mset i j 153)

              ;; Diagonal top-right
              (and (= t 134) (or (= r 0) (= r 134)))
              (mset i j 150)
              ;; Diagonal top-left
              (and (= t 133) (or (= l 0) (= l 133)))
              (mset i j 149)

              ;; Add stalagtites
              (and (= l b r 0) (< j 17))
              ;(mset i j (rvalue *stalagtites*))
              (mset i j 135)
              ;; Add spiky bottom right border
              (and (= r b 0) (< j 17))
              (mset i j 132)
              ;; Add spiky bottom left border
              (and (= l b 0) (< j 17))
              (mset i j 131)
              ;; Add bottom-right normal border
              (and (= b 0) (= r 0))
              (mset i j 159)
              ;; Add bottom-left normal border
              (and (= b 0) (= l 0))
              (mset i j 158)
              ;; Middle entrance border
              (and (= b 0) (not= l 0) (not= r 0) (not= br 0) (not= bl 0))
              (mset i j 143)
              ;; Add normal bottom tile
              (and (= b 0) (< j 17))
              (mset i j 152)

              ;; Add column border tile
              (= l r 0)
              (mset i j 151)
              ;; Normal right tile
              (or (= r 0) (and (>= r 131) (<= r 136)))
              (mset i j 155)
              ;; Normal left tile
              (or (= l 0) (and (>= l 131) (<= l 136)))
              (mset i j 154)))))))

;; Generates cave walls if needed
(fn update-cave-walls []
  ;; Generate walls for next block
  (local current-block (// (math.abs *cam*.x) 240))
  (local from (+ current-block 2))

  ;; Generate a block if cam is 2 blocks away from last generated block
  (when (< *last-block-generated* from)
    ;; 35% of possibility to increase wall size
    ;; 65% of decrease
    (global n (r 0 100))
    (if (and (< ymax 9) (<= n 35))
        (incg ymax)
        (> ymax 2)
        (decg ymax))

    ;; Select a noise function
    (var noisef sn)
    (when (= (r 0 1) 0)
          (set noisef pn))

    (global *last-block-generated* from)
    (when (> from 7) (clear-map-block (% from 8)))


    ;; Add from/to which tile to start generation
    (global from-tile (* (% from 8) 30))
    (global to-tile (- (* (+ (% from 8) 1) 30) 1))
    (generate-cave-walls from-tile to-tile noisef)

    ;; Decorate 1 block before
    (if (= (% from 8) 0)
        (decorate-block 210 239)
        (decorate-block (- from-tile 30) (- to-tile 30)))))
  
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

(fn init-shots []
  (global *basic-shot* { :x 0 :y 0 :w 5 :h 1 :speedx 2 :speedy 0 :damage 2 :spr 261 :rot 0 })
  (global *blue-shot* { :x 0 :y 0 :w 8 :h 2 :speedx 8 :speedy 0 :damage 8 :spr 306 :flip 0 :rot 0 :curve 0 })

  ;; Implement update and draw methods
  (tset *basic-shot*
        ;; Updates a shot. Returns true if it's out of bounds, returns nil otherwise
        :update (fn [self]
                  (inc self.y self.speedy)
                  (inc self.x self.speedx)
                  (out-of-bounds? self)))
        
  (tset *basic-shot*
        ;; Draws shot with a specific sprite and position
        :draw (fn [self]
                (spr self.spr self.x self.y 0 1 0 self.rot)))

  ;; Implement update and draw methods
  (tset *blue-shot*
        ;; Updates a shot. Returns true if it's out of bounds, returns nil otherwise
        :update (fn [self]
                  (dec self.speedy (* self.curve *dt*))
                  (inc self.x self.speedx)
                  (inc self.y self.speedy)
                  (out-of-bounds? self)))
        
  (tset *blue-shot*
        ;; Draws shot with a specific sprite and position
        :draw (fn [self]
                (spr self.spr self.x self.y 0 1 self.flip self.rot))))

;; Creates a shot of a certain type
(fn create-shot [type axis]
  (if (= type :basic-shot)
      (do (sfx 3 50 -1 3 7)
          (if (= axis :y)
            (do (local shot1 (deepcopy *basic-shot*))
                (local shot2 (deepcopy *basic-shot*))
                (set shot1.speedy shot1.speedx)
                (set shot1.rot 1)
                (set shot1.speedx 0)
                (set shot2.speedy (- 0 shot2.speedx))
                (set shot2.rot 1)
                (set shot2.flip 1)
                (set shot2.speedx 0)
                [shot1 shot2])
            (deepcopy *basic-shot*)))

      (= type :blue-shot)
      (do (sfx 3 20 -1 3 8 3)
          (if (= axis :y)
            (do (local shot1 (deepcopy *blue-shot*))
                (local shot2 (deepcopy *blue-shot*))
                (set shot1.speedy shot1.speedx)
                (set shot1.rot 1)
                (set shot1.speedx 0)
                (set shot2.speedy (- 0 shot2.speedx))
                (set shot2.rot 3)
                (set shot2.flip 1)
                (set shot2.speedx 0)
                [shot1 shot2])
            
            (deepcopy *blue-shot*)))

      (and (= type :triple-shot) (= axis :x))
      (do (sfx 7 30 -1 3 8 3)
          (local shot1 (deepcopy *blue-shot*))
          (set shot1.speedy 2)
          (set shot1.curve 2)
          (set shot1.spr 307)
          (set shot1.flip 2)
          (set shot1.damage 2)
          (local shot2 (deepcopy *blue-shot*))
          (local shot3 (deepcopy *blue-shot*))
          (set shot3.speedy -2)
          (set shot3.curve -2)
          (set shot3.spr 307)
          [shot1 shot2 shot3])))

      ;(= type :super-shot)
      ;(do (sfx 3 50 -1 3 7)
          ;(deepcopy *blue-shot*))))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Player                                                                                       ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

(fn init-player []
  (init-shots)

  ;(pmem 2 1)
  ;(pmem 3 1)
  ;(pmem 4 1)
  (fn get-available-shots []
    (local available-shots [ :basic-shot ])
    (when (= (pmem 2) 1)
      (table.insert available-shots (+ (length available-shots) 1) :blue-shot))
    (when (= (pmem 3) 1)
      (table.insert available-shots (+ (length available-shots) 1) :triple-shot))
    ;(when (= (pmem 4) 1)
      ;(table.insert available-shots (+ (length available-shots) 1) :super-shot))
    available-shots)


  ;; Player table object
  (global *player* {
           :x 32 :y 68
           :w 8   :h 8
           :vx 0  :vy 0
           :shots []
           :health 100
           :state :none
           :hurt-timer 0
           :points 0
           :available-shots (get-available-shots)
           :current-shot :basic-shot
           :emitter (deepcopy *motor-emitter*)
         })

  (set *player*.current-shot (. *player*.available-shots (length *player*.available-shots)))
  ;(set *player*.current-shot :triple-shot)

  ;; Player animations
  (tset *player*
        :animator {
          :current-animation :moving
          :current-index 1
          :elapsed 0
          :speed 100
        })

  (if (= *player*.current-shot :basic-shot)
      (set *player*.target-points 15)
      (= *player*.current-shot :blue-shot)
      (set *player*.target-points 50)
      (= *player*.current-shot :triple-shot)
      (set *player*.target-points 0))

  (tset *player*
        :change-outfit
        (fn [self shot]
  (if (= shot :basic-shot)
      (do (set self.animator.animations
           { :moving [ 257 258 259 260 ]
             :hurt [ 257 256 258 256 259 256 260 256 ] }))
      (= shot :blue-shot)
      (do (set self.animator.animations
           { :moving [ 400 401 402 403 ]
             :hurt [ 400 256 401 256 402 256 403 256 ] }))
      (= shot :triple-shot)
      (do (set self.animator.animations
           { :moving [ 432 433 434 435 ]
             :hurt [ 432 256 433 256 434 256 435 256 ] })))))

  (*player*:change-outfit *player*.current-shot)

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

                  ;; Shoot forward if Z is pressed
                  (if (and (btnp 4 10 10) (not (btn 5)))
                      (self:shoot :x)

                      ;; Shoot up and down if X is pressed
                      (btnp 5 10 10)
                      (self:shoot :y))

                  ;; Change weapon if A or S is pressed
                  (if (btnp 6)
                      (set self.current-shot (self:change-shot :p))
                      (btnp 7)
                      (set self.current-shot (self:change-shot :n)))

                  ;; Positioning
                  (set self.x (+ self.x self.vx))
                  (set self.y (+ self.y self.vy))

                  ;; Check if out of bounds and reposition player
                  (if (> (+ self.x self.w) +width+) (set self.x (- +width+ self.w))
                    (< self.x 0) (set self.x 0))
                  (if (> (+ self.y self.h) +height+) (set self.y (- +height+ self.h))
                    (< self.y 0) (set self.y 0))))

  (set *player*.change-shot
    (fn [self dir]
      (var changed-shot self.current-shot)
      (each [k v (ipairs self.available-shots)]
        (when (= v self.current-shot)
          (sfx 5 30 -1 3 8 3)
          (set changed-shot
            (if (= dir :n)
                (. self.available-shots (+ (% k (length self.available-shots)) 1))
                (= dir :p)
                (. self.available-shots (if (= k 1)
                                            (length self.available-shots)
                                            (- k 1)))))))
      (self:change-outfit changed-shot)
      changed-shot))

  ;; Draws player (called on OVR)
  (tset *player*
        :draw (fn [self]
                ;; Update/draw shots
                (each [index shot (pairs self.shots)]
                  (let [should-delete? (shot:update)]
                    (shot:draw)
                    (when should-delete?
                      (table.remove self.shots index))))

                ;; Motor emitter
                (when (not (= self.state :dead))
                  (self.emitter:update)

                  (animate self)
                  (spr (get-animation-frame self.animator) self.x self.y 0))))

  ;; Performs player shoot action
  (fn store-shot [shot]
    (set shot.x *player*.x)
    (set shot.y (+ *player*.y 4 (r -2 2)))
    (table.insert *player*.shots (+ (length *player*.shots) 1) shot))  

  (tset *player*
        :shoot (fn [self axis]
                (let [shot-obj (create-shot self.current-shot axis)]
                  ;; If multiple shots are shot at once, store each one
                  (when shot-obj
                    (if (> (length shot-obj) 1)
                        (each [i shot (pairs shot-obj)]
                          (store-shot shot))
                        (store-shot shot-obj))))))

  ;; Hurts player 
  (tset *player*
        :hurt (fn [self damage]
                (when (and (not= self.state :hurt) (not= *game-state* "game-over"))
                      ;(dec self.health 0)
                      (dec self.health (math.max 1 (r (- damage 5) damage)))
                      (if (<= self.health 0)
                          (do (global *time-elapsed* 0)
                              (set self.state :dead)
                              (local emitter (deepcopy *pexplosion-emitter*))
                              (set emitter.x self.x)
                              (set emitter.y self.y)
                              (set emitter.num-particles 17)
                              (set emitter.lifetime-range { :min 800 :max 1200 })
                              (set emitter.scale-range { :min 6 :max 9 })
                              (set emitter.pos-range { :xmin 0 :xmax 16 :ymin 2 :ymax 18 })
                              (table.insert *emitters* emitter)
                              (sfx 4 30 -1 3 15 -1)
                              ;; Stop camera
                              (set *cam*.speedx 0)
                              (music 1)
                              (global *game-state* "game-over"))
                          (do (sfx 4 60 -1 3 88)
                              ;;; Increase game speed when damaged
                              ;(when (< *cam*.speedx *cam*.max-speed) (inc *cam*.speedx 5))
                              (global *shake* 18)
                              (set self.animator.current-animation :hurt)
                              (set self.state :hurt)
                              (set self.hurt-timer 90))))))

  (tset *player*
        :crush (fn [self]
                 (self:hurt 105))))

;; Destroys shot with a certain index from *player*.shots
(fn destroy-shot [index]
  (table.remove *player*.shots index))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Amethysts                                                                                    ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

(fn init-goods []
  (global goods []))

(fn spawn-good [type x y]
  ;; Absolute position
  (let [good { :x (r (- (math.round x) 10) (+ (math.round x) 10))
               :y (r (- (math.round y) 10) (+ (math.round y) 10))
               :w 8 :h 8 :collected? false
               :type type
               :rfactor (r 0 100)}] ; Random factor for the sin period when updating
    (when (= type :amethyst)
      (set good.animator {
        :current-animation :shining
        :current-index 1
        :elapsed 0
        :speed 60
        :animations { :shining [ 277 277 277 277 277 277 277 277 277 288 289 290 291 278 ] }
      }))
    (table.insert goods (+ (length goods) 1) good)))

(fn spawn-goods [x y points]
  (local rn (r 0 100))
  (when (and (< rn 30) (< *player*.health 100))
    (spawn-good :life x y))
  (for [i 0 (r 0 points) 1]
    (spawn-good :amethyst x y)))

(fn update-goods []
  (each [index good (pairs goods)]
    (dec good.x (* *cam*.speedx *dt*))

    (match good.type
      :amethyst (do (animate good)
                    (spr (get-animation-frame good.animator)
                         good.x
                         (+ good.y (* (sin (* (+ *tick* good.rfactor) 0.05)) 2))
                         0))

      :life (spr 387 good.x (+ good.y (* (sin (* (+ *tick* good.rfactor) 0.05)) 2)) 0))

    ;; Collect amethysts if collision occurs
    (when (bcollides? *player* good)
      (set good.collected? true)
      (match good.type
        :amethyst (do (sfx 5 70 -1 3 8 3)
                  (inc *player*.points))
        :life (do (sfx 8 64 -1 3 8 -2)
                  (inc *player*.health (math.min 20 (- 100 *player*.health))))))

    ;; Remove when out of bounds
    (when (or (< (+ good.x good.w) 0) good.collected?)
      (table.remove goods index))))

;(fn collect-amethyst []
  ;)

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Enemies                                                                                      ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

;; Spawns a single enemy given a type and optionals x and y position values
;; Returns the enemy
(fn spawn-enemy [type ?x ?y]
  (let [enemy (if (= type :simple-fish) (deepcopy *simple-fish*)
                  (= type :ghost-fish) (deepcopy *ghost-fish*)
                  (= type :stronger-fish) (deepcopy *stronger-fish*)
                  (= type :shooter-fish) (deepcopy *shooter-fish*)
                  (= type :energy-ball) (deepcopy *energy-ball*)
                  (= type :follower) (deepcopy *follower*)
                  (= type :anglerfish) (deepcopy *anglerfish*)
                  (= type :snake) (deepcopy *snake*)
                  (= type :snail) (deepcopy *snail*)
                  (= type :easy-snail) (deepcopy *easy-snail*)
                  (= type :guard) (deepcopy *guard*))]
    (tset enemy :type type)
    (tset enemy :x (or ?x (+ +width+ 8.0)))
    (tset enemy :y (or ?y (r 0 (- +height+ enemy.h))))
    (table.insert *enemy-pool* enemy)
    enemy))

(fn init-enemies []
  ;; List of enemy types 
  (global *enemy-types* [ :simple-fish :stronger-fish ])
  (global *enemy* { :w 8 :h 8 :speedx 50 :speedy 0 :damage 2.0 :health 2.0 :points 1 :emitter :pexplosion :flicker 0 :no-flicker false })
  (set *enemy*.animator
       { :current-animation :moving
         :current-index 1
         :elapsed 0
         :speed 150
         :animations 
           { :moving nil }})

  (set *enemy*.update
       (fn [self]
          (inc self.y (* self.speedy *dt*))
          (dec self.x (* self.speedx *dt*))))

  (set *enemy*.draw
       (fn [self]
         (animate self)
         (if (and (> self.flicker 0) (< (% *tick* 5) 3))
             (do (dec self.flicker))
             (spr (get-animation-frame self.animator) self.x self.y 0))))

  ;; Simple fish
  (global *simple-fish* (deepcopy *enemy*))
  (set *simple-fish*.w 7)
  (set *simple-fish*.h 3)
  (set *simple-fish*.animator.animations.moving [ 292 293 294 293 292 295 296 295 ])
  (set *simple-fish*.update
       (fn [self]
          (dec self.x (* (+ self.speedx *cam*.speedx) *dt*))
          (inc self.y (* 0.2 (sin (* 0.05 (+ *tick* self.y)))))))

  ;; Ghost fish
  (global *ghost-fish* (deepcopy *simple-fish*))
  (set *ghost-fish*.damage 5)
  (set *ghost-fish*.animator.animations.moving [ 377 378 379 378 377 380 381 380 ])

  ;; Stronger fish
  (global *stronger-fish* (deepcopy *enemy*))
  (set *stronger-fish*.speedx 30)
  (set *stronger-fish*.damage 5)
  (set *stronger-fish*.health 4)
  (set *stronger-fish*.points 1)

  (set *stronger-fish*.update
        (fn [self]
          (dec self.x (* (+ self.speedx *cam*.speedx) *dt*))
          (inc self.y (* 0.5 (sin (* 0.05 (+ *tick* self.y)))))))

  (set *stronger-fish*.animator.animations.moving [ 273 274 275 276 275 274 ])

  ;; Shooter fish
  (global *shooter-fish* (deepcopy *stronger-fish*))
  (set *shooter-fish*.speedx 20)
  (set *shooter-fish*.health 24)
  (set *shooter-fish*.damage 15)
  (set *shooter-fish*.animator.animations.moving [ 269 270 271 285 271 270 ])
  (set *shooter-fish*.update
        (fn [self]
           (when (= (% (+ *tick* 40) 40) 0)
             (var ball (spawn-enemy :energy-ball self.x self.y))
             (set ball.animator.animations.moving [ 264 308 309 308 ])
             (set ball.animator.speed 50)
             (set ball.damage 20)
             (set ball.w 3)
             (set ball.h 3)
             (set ball.speedx (+ *cam*.speedx 80)))
          (dec self.x (* (+ self.speedx *cam*.speedx) *dt*))
          (inc self.y (* 0.5 (sin (* 0.05 (+ *tick* self.y)))))))

  (global *energy-ball* (deepcopy *enemy*))
  (set *energy-ball*.animator.animations.moving [ 265 323 324 ])
  (set *energy-ball*.points 0)
  (set *energy-ball*.health 9999)
  (set *energy-ball*.speedx 130)
  (set *energy-ball*.damage 20)
  (set *energy-ball*.no-flicker true)

  (global *follower* (deepcopy *energy-ball*))
  (set *follower*.speedx 200)
  (set *follower*.update
   (fn [self]
     (if (and (< self.y *player*.y) (> self.x *player*.x))
         (set self.speedy 35)
         (and (> self.y *player*.y) (> self.x *player*.x))
         (set self.speedy -35))
     (inc self.y (* self.speedy *dt*))
     (dec self.x (* self.speedx *dt*))))

  (global *anglerfish* (deepcopy *enemy*))
  (set *anglerfish*.w 32)
  (set *anglerfish*.h 32)
  (set *anglerfish*.points 100)
  (set *anglerfish*.damage 40)
  (set *anglerfish*.health 2000)
  (set *anglerfish*.shake true)
  (set *anglerfish*.boss? true)
  (set *anglerfish*.state :arriving)
  (set *anglerfish*.next-state :centering)
  (set *anglerfish*.tick 0)
  (set *anglerfish*.reposition-flag false)
  ;; Current attack
  (set *anglerfish*.cattack nil)
  ;; Attack frame
  (set *anglerfish*.aframe 0)
  ;; Attack speed factor
  (set *anglerfish*.asfactor 1)
  (set *anglerfish*.attack-types [ :follow :energy :straight :pacifist ])
  (set *anglerfish*.animator
       { :current-animation :moving
         :current-index 1
         :elapsed 0
         :speed 150
         :animations 
           { :moving [ 300 312 448 420 448 312 ]
             :attack [ 160 164 160 168 ] }})

  (set *anglerfish*.draw
       (fn [self]
         (animate self)
         (if (and (> self.flicker 0) (< (% self.tick 5) 3))
             (do (dec self.flicker))
             (spr (get-animation-frame self.animator) self.x self.y 0 1 0 0 4 4))))

  (set *anglerfish*.move
       (fn [self]
         ;(inc self.y (+ 68 (* 50 (sin (* 0.03 self.tick)))))))
         (inc self.y (- (* 1.5 (sin (* 0.04 (+ self.tick 39)))) 0.0))))

  (set *anglerfish*.finish-attack
   (fn [self]
     (set self.aframe 0)
     (set self.tick 0)
     (set self.cattack nil)
     (set self.reposition-flag false)
     (set self.state :centering)
     (set self.next-state :moving)))

  (set *anglerfish*.attack
   (fn [self]
     (when (not self.cattack)
       (set self.cattack (. self.attack-types (r 1 (length self.attack-types)))))
     (if (and (not self.reposition-flag) (or (= self.cattack :straight) (= self.cattack :follow)))
           (if (< self.y (- *player*.y 1))
             (inc self.y (* 50 *dt*))
             (> self.y (+ *player*.y 1))
             (dec self.y (* 50 *dt*))
             (set self.reposition-flag true))
     
         (= self.cattack :follow)
         (do (when (= (% self.tick 100) 0)
               (spawn-enemy :follower self.x self.y)
               (set self.reposition-flag false))
             (when (= (% self.tick 600) 0)
               (self:finish-attack)))

         (= self.cattack :straight)
         (do (when (= (% self.tick 150) 0)
               (global *shake* 0)
               (set self.reposition-flag false))
             (when (= (% self.tick 3) 0)
               (local ball (spawn-enemy :energy-ball self.x self.y))
               (set ball.speedx 500))
             (global *shake* 5)
             (when (= (% self.tick 500) 0)
               (self:finish-attack)))

         (= self.cattack :energy)
         ;(or (= self.cattack :energy) (= self.cattack :follow) (= self.cattack :straight))
         (do (self:move)
             (when (= (% self.tick (math.round (* 15 self.asfactor))) 0)
               (sfx 3 20 -1 3 8 3)
               (spawn-enemy :energy-ball self.x (+ self.y (/ self.h 2))))
             (when (= (% self.tick 500) 0)
               (self:finish-attack)))
         
         (= self.cattack :pacifist)
         (self:finish-attack))))

  (set *anglerfish*.update
   (fn [self]
     ;(trace self.health)
     ;(inc self.tick)
     (inc self.tick)

     (when (not= self.state :arriving)
       (global *boss-life* (math.max 0 self.health)))

     (when (and (< self.health 1000) (> self.asfactor 0.5))
       (set self.asfactor 0.8))

     (if (= self.state :arriving)
         (if (< self.tick 200)
             (when (> *cam*.speedx 15) (set *cam*.speedx 15))
             (do (when (< *cam*.speedx 50)
                   (set *cam*.speedx 50))
                 (when (< self.x 200)
                   (set self.state :centering)
                   (set self.next-state :moving))
                 (dec self.x (* 60 *dt*))))

         (= self.state :attack)
         (do (when (not (= self.animator.current-animation :attack))
               (set self.animator.current-animation :attack))
             (when (= (% self.tick 30) 0)
               (local emitter (deepcopy *bexplosion-emitter*))
               (set emitter.x (+ self.x 9))
               (set emitter.y (+ self.y 12))
               ;(set emitter. (+ self.y 16))
               (table.insert *emitters* emitter))
             (self:attack))

         (= self.state :centering)
         (do (if (< (+ self.y (/ self.h 2)) 65)
                 (inc self.y (* 40 *dt*))
                 (> (+ self.y (/ self.h 2)) 71)
                 (dec self.y (* 40 *dt*))
                 (do (set self.tick 0)
                     (set self.state self.next-state))))
     
         (= self.state :moving)
         (do (when (not (= self.animator.current-animation :moving))
               (set self.animator.current-animation :moving))
             (when (= (% self.tick 15) 0) ; Spawn monster
               (local rn (r 0 100))
               (when (< rn 40)
                 (local enemy (spawn-enemy :stronger-fish self.x (+ self.y 16)))
                 (set enemy.health 16)))
             (when (= (% self.tick 400) 0)
               (self:finish-attack)
               (set self.state :centering)
               (set self.next-state :attack))
             (self:move)))))

  (global *snake* (deepcopy *enemy*))
  (set *snake*.length 30)
  (set *snake*.animator.animations.moving [ 368 374 371 374 ])
  (set *snake*.animator.speedx 100)
  (set *snake*.speedx 100)
  (set *snake*.health 100)
  (set *snake*.damage 30)
  (set *snake*.draw
   (fn [self]
     (var bindex 1) ; body index
     (local aindex (if (< (% *tick* 32) 8) 0
                       (< (% *tick* 32) 16) 2
                       (< (% *tick* 32) 24) 1
                       2)) ; animation index

     (spr (+ 368 aindex) self.x self.y 0)
     (for [i 1 self.length 1]
       (spr (+ 371 aindex) (+ self.x (* bindex 8)) self.y 0)
       (inc bindex))
     (spr (+ 374 aindex) (+ self.x (* bindex 8)) self.y 0)))
       ;(animate self)
       ;(spr (get-animation-frame self.animator) self.x self.y 0 1 0 0 3 1)))

  (set *snake*.update
    (fn [self]
       (when (< self.w (* (+ self.length 2) 8))
         (set self.w (* (+ self.length 2) 8)))
       (dec self.x (* (+ self.speedx *cam*.speedx) *dt*))))
       ;(inc self.y (* 0.2 (sin (* 0.05 (+ *tick* self.y)))))))


  (global *snail* (deepcopy *enemy*))
  (set *snail*.animator.animations.moving [ 266 ])
  (set *snail*.health 12)
  (set *snail*.damage 40)
  (set *snail*.draw
   (fn [self]
       (animate self)
       (spr (get-animation-frame self.animator) self.x self.y 0 1 0 0 1 2)))

  (set *snail*.update
   (fn [self]
       (when ( = (% (+ *tick* (math.round self.y)) 70) 0)
         (var ball (spawn-enemy :energy-ball self.x self.y))
         (set ball.animator.animations.moving [ 264 308 309 308 ])
         (set ball.animator.speed 50)
         (set ball.damage 20)
         (set ball.w 3)
         (set ball.h 3)
         (set ball.speedx (- self.x *player*.x))
         (set ball.speedy (- *player*.y self.y)))
       (dec self.x (* *cam*.speedx *dt*))))

  (global *easy-snail* (deepcopy *snail*))
  (set *easy-snail*.animator.animations.moving [ 338 ])
  (set *easy-snail*.health 12)
  (set *easy-snail*.damage 30)
  (set *easy-snail*.update
   (fn [self]
       (when ( = (% (+ *tick* (math.round self.y)) 70) 0)
         (var ball (spawn-enemy :energy-ball self.x self.y))
         (set ball.animator.animations.moving [ 264 308 309 308 ])
         (set ball.animator.speed 50)
         (set ball.damage 20)
         (set ball.w 3)
         (set ball.h 3)
         (set ball.speedx *cam*.speedx)
         (set ball.speedy -40))
       (dec self.x (* *cam*.speedx *dt*))))


  (global *guard* (deepcopy *enemy*))
  (set *guard*.animator.animations.moving [ 304 ])
  (set *guard*.health 10)
  (set *guard*.tick 0)

  (set *guard*.update
   (fn [self]
       (inc self.tick)
       (when ( = (% self.tick 60) 0)
         (var ball (spawn-enemy :energy-ball self.x self.y))
         (set ball.animator.animations.moving [ 264 308 309 308 ])
         (set ball.animator.speed 50)
         (set ball.damage 7)
         (set ball.w 3)
         (set ball.h 3)
         (set ball.speedx (+ *cam*.speedx 20)))
       (set self.y (+ 68 (* 50 (sin (* 0.03 *tick*)))))
       (dec self.x (* *cam*.speedx *dt*))))

  ;; Pool containing all enemies
  (global *enemy-pool* []))

;; Spawns a snail
(fn spawn-snail [?enemy]
  (when (< ymax 9)
    (local camtile (% (math.abs (math.round (// *cam*.x 8))) 240))
    (var found-tile false)
    ;; Search next map block
    (for [i (+ camtile 30) (+ camtile 60) 1]
      ;; Tries to find a bottom free location
      (for [j 10 16 1]
        (when (and (> (mget i j) 127) (= (mget i (- j 1)) 0) (not= i *last-snail-x*))
          (spawn-enemy (or ?enemy :snail)
                       (- (* (- i camtile -1) 8) (% (math.abs *cam*.x) 8))
                       (+ (* (- j 1) 8) 4))
          (global *last-snail-x* i)
          (set found-tile true)
          (lua :break)))
      (when found-tile (lua :break)))))

;; Destroy enemy with a certain index from *enemy-pool*
(fn destroy-enemy [index]
  (table.remove *enemy-pool* index))

;; Updates enemies from *enemy-pool*
(fn update-enemies []
  ;; Update enemy position
  (each [index enemy (pairs *enemy-pool*)]

    (enemy:update)
    (enemy:draw)

    ;; Deal with player-enemy collision
    (when (bcollides? *player* enemy)
      (*player*:hurt enemy.damage))

    ;; Deal with shot-enemy collision
    (each [shot-index shot (pairs *player*.shots)]
      (when (bcollides? shot enemy) (dec enemy.health shot.damage)
                                    ;; Play sound when shot
                                    (when (and (> enemy.health 0) (not enemy.no-flicker)) (set enemy.flicker 18) (sfx 4 33 4 3 6))
                                    (destroy-shot shot-index)
                                    (when (and enemy.shake (= *shake* 0)) (global *shake* 5))))

    ;; Destroy enemy if it's to the left of the screen or it has no more health
    (when (or (< (+ enemy.x enemy.w) -8.0)
              (> enemy.x 480)
              (< enemy.y -200)
              (> enemy.y (+ +height+ 200))
              (<= enemy.health 0))

      ;; Player killed enemy
      (when (<= enemy.health 0)
        (when enemy.boss? (global *boss-killed* true))
        (sfx 4 12 -1 3 6)
        (local emitter (match enemy.emitter
                         :pexplosion (deepcopy *pexplosion-emitter*)
                         :cexplosion (deepcopy *cexplosion-emitter*)))
        (set emitter.x enemy.x)
        (set emitter.y enemy.y)
        (table.insert *emitters* emitter)
        (spawn-goods (math.max enemy.x 60) (+ enemy.y (/ enemy.h 2)) enemy.points))
      (destroy-enemy index))))

;; Spaws enemies according to various parameters
(fn init-enemy-spawners []
  (global *spawners* {})
  (global *active-spawners* 0)
  (global *spawner* { :enemy :simple-fish :delay 30 :duration 5 :finished false })

  ;; Avoids overlapping snails
  (global *last-snail-x* 0)
  (set *spawner*.update
   (fn [self ?delay ?x ?y ?enemy]
     (when (= (% *tick* (or ?delay self.delay)) 0)
       (spawn-enemy (or ?enemy self.enemy) ?x ?y))
     (if (< self.duration 0)
         (set self.finished true)
         (dec self.duration *dt*))))

  (global *fish-spawner* (deepcopy *spawner*))

  (global *ghost-fish-spawner* (deepcopy *spawner*))
  (set *ghost-fish-spawner*.enemy :ghost-fish)

  (global *stronger-fish-spawner* (deepcopy *fish-spawner*))
  (set *stronger-fish-spawner*.enemy :stronger-fish)
  (set *stronger-fish-spawner*.delay 55)

  (global *snail-spawner* (deepcopy *spawner*))
  (set *snail-spawner*.enemy :snail)
  (set *snail-spawner*.delay 250)
  (set *snail-spawner*.duration 15)
  (set *snail-spawner*.update
   (fn [self ?delay]
     (when (= (% *tick* (or delay self.delay)) 0)
       ;(trace "spawning")
       (spawn-snail self.enemy))
     (if (< self.duration 0)
         (set self.finished true)
         (dec self.duration *dt*))))

  (global *easy-snail-spawner* (deepcopy *snail-spawner*))
  (set *easy-snail-spawner*.enemy :easy-snail)

  (global *shooter-fish-spawner* (deepcopy *spawner*))
  (set *shooter-fish-spawner*.enemy :shooter-fish)
  (set *shooter-fish-spawner*.delay 180)

  (global *snake-spawner* (deepcopy *spawner*))
  (set *snake-spawner*.enemy :snake)
  (set *snake-spawner*.delay 180)

  (global *guard-spawner* (deepcopy *spawner*))
  (set *guard-spawner*.enemy :guard)
  (set *guard-spawner*.update
   (fn [self]
     (when (= (% *tick* 150) 0)
       (spawn-enemy :guard)
       (set self.finished true))))
  
  (global *easy-spawners* [ :fish :stronger-fish :guard :easy-snail ])
  (global *medium-spawners* [ :guard :snail :snake :shooter-fish :ghost-fish ])
  ;; Tick counter for waves
  (global *wave-counter* 0))

;; Returns true if the camera is within certain range
(fn camr [from to]
  (and (> *cam*.x to) (< *cam*.x from)))

;; Returns a copy of a certain spawner
(fn get-spawner [type]
  (match type
    :fish (deepcopy *fish-spawner*)
    :ghost-fish (deepcopy *ghost-fish-spawner*)
    :stronger-fish (deepcopy *stronger-fish-spawner*)
    :shooter-fish (deepcopy *shooter-fish-spawner*)
    :snake (deepcopy *snake-spawner*)
    :guard (deepcopy *guard-spawner*)
    :easy-snail (deepcopy *easy-snail-spawner*)
    :snail (deepcopy *snail-spawner*)))

;; Adds a single spawner to the spawner table
(fn add-spawner [spawners]
  (local spw (. spawners (r 1 (length spawners))))
  (when (= (. *spawners* spw) nil)
    (incg *active-spawners*)
    (tset *spawners* spw (get-spawner spw))))

(fn update-enemy-spawners []
  ;(trace *cam*.x)
  ;(trace (length *enemy-pool*))
  ;(trace "---------------------")
  (when (and (< *cam*.speedx *cam*.max-speed) (= (% *tick* 400) 0))
    (inc *cam*.speedx))

  (if (= *enemy-wave* :easy-wave)
      (do (when (< *active-spawners* 2)
            (add-spawner *easy-spawners*))
          (each [k spawner (pairs *spawners*)]
            (spawner:update)
            (when spawner.finished
              (decg *active-spawners*)
              (tset *spawners* k nil)))
          
          (when (< *cam*.x -2000)
            (global *enemy-wave* :medium-wave)))

      (= *enemy-wave* :medium-wave)
      (do (when (< *active-spawners* 2)
            (add-spawner *medium-spawners*))
          (each [k spawner (pairs *spawners*)]
            (spawner:update)
            (when spawner.finished
              (decg *active-spawners*)
              (tset *spawners* k nil)))
          
          (when (< *cam*.x -4000)
            (each [k spawner (pairs *spawners*)]
              (decg *active-spawners*)
              (tset *spawners* k nil))
            (global *enemy-wave* :boss-wave)))

      (= *enemy-wave* :boss-wave)
      (do (if *boss-killed*
             (do (global *enemy-wave* :none)
                 (global *time-elapsed* 0)
                 (global *game-state* "win"))

             (> *cam*.x -4600)
             (do (when (> *cam*.speedx 20) (set *cam*.speedx 20))
                  (when (< *active-spawners* 2) (add-spawner [:fish :stronger-fish]))
                  (each [k spawner (pairs *spawners*)]
                    (spawner:update)
                    (when spawner.finished
                      (decg *active-spawners*)
                      (tset *spawners* k nil))))
             (<= (length *enemy-pool*) 0)
             (spawn-enemy :anglerfish)))

      ;; First wave
      (= *enemy-wave* :first-wave)
      (do (when (and (< *cam*.x -100) (= (% *tick* 200) 0))
            (incg *wave-counter* 9))
          (if (and (< *cam*.x -30) (> *cam*.x -100))
              (*fish-spawner*:update 80 nil (+ 68 (r -40 40)))
              (and (< *cam*.x -100) (> *cam*.x -700))
              (do (*fish-spawner*:update (- 100 *wave-counter*))
                  (*fish-spawner*:update (- 120 *wave-counter*) nil nil :stronger-fish))
              (< *cam*.x -700)
              (do 
                  (global *wave-counter* 0)
                  (global *enemy-wave* :easy-wave))))))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Background                                                                                   ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

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

;; Draws algae with a parallax factor pfactor
(fn draw-algae [pfactor]
  (local positions [ 0 15 32 39 47 56 62 79 83 98 107 113 125 132 147 153 165 169 177 182 189 198 213 224 232 240  ])
  (local sprites [ 51 54 51 52 52 53 54 51 54 53 51 53 51 53 54 52 54 52 51 53 54 52 54 51 52 54 ])

  (for [i 1 26 1]
  ;(for [i 1 15 1]
    (local pos (. positions i))
    ;(trace (length positions))
    ;(trace (length sprites))
    (loop-spr (. sprites i) pos (+ 136 (% pos 8)) 1 5 pfactor 0 (% pos 2))))

;; Draws background decoration
(fn draw-bg []
  (draw-cave-bg 0.1)
  (draw-algae 0.6)
  (*bg-bubbles*:update))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Game                                                                                       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn update-game-debug []
  (when (btnp 6)
    (spawn-enemy :anglerfish)))

(fn draw-healthbar [x y n]
  ;; Health icon
  (spr 387 x (+ y 3) 0)

  ;; Health bar
  (spr 384 (+ x 3) y 0 1 0 0 2 1)
  (for [i 2 5 1]
    (spr 385 (+ x (* 8 i) 3) y 0 1 0 0 1 1))
  (spr 385 (+ x 42 3) y 0 1 0 0 2 1)

  (spr 384 (+ x 3) (+ y 5) 0 1 2 0 2 1)
  (for [i 2 5 1]
    (spr 385 (+ x (* 8 i) 3) (+ y 5) 0 1 2 0 1 1))
  (spr 385 (+ x 42 3) (+ y 5) 0 1 2 0 2 1)

  ;; Filling
  ;; Only draw if we have life
  (when (> n 0)
    (var fill-color 1)
    (when (< n 10) (set fill-color 9))
    (for [j y (+ y 4) 1]
      (for [i (+ x 3) (+ x 3 n -1) 1]
        (pix (+ i 4) (+ j 4) fill-color)))))

(fn draw-shot-icons [x y]
  (if (= *player*.current-shot :basic-shot)
      (spr 388 x y 0)
      (spr 395 x y 0))

  (if (has-element? *player*.available-shots :blue-shot)
      (if (= *player*.current-shot :blue-shot)
          (spr 389 (+ x 8) y 0)
          (spr 396 (+ x 8) y 0))
      (spr 392 (+ x 8) y 0))

  (if (has-element? *player*.available-shots :triple-shot)
      (if (= *player*.current-shot :triple-shot)
          (spr 390 (+ x 16) y 0)
          (spr 397 (+ x 16) y 0))
      (spr 393 (+ x 16) y 0)))

(fn draw-boss-healthbar [x y]
  (when (and (> *boss-life* 0) (not *boss-killed*))
    ;; Boss icon
    (spr 407 x (+ y 2) 0)

    ;; Health bar
    (spr 404 (+ x 3) y 0 1 0 0 2 1)
    (for [i 2 27 1]
      (spr 405 (+ x (* 8 i) 3) y 0 1 0 0 1 1))
    (spr 406 (+ x (* 28 8) 2) y 0 1 0 0 1 1)

    (spr 404 (+ x 3) (+ y 3) 0 1 2 0 2 1)
    (for [i 2 27 1]
      (spr 405 (+ x (* 8 i) 3) (+ y 3) 0 1 2 0 1 1))
    (spr 406 (+ x (* 28 8) 2) (+ y 3) 0 1 2 0 1 1)

    ;; Filling
    ;; Only draw if there is life
    (when (> *boss-life* 0)
      (var fill-color 7)
      (for [j y (+ y 2) 1]
        (for [i (+ x 3) (+ x 3 (math.round (/ *boss-life* 8.968609)) -1) 1]
          (pix (+ i 4) (+ j 4) fill-color))))))

(fn draw-hud []
  (spr 277 5 13 0)
  (if (> *player*.target-points 0)
      (print (.. *player*.points (.. "/" *player*.target-points)) 15 13 12)
      (print *player*.points 15 13 12))
  (draw-healthbar 5 0 (// *player*.health 2))
  (draw-shot-icons 65 3)
  (draw-boss-healthbar 5 (- 136 10)))

(fn draw-game []
  (cls)
  (local txcam (// (math.abs *cam*.x) 8))
  (local tycam (// (math.abs *cam*.y) 8))
  (map txcam tycam 31 18 (- 0 (% (math.abs *cam*.x) 8)) (- 0 (% (math.abs *cam*.y) 8)) 0)
  (update-goods)
  (*player*:draw)
  (update-enemies)
  (update-emitters)
  (draw-hud))

(fn update-camera []
  ;; Move camera
  (set *cam*.ox (- *cam*.ox (* *cam*.speedx *dt*)))
  (set *cam*.x (+ *cam*.ox *cam*.offsetx))
  (set *cam*.y (+ *cam*.oy *cam*.offsety)))

(fn update-game []
  (update-camera)
  (update-cave-walls)

  ;; Shake screen if receives damage
  (when (> *shake* 0)
    ;; Shake OVR
    (set *cam*.offsetx (r -2 2))
    (set *cam*.offsety (r -2 2))

    ;; Shake bg
    (poke 0x3FF9 (r 0 1))
    (poke (+ 0x3FF9 1) (r 0 1))

    (decg *shake*)
    ;; Restore defaults
    (when (= *shake* 0)
      (memset 0x3FF9 0 2)
      (set *cam*.offsety 0)
      (set *cam*.offsetx 0)))

  (*player*:update)
  (update-game-debug)
  (update-enemy-spawners))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Icosahedron                                                                                  ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;; Adapted from http://www.songho.ca/opengl/gl_sphere.html

(global *icosahedron* [])
(global *t-icosahedron* [])

;; Returns the minimum z value of the vertices of a triangle
(fn minz [t]
  (math.min (. (. t 1) 3)
            (. (. t 2) 3)
            (. (. t 3) 3)))

;; Returns the sum of the vertices of a triangle
(fn sum-tri [t]
  (+ (. (. t 1) 3)
     (. (. t 2) 3)
     (. (. t 3) 3)))

;; Field of view
(global +fov+ 120)

(fn compute-icosahedron-vertices [radius]
  (local hangle (* (/ math.pi 180) 72))
  (local vangle (math.atan (/ 1 2)))
  
  (local vertices [])
  (var i1 0)
  (var i2 0)
  (var z 0)
  (var xy 0)
  (var hangle1 (- (/ -3.141592 2) (/ hangle 2)))
  (var hangle2 (/ -3.141592 2))
  
  ;; Top vertex
  (tset vertices 0 0)
  (tset vertices 1 radius)
  (tset vertices 2 0)
  
  ;; Faces
  (for [i 1 5 1]
    (set i1 (* i 3))
    (set i2 (* (+ i 5) 3))
    (set z (* radius (sin vangle)))
    (set xy (* radius (cos vangle)))

    (tset vertices i1 (* xy (cos hangle1)))
    (tset vertices i2 (* xy (cos hangle2)))

    (tset vertices (+ i1 1) z)
    (tset vertices (+ i2 1) (- 0 z))

    (tset vertices (+ i1 2) (* xy (sin hangle1)))
    (tset vertices (+ i2 2) (* xy (sin hangle2)))

    (inc hangle1 hangle)
    (inc hangle2 hangle))
  
  ;; Bottom vertex
  (set i1 (* 11 3))
  (tset vertices i1 0)
  (tset vertices (+ i1 1) (- 0 radius))
  (tset vertices (+ i1 2) 0)

  ;; Return vertices
  vertices)

;; Sets a vertice from an array
(fn getv3 [arr i]
  (local v [])
  (tset v 1 (. arr i))
  (tset v 2 (. arr (+ i 1)))
  (tset v 3 (. arr (+ i 2)))
  v)

;; Convert 3d coords to 2d
(fn convert-3d-2d [ox oy oz]
  (local v [])
  (tset v 0 (+ (* ox (/ +fov+ (+ oz 20))) (/ +width+ 2)))
  (tset v 1 (+ (* oy (/ +fov+ (+ oz 20))) (/ +height+ 2)))
  v)

(fn draw-tri [vertices color]
  (local xo (/ +width+ 2))
  (local yo (/ +height+ 2))
  (local v1-3d (. vertices 1))
  (local v2-3d (. vertices 2))
  (local v3-3d (. vertices 3))

  (local v1 (. vertices 1))
  (local v2 (. vertices 2))
  (local v3 (. vertices 3))

  (tri (+ (. v1 1) xo) (+ (. v1 2) yo)
       (+ (. v2 1) xo) (+ (. v2 2) yo)
       (+ (. v3 1) xo) (+ (. v3 2) yo)
       color))

(fn build-icosahedron-triangles []
  (local tmp-verts (compute-icosahedron-vertices 40))
  
  (var v0 [])
  (var v1 [])
  (var v2 [])
  (var v3 [])
  (var v4 [])
  (var v11 [])
  (var index 0)

  (set v0 (getv3 tmp-verts 0))
  (set v11 (getv3 tmp-verts (* 11 3)))

  (for [i 1 5 1]
    (set v1 (getv3 tmp-verts (* i 3)))
    (if (< i 5)
        (set v2 (getv3 tmp-verts (* (+ i 1) 3)))
        (set v2 (getv3 tmp-verts 3)))

    (set v3 (getv3 tmp-verts (* (+ i 5) 3)))
    (if (< i 5)
        (set v4 (getv3 tmp-verts (* (+ i 6) 3)))
        (set v4 (getv3 tmp-verts (* 6 3))))

    ;; Insert triangles and indexes for color choice
    (table.insert *icosahedron* [v0 v1 v2 index])
    (table.insert *icosahedron* [v1 v3 v2 (+ index 1)])
    (table.insert *icosahedron* [v2 v3 v4 (+ index 2)])
    (table.insert *icosahedron* [v3 v11 v4 (+ index 3)])
    (inc index 4)))

(fn sort-icosahedron []
  (table.sort *t-icosahedron* (fn [a b]
                              (if (< (minz b) (minz a))
                                  true
                                  (> (minz b) (minz a))
                                  false
                                  ;; To avoid a flickering glitch,
                                  ;; when both minz are equal
                                  ;; we sort arbitrarily by the sum of 
                                  ;; the vertices of the triangle
                                  (if (< (sum-tri b) (sum-tri a))
                                      true
                                      false)))))

;; Rotate a point with angles gamma (x), beta (y) and alpha (z)
(fn rotate-point [point g b a]
  (local px (. point 1))
  (local py (. point 2))
  (local pz (. point 3))
  
  (local newpoint [(+ (* px (cos a) (cos b))
                      (* py (- (* (cos a) (sin b) (sin g)) (* (sin a) (cos g))))
                      (* pz (+ (* (cos a) (sin b) (cos g)) (* (sin a) (sin g)))))

                   (+ (* px (* (sin a) (cos b)))
                      (* py (+ (* (sin a) (sin b) (sin g)) (* (cos a) (cos g))))
                      (* pz (- (* (sin a) (sin b) (cos g)) (* (cos a) (sin g)))))

                   (+ (* px (- 0 (sin b)))
                      (* py (cos b) (sin g))
                      (* pz (cos b) (cos g)))])
  newpoint)

(fn rotate-icosahedron [x y z]
  (each [i triangle (pairs *icosahedron*)]
    (var new-triangle [])
    (for [j 1 3 1]
      (table.insert new-triangle (rotate-point (. triangle j) x y z)))
    ;; Insert same id
    (table.insert new-triangle (. triangle 4))
    (tset *t-icosahedron* i new-triangle)))

(fn translate-point [point x y z]
  (local px (. point 1))
  (local py (. point 2))
  (local pz (. point 3))
  
  (local newpoint [(+ px x) (+ py y) (+ pz z)])
  newpoint)

(fn translate-icosahedron [x y z]
  (each [i triangle (pairs *icosahedron*)]
    (var new-triangle [])
    (for [j 1 3 1]
      (table.insert new-triangle (translate-point (. triangle j) x y z)))
    ;; Insert same id
    (table.insert new-triangle (. triangle 4))
    (tset *t-icosahedron* i new-triangle)))

(fn transform-icosahedron [r t]
  (each [i triangle (pairs *icosahedron*)]
    (var new-triangle [])
    (for [j 1 3 1]
      (table.insert new-triangle (translate-point (rotate-point (. triangle j)
                                                                r.x r.y r.z)
                                                  t.x t.y t.z)))
    ;; Insert same id
    (table.insert new-triangle (. triangle 4))
    (tset *t-icosahedron* i new-triangle)))

(fn get-tri-color [triangle]
  (local p1 (. triangle 1))
  (local p2 (. triangle 2))
  (local p3 (. triangle 3))

  (if (and (< (math.min (. p1 1) (. p2 1) (. p3 1)) 0)
           (< (math.max (. p1 2) (. p2 2) (. p3 2)) 20))
      7
      0))
    
(fn draw-icosahedron []
  (for [index 1 (length *t-icosahedron*) 1]
    (local triangle (. *t-icosahedron* index))
    (local color-id (% (. triangle 4) 5))

    (var color 7)
    (match color-id
      0 (set color 8)
      1 (set color 14)
      2 (set color 15)
      3 (set color 0))

    (draw-tri triangle color)))

(fn init-icosahedron []
  (build-icosahedron-triangles)
  (sort-icosahedron)
  (global *t-icosahedron* (deepcopy *icosahedron*)))

(fn ico-r [offset]
  (- 0xff (math.abs (math.round (* 150 (sin (* (+ *tick* offset) 0.01)))))))
(fn ico-g [offset]
  (+ 0x00 (math.abs (math.round (* 50 (sin (* (+ *tick* offset) 0.07)))))))
(fn ico-b [offset]
  (- 0x88 (math.abs (math.round (* 50 (sin (* (+ *tick* offset) 0.07)))))))
  ;0x66)
(fn ico-pal [i offset]
  (pal i (ico-r offset) (ico-g offset) (ico-b offset)))

(fn update-icosahedron [?offset-y]
  ;; Change color palette
  (ico-pal 7 0)
  (ico-pal 0 100)
  (ico-pal 15 200)
  (ico-pal 8 50)
  (ico-pal 14 150)
  (pal 6 
       (- 0x2a (math.abs (math.round (* 16 (sin (* *tick* 0.01))))))
       (- 0x37 (math.abs (math.round (* 27 (sin (* *tick* 0.01))))))
       (- 0x58 (math.abs (math.round (* 55 (sin (* *tick* 0.01)))))))
  ;; Translate and rotate in one loop
  ;(transform-icosahedron { :x (* (/ math.pi 3) *time-elapsed*) :y (* (/ math.pi 2) *time-elapsed*) :z 0 }
                         ;{ :x 0 :y (- (* 0.11 (sin (* *tick* 0.05))) (or ?offset-y 0)) :z 0 })
  (transform-icosahedron { :x (* (/ math.pi 4) *elapsed*) :y (* (/ math.pi 2) *elapsed*) :z 0 }
                         { :x 0 :y (- (* 3 (sin (* *tick* 0.05))) (or ?offset-y 0)) :z 0 })
  ;(transform-icosahedron { :x 0 :y 0 :z 0 }
                         ;{ :x 0 :y (- 0 (or ?offset-y 0)) :z 0 })
  ;; Sort rendering order for icosahedron triangles
  (sort-icosahedron))

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Menu                                                                                         ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

(fn update-menu []
  (cls 5)

  (*bg-bubbles*:update)

  ;; Print multiple times with a small offset for a bold effect
  (print "AMETHYST WATERS" (* 4 8) (* 3 8) 12 true 2)
  (print "AMETHYST WATERS" (- (* 4 8) 1) (* 3 8) 12 true 2)
  (print "AMETHYST WATERS" (* 4 8) (- (* 3 8) 1) 12 true 2)

  (update-icosahedron)
  (draw-icosahedron)

  (when (< (% *tick* 60) 30)
    (print "- Press Z to play the game -" (* 6 8) (+ (* 12 8) 6) 12))

  (when (btnp 4)
    ;(*bg-bubbles*:clear)
    (sfx 5 55 -1 3 6 -2)
    (global *time-elapsed* -1.0)
    (music 0)
    ;; Time when game session is started
    (global *initial-time* (time))
    (global *game-state* "t-menu-game")))

(fn ease-in-back [x]
  (- (* 2.70158 x x x) (* 1.70158 x x)))

(fn t-menu-game []
  (cls 5)

  (var map-pos 196)
  (var particle-speed 0)
  (var title-speed 0)
  (var ico-speed 0)
  (var message-speed 0)
  (var message-delay 15)
  (when (> *time-elapsed* 0.0)
    (set map-pos (- 236 (* 180 (ease-in-back (* 0.5 *time-elapsed*)))))
    (set particle-speed (* 8 (ease-in-back (* 0.5 *time-elapsed*))))
    (set title-speed (* 200 (ease-in-back (* 0.5 *time-elapsed*))))
    (set ico-speed (* 260 (ease-in-back (* 0.5 *time-elapsed*))))
    (set message-speed (* 300 (ease-in-back (* 0.5 *time-elapsed*))))
    (set message-delay 10))

  (*bg-bubbles*:update)

  (each [k part (pairs *bg-bubbles*.particles)]
    (dec part.y particle-speed))

  ;; Print multiple times with a small offset for a bold effect
  (print "AMETHYST WATERS" (* 4 8) (- (* 3 8) title-speed) 12 true 2)
  (print "AMETHYST WATERS" (- (* 4 8) 1) (- (* 3 8) title-speed) 12 true 2)
  (print "AMETHYST WATERS" (* 4 8) (- (* 3 8) 1 title-speed) 12 true 2)

  (update-icosahedron ico-speed)
  (draw-icosahedron)

  (when (< (% *tick* message-delay) 10)
    (print "- Press Z to play the game -" (* 6 8) (- (+ (* 12 8) 6) message-speed) 12))
  
  (local txcam (// (math.abs *cam*.x) 8))
  (local tycam (// (math.abs *cam*.y) 8))

  (when (< map-pos 138)
    (pal 0 0x14 0x14 0x28)
    (pal 7 0x8e 0x2e 0x91)
    (pal 8 0x3c 0x40 0x55)
    (pal 14 0x20 0x18 0x34)
    (pal 15 0xf6 0x61 0xba)
    (pal 6 0x20 0x2d 0x51))
  (if (<= map-pos 0)
      (do (map txcam tycam 31 18 (- 0 (% (math.abs *cam*.x) 8)) 0 -1)
          (set *player*.y 68)
          (set *bg-bubbles*.emition-delay 1000)
          (global *game-state* "game"))
      (do (map txcam tycam 31 18 (- 0 (% (math.abs *cam*.x) 8)) map-pos -1)
          (set *player*.y (+ 68 map-pos))))

  (*player*:draw)
  (update-emitters))


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;
;;; Main functions                                                                               ;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;

(fn init []
  (init-emitters)

  (init-icosahedron)

  (music 1)
  (init-player)
  (init-cave-walls)
  (init-enemies)
  (init-enemy-spawners)
  (init-goods)
  
  ;; Set border color
  (poke 0x03FF8 5)

  (global +width+ 240.0)
  (global +height+ 136.0)

  (global *dt* 0.0)
  (global *previous-time* (time))
  (global *tick* 0)
  ;; Tick for transitions
  (global *t-tick* 0)
  (global *elapsed* 0)
  (global *time-elapsed* 0)

  (global *cam* { :x 0 :y 0
                  :ox 0 :oy 0
                  :speedx 20 :speedy 0 
                  :max-speed 200
                  :offsetx 0 :offsety 0 })

  (global *last-block-generated* 0)
  (global *max-wall-y* 6)
  (generate-cave-walls 14 59 pn)
  (decorate-block 14 59)

  (global *shake* 0)
  (global *enemy-wave* :first-wave)
  (global *boss-life* -1)
  (global *boss-killed* false)
  (global *music-playing* true)

  ;; Controls which message to display in the game over screen
  (global highscore-flag false)
  (global *game-state* "menu"))

(fn update-win-screen []
  (cls 5)

  (when (not *music-playing*)
    (global *music-playing* true)
    (music 1))

  (local title-string "YOU WON!!!")
  (local width (print title-string 0 -16 12 true 2))
  (print title-string (// (- 240 width) 2) (* 2 8) 12 true 2)
  (print title-string (- (// (- 240 width) 2) 1) (* 2 8) 12 true 2)
  (print title-string (// (- 240 width) 2) (- (* 2 8) 1) 12 true 2)

  (local middle-text ["You explored the Amethyst Waters."
                      (.. "And look! You collected " *player*.points " amethysts!")])
  (for [i 1 (length middle-text) 1]
    (local width (print (. middle-text i) 0 -16))
    (print (. middle-text i) (// (- 240 width) 2) (+ 60 (* 8 (- (* i 1.5) 1))) 15))

  (local bottom-string "Press Z to go back to the title screen.")
  (local width (print bottom-string 0 -16 12))
  (print "Press Z to go back to the title screen" (// (- 240 width) 2) (+ (* 13 8) 6) 12)

  (when (btnp 4)
    ;; Reset icosahedron
    (global *icosahedron* [])
    (global *t-icosahedron* [])
    (init-icosahedron)
    ;; Clear map
    (for [i 0 7]
      (clear-map-block i))
    (init)
    ;; Time when game session is started
    (global *initial-time* (time))
    (global *game-state* "menu")))

(fn update-game-over []
  (if (< *time-elapsed* 2)
    (draw-bg)
    (do (cls 5)
        ;; Print multiple times with a small offset for a bold effect
        (local title-string "YOU CRASHED")
        (print title-string (- 256 (* (length title-string) 16)) (* 2 8) 12 true 2)
        (print title-string (- (- 256 (* (length title-string) 16)) 1) (* 2 8) 12 true 2)
        (print title-string (- 256 (* (length title-string) 16)) (- (* 2 8) 1) 12 true 2)
        (spr 288 32 21 0)
        (print (.. "x " *player*.points) 42 21 12)
        ;; Aquire triple shot
        (var middle-text [])
        (var icon nil)
        (var padding 0)
        ;; Aquire blue shot
        (if (and (= *player*.target-points 15) (>= *player*.points 15))
            (do (when (not= (pmem 2) 1) (pmem 2 1))
                (set icon 389)
                (set middle-text [ "YOU UNLOCKED A NEW WEAPON!" "Press A or S to change weapons." ]))

            ;; Aquire triple shot
            (and (= *player*.target-points 50) (>= *player*.points 20))
            (do (when (not= (pmem 3) 1) (pmem 3 1))
                (set icon 390)
                (set middle-text [ "YOU UNLOCKED A NEW WEAPON!" "Press A or S to change weapons." ]))

            ;; Player didn't reach target points
            (< *player*.points *player*.target-points)
            (set middle-text [(.. "Get " *player*.target-points " amethysts") "to unlock your next weapon!"])

            ;; If already has super shot
            (set middle-text ["You have superpowers!!"]))

        (when icon
          (spr icon 114 44 0 2)
          (set padding 8))
        (for [i 1 (length middle-text) 1]
          (local width (print (. middle-text i) 0 -16))
          (print (. middle-text i) (// (- 240 width) 2) (+ 60 padding (* 8 (- i 1))) 15))

        (print "Press Z to test your skills again!" 32 (+ (* 13 8) 6) 12)
        ;(print "and try your luck again." (* 9 8) (+ (* 14 8) 6) 12)

        (when (btnp 4)
          (for [i 0 7]
            (clear-map-block i))
          (init)
          (music 0)
          ;; Time when game session is started
          (global *initial-time* (time))
          (global *game-state* "game")))))


(global TIC ; Function called once every frame
  (fn []
    ;; Calculate delta time
    (global *dt* (/ (- (time) *previous-time*) 1000.0))
    (global *previous-time* (time))
    (incg *time-elapsed* *dt*)
    (incg *tick*)
    ;; All time elapsed since the start of the game session
    (incg *elapsed* *dt*)

    (if (= *game-state* "game")
        (do (update-game)
            (draw-bg))

        (= *game-state* "menu")
        (update-menu) 

        ;; Transition from menu to game
        (= *game-state* "t-menu-game")
        (t-menu-game) 

        (= *game-state* "win")
        (if (< *time-elapsed* 10)
            (do (when (> *cam*.speedx 10) (set *cam*.speedx 10))
                (if *music-playing*
                  (global *music-playing* false)
                  (music))
                (when (= (% *tick* 45) 0)
                  (sfx 9 (r 20 30) -1 0 10 0)
                  (local emitter (deepcopy *pexplosion-emitter*))
                  (set emitter.x (r 10 230))
                  (set emitter.y (r 10 126))
                  (set emitter.scale-range { :min 10 :max 40 })
                  (table.insert *emitters* emitter))
                (draw-bg)
                (update-game))
            (update-win-screen))

        (= *game-state* "game-over")
        (update-game-over))))

(global OVR
  (fn []
    (if (= *game-state* "game")
        (draw-game)
        (and (= *game-state* "game-over") (< *time-elapsed* 2))
        (draw-game)
        (and (= *game-state* "win") (< *time-elapsed* 10))
        (draw-game))))

(global scanline
 (fn [row]
     (if (= *game-state* "game")
         (poke 0x3ff9 (* (sin (+ (/ (time) 200) (/ row 5))) 2.2))
         (and (= *game-state* "game-over") (< *time-elapsed* 2))
         (poke 0x3ff9 (* (sin (+ (/ (time) 200) (/ row 5))) 2.2))
         (and (= *game-state* "win") (< *time-elapsed* 10))
         (poke 0x3ff9 (* (sin (+ (/ (time) 200) (/ row 5))) 2.2)))))

(init)

;; <TILES>
;; 005:622cc00000000000000000000000000000000000000000000000000000000000
;; 008:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 009:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 010:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 011:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 012:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 016:fffffffffff66fffff6066fff60b006ff666606fff6006fffff66fffffffffff
;; 017:fffffffffffffffffff66fffff6666ffff6666fffff66fffffffffffffffffff
;; 018:fffffffffffffffffffffffffff6ffffff666ffffff6ffffffffffffffffffff
;; 019:fffffffffffffffffffffffffff66ffffff66fffffffffffffffffffffffffff
;; 024:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00ee0000000000000000000000000
;; 025:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 026:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 027:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 028:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 029:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 030:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 031:000000000000000000000000e0ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
;; 032:ffffff6ff66bff6ffff6ff6ff6fffffffbf6b66ffff6ffffff6fffbfffffffff
;; 033:fffff6fffbfffffffffffffffffffffff6ffffbfffffffffffffffff6fffffff
;; 034:fffffffffffcbfffffc06bfffcbc00bffb6660bfffb00bfffffbbfffffffffff
;; 035:fffffffffffffffffffbbfffffb66bffffb66bfffffbbfffffffffffffffffff
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
;; 131:0065555505555555007665550005555500575655000057560005675700000050
;; 132:5555555055556000555555005556700056565500657500005757500000500000
;; 133:0000050000057575000057560055656500076655005555550006555505555555
;; 134:0500000075765000657500005565750055555000555667005555555055555600
;; 135:5555555555555555555555556555556575655565756565700575750000050000
;; 136:0005000005757500756565707565556565555565555555555555555555555555
;; 142:5000000555000005555050555555555555555555555555555555555555555555
;; 143:5555555555555555555555555555555555555555555050555500000550000005
;; 149:0055555505555555555555555555555555555555555555555555555555555555
;; 150:5555550055555550555555555555555555555555555555555555555555555555
;; 151:5555555005555555555555555555555055555555055555505555555555555555
;; 152:5555555555555555555555555555555555555555555555555555555505550050
;; 153:5505550055555555555555555555555555555555555555555555555555555555
;; 154:0555555505555555555555550555555555555555555555550555555555555555
;; 155:5555555555555555555555505555555055555555555555555555555055555555
;; 156:5500555055555555555555505555555555555555555555505555555555555555
;; 157:0500505555555555555555550555555505555555555555555555555505555555
;; 158:5555555555555555055555555555555555555555055555555555555505550055
;; 159:5555555055555555555555555555555055555550555555555555555555050050
;; </TILES>

;; <SPRITES>
;; 000:0000600000006000000666600066666666666666666666660066666600066660
;; 001:000020000000a000000cc220c02cc288ca2228aa2a2228882022222200022220
;; 002:0000c0000000a000000cc220002cc288ca2228aa2a2228880022222200022220
;; 003:000020000000a000000cc220002cc2880a2228aa2a2228880022222200022220
;; 004:0000c0000000a000000cc220002cc288ca2228aa0a2228880022222200022220
;; 005:622cc00000000000000000000000000000000000000000000000000000000000
;; 007:677ff00000000000000000000000000000000000000000000000000000000000
;; 008:0100000019100000010000000000000000000000000000000000000000000000
;; 009:00000000000ff00000f77f000f7778f00f7788f000f88f00000ff00000000000
;; 010:0000001000000190000011600009999000111960099966900212196006666600
;; 013:000000000000000000b0b0000bbbbbb0b1bbbbb0bbbbbb00b000000000000000
;; 014:000000000000000000b0b0b00bbbbbb0b1bbbbb0bbbbbbb0b000000000000000
;; 015:000000000000000000b0b00b0bbbbbbbb1bbbbbbbbbbbbbbb000000b00000000
;; 016:6662cccc06222ccc000000000000000000000000000000000000000000000000
;; 017:0000000000000000001010000111111012111110111111001000000000000000
;; 018:0000000000000000001010100111111012111110111111101000000000000000
;; 019:0000000000000000001010010111111112111111111111111000000100000000
;; 020:0000000000000000001010100111111012111110111111100100001000000000
;; 021:fff77000fff77000000000000000000000000000000000000000000000000000
;; 022:ff000000ff000000000000000000000000000000000000000000000000000000
;; 023:000000000000000000f0f0000f777f77f70000f0000000000000000000000000
;; 024:1119900011199000000000000000000000000000000000000000000000000000
;; 025:00f0000007670000f6f6f0000767000000f00000000000000000000000000000
;; 026:0606600006060000060600000006000006000000000600000000000000000000
;; 029:000000000000000000b0b0b00bbbbbb0b1bbbbb0bbbbbbb00b0000b000000000
;; 032:00f000000ff70000ccf6f000076f000000f00000000000000000000000000000
;; 033:00f000000ff70000ccf6f000076f000000f00000000000000000000000000000
;; 034:00f000000ff70000ccf6f000076f000000f00000000000000000000000000000
;; 035:0cbb0000c1b1b000c111b000b1b1b000abbba0000aaa00000000000000000000
;; 036:717777f077770000077000000000000000000000000000000000000000000000
;; 037:7177770077770000077000000000000000000000000000000000000000000000
;; 038:7177700077770000077000000000000000000000000000000000000000000000
;; 039:71777f0077770000077000000000000000000000000000000000000000000000
;; 040:7777f00077770000077000000000000000000000000000000000000000000000
;; 041:00f000000aca0000fc7cf0000aca000000f00000000000000000000000000000
;; 044:00000000000000060000066000006000000ff000000ff0000000000000000000
;; 045:0000000066666660000000660000000000000000000000000000000000666666
;; 046:0000000000000000600000006600000006000000066000000660000066660000
;; 047:0000000000000000000000000000000000000000000000000000000000000660
;; 048:000000000f0000f00f0660f007766770067cb760066666600b0000b000000000
;; 049:000000000000bcc0000cbcc000bcbcb00abbbb00aaaaa000066a000000600000
;; 050:6aabbccc66aabccc6aabbccc0000000000000000000000000000000000000000
;; 051:000000cc0000bbcc00abbcbbaaaabb006aaa0000660000000000000000000000
;; 052:1210000029200000121000000000000000000000000000000000000000000000
;; 053:2010000009000000102000000000000000000000000000000000000000000000
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
;; 082:000000a000000a800000aa600008888000aaa860088866800caca86006666600
;; 092:0000666600000666000000660000000000000000000000000000000000000000
;; 093:6666666666666666666666666666666600000000000000000000000000000000
;; 094:6666600066660000666000006000000000000000000000000000000000000000
;; 096:000f0000000700000000700000000f0001100070011000700077770000000000
;; 097:0f00f70000700000007000000007110000001100000000000000000000000000
;; 098:0606600006060000060600000006000006000000000600000000000000000000
;; 112:0002000000720000077777000000777000000777000000770000000000000000
;; 113:0000000000000000000000770000077700002770000727000077700000000000
;; 114:0000000000000000000020000007277700777777000000000000000000000000
;; 115:0000000000000000007777000777777077700777770000770000000000000000
;; 116:0000000000000000770000777770077707777770007777000000000000000000
;; 117:0000000000000000000077707007777777777077777700070000000000000000
;; 118:0000000000000000007770000777720077700020770000020000000000000000
;; 119:0000000000000000770000027770002007777200007770000000000000000000
;; 120:0000000000000000000000000000000077077220777700000000000000000000
;; 121:acaaaa20aaaa00000aa000000000000000000000000000000000000000000000
;; 122:acaaaa00aaaa00000aa000000000000000000000000000000000000000000000
;; 123:acaaa000aaaa00000aa000000000000000000000000000000000000000000000
;; 124:acaaa200aaaa00000aa000000000000000000000000000000000000000000000
;; 125:aaaa2000aaaa00000aa000000000000000000000000000000000000000000000
;; 128:000000000000000000000000000bcccc000c6666000c6666000c6666000c6666
;; 129:000000000000000000000000cccccccc66666666666666666666666666666666
;; 130:000000000000000000000000ccccb0006666c0006666c0006666c0006666c000
;; 131:0cc00000cccc0000bccb0000bccb0000bccb0000bccb0000cccc000000000000
;; 132:bcccccb0c66666c0c66666c0c62226c0c66666c0c66666c0bcccccb000000000
;; 133:bcccccb0c66666c0c6bbb6c0c6bbb6c0c6bbb6c0c66666c0bcccccb000000000
;; 134:bcccccb0c66666c0c6ff66c0c66ff6c0c6ff66c0c66666c0bcccccb000000000
;; 135:bcccccb0c66666c0c66cc6c0c6ccc6c0c6cc66c0c66666c0bcccccb000000000
;; 136:8aaaaa80a66666a0a6aaa6a0a6aaa6a0a6aaa6a0a66666a08aaaaa8000000000
;; 137:8aaaaa80a66666a0a6aa66a0a66aa6a0a6aa66a0a66666a08aaaaa8000000000
;; 138:8aaaaa80a66666a0a66aa6a0a6aaa6a0a6aa66a0a66666a08aaaaa8000000000
;; 139:abbbbba0b66666b0b66666b0b62226b0b66666b0b66666b0abbbbba000000000
;; 140:abbbbba0b66666b0b6bbb6b0b6bbb6b0b6bbb6b0b66666b0abbbbba000000000
;; 141:abbbbba0b66666b0b6ff66b0b66ff6b0b6ff66b0b66666b0abbbbba000000000
;; 142:abbbbba0b66666b0b66cc6b0b6ccc6b0b6cc66b0b66666b0abbbbba000000000
;; 144:0000b0000000a000000ccbb0c0bccb66cabbb6aababbb666b0bbbbbb000bbbb0
;; 145:0000c0000000a000000ccbb000bccb66cabbb6aababbb66600bbbbbb000bbbb0
;; 146:0000b0000000a000000ccbb000bccb660abbb6aababbb66600bbbbbb000bbbb0
;; 147:0000c0000000a000000ccbb000bccb66cabbb6aa0abbb66600bbbbbb000bbbb0
;; 148:000000000000000000000000000bcccc000c6666000c6666000c666600000000
;; 149:000000000000000000000000cccccccc66666666666666666666666600000000
;; 150:000000000000000000000000ccccb0006666c0006666c0006666c00000000000
;; 151:0cc00000cccc0000bccb0000bccb0000bccb0000bccb0000cccc000000000000
;; 160:0000f00000007000000ccff0c0fccf88c7fff8aaf7fff888f0ffffff000ffff0
;; 161:0000c00000007000000ccff000fccf88c7fff8aaf7fff88800ffffff000ffff0
;; 162:0000f00000007000000ccff000fccf8807fff8aaf7fff88800ffffff000ffff0
;; 163:0000c00000007000000ccff000fccf88c7fff8aa07fff88800ffffff000ffff0
;; 176:0000c0000000a000000cccc0c0cccc88caccc8aacaccc888c0cccccc000cccc0
;; 177:0000c0000000a000000cccc000cccc88caccc8aacaccc88800cccccc000cccc0
;; 178:0000c0000000a000000cccc000cccc880accc8aacaccc88800cccccc000cccc0
;; 179:0000c0000000a000000cccc000cccc88caccc8aa0accc88800cccccc000cccc0
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
;; 000:56008600a600c600c600d600d600d600d600c600c600c600d600e600e600f600f600f600f600f600f600e600e600e600e600e600e600e600e600e600370000ff0000
;; 001:52002200120032005200720082009200b200b200a200a200c200c200c200c200d200d200d200e200e200f200f200f200f200f200f200f200f200f200570000000000
;; 002:46000600160026002600360046005600760076007600860096009600a600a600b600b600c600d600d600e600e600e600e600e600e600e600e600e600250000000000
;; 003:0009101a300d501e601080019012b002b014c025c026d027d047e037e017e037e037f047f057f067f077f087f096f0a6f0b6f0a6f0b6f0c6f0d6f0e6315000000000
;; 004:0390435083509330a330c330c320a330b340b350c340c310c300d300d300e300e300e300f300f300f300f300f300f300f300f300f300f300f300f300100000000000
;; 005:3a053a153a342a342a5d2a661a311a831a711ae01ac66ad5faeffaecfafcfaf0fa6efa70fa80fa40faa0fa40fa81faa1fa8efa23fa80fa60fa60fa80670000000000
;; 006:420022001200320042005200520062006200620062007200720082008200820082009200a200a200b200c200c200c200d200d200e200e200e200f200570000000000
;; 007:30e04050201010e0300000a0007030c030e0006010c0208030b030b090e0a0a0b000c000c0a0d000d0a0e060e020e000c0d0e000f000f000f000f000482000000000
;; 008:b900a900292029c059708940c9c0f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900f900550000000000
;; 009:090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900304000000000
;; 010:0a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a00300000000000
;; 011:0b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b000b00300000000000
;; 012:0c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c000c00309000000000
;; 013:0d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d00300000000000
;; 014:0e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e00309000000000
;; 015:0f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f00309000000000
;; </SFX>

;; <PATTERNS>
;; 000:d76106d11004433006411004833006811004433006411004d33006d11004933006911004833006811004633006611004833006811004933004911002433006411004633006611004833006811004633006611004433006411004833006811004633006611004c33004c11002f33004f11002433006411004633006611004833006811004933006911004933006911004833006811004433006411004833006811004433006411004d33004d11002933006911004833006811004633006611004
;; 001:d67168000000034600000000000000000000000000000000000000000000000000000000823668000000000000000000906468000000000000000000000000000000000000000000000000000000000000000000400018000000600418000000800018000000000000900618900018000000000000800018800018000000000000600018600018000000900018000000808468000000000000034600000000000000000000000000000000000000000000000000000000000000000000000000
;; 002:d67168000000034600000000000000000000000000000000023600000000000000023000d04468000000000000000000f06468000000000000000000000000000000000000000000000000000000800418000000900018000000400018000000f00066000000000000000000400018000000400018000000400018000000600018400018600018000000804418000000800418000000000000000000400018000000000000000000d00016000000000000000000900016000000000000000000
;; 003:867118000000d00018600018806468034600000000000000000000000000600418000000600018000000400018000000800018000000d00018600018806468000000000000000000000000000000000000000000800418000000400018600018f00016000000400018000000600018000000606418000000000000000000400418000000800018000000600018800018906418000000800418000000600018000000812468000000000000000000000000000000400418000000600018000000
;; 004:d67118000000400018800018d06468000000034600000000000000000000f0041800000040001a00000060001a00000080841a04660000000000000000000000000060046a00000000000000000000000000000000000000000080001a00000080006a000000000000000000000000000000d43618000000d00018000000600018800018606418000000400418000000400068000000000000034600000000000000000000000000000000000000000000000000000000000000000000000000
;; 005:d65124000000000000000000000000000000000000000000000000000000000000000000d00024000000000000000000600024000000000000000000000000000000000000000000000000000000000000000000600024000000000000000000800024000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000d00022000000000000000000000000000000000000000000000000000000000000000000d00022000000000000000000
;; 006:d65124000000000000000000000000000000000000000000000000000000000000000000d00024000000000000000000900024000000000000000000000000000000000000000000000000000000000000000000900024000000000000000000800024000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000d00024000000000000000000000000000000000000000000000000000000000000000000d00024000000000000000000
;; 007:d65124000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 008:d65124000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000400024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 009:d67166000000023000000000011600000000000000000000000000000000000000000000811666000000000000000000906466000000000000000000000000000000000000000000000000000000000000000000400016000000600416000000800016000000000000900616900016000000000000800016800016000000000000600016600016000000900016000000808466000000000000023600000000000000000000000000000000000000000000000000000000000000000000000000
;; 010:d67166000000023600000000000000000000000000000000012600000000000000023000d04466000000000000000000f06466000000000000000000000000000000000000000000000000000000800416000000900016000000400016000000f00064000000000000000000400016000000400016000000400016000000600016400016600016000000804416000000800416000000000000000000400016000000000000000000d00014000000000000000000900014000000000000000000
;; 011:867116000000d00016600016806466023600000000000000000000000000600416011600600016000000400016000000800016000000d00016600016806466000000000000012600000000000000000000000000800416012000400016600016f00014000000400016000000600016000000606416000000000000000000400416000000800016000000600016800016906416000000800416000000600016000000812466000000000000023600000000000000400416012600600016000000
;; 012:d67116000000400016800016d06466000000012600000000000000000000f00416000000400018000000600018000000808418012600000000000000000000000000600468000000000000023600000000000000000000000000800018000000800068000000000000000000000000000000d12616000000d00016000000600016800016606416000000400416000000400066000000000000023600000000000000000000000000000000000000000000000000000000000000000000000000
;; 013:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000411106000000622106000000833006000000933106000000922006000000833006000000422006000000833006000000400006000000d00004000000900006000000800006000000600006000000
;; 014:000000000000d33106d11004433006411004833006811004433006411004d33006d11004933006911004833006811004633006611004833006811004933004911002433006411004633006611004833006811004633006611004433006411004833006811004633006611004c33004c11002f33004f11002433006411004633006611004643124000000400024000000d00022000000000000000000000000000000000000000000000000000000000000000000d00022000000000000000000
;; 015:000000d45106d11004433006411004833006811004433006411004d33006d11004933006911004833006811004633006611004833006811004933004911002433006411004633006611004833006811004633006611004433006411004833006811004633006611004c33004c11002f33004f11002433006411004633006611004833006811004933006911004933006911004833006811004433006411004833006811004433006411004d33004d11002933006911004833006811004633006
;; 016:d76124000000000000000000000000000000000000000000000000000000000000000000d00024000000000000000000600024000000000000000000000000000000000000000000000000000000000000000000600024000000000000000000800024000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000d00022000000000000000000000000000000000000000000000000000000000000000000d00022000000000000000000
;; </PATTERNS>

;; <TRACKS>
;; 000:104f001041101826001c27001038001439001806001c0700101800e419000000000000000000000000000000000000002e0000
;; 001:180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; </TRACKS>

;; <PALETTE>
;; 000:141428fa0c36bbcc5204fa0400ff000c0c10202d518e2e913c405591142c5d8161599dcaf2f4f60cff08201834f661ba
;; </PALETTE>

