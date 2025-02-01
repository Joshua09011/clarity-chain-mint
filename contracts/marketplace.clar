;; Marketplace Contract
(define-map listings
  uint
  {
    price: uint,
    seller: principal,
    active: bool
  }
)

(define-constant err-not-owner (err u201))
(define-constant err-not-listed (err u202))
(define-constant err-wrong-price (err u203))

;; Create listing
(define-public (list-asset (asset-id uint) (price uint))
  (let ((asset-contract (contract-call? .asset-registry get-asset asset-id)))
    (asserts! (is-eq (get owner asset-contract) tx-sender) err-not-owner)
    (map-set listings asset-id
      {
        price: price,
        seller: tx-sender,
        active: true
      }
    )
    (ok true)
  )
)

;; Purchase asset
(define-public (purchase-asset (asset-id uint))
  (let (
    (listing (unwrap! (map-get? listings asset-id) err-not-listed))
    (price (get price listing))
  )
    (asserts! (get active listing) err-not-listed)
    (try! (stx-transfer? price tx-sender (get seller listing)))
    (try! (contract-call? .asset-registry transfer-asset asset-id tx-sender))
    (map-delete listings asset-id)
    (ok true)
  )
)
