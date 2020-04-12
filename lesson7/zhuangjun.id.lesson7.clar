; 定义map tokens， 键：账户, 值: 余额
(define-map tokens ((account principal)) ((balance uint)))

; 函数get-balance, 从tokens中根据账户取得余额， 默认为0
(define-private (get-balance (account principal))
  (default-to u0 (get balance (map-get? tokens (tuple (account account))))))

; 函数token-credit!， 账户余额增加。 如果增加值<=0,抛错。
(define-private (token-credit! (account principal) (amount uint))
  (if (<= amount u0)
      (err "must move positive balance")
      (let ((current-amount (get-balance account)))
        (begin
          (map-set tokens (tuple (account account))
                      (tuple (balance (+ amount current-amount))))
          (ok amount)))))

; 函数token-transfer， 代币转账, tx-sender, 减少指定数量， to增加指定数量， 
(define-public (token-transfer (to principal) (amount uint))
  (let ((balance (get-balance tx-sender)))
    (if (or (> amount balance) (<= amount u0))
        (err "must transfer positive balance and possess funds")
        (begin
          (map-set tokens (tuple (account tx-sender))
                      (tuple (balance (- balance amount))))
          (token-credit! to amount)))))

; 函数mint!， tx-sender获得指定数量的代币
(define-public (mint! (amount uint))
   (let ((balance (get-balance tx-sender)))
     (token-credit! tx-sender amount)))