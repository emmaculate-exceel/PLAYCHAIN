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

;; Helper function to add to active players
(define-private (add-to-set (value (string-ascii 100)))
  (begin 
    (map-set active-players value true)
    true)
)

;; Helper function to remove from active players
(define-private (remove-from-set (value (string-ascii 100)))
  (begin
    (map-delete active-players value)
    true)
)
