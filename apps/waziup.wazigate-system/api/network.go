package api

import (
	// "fmt"
	"encoding/json"
	"log"
	"net"
	"net/http"
	"regexp"
	"strings"
	"sync"
	"time"

	routing "github.com/julienschmidt/httprouter"
	// In future we will use something like this lib to handle wifi stuff
	// wifi "github.com/mark2b/wpa-connect"
)

var wifiOperation = &sync.Mutex{}

/*-------------------------*/

// GetNetInfo implements GET /net
func GetNetInfo(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	dev, _ := exeCmd("ip route show default | head -n 1 | awk '/default/ {print $5}'")
	mac, _ := exeCmd("cat /sys/class/net/" + dev + "/address")

	cmd := "ip -4 addr show " + dev + " | awk '$1 == \"inet\" {gsub(/\\/.*$/, \"\", $2); print $2}'"
	ip, _ := exeCmd(cmd)

	/*---------------*/

	out := map[string]interface{}{
		"ip":  ip,
		"dev": dev,
		"mac": mac,
	}

	outJson, err := json.Marshal(out)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	resp.Write([]byte(outJson))
}

/*-------------------------*/

// GetGWID implements GET /gwid
// This is Deprecated, now we call an API on the `wazigate-edge` to get the gateway Id
func GetGWID(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	interfs, err := net.Interfaces()
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())

		if DEBUG_MODE {
			http.Error(resp, "[ Error ]: "+err.Error(), http.StatusInternalServerError)
		}
	}

	localID := ""

	for _, interf := range interfs {
		addr := interf.HardwareAddr.String()
		if addr != "" {
			localID = strings.ReplaceAll(addr, ":", "")
			break
		}
	}
	resp.Write([]byte(localID))
}

/*-------------------------*/

// GetNetWiFi implements GET /net/wifi
func GetNetWiFi(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	out, err := getNetWiFi()
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
		http.Error(resp, "[ Error ]: "+err.Error(), http.StatusInternalServerError)
		return
	}

	outJSON, err := json.Marshal(out)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	resp.Write([]byte(outJSON))
}

/*-------------------------*/

func getWiFiClientStatus() (map[string]interface{}, error) {

	cmd := "wpa_cli status -i " + WIFI_DEVICE
	stdout, err := execOnHost(cmd)
	if err != nil {
		return nil, err // The WiFi is not connected
	}

	/*--------*/

	re := regexp.MustCompile(`([\w]+)=(.*)`)
	var status map[string]string = make(map[string]string)

	subMatchAll := re.FindAllStringSubmatch(string(stdout), -1)
	for _, element := range subMatchAll {
		status[element[1]] = element[2]
	}

	// All possible keys:
	// bssid=9c:c8:fc:29:e5:e0
	// freq=2412
	// ssid=GoliNet
	// id=0
	// mode=station
	// pairwise_cipher=CCMP
	// group_cipher=CCMP
	// key_mgmt=WPA2-PSK
	// wpa_state=COMPLETED
	// ip_address=192.168.200.1  /* Not very accurate*/
	// p2p_device_address=f6:8d:01:5d:ae:28
	// address=b8:27:eb:49:66:e2
	// uuid=087d50a2-7a1c-589c-bcec-cd5acde1ff57

	ssid, _ := status["ssid"]
	freq, _ := status["freq"]
	state, _ := status["wpa_state"]

	/*--------*/

	return map[string]interface{}{
		"ssid":  ssid,
		"freq":  freq,
		"state": state,
	}, nil
}

/*-------------------------*/

func getNetWiFi() (map[string]interface{}, error) {

	/*iwifi, err := net.InterfaceByName( WIFI_DEVICE)
	if err != nil {
		log.Printf( "[Err   ] %s", err.Error())
		if( DEBUG_MODE){
			http.Error( resp, "[ Error ]: "+ err.Error(), http.StatusInternalServerError)
		}

	}

	addrs, err := iwifi.Addrs();
	if err != nil {
		log.Printf( "[Err   ] %s", err.Error())
		if( DEBUG_MODE){
			http.Error( resp, "[ Error ]: "+ err.Error(), http.StatusInternalServerError)
		}
	}

	ip := ""
	if len( addrs) > 0 {
		ip = addrs[0].(*net.IPNet).IP.String()
	} /**/

	/*-----*/

	cmd := "ip -4 addr show " + WIFI_DEVICE + " | awk '$1 == \"inet\" {gsub(/\\/.*$/, \"\", $2); print $2}'"
	ip, _ := exeCmd(cmd)

	/*-----*/

	cmd = "ip link show up " + WIFI_DEVICE
	outc, _ := exeCmd(cmd)
	enabled := outc != ""

	/*-----*/

	cmd = "iw " + WIFI_DEVICE + " info | grep ssid | awk '{print $2\" \"$3\" \"$4\" \"$5\" \"$6}'"
	outc, _ = exeCmd(cmd)
	ssid := outc

	/*-----*/

	cmd = "systemctl is-active --quiet hostapd && echo 1"
	outc, err := execOnHost(cmd)
	apMode := outc == "1"
	if err != nil {
		apMode = false // we may chnage this
	}

	/*-----*/

	wifiClientStatus, err := getWiFiClientStatus()
	state := ""
	if err == nil {
		state = wifiClientStatus["state"].(string)
	}

	/*---------------*/

	return map[string]interface{}{
		"ip":      ip,
		"enabled": enabled,
		"ssid":    ssid,
		"ap_mode": apMode,
		"state":   state,
	}, nil

}

