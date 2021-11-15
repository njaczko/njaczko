package tries_test

import (
	"github.com/njaczko/njaczko/projects/tries"

	gk "github.com/onsi/ginkgo"
	gm "github.com/onsi/gomega"
)

var _ = gk.Describe("Tries", func() {

	gk.Context("New", func() {
		gk.It("returns a new trie", func() {
			n := tries.New([]string{"foo", "bar", "baz"})
			gm.Expect(n).NotTo(gm.BeNil())
		})
	})

	gk.Context("Node#Traverse", func() {
		var (
			parentNode *tries.Node
			childNode  *tries.Node
		)
		gk.BeforeEach(func() {
			parentNode = &tries.Node{}
			childNode = &tries.Node{}
			parentNode.OutgoingEdges = map[rune]*tries.Node{
				'a': childNode,
			}
		})

		gk.It("returns the correct node if there is an outgoing edge with the label", func() {
			gm.Expect(parentNode.Traverse('a')).To(gm.Equal(childNode))
		})

		gk.It("returns nil if the node does not have an outgoing edge with the label", func() {
			gm.Expect(parentNode.Traverse('x')).To(gm.BeNil())
		})
	})

	gk.Context("Trie#AddPattern", func() {
		gk.It("correctly sets the outgoing edges", func() {
			rootNode := &tries.Node{}
			t := tries.Trie{Root: rootNode}
			err := t.AddPattern("bar")
			gm.Expect(err).NotTo(gm.HaveOccurred())

			bNode := rootNode.OutgoingEdges['b']
			gm.Expect(bNode).NotTo(gm.BeNil())

			aNode := bNode.OutgoingEdges['a']
			gm.Expect(aNode).NotTo(gm.BeNil())

			rNode := aNode.OutgoingEdges['r']
			gm.Expect(rNode).NotTo(gm.BeNil())

			gm.Expect(rNode.OutgoingEdges).To(gm.Equal(map[rune]*tries.Node{
				tries.EndOfPatternSentinel: nil,
			}))
		})
	})

	gk.Context("Trie#ContainsPattern", func() {
		var t *tries.Trie
		gk.BeforeEach(func() {
			t = tries.New([]string{"foo", "bar", "barn"})
		})

		gk.It("returns false if the pattern has not been added", func() {
			contains, err := t.ContainsPattern("baz")
			gm.Expect(err).NotTo(gm.HaveOccurred())
			gm.Expect(contains).To(gm.BeFalse())
		})

		gk.It("returns true if the pattern has been added", func() {
			contains, err := t.ContainsPattern("foo")
			gm.Expect(err).NotTo(gm.HaveOccurred())
			gm.Expect(contains).To(gm.BeTrue())
		})

		gk.It("returns true if the pattern is a substring of another pattern", func() {
			contains, err := t.ContainsPattern("bar")
			gm.Expect(err).NotTo(gm.HaveOccurred())
			gm.Expect(contains).To(gm.BeTrue())
		})

		gk.It("returns false if pattern has not been added, but is a substring of another pattern", func() {
			contains, err := t.ContainsPattern("fo")
			gm.Expect(err).NotTo(gm.HaveOccurred())
			gm.Expect(contains).To(gm.BeFalse())
		})
	})
})
