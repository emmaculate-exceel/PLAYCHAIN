;; Define constants 
(define-constant PLAYER_COUNT u50)
(define-constant REWARD_MULTIPLIER u10)
(define-constant MAX_REWARD u1000000)

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

;; Function to update player salary
(define-public (update-player-salary (name (string-ascii 100)) (new-salary uint))
  (let 
    ((player-entry { name: name }))
    (begin
      ;; Validate player exists and is active
      (asserts! (is-some (map-get? player-map player-entry)) (err u1))
      (asserts! (default-to false (map-get? active-players name)) (err u2))
      
      ;; Input validation for new salary
      (asserts! (> new-salary u0) (err u3))
      
      ;; Update player salary
      (map-set player-map 
        player-entry 
        (merge 
          (unwrap! (map-get? player-map player-entry) (err u4)) 
          { salary: new-salary }
        )
      )
      (ok true)
    )
  )
)

;; Function to bulk add players
(define-public (bulk-add-players (players (list 50 { name: (string-ascii 100), salary: uint })))
  (begin 
    (try! (fold bulk-add-player-fold players (ok true)))
    (ok true)
  )
)

;; Helper function for bulk add using fold
(define-private (bulk-add-player-fold 
  (player { name: (string-ascii 100), salary: uint }) 
  (result (response bool uint))
)
  (match result
    prev-result
    (match (add-player (get name player) (get salary player))
      success (ok true)
      error (err error)
    )
    error-val (err error-val)
  )
)

;; Function to calculate total active player payroll
(define-read-only (get-total-active-payroll)
  (let 
    ((player-names (list 
      "player1" "player2" "player3" "player4" "player5"
      "player6" "player7" "player8" "player9" "player10"
    )))
    (ok (fold calculate-active-salary player-names u0))
  )
)

;; Helper function to calculate active player salaries
(define-private (calculate-active-salary 
  (name (string-ascii 100)) 
  (total uint)
)
  (match (map-get? player-map { name: name })
    player-details 
      (if (get active player-details)
        (+ total (get salary player-details))
        total
      )
    total
  )
)

;; Function to transfer fan rewards
(define-public (transfer-fan-rewards 
  (fan-id principal) 
  (recipient principal) 
  (amount uint)
)
  (let 
    ((current-rewards (default-to u0 (map-get? fan-rewards fan-id))))
    (begin
      ;; Validate transfer amount
      (asserts! (>= current-rewards amount) (err u1))
      
      ;; Update fan rewards
      (map-set fan-rewards fan-id (- current-rewards amount))
      
      ;; Placeholder for token transfer event
      (print { 
        type: "fan-reward-transfer", 
        fan-id: fan-id, 
        recipient: recipient, 
        amount: amount 
      })
      
      (ok true)
    )
  )
)

;; Previous code remains the same...

;; Helper function to compare fan rewards
(define-private (compare-fan-rewards 
  (a { fan: principal, rewards: uint }) 
  (b { fan: principal, rewards: uint })
)
  (> (get rewards a) (get rewards b))
)

;; Helper function to sort fan rewards list
(define-private (sort-fans-by-rewards 
  (fans (list 100 { fan: principal, rewards: uint }))
)
  (fold 
    (lambda 
      (current 
       (sorted-list (list 100 { fan: principal, rewards: uint }))
      )
      (insert-sorted current sorted-list)
    )
    fans
    (list)
  )
)

;; Helper function to insert an item into a sorted list
(define-private (insert-sorted 
  (item { fan: principal, rewards: uint }) 
  (sorted-list (list 100 { fan: principal, rewards: uint }))
)
  (if (is-eq sorted-list (list))
    (list item)
    (let 
      ((first-item (unwrap-panic (element-at sorted-list u0))))
      (if (compare-fan-rewards item first-item)
        (unwrap-panic (as-max-len (concat (list item) sorted-list) u100))
        (unwrap-panic (as-max-len (concat sorted-list (list item)) u100))
      )
    )
  )
)

;; Function to get top fans
(define-read-only (get-top-fans 
  (fans (list 100 principal)) 
  (count uint)
)
  (let 
    (
      (fan-rewards-list 
        (map 
          (lambda (fan) 
            { 
              fan: fan, 
              rewards: (default-to u0 (map-get? fan-rewards fan)) 
            }
          ) 
          fans
        )
      )
      (sorted-fans (sort-fans-by-rewards fan-rewards-list))
      (top-fans 
        (map 
          (get fan) 
          (take 
            (min count (len sorted-fans)) 
            sorted-fans
          )
        )
      )
    )
    (ok top-fans)
  )
)

;; Wrapper function to get top fans from a predefined list
(define-read-only (get-top-fans-default (count uint))
  (let 
    ((all-fans (list 
      tx-sender
      (as-contract tx-sender)
    )))
    (get-top-fans all-fans count)
  )
)