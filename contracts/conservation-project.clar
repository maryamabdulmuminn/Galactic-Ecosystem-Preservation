;; Conservation Project Management Contract

(define-data-var project-counter uint u0)

(define-map conservation-projects uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    planet: (string-ascii 50),
    star-system: (string-ascii 50),
    coordinator: principal,
    status: (string-ascii 20),
    start-date: uint,
    end-date: uint
})

(define-public (create-project (name (string-ascii 100)) (description (string-utf8 1000)) (planet (string-ascii 50)) (star-system (string-ascii 50)) (end-date uint))
    (let
        ((project-id (+ (var-get project-counter) u1)))
        (map-set conservation-projects project-id {
            name: name,
            description: description,
            planet: planet,
            star-system: star-system,
            coordinator: tx-sender,
            status: "active",
            start-date: block-height,
            end-date: end-date
        })
        (var-set project-counter project-id)
        (ok project-id)
    )
)

(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
    (let
        ((project (unwrap! (map-get? conservation-projects project-id) (err u404))))
        (asserts! (is-eq tx-sender (get coordinator project)) (err u403))
        (ok (map-set conservation-projects project-id
            (merge project { status: new-status })))
    )
)

(define-read-only (get-project (project-id uint))
    (map-get? conservation-projects project-id)
)

(define-read-only (get-project-count)
    (var-get project-counter)
)

