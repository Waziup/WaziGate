/*
	@author: mojtaba.eskandari@waziup.org
	@author: johann.forster@waziup.org
	@Wazigate System Management
*/
package main

import (
	"log"
	"os"

	_ "embed"

	"github.com/Waziup/wazigate-system/api"
)

const packageJSONFile = "/var/lib/waziapp/package.json"

func main() {
	if err := os.WriteFile(packageJSONFile, packageJSON, 0777); err != nil {
		log.Println("Make sure to run this container with the mapped volume '/var/lib/waziapp'.")
		log.Println("See the Waziapp documentation for more details on running Waziapps.")
		log.Fatal(err)
	}

	api.PackageJSON = packageJSON
	api.ListenAndServeHTTP()
}

//go:embed package.json
var packageJSON []byte
