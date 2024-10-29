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

;; Function to add a new player 
(define-public (add-player (name (string-ascii 100)) (salary uint))
  (let 
    ((player-entry { name: name }))
    (begin
      ;; Input validation
      (asserts! (> salary u0) (err u1))
      (asserts! (is-none (map-get? player-map player-entry)) (err u2))
      ;; Check if player is already active
      (asserts! (is-none (map-get? active-players name)) (err u3))
      ;; Add player
      (map-set player-map player-entry { salary: salary, active: true })
      (add-to-set name)
      (ok true)
    )
  )
)

;; Function to remove a player 
(define-public (remove-player (name (string-ascii 100)))
  (let 
    ((player-entry { name: name }))
    (begin
      ;; Check if player exists and is active
      (asserts! (is-some (map-get? player-map player-entry)) (err u2))
      (asserts! (default-to false (map-get? active-players name)) (err u3))
      ;; Remove player
      (map-set player-map player-entry { salary: u0, active: false })
      (remove-from-set name)
      (ok true)
    )
  )
)

;; Reward for Fan based on fan engagement 
(define-public (reward-fan (fan-id principal) (engagement uint))
  (let 
    (
      (reward-amount (* engagement REWARD_MULTIPLIER))
      (current-reward (default-to u0 (map-get? fan-rewards fan-id)))
    )
    (begin
      ;; Input validation
      (asserts! (> engagement u0) (err u1))
      (asserts! (<= reward-amount MAX_REWARD) (err u2))
      ;; Check for potential overflow
      (asserts! (<= (+ current-reward reward-amount) MAX_REWARD) (err u3))
      ;; Update rewards
      (map-set fan-rewards fan-id (+ current-reward reward-amount))
      (ok reward-amount)
    )
  )
)

;; Get rewards for a specific fan 
(define-read-only (get-fan-rewards (fan-id principal))
  (ok (default-to u0 (map-get? fan-rewards fan-id)))
)

;; Function to get a player's details
(define-read-only (get-player-details (name (string-ascii 100)))
  (let 
    ((player-entry { name: name }))
    (match (map-get? player-map player-entry)
      player (ok player)
      (err u3)  ;; Player not found
    )
  )
)

;; Function to check if player is active
(define-read-only (is-player-active (name (string-ascii 100)))
  (match (map-get? active-players name)
    active (ok active)
    (ok false)
  )
)