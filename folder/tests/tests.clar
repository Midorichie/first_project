;; test-staking.clar

;; Test the staking functionality
(begin
  (asserts! (is-eq (contract-call? .staking stake u100) (ok u100)) (err u200))
  (asserts! (is-eq (contract-call? .staking unstake) (ok u100)) (err u201))
  (asserts! (is-eq (contract-call? .staking claim-rewards) (ok u10)) (err u202))
)
