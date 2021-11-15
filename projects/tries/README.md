# tries

A Go implementation of [tries](https://en.wikipedia.org/wiki/Trie).

## Installation

Use `go get`:

```sh
go get -u github.com/njaczko/njaczko/projects/tries
```

## Usage

Here's an example Go program:

```go
package main

import (
	"fmt"

	"github.com/njaczko/njaczko/projects/tries"
)

func main() {
	coolTrie := tries.New([]string{"foo", "bar", "baz"})

	contains, err := coolTrie.Contains("foo")
	if err != nil {
		panic(err)
	}

	if contains {
		fmt.Println("coolTrie contains 'foo'!")
		return
	}
	fmt.Println("coolTrie does not contain 'foo'!")
}
```

The program's output is:

```
coolTrie contains 'foo'!
```
