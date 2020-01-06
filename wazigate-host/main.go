/* 
	@author: mojtaba.eskandari@waziup.org Nov 25th 2019
	@A deamon to execute commands on host
*/
package main

import (
	// "fmt"
	"os"
	"log"
	"flag"
	// "time"
	"net/http"
	// "encoding/json"
	"strings"
	// "strconv"

	"os/exec"
	"path/filepath"
	"io/ioutil"

	routing "github.com/julienschmidt/httprouter"	
)

/*-------------------------*/

var router = routing.New()

func init() {

	router.GET( "/", homeLink)
	router.POST( "/cmd", execCommand)
}

/*-------------------------*/

var execPath = ""

func main() {

	log.Printf( "Initializing...")

	dir, err := filepath.Abs( filepath.Dir( os.Args[0]))
	if err != nil {
		log.Fatal( err)
	}
	execPath = dir

	// log.Printf( dir)

	host := flag.String( "s", "", "Server address")
	port := flag.String( "p", "5200", "Port number")
	debugMode := flag.String( "d", "0", "Debug Mode")

	flag.Parse()

	if *debugMode != "0" {
		// If debug mode
		f, err := os.OpenFile( execPath +"/host.logs", os.O_RDWR | os.O_CREATE | os.O_APPEND, 0666)
		if err != nil {
			log.Fatalf("[Err   ]: Error opening file: %v", err)
		}
		defer f.Close()

		log.SetOutput(f)
	}

	ListenAndServeHTTP( *host +":"+ *port)
}

/*-------------------------*/

func ListenAndServeHTTP( addr string) {

	log.Printf( "[Info  ] Serving on %s", addr)
	log.Fatal( http.ListenAndServe( addr, router))
}

/*-------------------------*/

func homeLink( resp http.ResponseWriter, req *http.Request, params routing.Params) {
	resp.Write( []byte( "Salam, It works!"))
}

/*-------------------------*/

func execCommand( resp http.ResponseWriter, req *http.Request, params routing.Params) {
	
	// cmd := string( req.Body)
	cmd, err := ioutil.ReadAll( req.Body)
	if( err != nil) {
		log.Printf( "[Err   ] executing [ %s ] command. \n\tError: [ %s ]", cmd, err.Error())
		http.Error( resp, err.Error(), http.StatusBadRequest)
		return
	}

	log.Printf( "[Info  ] executing [ %s ] ", cmd)

	exe := exec.Command( "sh", "-c", string( cmd))
	exe.Dir = execPath
    stdout, err := exe.Output()

    if( err != nil) {
		log.Printf( "[Err   ] executing [ %s ] command. \n\tError: [ %s ]", cmd, err.Error())
		http.Error( resp, err.Error(), http.StatusBadRequest)
		return
	}

	out := strings.Trim( string( stdout), " \n\t\r")
	
	resp.Write( []byte( out))
}