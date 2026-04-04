;; SPDX-License-Identifier: PMPL-1.0-or-later
;; TESTING-REPORT.scm - Blue Screen of App Testing Report
;; Generated: 2025-12-29
;; Format: Guile Scheme S-expression

(testing-report
  (metadata
    (version "1.0.0")
    (schema-version "1.0.0")
    (created "2025-12-29T00:00:00Z")
    (updated "2025-12-29T00:00:00Z")
    (project "blue-screen-of-app")
    (project-version "2.0.0")
    (report-type "comprehensive-testing"))

  (environment
    (runtime "Deno")
    (runtime-version "1.45.0")
    (v8-version "12.7.224.12")
    (typescript-version "5.5.2")
    (os "Linux")
    (os-version "Fedora 43")
    (architecture "x86_64")
    (test-framework "deno-test-native"))

  (summary
    (overall-status "PASS")
    (total-tests 40)
    (passed-tests 40)
    (failed-tests 0)
    (skipped-tests 0)
    (pass-rate 100.0)
    (total-duration-ms 1500)
    (coverage
      (line-coverage 97.4)
      (branch-coverage 83.3)))

  (test-suites
    (suite
      (name "unit/analytics")
      (file "tests/unit/analytics.test.js")
      (category "unit")
      (total 8)
      (passed 8)
      (failed 0)
      (duration-ms 10)
      (tests
        (test (name "trackVisit should increment total visits") (status "pass"))
        (test (name "trackVisit should track style views") (status "pass"))
        (test (name "trackVisit should track error code views") (status "pass"))
        (test (name "trackVisit should track custom messages") (status "pass"))
        (test (name "trackApiCall should increment API calls") (status "pass"))
        (test (name "getStatsObject should return complete summary") (status "pass"))
        (test (name "getUptime should return positive number") (status "pass"))
        (test (name "resetStats should reset all counters") (status "pass"))))

    (suite
      (name "unit/errorMessages")
      (file "tests/unit/errorMessages.test.js")
      (category "unit")
      (total 10)
      (passed 10)
      (failed 0)
      (duration-ms 10)
      (tests
        (test (name "getRandomErrorJS should return valid error object") (status "pass"))
        (test (name "getRandomErrorJS should return percentage between 0 and 100") (status "pass"))
        (test (name "getRandomErrorJS should return valid stop code from list") (status "pass"))
        (test (name "getRandomErrorJS should return different errors on multiple calls") (status "pass"))
        (test (name "getErrorByCodeJS should return correct error for valid code") (status "pass"))
        (test (name "getErrorByCodeJS should handle lowercase and dashes") (status "pass"))
        (test (name "getErrorByCodeJS should return null for invalid code") (status "pass"))
        (test (name "getErrorByCodeJS should return description for known codes") (status "pass"))
        (test (name "getAllStopCodes should return humorous error codes") (status "pass"))
        (test (name "getAllStopCodes should return non-empty array") (status "pass"))))

    (suite
      (name "integration/api")
      (file "tests/integration/api.test.js")
      (category "integration")
      (total 12)
      (passed 12)
      (failed 0)
      (duration-ms 1000)
      (tests
        (test (name "GET /api/error should return random error data") (status "pass"))
        (test (name "GET /api/error/:code should return specific error") (status "pass"))
        (test (name "GET /api/error/:code should handle lowercase codes") (status "pass"))
        (test (name "GET /api/error/:code should return 404 for invalid code") (status "pass"))
        (test (name "GET /api/codes should return list of error codes") (status "pass"))
        (test (name "GET /api/codes should include humorous codes") (status "pass"))
        (test (name "GET /api/styles should return list of available styles") (status "pass"))
        (test (name "GET /api/analytics should return analytics summary") (status "pass"))
        (test (name "GET /api/analytics should track API calls") (status "pass"))
        (test (name "GET /api/health should return health status") (status "pass"))
        (test (name "POST /api/analytics/reset should reset analytics") (status "pass"))
        (test (name "GET /unknown-route should return 404") (status "pass"))))

    (suite
      (name "integration/bsod")
      (file "tests/integration/bsod.test.js")
      (category "integration")
      (total 10)
      (passed 10)
      (failed 0)
      (duration-ms 300)
      (tests
        (test (name "GET / should render BSOD page with default style") (status "pass"))
        (test (name "GET /?style=win10 should accept style parameter") (status "pass"))
        (test (name "GET /?code=COFFEE_NOT_FOUND should accept custom error code") (status "pass"))
        (test (name "GET /?message=Custom should accept custom message") (status "pass"))
        (test (name "GET /?technical=Custom should accept custom technical detail") (status "pass"))
        (test (name "GET /?percentage=75 should accept custom percentage") (status "pass"))
        (test (name "GET / with multiple parameters should handle them all") (status "pass"))
        (test (name "GET /random should redirect to a style") (status "pass"))
        (test (name "GET /random should redirect to different styles") (status "pass"))
        (test (name "GET /unknown-route should return 404") (status "pass")))))

  (coverage-details
    (file
      (name "Analytics.bs.js")
      (path "src/Analytics.bs.js")
      (line-coverage 94.9)
      (branch-coverage 100.0))
    (file
      (name "ErrorMessages.bs.js")
      (path "src/ErrorMessages.bs.js")
      (line-coverage 98.9)
      (branch-coverage 75.0)))

  (issues-found
    (issue
      (id "ISSUE-001")
      (severity "critical")
      (title "Node.js/Jest Tests Incompatible with Deno")
      (description "Original test files used CommonJS require syntax and Jest framework")
      (resolution "Rewrote all tests using Deno native test framework with ES modules")
      (status "resolved")
      (files-modified
        "tests/unit/analytics.test.js"
        "tests/unit/errorMessages.test.js"
        "tests/integration/api.test.js"
        "tests/integration/bsod.test.js"))

    (issue
      (id "ISSUE-002")
      (severity "medium")
      (title "Lint Errors in server.js")
      (description "Async functions without await expressions and unused variables")
      (resolution "Removed unnecessary async keywords and prefixed unused parameters")
      (status "resolved")
      (files-modified "src/server.js"))

    (issue
      (id "ISSUE-003")
      (severity "low")
      (title "Missing .tool-versions")
      (description "Project lacked version management file for asdf")
      (resolution "Created .tool-versions with deno 1.45.0")
      (status "resolved")
      (files-created ".tool-versions")))

  (recommendations
    (short-term
      (recommendation
        (priority "high")
        (title "Add SPDX headers to source files")
        (description "The ReScript-generated .bs.js files lack SPDX license headers"))
      (recommendation
        (priority "medium")
        (title "Increase branch coverage")
        (description "Add tests for edge cases in ErrorMessages module"))
      (recommendation
        (priority "low")
        (title "Port configuration")
        (description "Make port configurable via environment variable for development")))

    (long-term
      (recommendation
        (priority "medium")
        (title "ReScript source files")
        (description "Add ReScript sources or document .bs.js as primary sources"))
      (recommendation
        (priority "low")
        (title "End-to-end tests")
        (description "Add browser-based E2E tests for visual rendering verification"))
      (recommendation
        (priority "low")
        (title "Performance benchmarks")
        (description "Add Deno benchmarks to track response time and throughput"))))

  (api-endpoints-tested
    (endpoint
      (method "GET")
      (path "/")
      (description "Main BSOD page")
      (status "verified"))
    (endpoint
      (method "GET")
      (path "/random")
      (description "Random style redirect")
      (status "verified"))
    (endpoint
      (method "GET")
      (path "/api/health")
      (description "Health check")
      (status "verified"))
    (endpoint
      (method "GET")
      (path "/api/error")
      (description "Random error")
      (status "verified"))
    (endpoint
      (method "GET")
      (path "/api/error/:code")
      (description "Specific error by code")
      (status "verified"))
    (endpoint
      (method "GET")
      (path "/api/codes")
      (description "List all error codes")
      (status "verified"))
    (endpoint
      (method "GET")
      (path "/api/styles")
      (description "List all styles")
      (status "verified"))
    (endpoint
      (method "GET")
      (path "/api/analytics")
      (description "Analytics summary")
      (status "verified"))
    (endpoint
      (method "POST")
      (path "/api/analytics/reset")
      (description "Reset analytics")
      (status "verified")))

  (bsod-styles-tested
    (style (name "win10") (status "verified"))
    (style (name "win11") (status "verified"))
    (style (name "win7") (status "verified"))
    (style (name "winxp") (status "verified")))

  (error-codes-tested
    (code "CRITICAL_PROCESS_DIED")
    (code "SYSTEM_SERVICE_EXCEPTION")
    (code "PAGE_FAULT_IN_NONPAGED_AREA")
    (code "COFFEE_NOT_FOUND")
    (code "PRODUCTION_DEPLOYMENT_ON_FRIDAY")
    (code "NPM_INSTALL_TIMEOUT")
    (code "STACKOVERFLOW_COPY_PASTE_ERROR")
    (code "MERGE_CONFLICT_ANXIETY")
    (code "UNDEFINED_IS_NOT_A_FUNCTION")
    (code "CIRCULAR_DEPENDENCY_LOOP"))

  (conclusion
    (status "PASS")
    (quality-assessment "excellent")
    (deployment-ready #t)
    (key-accomplishments
      "Migrated all tests from Jest/Node.js to Deno native test framework"
      "Fixed lint issues in main server file"
      "Created proper version management with .tool-versions"
      "Verified all API endpoints function correctly"
      "Confirmed BSOD page rendering with various style options"
      "Achieved 97.4% line coverage and 83.3% branch coverage")))

;; Helper functions for reading this report programmatically
(define (get-test-summary report)
  "Extract the summary section from a testing report"
  (assoc-ref report 'summary))

(define (get-failed-tests report)
  "Get a list of failed tests from the report"
  (let ((suites (assoc-ref report 'test-suites)))
    (filter (lambda (test)
              (equal? (assoc-ref test 'status) "fail"))
            (apply append (map (lambda (suite)
                                (assoc-ref suite 'tests))
                              suites)))))

(define (get-coverage report)
  "Extract coverage information from the report"
  (assoc-ref (get-test-summary report) 'coverage))

(define (is-deployment-ready? report)
  "Check if the project is ready for deployment based on test results"
  (let ((conclusion (assoc-ref report 'conclusion)))
    (and (equal? (assoc-ref conclusion 'status) "PASS")
         (assoc-ref conclusion 'deployment-ready))))

;; End of TESTING-REPORT.scm
