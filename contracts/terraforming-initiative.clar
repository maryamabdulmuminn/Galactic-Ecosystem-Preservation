;; Terraforming Initiative Contract

(define-data-var initiative-counter uint u0)

(define-map terraforming-initiatives uint {
    planet-name: (string-ascii 50),
    description: (string-utf8 1000),
    target-parameters: (list 5 (string-ascii 50)),
    status: (string-ascii 20),
    start-date: uint,
    estimated-completion: uint,
    coordinator: principal
})

(define-public (create-initiative (planet-name (string-ascii 50)) (description (string-utf8 1000)) (target-parameters (list 5 (string-ascii 50))) (estimated-completion uint))
    (let
        ((initiative-id (+ (var-get initiative-counter) u1)))
        (map-set terraforming-initiatives initiative-id {
            planet-name: planet-name,
            description: description,
            target-parameters: target-parameters,
            status: "planning",
            start-date: block-height,
            estimated-completion: estimated-completion,
            coordinator: tx-sender
        })
        (var-set initiative-counter initiative-id)
        (ok initiative-id)
    )
)

(define-public (update-initiative-status (initiative-id uint) (new-status (string-ascii 20)))
    (let
        ((initiative (unwrap! (map-get? terraforming-initiatives initiative-id) (err u404))))
        (asserts! (is-eq tx-sender (get coordinator initiative)) (err u403))
        (ok (map-set terraforming-initiatives initiative-id
            (merge initiative { status: new-status })))
    )
)

(define-read-only (get-initiative (initiative-id uint))
    (map-get? terraforming-initiatives initiative-id)
)

(define-read-only (get-initiative-count)
    (var-get initiative-counter)
)

