;; test-xbtc-staking.clar

;; Test the xBTC staking functionality
(begin
  (asserts! (is-eq (contract-call? .staking stake-xbtc u500) (ok u500)) (err u300))
  (asserts! (is-eq (contract-call? .staking unstake-xbtc) (ok u500)) (err u301))
  (asserts! (is-eq (contract-call? .staking claim-xbtc-rewards) (ok u75)) (err u302)) ;; 15% of 500
)
