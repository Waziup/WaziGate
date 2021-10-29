package api

import (
	// "fmt"
	"encoding/json"
	"errors"
	"log"
	"regexp"
	"strings"
	"time"

	// "strconv"
	"context"
	"io"
	"net"
	"net/http"

	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"

	routing "github.com/julienschmidt/httprouter"
)

/*-------------------------*/

// Configuration keeps the general config of the settings app
type Configuration struct {
	SetupWizard     bool    `json:"setup_wizard"`
	FanTriggerTemp  float64 `json:"fan_trigger_temp"`  // At which temperature the Fan should start
	OLEDHaltTimeout int     `json:"oled_halt_timeout"` // After what time the OLED goes off
	LocalTimezone   string  `json:"local_timezone"`    // Local time zone
}

/*----------------*/

// This function loads the configuration file into the Configuration object
func loadConfigs() Configuration {

	filename := GetRootPath() + "/conf.json"
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
		return Configuration{
			false,
			62.1,   // in CC
			1 * 60, // 1 minutes
			"auto", // Auto means set the local timezone based on the connected IP
		}
	}

	var c Configuration
	err = json.Unmarshal(bytes, &c)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
		return Configuration{}
	}
	return c
}

/*-------------------------*/

// This function executes a shell command in the `wazigate-system` container
// `withLogs` indicates that if the function should print logs of the command or not
func exeCmdWithLogs(cmd string, withLogs bool) (string, error) {

	if withLogs && DEBUG_MODE {
		log.Printf("[Info  ] executing [ %s ] ", cmd)
	}

	exe := exec.Command("sh", "-c", cmd)
	stdout, err := exe.Output()

	if err != nil {
		if withLogs {
			log.Printf("[Err   ] executing [ %s ] command. \n\tError: [ %s ]", cmd, err.Error())
		}
		return "", err
	}
	return strings.Trim(string(stdout), " \n\t\r"), nil
}

/*-------------------------*/

// Execute a shell command with Logs in the `wazigate-system` container
func exeCmd(cmd string) (string, error) {
	return exeCmdWithLogs(cmd, true)
}

/*-------------------------*/

// This function returns `true` if the host deamon is responsing
// and so available to execute shell command on the host
func hostReady() bool {

	socketAddr := os.Getenv("WAZIGATE_HOST_ADDR")
	if socketAddr == "" {
		socketAddr = "/var/run/wazigate-host.sock" // Default address for the Host
	}

	_, err := SocketReqest(socketAddr, "", "GET", "", strings.NewReader(""), false)
	return err == nil

}

/*-------------------------*/

// This function executes a shell command on the host
// Use this function with care as all the commands are executed on the host machine
// `withLogs` indicates that if the function should print logs of the command or not
func execOnHostWithLogs(cmd string, withLogs bool) (string, error) {

	if withLogs && DEBUG_MODE {
		log.Printf("[Exec  ]: Host Command [ %s ]", cmd)
	}

	socketAddr := os.Getenv("WAZIGATE_HOST_ADDR")
	if socketAddr == "" {
		socketAddr = "/var/run/wazigate-host.sock" // Default address for the Host
	}

	response, err := SocketReqest(socketAddr, "cmd", "POST", "application/json", strings.NewReader(cmd), withLogs)

	if err != nil {
		if response != nil && response.Body != nil {
			response.Body.Close()
		}
		if withLogs {
			log.Printf("[Err   ]: %s ", err.Error())
		}

		oledWrite("\n\n  HOST ERROR!")

		return "", err
	}

	resBody, err := ioutil.ReadAll(response.Body)
	response.Body.Close()
	if err != nil {
		log.Printf("[Err   ]: %s ", err.Error())
		return "", err
	}

	err = nil
	if response.StatusCode != 200 {
		err = errors.New("Execution failed on the host!")
	}

	return string(resBody), err
}

/*-------------------------*/

// This function executes a shell command on the host and shows the logs
func execOnHost(cmd string) (string, error) {
	return execOnHostWithLogs(cmd, true)
}

/*-------------------------*/

// This function retrieves the root path of where the binary is being executed
func GetRootPath() string {
	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}
	return dir
}

/*-------------------------*/

// Implements GET /conf
func GetSystemConf(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	// bytes, err := json.MarshalIndent( Config, "", "  ")
	bytes, err := json.Marshal(Config)

	if err != nil {
		log.Printf("[Err   ] %s", err.Error())

		errorDesc := ""
		if DEBUG_MODE {
			errorDesc = err.Error()
		}
		if resp != nil {
			http.Error(resp, "[Err   ]: "+errorDesc, http.StatusInternalServerError)
		}
	}
	resp.Write(bytes)
}

/*-------------------------*/

// Implements POST|PUT /conf
func SetSystemConf(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	decoder := json.NewDecoder(req.Body)

	if err := decoder.Decode(&Config); err != nil {

		log.Printf("[Err   ] %s", err.Error())
		if DEBUG_MODE {
			http.Error(resp, "[ Error ]: "+err.Error(), http.StatusBadRequest)
		}
		return
	}

	saveConfig(Config)
	resp.Write([]byte("Saved"))
}

/*-------------------------*/

// Implements POST|PUT /shutdown
func SystemShutdown(resp http.ResponseWriter, req *http.Request, params routing.Params) {
	systemShutdown("shutdown")
}

/*-------------------------*/

// Implements POST|PUT /reboot
func SystemReboot(resp http.ResponseWriter, req *http.Request, params routing.Params) {
	systemShutdown("reboot")
}

