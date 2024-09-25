(define-data-var xbtc-liquidity-pool uint 0) ;; New liquidity pool for xBTC
(define-data-var xbtc-rewards-pool uint 500000) ;; Separate rewards pool for xBTC staking

(define-map xbtc-stakes { staker: principal } { staked-amount: uint })

;; STX staking methods remain unchanged

;; New method for xBTC staking
(define-public (stake-xbtc (amount uint))
  (begin
    ;; Ensure the staker sends a positive amount to stake
    (asserts! (> amount u0) (err u100))

    ;; Update the staker's record in the xbtc-stakes map
    (map-set xbtc-stakes { staker: tx-sender } { staked-amount: amount })

    ;; Add the staked amount to the xbtc-liquidity-pool
    (var-set xbtc-liquidity-pool (+ (var-get xbtc-liquidity-pool) amount))

    ;; Return success
    (ok amount)
  )
)

;; New method for unstaking xBTC
(define-public (unstake-xbtc)
  (let ((staked-amount (get staked-amount (map-get? xbtc-stakes { staker: tx-sender }))))
    ;; Ensure the staker has staked xBTC tokens
    (if (is-some staked-amount)
      (let ((amount (unwrap! staked-amount (err u101))))
        ;; Update the xbtc-liquidity-pool by removing the staked amount
        (var-set xbtc-liquidity-pool (- (var-get xbtc-liquidity-pool) amount))

        ;; Remove the staker's record
        (map-delete xbtc-stakes { staker: tx-sender })

        ;; Return the unstaked amount to the user
        (ok amount)
      )
      (err u102) ;; Error if the user has not staked xBTC
    )
  )
)

;; New method for claiming xBTC rewards
(define-public (claim-xbtc-rewards)
  (let ((staked-amount (get staked-amount (map-get? xbtc-stakes { staker: tx-sender }))))
    ;; Ensure the user has staked xBTC
    (if (is-some staked-amount)
      (let ((amount (unwrap! staked-amount (err u103)))
            (reward (* amount u15))) ;; Simple reward calculation (15% of staked amount)

        ;; Deduct from the xbtc-rewards-pool
        (var-set xbtc-rewards-pool (- (var-get xbtc-rewards-pool) reward))

        ;; Transfer the reward to the staker
        (ok reward)
      )
      (err u104) ;; Error if the user has no staked xBTC
    )
  )
)

;; Helper function to calculate yield distribution based on pool performance
(define-public (distribute-rewards)
  (let ((stx-liquidity (var-get liquidity-pool))
        (xbtc-liquidity (var-get xbtc-liquidity-pool)))
    ;; Distribute rewards proportionally based on the performance of the liquidity pools
    (ok (tuple (stx-rewards (var-get rewards-pool))
               (xbtc-rewards (var-get xbtc-rewards-pool))))
  )
)
