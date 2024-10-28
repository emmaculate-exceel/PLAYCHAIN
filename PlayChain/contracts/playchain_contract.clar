;; Define constants 
(define-constant PLAYER_COUNT u50)
(define-constant REWARD_MULTIPLIER u10)
(define-constant MAX_REWARD u1000000) ;; Add maximum reward limit

;; Define maps for data storage
(define-map fan-rewards principal uint)
(define-map active-players (string-ascii 100) bool)
(define-map player-map 
  { name: (string-ascii 100) } 
  { 
    salary: uint,
    active: bool 
  }
)

