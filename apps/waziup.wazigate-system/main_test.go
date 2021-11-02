package main

import (
	"io/ioutil"
	"log"
	"os"
	"testing"
)

// Disabling logs
func TestMain(m *testing.M) {

	log.SetOutput(ioutil.Discard)
	os.Exit(m.Run())
}
