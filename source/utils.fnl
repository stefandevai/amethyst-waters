;; Loads custom palette using a string. See <https://github.com/nesbox/TIC-80/wiki/palette> for more information.
(fn load-palette [str]
  (for [i 0 15 1]
    (poke (+ 0x03FC0 (* i 3))
          (tonumber (string.sub str (+ (* i 6) 1) (+ (* i 6) 2)) 16))

    (poke (+ 0x03FC0 (* i 3) 1)
          (tonumber (string.sub str (+ (* i 6) 3) (+ (* i 6) 4)) 16))

    (poke (+ 0x03FC0 (* i 3) 2)
          (tonumber (string.sub str (+ (* i 6) 5) (+ (* i 6) 6)) 16))))

