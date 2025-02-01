;; Asset Registry Contract
(define-non-fungible-token asset-token uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-asset-exists (err u101))
(define-constant err-not-found (err u102))
(define-constant err-unauthorized (err u103))

;; Asset data structure
(define-map assets
  uint
  {
    owner: principal,
    verifier: principal,
    metadata: (string-utf8 256),
    verified: bool,
    created-at: uint
  }
)

;; Track the next available asset ID
(define-data-var next-asset-id uint u1)

;; Create new asset
(define-public (create-asset (metadata (string-utf8 256)) (verifier principal))
  (let ((asset-id (var-get next-asset-id)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? asset-token asset-id tx-sender))
    (map-set assets asset-id
      {
        owner: tx-sender,
        verifier: verifier,
        metadata: metadata,
        verified: false,
        created-at: block-height
      }
    )
    (var-set next-asset-id (+ asset-id u1))
    (ok asset-id)
  )
)

;; Transfer asset
(define-public (transfer-asset (asset-id uint) (recipient principal))
  (let ((asset (unwrap! (map-get? assets asset-id) err-not-found)))
    (asserts! (is-eq (get owner asset) tx-sender) err-unauthorized)
    (try! (nft-transfer? asset-token asset-id tx-sender recipient))
    (map-set assets asset-id
      (merge asset { owner: recipient })
    )
    (ok true)
  )
)

;; Verify asset
(define-public (verify-asset (asset-id uint))
  (let ((asset (unwrap! (map-get? assets asset-id) err-not-found)))
    (asserts! (is-eq (get verifier asset) tx-sender) err-unauthorized)
    (map-set assets asset-id
      (merge asset { verified: true })
    )
    (ok true)
  )
)

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (ok (map-get? assets asset-id))
)
