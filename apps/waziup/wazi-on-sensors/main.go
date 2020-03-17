/* 
	@author: mojtaba.eskandari@waziup.org March 9th 2020
	@Wazigate Sample APP (Sensors on board)
*/
package main

import (
	// "fmt"
	"log"
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

func init() {

	router.GET( "/", HomeLink)
	router.GET( "/ui/*file_path", UI)
	router.GET( "/sensors", AllSensors)
	router.GET( "/sensors/:sensor_name", GetSensor)
}

/*-------------------------*/

func main() {

	ListenAndServeHTTP()
}


/*-------------------------*/


func HomeLink( resp http.ResponseWriter, req *http.Request, params routing.Params) {

	resp.Write( []byte( "Salam Goloooo, It works!"))
}
	
/*-------------------------*/

// func APIDocs( resp http.ResponseWriter, req *http.Request, params routing.Params) {
// 	// log.Println( req.URL.Path)
// 	http.FileServer( http.Dir("./")).ServeHTTP( resp, req)
// }

/*-------------------------*/

// var server = http.FileServer( http.Dir("./"))
func UI( resp http.ResponseWriter, req *http.Request, params routing.Params) {
	// log.Println( req.URL.Path)
	// log.Println( params.ByName( "file_path"))

	http.FileServer( http.Dir("./")).ServeHTTP( resp, req)
}

/*-------------------------*/

func ListenAndServeHTTP() {
	
	addr := os.Getenv( "WAZIGATE_SYSTEM_ADDR")
	if addr == "" {
		addr = ":80"
	}

	log.Printf( "[Info  ] Serving on %s", addr)
	
	log.Fatal( http.ListenAndServe( addr, router))
}

/*-------------------------*/


func exeCmd( cmd string, withLogs bool) string {

	if( withLogs){
		log.Printf( "[Info  ] executing [ %s ] ", cmd)
	}

	exe := exec.Command( "sh", "-c", cmd)
    stdout, err := exe.Output()

    if( err != nil) {
		if( withLogs){
			log.Printf( "[Err   ] executing [ %s ] command. \n\tError: [ %s ]", cmd, err.Error())

		}
        return ""
	}
	return strings.Trim( string( stdout), " \n\t\r")
}


/*-------------------------*/

/*-------------------------*/
// go mod init && go mod tidy