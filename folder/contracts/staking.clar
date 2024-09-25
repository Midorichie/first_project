(define-data-var liquidity-pool uint 0)
(define-data-var rewards-pool uint 1000000)
(define-map stakes { staker: principal } { staked-amount: uint })

(define-public (stake (amount uint))
  (begin
    ;; Ensure the staker sends a positive amount to stake
    (asserts! (> amount u0) (err u100))

    ;; Update the staker's record in the stakes map
    (map-set stakes { staker: tx-sender } { staked-amount: amount })

    ;; Add the staked amount to the liquidity pool
    (var-set liquidity-pool (+ (var-get liquidity-pool) amount))

    ;; Return success
    (ok amount)
  )
)

(define-public (unstake)
  (let ((staked-amount (get staked-amount (map-get? stakes { staker: tx-sender }))))
    ;; Ensure the staker has staked tokens
    (if (is-some staked-amount)
      (let ((amount (unwrap! staked-amount (err u101))))
        ;; Update the liquidity pool by removing the staked amount
        (var-set liquidity-pool (- (var-get liquidity-pool) amount))

        ;; Remove the staker's record
        (map-delete stakes { staker: tx-sender })

        ;; Return the unstaked amount to the user
        (ok amount)
      )
      (err u102) ;; Error if the user has not staked
    )
  )
)

(define-public (claim-rewards)
  (let ((staked-amount (get staked-amount (map-get? stakes { staker: tx-sender }))))
    ;; Ensure the user has staked tokens
    (if (is-some staked-amount)
      (let ((amount (unwrap! staked-amount (err u103)))
            (reward (* amount u10))) ;; Simple reward calculation (10% of staked amount)

        ;; Deduct from the rewards pool
        (var-set rewards-pool (- (var-get rewards-pool) reward))

        ;; Transfer the reward to the staker
        (ok reward)
      )
      (err u104) ;; Error if the user has no staked tokens
    )
  )
)
