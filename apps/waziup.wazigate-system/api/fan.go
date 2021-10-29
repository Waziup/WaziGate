package api

import (
	"log"
	"strconv"
	"time"

	"periph.io/x/periph/conn/gpio"
	"periph.io/x/periph/conn/gpio/gpioreg"
	"periph.io/x/periph/host"
)

/*-------------------------*/

const FAN_PIN = "GPIO5" // PIN #29
// const TRIGGER_TEMP 	=	62.0		// Trigger the FAN once the CPU temperature goes above this (Celsius)

/*-------------------------*/

// This function is constantly (every 5 seconds) checking the CPU temperature
// and if it goes beyond the threshold defined in the dahsboard, it triggers the fan
func FanLoop() {

	go func() {
		if _, err := host.Init(); err != nil {
			log.Printf("[Err   ]: %s ", err.Error())
		}

		// Wait for the host to come up before sending any command
		for {
			if hostReady() {
				break
			}
			time.Sleep(5 * time.Second)
		}

		pin := gpioreg.ByName(FAN_PIN) // FAN pin
		pin.Out(gpio.Low)
		fanIsOn := false

		for {
			tempStr, _ := execOnHostWithLogs("vcgencmd measure_temp | egrep -o '[0-9]*\\.[0-9]*'", false)

			temp, err := strconv.ParseFloat(tempStr, 64)
			if err != nil {
				log.Printf("[Err   ]: %s ", err.Error())
			}

			// if DEBUG_MODE {
			// 	// log.Printf( "[Info  ] CPU Temperature: [ %f ]", temp)
			// }

			if !fanIsOn && temp > Config.FanTriggerTemp {
				log.Printf("[Info  ] CPU Temperature: [ %f ]", temp)
				if err := pin.Out(gpio.High); err != nil {

					log.Printf("[Err   ]: %s ", err.Error())

				} else {

					fanIsOn = true
				}

			}

			if fanIsOn && temp <= Config.FanTriggerTemp-3 {
				log.Printf("[Info  ] CPU Temperature: [ %f ]", temp)
				if err := pin.Out(gpio.Low); err != nil {

					log.Printf("[Err   ]: %s ", err.Error())

				} else {

					fanIsOn = false
				}
			}

			time.Sleep(5 * time.Second)
		}

	}()

	log.Printf("[Info  ] Fan manager initialized.")
}

/*-------------------------*/
