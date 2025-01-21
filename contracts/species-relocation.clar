;; Species Relocation Contract

(define-data-var relocation-counter uint u0)

(define-map species-relocations uint {
    species-name: (string-ascii 100),
    origin-planet: (string-ascii 50),
    destination-planet: (string-ascii 50),
    quantity: uint,
    status: (string-ascii 20),
    relocation-date: uint,
    coordinator: principal
})

(define-public (initiate-relocation (species-name (string-ascii 100)) (origin-planet (string-ascii 50)) (destination-planet (string-ascii 50)) (quantity uint))
    (let
        ((relocation-id (+ (var-get relocation-counter) u1)))
        (map-set species-relocations relocation-id {
            species-name: species-name,
            origin-planet: origin-planet,
            destination-planet: destination-planet,
            quantity: quantity,
            status: "planned",
            relocation-date: block-height,
            coordinator: tx-sender
        })
        (var-set relocation-counter relocation-id)
        (ok relocation-id)
    )
)

(define-public (update-relocation-status (relocation-id uint) (new-status (string-ascii 20)))
    (let
        ((relocation (unwrap! (map-get? species-relocations relocation-id) (err u404))))
        (asserts! (is-eq tx-sender (get coordinator relocation)) (err u403))
        (ok (map-set species-relocations relocation-id
            (merge relocation { status: new-status })))
    )
)

(define-read-only (get-relocation (relocation-id uint))
    (map-get? species-relocations relocation-id)
)

(define-read-only (get-relocation-count)
    (var-get relocation-counter)
)

