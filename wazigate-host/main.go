/* 
	@author: mojtaba.eskandari@waziup.org Nov 25th 2019
	@A deamon to execute commands on host
*/
package main

import (
	// "fmt"
	// "os"
	"log"
	"flag"
	// "time"
	"net/http"
	// "encoding/json"
	"strings"
	// "strconv"

	"os/exec"
	// "path/filepath"
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

func main() {

	log.Printf( "Initializing...")

	host := flag.String( "s", "", "Server address")
	port := flag.String( "p", "5200", "Port number")

	flag.Parse()

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
    stdout, err := exe.Output()

    if( err != nil) {
		log.Printf( "[Err   ] executing [ %s ] command. \n\tError: [ %s ]", cmd, err.Error())
		http.Error( resp, err.Error(), http.StatusBadRequest)
		return
	}

	out := strings.Trim( string( stdout), " \n\t\r")
	
	resp.Write( []byte( out))
}