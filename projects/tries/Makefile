.PHONY: phony

unit-tests: phony ## Run the unit tests.
	go run github.com/onsi/ginkgo/ginkgo -r \
		-randomizeAllSpecs -randomizeSuites -trace \
		-cover -coverprofile=cover.coverprofile -outputdir=.

view-test-coverage: phony unit-tests ## View unit test coverage in browser.
	go tool cover -html=cover.coverprofile
