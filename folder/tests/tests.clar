;; test-xbtc-staking.clar

;; Test the xBTC staking functionality
(begin
  ;; Test staking xBTC
  (asserts! (is-eq (contract-call? .staking stake-xbtc u500) (ok u500)) (err u300))
  
  ;; Test unstaking xBTC
  (asserts! (is-eq (contract-call? .staking unstake-xbtc) (ok u500)) (err u301))
  
  ;; Test claiming xBTC rewards (15% of staked amount)
  (asserts! (is-eq (contract-call? .staking claim-xbtc-rewards) (ok u75)) (err u302)) ;; 15% of 500

  ;; Test auto-compounding functionality when enabled
  (asserts! (is-eq (contract-call? .staking set-auto-compounding true) (ok true)) (err u400))
  (asserts! (is-eq (contract-call? .staking stake-xbtc-with-auto-compounding u500) (ok u575)) (err u401)) ;; 500 + 75 (claimed reward)

  ;; Test yield optimization feature
  (asserts! (is-eq (contract-call? .staking set-yield-optimization true) (ok true)) (err u402))

  ;; Test creating a governance proposal
  (asserts! (is-eq (contract-call? .staking create-proposal "Adjust fee structure") (ok u0)) (err u403))

  ;; Test voting on a governance proposal
  (asserts! (is-eq (contract-call? .staking vote-on-proposal u0) (ok u1)) (err u404))

  ;; Test executing a governance proposal
  (asserts! (is-eq (contract-call? .staking execute-proposal u0) (ok "Adjust fee structure")) (err u405)) ;; Placeholder execution logic
)
