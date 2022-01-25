package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Printf("Hello world, GOOS=%v, GOARCH=%v\n", runtime.GOOS, runtime.GOARCH)
}
