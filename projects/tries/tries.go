package tries

import (
	"errors"
)

// EndOfPatternSentinel is an invalid rune so that sentinel nodes in the tree
// will never be confused with nodes that represent characters from strings
// that are added to the trie
const EndOfPatternSentinel = rune(-1)

var ErrEdgeNotFound = errors.New("this node does not have an edge with this label")

type Trie struct {
	Root *Node
}

type Node struct {
	// OutgoingEdges is a map of single character labels to their outgoing edges
	OutgoingEdges map[rune]*Node
}

// New returns the root node of a trie that represents the collection of
// patterns.
func New(patterns []string) *Trie {
	t := &Trie{Root: &Node{}}
	for _, p := range patterns {
		t.Add(p)
	}
	return t
}

// Add adds the given pattern to the trie.
func (t *Trie) Add(pat string) {
	currentNode := t.Root
	for _, c := range pat {
		nextNode := currentNode.Traverse(c)
		if nextNode == nil {
			// the trie does not contain the subpattern ending with this
			// character, so add a new node
			nextNode = &Node{}
		}
		if currentNode.OutgoingEdges == nil {
			currentNode.OutgoingEdges = make(map[rune]*Node)
		}
		currentNode.OutgoingEdges[c] = nextNode
		currentNode = nextNode
	}

	if currentNode.OutgoingEdges == nil {
		currentNode.OutgoingEdges = make(map[rune]*Node)
	}
	// add one more edge indicating the end of the pattern so patterns that are
	// a prefix of another pattern in the tree also end on a leaf
	currentNode.OutgoingEdges[EndOfPatternSentinel] = nil
}

// Contains returns true iff the trie contains the given pattern.
func (t *Trie) Contains(pat string) bool {
	currentNode := t.Root
	for _, c := range pat {
		// consume one character and attempt to traverse one node
		currentNode = currentNode.Traverse(c)
		if currentNode == nil {
			return false
		}
	}

	// traverse the end of pattern sentinel to make sure the trie contains this
	// pattern, as opposed to another pattern that starts with this pattern
	if _, ok := currentNode.OutgoingEdges[EndOfPatternSentinel]; ok {
		return true
	}

	return false
}

func (n *Node) Traverse(edgeLabel rune) *Node {
	return n.OutgoingEdges[edgeLabel]
}