/*-------------------------*/

// SetNetWiFi implements POST/PUT /net/wifi
func SetNetWiFi(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	if err := req.ParseForm(); err != nil {
		log.Printf("[Err   ] %s", err.Error())
		if DEBUG_MODE {
			http.Error(resp, "[ Error ]: "+err.Error(), http.StatusInternalServerError)
		}
		return
	}

	var reqJSON map[string]interface{}
	decoder := json.NewDecoder(req.Body)
	err := decoder.Decode(&reqJSON)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	// log.Println( reqJSON)

	if enabled, exist := reqJSON["enabled"]; exist {
		if enabled == true || enabled == "1" {
			exeCmd("ip link set " + WIFI_DEVICE + " up")
		} else {
			exeCmd("ip link set " + WIFI_DEVICE + " down")
		}
	}

	if ssid, exist := reqJSON["ssid"]; exist {
		exeCmd("ip link set " + WIFI_DEVICE + " up")

		cmd := "sudo cp /etc/wpa_supplicant/wpa_supplicant.conf.orig /etc/wpa_supplicant/wpa_supplicant.conf;"
		// exeCmd( cmd)
		stdout, err := execOnHost(cmd)
		if err != nil {
			log.Printf("[HOST  ] %s \t %s", err.Error(), stdout)
		}

		cmd = ""
		if str, ok := ssid.(string); ok {
			cmd += "sudo wpa_passphrase \"" + str + "\""
		}

		if password, exist := reqJSON["password"]; exist {
			if str, ok := password.(string); ok {
				cmd += " \"" + str + "\""
			}
		}

		// if !DEBUG_MODE {
		cmd += " | grep -o '^[^#]*' " // Remove the plain text password from the phrase
		// }

		cmd += " >> /etc/wpa_supplicant/wpa_supplicant.conf; "
		// exeCmd( cmd)
		stdout, err = execOnHost(cmd)
		if err != nil {
			log.Printf("[HOST  ] %s \t %s", err.Error(), stdout)
		}

		wifiOperation.Lock()

		//Start the WiFi Client
		startWiFiClient()

		wifiOperation.Unlock()

		CheckWlanConn() // Check if the WiFi connection was successfull otherwise revert to AP mode
	}

	out := "WiFi set successfully"

	outJSON, err := json.Marshal(out)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	resp.Write([]byte(outJSON))

	// resp.Write( []byte( "WiFi configs set successfully"))
}

/*-------------------------*/

func startWiFiClient() error {

	oledWrite("\nConnecting to\n   WiFi...")
	stdout, err := execOnHost("sudo bash start_wifi.sh")

	if err != nil {
		log.Printf("[HOST  ] %s \t %s", err.Error(), stdout)

	} else {

		log.Printf("[Info   ] %s", stdout)
	}
	oledWrite("") // Clean the OLED msg

	return err
}

/*-------------------------*/

// This function determines if the gateway is in the Access Point Mode
func apMode(withLogs bool) bool {

	apAtive, _ := execOnHostWithLogs("systemctl is-active --quiet hostapd && echo 1", withLogs)
	return apAtive == "1"
}

/*-------------------------*/

