package api

import (
	"log"
	"sync"
	"time"

	"periph.io/x/periph/conn/gpio"
	"periph.io/x/periph/conn/gpio/gpioreg"
	"periph.io/x/periph/host"
)

/*-------------------------*/

const LED1_PIN = "GPIO27" // PIN #13
const LED2_PIN = "GPIO22" // PIN #15

/*-------------------------*/

// This function controlls the LED indicators
func LEDsLoop() {

	go func() {
		if _, err := host.Init(); err != nil {
			log.Printf("[Err   ]: %s ", err.Error())
		}

		blinkStart(LED1_PIN, 500, 500)
		time.Sleep(500 * time.Millisecond)
		blinkStart(LED2_PIN, 500, 500)

		// Wait for the host to come up before sending any command
		for {
			if hostReady() {
				break
			}
			time.Sleep(5 * time.Second)
		}

		/*----------*/

		for {

			/*----------*/

			netInfo, err := getNetWiFi()
			if err != nil {
				log.Printf("[ERR  ] Get wifi info: %v", err)
				blinkStart(LED2_PIN, 50, 100)

			} else {

				if netInfo["ap_mode"].(bool) {

					blinkStart(LED2_PIN, 1000, 1000)

				} else if netInfo["ssid"].(string) != "" && netInfo["state"].(string) == "COMPLETED" {
					turnOnLED(LED2_PIN)
					// blinkStart(LED2_PIN, 100, 2000)
				} else if netInfo["state"].(string) != "" {
					// Connecting...
					blinkStart(LED2_PIN, 100, 500)
				} else {
					// Something went wrong, Not connected
					blinkStart(LED2_PIN, 100, 100)
				}

			}

			/*----------*/

			if CloudAccessible(false /*Without Logs*/) {
				turnOnLED(LED1_PIN)
			} else {
				blinkStart(LED1_PIN, 100, 100)
			}

			/*----------*/

			time.Sleep(3 * time.Second)
		}

	}()

	log.Printf("[Info  ] LED manager initialized.")
}

/*-------------------------*/

var ledLock1, ledLock2 chan struct{}
var wg1, wg2 sync.WaitGroup

// This function receives a GPIO attached to a LED, an ON time duration and an OFF time duration
// and blinks the LED accordingly
func blinkStart(ledGpio string, onTime time.Duration, offTime time.Duration) {

	blinkStop(ledGpio) // Clear blinking if it is already blinking...

	go func(ledGpio string) {

		pin := gpioreg.ByName(ledGpio) // LED pin

		var quitLock *chan struct{}
		switch ledGpio {
		case LED1_PIN:
			{
				ledLock1 = make(chan struct{}, 1)
				quitLock = &ledLock1
				wg1.Add(1)
				defer wg1.Done()
			}
		case LED2_PIN:
			{
				ledLock2 = make(chan struct{}, 1)
				quitLock = &ledLock2
				wg2.Add(1)
				defer wg2.Done()
			}
		}

		for {

			select {
			case <-*quitLock:
				return
			default:
				{

					if err := pin.Out(gpio.High); err != nil {
						log.Printf("[Err   ]: LED %s ", err.Error())
					}

					time.Sleep(onTime * time.Millisecond)

					if err := pin.Out(gpio.Low); err != nil {
						log.Printf("[Err   ]: LED %s ", err.Error())
					}

					time.Sleep(offTime * time.Millisecond)
				}
			}

		}
	}(ledGpio)
}

/*-------------------------*/

// This function receives a GPIO attached to a LED and stops the blinking if it is blinking
func blinkStop(ledGpio string) {

	if ledGpio == LED1_PIN {

		select {
		case ledLock1 <- struct{}{}:
			{
				wg1.Wait()
				close(ledLock1)
				ledLock1 = nil
			}
		default:
		}

		return
	}

	if ledGpio == LED2_PIN {

		select {
		case ledLock2 <- struct{}{}:
			{
				wg2.Wait()
				close(ledLock2)
				ledLock2 = nil
			}
		default:
		}

		return
	}

}

/*-------------------------*/

// This function receives a GPIO attached to a LED and turns on the LED
func turnOnLED(ledGpio string) {

	blinkStop(ledGpio)

	pin := gpioreg.ByName(ledGpio) // LED pin

	if err := pin.Out(gpio.High); err != nil {
		log.Printf("[Err   ]: LED %s ", err.Error())
	}

}

/*-------------------------*/

// This function receives a GPIO attached to a LED and turns off the LED
func turnOFFLED(ledGpio string) {

	blinkStop(ledGpio) // Clear blinking if it is already blinking...

	pin := gpioreg.ByName(ledGpio) // LED pin

	if err := pin.Out(gpio.Low); err != nil {
		log.Printf("[Err   ]: LED %s ", err.Error())
	}
}

/*-------------------------*/
