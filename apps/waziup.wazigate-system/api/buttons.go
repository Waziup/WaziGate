package api

import (
	"log"
	"time"

	"periph.io/x/periph/conn/gpio"
	"periph.io/x/periph/conn/gpio/gpioreg"
	"periph.io/x/periph/host"
	// "strconv"
)

/*-------------------------*/

const WiFi_BTN = "GPIO6"     // PIN #31
const WiFi_BTN_COUNTDOWN = 3 // for n seconds the button needs to be held down to revert the wifi/web ui settings

const PWR_BTN = "GPIO26"     // PIN #37
const SHUTDOWN_COUNTDOWN = 3 // for n seconds the button needs to be held down to activate shutdown procedure

/*-------------------------*/

// This function handles the push buttons on WaziHAT
func ButtonsLoop() {

	if _, err := host.Init(); err != nil {
		log.Printf("[Err   ]: %s ", err.Error())
	}

	/*---------*/
	//WiFi button

	go func() {

		btnPin := gpioreg.ByName(WiFi_BTN)
		if btnPin == nil {
			log.Printf("[Err   ] Failed to find %v", WiFi_BTN)
		}

		// Set it as input, with a pull down (defaults to Low when unconnected) and
		// enable rising edge triggering.
		if err := btnPin.In(gpio.PullDown, gpio.RisingEdge); err != nil {
			log.Printf("[Err   ]: %s ", err.Error())
		}

		for btnPin.WaitForEdge(-1) {

			if oledHalted {

				//Since power button and OLED shared a pin, we need to wait for the oled to be re-initialized
				go func() {
					time.Sleep(1 * time.Second)
					oledShow("\n\n   Screen ON", false)
				}()

			}

			if DEBUG_MODE {
				log.Printf("[BTN   ] %s pushed", btnPin)
			}

			holdCounter := 1
			for btnPin.Read() == gpio.High {
				time.Sleep(1 * time.Second)
				holdCounter++
				if holdCounter > WiFi_BTN_COUNTDOWN {
					if DEBUG_MODE {
						log.Printf("[BTN   ] %s held long enough. Triggering the action!", btnPin)
					}
					wifiOperation.Lock()
					ActivateAPMode()
					wifiOperation.Unlock()
				}
			}
		}
	}()

	/*---------*/

	//Power button
	go func() {

		btnPin := gpioreg.ByName(PWR_BTN)
		if btnPin == nil {
			log.Printf("[Err   ] Failed to find %v", PWR_BTN)
		}

		// Set it as input, with a pull down (defaults to Low when unconnected) and
		// enable rising edge triggering.
		if err := btnPin.In(gpio.PullDown, gpio.RisingEdge); err != nil {
			log.Printf("[Err   ]: %s ", err.Error())
		}

		for btnPin.WaitForEdge(-1) {

			if oledHalted {
				oledShow("\n\n   Screen ON", false)
			}

			if DEBUG_MODE {
				log.Printf("[BTN   ] %s pushed", btnPin)
			}

			holdCounter := 1
			for btnPin.Read() == gpio.High {
				time.Sleep(1 * time.Second)
				holdCounter++
				if holdCounter > SHUTDOWN_COUNTDOWN {
					if DEBUG_MODE {
						log.Printf("[BTN   ] %s held long enough. Triggering the action!", btnPin)
					}
					systemShutdown("shutdown")
					return
				}
			}
		}
	}()

	/*---------*/

	log.Printf("[Info  ] Button manager initialized.")
}

/*-------------------------*/
