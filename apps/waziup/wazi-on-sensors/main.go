/*
*	@author: mojtaba.eskandari@waziup.org March 9th 2020
*	@Wazigate Sample APP (Sensors on board)
 */
package main

import (
	// "fmt"

	"log"
	"net"

	// "time"
	"net/http"
	// "encoding/json"
	"strings"
	// "strconv"

	"os"
	"os/exec"

	// "path/filepath"
	// "io/ioutil"

	routing "github.com/julienschmidt/httprouter"
)

var router = routing.New()

// Please do not change this line
const sockAddr = "./app/proxy.sock"

func init() {

	router.GET("/", HomeLink)

	router.GET("/ui/*file_path", UI)

	router.GET("/sensors", AllSensors)
	router.GET("/sensors/:sensor_name", GetSensor)
}

/*-------------------------*/

func main() {

	log.Printf("Initializing...")

	if err := os.RemoveAll(sockAddr); err != nil {
		log.Fatal(err)
	}

	server := http.Server{
		Handler: router,
	}

	l, e := net.Listen("unix", sockAddr)
	if e != nil {
		log.Fatal("listen error:", e)
	}
	log.Printf("Serving... on socket: [%v]", sockAddr)
	server.Serve(l)
}

/*-------------------------*/

// HomeLink serves a hellow world to make sure it works
func HomeLink(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	resp.Write([]byte("Salam Goloooo, It works!"))
}

/*-------------------------*/

// func APIDocs( resp http.ResponseWriter, req *http.Request, params routing.Params) {
// 	// log.Println( req.URL.Path)
// 	http.FileServer( http.Dir("./")).ServeHTTP( resp, req)
// }

/*-------------------------*/

// UI serves the static ui
func UI(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	filePath := "." + req.URL.Path
	if filePath == "./" {
		filePath += "index.html"
	}

	http.ServeFile(resp, req, filePath)
}

/*-------------------------*/

func exeCmd(cmd string, withLogs bool) string {

	if withLogs {
		log.Printf("[Info  ] executing [ %s ] ", cmd)
	}

	exe := exec.Command("sh", "-c", cmd)
	stdout, err := exe.Output()

	if err != nil {
		if withLogs {
			log.Printf("[Err   ] executing [ %s ] command. \n\tError: [ %s ]", cmd, err.Error())

		}
		return ""
	}
	return strings.Trim(string(stdout), " \n\t\r")
}

/*-------------------------*/
// go mod init && go mod tidy
