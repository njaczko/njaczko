package tries_test

import (
	"testing"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestTrie(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Tries Suite")
}
