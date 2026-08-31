;; SPDX-License-Identifier: MPL-2.0
;; Guix development environment.
;; Usage: guix shell -D -f guix.scm

(use-modules (guix packages)
             (guix build-system gnu)
             (guix licenses)
             (gnu packages base)
             (gnu packages bash)
             (gnu packages zig)
             (gnu packages base)
             (gnu packages java)
             (gnu packages node)
             (gnu packages rust)
             (gnu packages golang)
             (gnu packages python)
             (gnu packages cmake))

(package
  (name "blue-screen-of-app")
  (version "0.1.0")
  (source #f)
  (build-system gnu-build-system)
  (inputs (list coreutils bash  zig make openjdk node rust go python cmake))
  (synopsis "blue-screen-of-app")
  (description "blue-screen-of-app — part of the hyperpolymath ecosystem.")
  (home-page "https://github.com/hyperpolymath/blue-screen-of-app")
  (license ((@@ (guix licenses) license) "MPL-2.0" "https://github.com/hyperpolymath/palimpsest-license")))
