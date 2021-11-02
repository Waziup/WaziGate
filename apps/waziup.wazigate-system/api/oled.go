package api

import (
	// "fmt"
	// "encoding/json"
	"log"
	"strings"
	"time"

	// "strconv"
	"net/http"

	// "os"
	// "os/exec"
	// "path/filepath"
	"io/ioutil"

	routing "github.com/julienschmidt/httprouter"

	"image"

	"periph.io/x/periph/conn/i2c/i2creg"
	"periph.io/x/periph/devices/ssd1306"
	"periph.io/x/periph/devices/ssd1306/image1bit"
	"periph.io/x/periph/host"

	"golang.org/x/image/font"
	"golang.org/x/image/font/basicfont"
	"golang.org/x/image/math/fixed"
)

/*-------------------------*/

var OledBuffer string     // A Shared buffer for showing message on the OLED
var OledCurrentMsg string // The message which is showing on the OLED at the moment

var oledDev *ssd1306.Dev
var oledDoesNotExist bool // We check if the OLED does not exist, we just ignore it.

// var oledHaltTimeout		int			// Off timeout value in seconds
var oledHalted bool // If OLED is off (we turn it off after some time of not use and come back after a push button)

/*-------------------------*/

// This function initializes the OLED
func oledInit() {

	oledDoesNotExist = false
	oledHalted = false

	//Handle halt timeout
	// oledHaltTimeout = 5 * 60 //default value seconds
	// oledHaltTimeoutTxt := os.Getenv( "OLED_TIMEOUT")
	// if oledHaltTimeoutTxt == "" {
	// 	oledHaltTimeoutInt, err := strconv.Atoi( oledHaltTimeoutTxt)
	// 	if( err == nil && oledHaltTimeoutInt > 0){
	// 		oledHaltTimeout = oledHaltTimeoutInt
	// // 	}
	// }

	// Make sure periph is initialized.
	if _, err := host.Init(); err != nil {
		log.Printf("[Err   ]: %s ", err.Error())
		oledDoesNotExist = true
	}

	// Use i2creg I²C bus registry to find the first available I²C bus.
	b, err := i2creg.Open("")
	if err != nil {
		log.Printf("[Err   ]: %s ", err.Error())
		oledDoesNotExist = true
	}
	// defer b.Close()

	oledDev, err = ssd1306.NewI2C(b, &ssd1306.DefaultOpts)
	if err != nil {
		log.Printf("[Err   ] initialize ssd1306: %s ", err.Error())
		oledDoesNotExist = true
	}
}

/*-------------------------*/

// This function make the OLED black
func oledHalt() {

	if oledDev == nil {
		log.Printf("[Err   ] OLED halt: No OLED Found!")
		return
	}
	oledShow("\n\n   Screen OFF", false)
	time.Sleep(1 * time.Second)
	oledHalted = true
	err := oledDev.Halt()
	if err != nil {
		log.Printf("[Err   ] OLED halt: %s ", err.Error())
	}
}

/*-------------------------*/

// This function shows a given message on the OLED
func oledShow(msg string, withLogs bool) {

	if oledDoesNotExist {
		if withLogs && DEBUG_MODE {
			log.Printf("[OLED  ] Oled display does not exist!")
		}
		return
	}

	if OledCurrentMsg == msg {
		return // Do nothing
	}
	OledCurrentMsg = msg

	if oledHalted {
		oledHalted = false
	}

	if withLogs && DEBUG_MODE {
		log.Printf("[OLED  ] \"%s\"", msg)
	}

	// Draw on it.
	img := image1bit.NewVerticalLSB(oledDev.Bounds())
	// Note: this code is commented out so periph does not depend on:

	f := basicfont.Face7x13
	drawer := font.Drawer{
		Dst:  img,
		Src:  &image.Uniform{image1bit.On},
		Face: f,
		// Dot:  fixed.P(0, img.Bounds().Dy()-1-f.Descent),
		Dot: fixed.P(0, f.Height-f.Descent),
	}

	lines := strings.Split(msg, "\n")
	for i, line := range lines {
		line = strings.TrimRight(string(line), " \n\t\r")

		drawer.Dot = fixed.P(0, (i+1)*f.Height-f.Descent)
		drawer.DrawString(line)
	}

	if err := oledDev.Draw(oledDev.Bounds(), img, image.Point{}); err != nil {
		log.Printf("[Err   ] OLED [ %s ] command. \n\tError: [ %s ]", msg, err.Error())

		//Wait for a while and try again after failure
		time.Sleep(2 * time.Second)
		oledInit()
	}

}

/*-------------------------*/

// OLED Controller
// This function gets the gateway status periodically and updates the OLED
func OledLoop() {

	go func() {
		oledInit()

		if oledDoesNotExist {
			return
		}

		OledBuffer = ""     // Clear the buffer
		autoClearTimer := 0 // Automatically clear a message if it is not removed after let's say 13 seconds

		allBootedOK := false
		GWStatusCheck := 0 // Check the containers status in every let's say 7 seconds.

		heartbeat := false // Just a toggle varianle to show heartbeat on the screen

		oledHaltCounter := 0

		for {

			/*---------*/

			if autoClearTimer > 12 {
				OledBuffer = ""
				oledShow("", false)
			}

			if len(OledBuffer) > 0 {
				oledShow(OledBuffer, true)
				autoClearTimer++
				time.Sleep(1 * time.Second)
				continue
			}
			autoClearTimer = 0

			if oledHalted {
				time.Sleep(1 * time.Second)
				continue
			}

			if oledHaltCounter > Config.OLEDHaltTimeout {
				oledHalt()
				oledHaltCounter = 0
				continue
			}

			oledHaltCounter++

			/*---------*/

			heartTxt := "  "
			heartbeat = !heartbeat
			if heartbeat {
				heartTxt = "* "
			}

			netTxt := "[ Internet NO ]"
			if CloudAccessible(false /*Without Logs*/) {
				netTxt = "[ Internet OK ]"
			}

			OledMsg := heartTxt + netTxt

			/*---------*/

			eip, wip, aip, ssid := GetAllIPs()

			if len(eip) > 0 {
				// msg.append( "Ethernet: "+ eip);
				OledMsg += "\nEth: " + eip
			}

			if len(wip) > 0 {
				OledMsg += "\n\nWiFi: (" + ssid + ")\n " + wip
			}

			if len(aip) > 0 {
				OledMsg += "\n\nAP: (" + ssid + ")\n " + aip
			}

			/*---------*/

			oledShow(OledMsg, false)
			time.Sleep(1 * time.Second)

			GWStatusCheck++
			if GWStatusCheck > 7 {
				GWStatusCheck = 0
				allBootedOK, _ = GetGWBootstatus(false)
			}

			if !allBootedOK {
				allBootedOK, OledMsg = GetGWBootstatus(false)
				oledShow(OledMsg, false)
				time.Sleep(1 * time.Second)
			}

		} // End of `for`

	}()

	log.Printf("[Info  ] OLED manager initialized.")

}

/*-------------------------*/

// Simply write the incoming message into the OLED buffer to be shown
func oledWrite(msg string) {
	OledBuffer = msg
}

/*-------------------------*/

// This function implements POST|PUT /oled API
func OledWriteMessage(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	msg, err := ioutil.ReadAll(req.Body)
	if err != nil {
		log.Printf("[Err   ] OLED [ %s ] command. \n\tError: [ %s ]", msg, err.Error())
		http.Error(resp, err.Error(), http.StatusBadRequest)
		return
	}

	oledWrite(string(msg))
}

/*-------------------------*/