// CheckWlanConn checks the status of WiFi and takes proper actions
// Return: fasle = AP Mode , true = WiFi Client mode
func CheckWlanConn() bool {

	wifiOperation.Lock()

	if apMode(true) {
		ActivateAPMode()
		wifiOperation.Unlock()
		return false // AP mode is active
	}

	wifiOperation.Unlock()

	// Give it some time to connect, then we check
	time.Sleep(2 * time.Second)
	for i := 0; i < 10; i++ {

		oledWrite("\nChecking WiFi." + strings.Repeat(".", i))

		// cmd = "iw " + WIFI_DEVICE + " info | grep ssid | awk '{print $2\" \"$3\" \"$4\" \"$5\" \"$6}'"
		// wifiRes, err := execOnHost("iwgetid")
		// if err == nil && wifiRes != "" {
		// 	oledWrite("") // Clean the OLED
		// 	return true
		// }

		wifiOperation.Lock()

		wifiClientStatus, err := getWiFiClientStatus()

		wifiOperation.Unlock()
		state := ""
		if err == nil {
			state = wifiClientStatus["state"].(string)
			if state == "COMPLETED" {
				return true
			}

			// time.Sleep(1 * time.Second)
			oledWrite("\nWiFi state:\n  " + state)
		}

		time.Sleep(5 * time.Second)
		// oledWrite("")
		// time.Sleep(2 * time.Second)
	}

	//Could no conenct, need to revert to AP setting

	if DEBUG_MODE {
		log.Printf("[Info  ] Could not connect!\nReverting the settings...")
	}
	oledWrite("Cannot Connect\n\nReverting to \n  Access point...")
	time.Sleep(2 * time.Second)

	wifiOperation.Lock()

	ActivateAPMode()

	wifiOperation.Unlock()

	return false
}

/*-------------------------*/

// Activate Access Point Mode
func ActivateAPMode() {

	oledWrite("\nActivating\n Access point mode...")

	stdout, err := execOnHost("sudo bash start_hotspot.sh")
	if err != nil {
		log.Printf("[HOST  ] %s \t %s", err.Error(), stdout)
	}
	if DEBUG_MODE {
		log.Printf("[Info  ] %s", stdout)
	}

	oledWrite("") // Clean the OLED

	time.Sleep(1 * time.Second)
}

/*-------------------------*/

// implements POST /net/wifi/ap
func SetNetAPMode(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	wifiOperation.Lock()

	ActivateAPMode()

	wifiOperation.Unlock()

	out := "Access Point mode Activated."

	outJson, err := json.Marshal(out)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	resp.Write([]byte(outJson))
	// resp.Write( []byte( "OK"))
}

/*-------------------------*/

// Implements GET /net/wifi/scanning
func NetWiFiScan(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	cmd := "iw " + WIFI_DEVICE + " scan | awk -f scan.awk"
	out, _ := exeCmd(cmd)
	lines := strings.Split(out, "\n")

	resp.Header().Set("Content-Type", "application/json")
	resp.Write([]byte{'['})

	firstItemServed := false
	for _, line := range lines {
		wrd := strings.Split(string(line), "\t")
		if len(wrd) == 3 && wrd[0] != "" {

			if firstItemServed {
				resp.Write([]byte{','})
			}

			out := map[string]interface{}{
				"name":     wrd[0],
				"signal":   wrd[1],
				"security": wrd[2],
			}

			outJson, err := json.Marshal(out)
			if err != nil {
				log.Printf("[Err   ] %s", err.Error())
			}

			if DEBUG_MODE {
				log.Printf("[Info  ] WiFi Scan: %v", out)
			}

			resp.Write([]byte(outJson))

			firstItemServed = true
		}
	}

	resp.Write([]byte{']'})
}

/*-------------------------*/

// Implements GET /net/wifi/ap
func GetNetAP(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	var cmd string

	cmd = "egrep \"^ssid=\" /etc/hostapd/hostapd.conf | awk '{match($0, /ssid=([^\"]+)/, a)} END{print a[1]}'"
	ssid, err := execOnHost(cmd)
	if err != nil {
		log.Printf("[HOST  ] %s \t %s", err.Error(), ssid)
		ssid = ""
	}

	cmd = "egrep \"^wpa_passphrase=\" /etc/hostapd/hostapd.conf | awk '{match($0, /wpa_passphrase=([^\"]+)/, a)} END{print a[1]}'"
	password, err := execOnHost(cmd)
	if err != nil {
		log.Printf("[HOST  ] %s \t %s", err.Error(), password)
		password = ""
	}

	cmd = "iw dev | awk '$1==\"Interface\"{print $2}' | grep \"" + WIFI_DEVICE + "\""
	deviceRes, _ := exeCmd(cmd)

	cmd = "ip -4 addr show " + WIFI_DEVICE + " | awk '$1 == \"inet\" {gsub(/\\/.*$/, \"\", $2); print $2}'"
	ip, _ := exeCmd(cmd)

	out := map[string]interface{}{
		"available": deviceRes != "",
		"device":    WIFI_DEVICE,
		"SSID":      ssid,
		"password":  password,
		"ip":        ip,
	}

	outJson, err := json.Marshal(out)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	resp.Write([]byte(outJson))

}

/*-------------------------*/