/*-------------------------*/

// This function shutdown/reboot the gateway gracefully
func systemShutdown(status string) {

	cmd := "sudo docker stop $(sudo docker ps -a -q); "
	if status == "reboot" {
		oledWrite("\n  Rebooting...")
		cmd += "sudo shutdown -r now"
	}

	if status == "shutdown" {
		oledWrite("\nShutting down...")
		cmd += "sudo shutdown -h now"
	}

	time.Sleep(2 * time.Second)

	oledWrite("") // Clean the OLED

	time.Sleep(1 * time.Second)

	log.Printf("[Info  ] System %s", status)

	oledHalt()

	stdout, _ := execOnHost(cmd)
	log.Printf("[Info  ] %s", stdout)
}

/*-------------------------*/

// This function shutdown the gateway gracefully, but quick without showing messages etc.
func systemQuickShutdown() {

	cmd := "sudo docker stop $(sudo docker ps -a -q); sudo shutdown -h now"

	stdout, _ := execOnHost(cmd)
	log.Printf("[Info  ] %s", stdout)
}

/*-------------------------*/

// This function writes down the Configuration object into the config file
func saveConfig(c Configuration) {

	filename := GetRootPath() + "/conf.json"

	bytes, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
		return
	}

	err = ioutil.WriteFile(filename, bytes, 0644)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}
}

/*-------------------------*/

// // Deprecated function
// func SystemUpdate(resp http.ResponseWriter, req *http.Request, params routing.Params) {

// 	oledWrite("\nUpdating...")

// 	cmd := "sudo bash update.sh | sudo tee update.logs &" // Run it and unlock the thing

// 	stdout, _ := execOnHost(cmd)
// 	log.Printf("[Info   ] %s", stdout)

// 	oledWrite("\nDONE.")

// 	time.Sleep(1 * time.Second)

// 	oledWrite("") // Clean the OLED

// 	out := "Update Done."

// 	outJson, err := json.Marshal(out)
// 	if err != nil {
// 		log.Printf("[Err   ] %s", err.Error())
// 	} /**/

// 	resp.Write([]byte(outJson))
// }

// /*-------------------------*/

// func SystemUpdateStatus(resp http.ResponseWriter, req *http.Request, params routing.Params) {

// 	cmd := "[ -f update.logs ] && cat update.logs"
// 	stdout, err := execOnHost(cmd)
// 	if err != nil {
// 		stdout = ""
// 		log.Printf("[Err   ] %s", err.Error())
// 	}

// 	outJson, err := json.Marshal(stdout)
// 	if err != nil {
// 		log.Printf("[Err   ] %s", err.Error())
// 	}
// 	resp.Write([]byte(outJson))
// }

// /*-------------------------*/

// This function provides the booting up information to be shown on the OLED
func GetGWBootstatus(withLogs bool) (bool, string) {

	//TODO: Old code. we need to use docker APIs directly

	cmd := "curl -s --unix-socket /var/run/docker.sock http://localhost/containers/json?all=true"
	outJsonStr, err := execOnHostWithLogs(cmd, withLogs)
	if err != nil {
		return false, ".."
	}

	var resJson []map[string]interface{}

	json.Unmarshal([]byte(outJsonStr), &resJson)

	allOk := true
	out := ""

	for _, obj := range resJson {

		// Finding the wazigate containers...
		re := regexp.MustCompile(`/wazigate-(.*)`)
		reFnd := re.FindSubmatch([]byte(obj["Names"].([]interface{})[0].(string)))

		if len(reFnd) < 1 {
			continue
		}
		cName := string(reFnd[1])

		cState := strings.ToUpper(obj["State"].(string))

		if cState != "RUNNING" {
			allOk = false
		}
		// cState = cState[0:3]

		neededSpaces := 16 - len(cName) - 2 - len(cState)
		out += cName + ": " + strings.Repeat(" ", neededSpaces) + cState + "\n"
	}

	return allOk, out
}

/*-------------------------*/

// // Deprecated function
// func FirmwareVersion(resp http.ResponseWriter, req *http.Request, params routing.Params) {

// 	out := os.Getenv("WAZIUP_VERSION")

// 	outJson, err := json.Marshal(out)
// 	if err != nil {
// 		log.Printf("[Err   ] %s", err.Error())
// 	}

// 	resp.Write([]byte(outJson))

// }

/*-------------------------*/

// SocketReqest makes a request to a unix socket
func SocketReqest(socketAddr string, url string, method string, contentType string, body io.Reader, withLogs bool) (*http.Response, error) {

	if withLogs && DEBUG_MODE {
		log.Printf("[SOCK ] `%s` %s \"%s\" '%v'", socketAddr, method, url, body)
	}

	httpc := http.Client{
		Transport: &http.Transport{
			DialContext: func(_ context.Context, _, _ string) (net.Conn, error) {
				return net.Dial("unix", socketAddr)
			},
			MaxIdleConns:    50,
			IdleConnTimeout: 3 * 60 * time.Second,
		},
	}

	req, err := http.NewRequest(method, "http://localhost/"+url, body)

	if err != nil {
		log.Printf("[Socket   ]: %s ", err.Error())
		return nil, err
	}

	if contentType != "" {
		req.Header.Set("Content-Type", contentType)
	}

	response, err := httpc.Do(req)
	// defer response.Body.Close()

	if err != nil {
		log.Printf("[Socket]: %s ", err.Error())
		return nil, err
	}

	return response, nil
}

/*-------------------------*/
