;; Blue-Screen-of-App - Guix Package Definition
;; Run: guix shell -D -f guix.scm

(use-modules (guix packages)
             (guix gexp)
             (guix git-download)
             (guix build-system node)
             ((guix licenses) #:prefix license:)
             (gnu packages base))

(define-public blue_screen_of_app
  (package
    (name "Blue-Screen-of-App")
    (version "0.1.0")
    (source (local-file "." "Blue-Screen-of-App-checkout"
                        #:recursive? #t
                        #:select? (git-predicate ".")))
    (build-system node-build-system)
    (synopsis "ReScript application")
    (description "ReScript application - part of the RSR ecosystem.")
    (home-page "https://github.com/hyperpolymath/Blue-Screen-of-App")
    (license license:agpl3+)))

;; Return package for guix shell
blue_screen_of_app
