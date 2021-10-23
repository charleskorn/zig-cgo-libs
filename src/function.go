package main

import "C"
import "math/rand"

//export RandomInt
func RandomInt() int {
	return rand.Int()
}