// Implements POST|PUT /net/wifi/ap
func SetNetAP(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	if err := req.ParseForm(); err != nil {
		log.Printf("[Err   ] %s", err.Error())
		if DEBUG_MODE {
			http.Error(resp, "[ Error ]: "+err.Error(), http.StatusInternalServerError)
		}
		return
	}

	var reqJson map[string]interface{}
	decoder := json.NewDecoder(req.Body)
	err := decoder.Decode(&reqJson)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	var cmd string

	out := ""

	if ssid, exist := reqJson["SSID"]; exist {
		if str, ok := ssid.(string); ok {
			cmd = "sed -i 's/^ssid.*/ssid=" + str + "/g' /etc/hostapd/hostapd.conf"
			stdout, err := execOnHost(cmd)
			if err != nil {
				log.Printf("[HOST  ] %s \t %s", err.Error(), stdout)
			}

			// cmd = "echo "+ str +" | tee /etc/hostapd/custom_ssid.txt > /dev/null"
			// exeCmd( cmd)

			out += "SSID "
		}
	}

	if password, exist := reqJson["password"]; exist {
		if str, ok := password.(string); ok {
			cmd = "sed -i 's/^wpa_passphrase.*/wpa_passphrase=" + str + "/g' /etc/hostapd/hostapd.conf"
			stdout, err := execOnHost(cmd)
			if err != nil {
				log.Printf("[HOST  ] %s \t %s", err.Error(), stdout)
			}

			out += "and Password "
		}
	}

	out += "saved."

	outJSON, err := json.Marshal(out)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	resp.Write([]byte(outJSON))

}

/*-------------------------*/

// Checks if Wziup cloud is accessible
func CloudAccessible(withLogs bool) bool {

	cmd := "timeout 3 curl -Is https://waziup.io | head -n 1 | awk '{print $2}'"
	rCode, _ := exeCmdWithLogs(cmd, withLogs)

	return rCode == "200"
}

/*-------------------------*/

// InternetAccessible implements GET /internet
func InternetAccessible(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	if CloudAccessible(true) {

		resp.Write([]byte("1"))

	} else {

		resp.Write([]byte("0"))
	}

}

/*-------------------------*/

// This function retrieves the IP addesses of all connected network interfaces (e.g. Wlan, Ethernet)
// It is usually used by the OLED controller
func GetAllIPs() (string, string, string, string) {

	cmd := "iw " + WIFI_DEVICE + " info | grep ssid | awk '{print $2\" \"$3\" \"$4\" \"$5\" \"$6}'"
	ssid, _ := exeCmdWithLogs(cmd, false)

	cmd = "status=$(ip addr show " + WIFI_DEVICE + " | grep \"state UP\"); if [ \"$status\" == \"\" ]; then echo \"\"; else echo $(ip -4 addr show " + WIFI_DEVICE + " | awk '$1 == \"inet\" {gsub(/\\/.*$/, \"\", $2); print $2}');  fi;"
	wip, _ := exeCmdWithLogs(cmd, false)
	aip := wip

	cmd = "status=$(ip addr show " + ETH_DEVICE + " | grep \"state UP\"); if [ \"$status\" == \"\" ]; then echo \"NOT Connected\"; else echo $(ip -4 addr show " + ETH_DEVICE + " | awk '$1 == \"inet\" {gsub(/\\/.*$/, \"\", $2); print $2}');  fi;"
	eip, _ := exeCmdWithLogs(cmd, false)

	if apMode(false) {
		wip = ""
	} else {
		aip = ""
	}

	return eip, wip, aip, ssid
}

/*-------------------------*/

// NetworkLoop provides a constant connectivity check
func NetworkLoop() {

	// Connecting might take some time, so throw it into another thread ;)
	go func() {

		// Wait for the host to come up before sending any command
		for {
			if hostReady() {
				oledWrite("\n \n    HOST READY")
				break
			}
			log.Println("[Info  ] Waiting for the HOST...")
			oledWrite("\n Waiting\n     for \n   the HOST")
			time.Sleep(2 * time.Second)
		}

		// Check WiFi Connectivity
		if CheckWlanConn() {
			oledWrite("\n WiFi Connected ")
			if DEBUG_MODE {
				log.Println("[Info  ] WiFi Connected.")
			}
		}

		// In order to provide a stable connectivity,
		// let's not rely on the OS and check the WiFi connection periodically
		time.Sleep(60 * time.Second)
		for {
			// We need to avoid race condition
			wifiOperation.Lock()

			wifiStatus, err := getNetWiFi()

			if err == nil {
				if apMode, ok := wifiStatus["ap_mode"]; ok {

					SSID, okSSID := wifiStatus["ssid"]
					IP, okIP := wifiStatus["ip"]

					if (okSSID && SSID == "") || (okIP && IP == "") {

						// Reconnect
						oledWrite("\n WiFi\n Reconnecting...")
						if apMode == true {
							ActivateAPMode()

						} else {

							startWiFiClient()
						}
					}
				}
			}

			wifiOperation.Unlock()

			time.Sleep(30 * time.Second)
		}
	}()
}

/*-------------------------*/
