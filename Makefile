generate:
	./openshift/generate.sh
.PHONY: generate

e2e-tests:
	./openshift/install.sh
	./openshift/e2e-tests.sh
.PHONY: e2e-tests
