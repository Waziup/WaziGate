package api

import (
	// "fmt"
	"encoding/json"
	"log"
	"net/http"
	"strings"

	// "strconv"

	// "github.com/wasmup/metrics"

	routing "github.com/julienschmidt/httprouter"
)

/*-------------------------*/

// This function implements GET /usage
// It provides the CPU, RAM and Storage (e.g. Disk) usage
func ResourceUsage(resp http.ResponseWriter, req *http.Request, params routing.Params) {

	// temp	:= execOnHost( "vcgencmd measure_temp | egrep -o '[0-9]*\\.[0-9]*'");
	// tempInt, _	:= strconv.ParseInt( execOnHost( `cat /sys/class/thermal/thermal_zone0/temp`), 10, 64);
	// temp	:=	string( tempInt / 1000);
	temp, _ := execOnHost(`echo "$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))"`)
	// config	:= execOnHost( "vcgencmd get_config int");

	/*---------*/

	/*clocks := map[string]int{
		"arm"	: 0,
		"core"	: 0,
		"h264"	: 0,
		"isp"	: 0,
		"v3d"	: 0,
		"uart"	: 0,
		"pwm"	: 0,
		"emmc"	: 0,
		"pixel"	: 0,
		"vec"	: 0,
		"hdmi"	: 0,
		"dpi"	: 0,
	}

	for i := range clocks {
		res	:= execOnHost( "vcgencmd measure_clock "+ i +" | cut -f2 -d \"=\"", resp);
		// clocks[i], _ = strconv.ParseInt( string( res), 10, 64)
		clocks[i], _ = strconv.Atoi( res)
		clocks[i] 	/= 1000000 //Calculate in MHz
	}

	/*------------*/

	/*volts := map[string]string{ "core" : "0", "sdram_c" : "0", "sdram_i" : "0", "sdram_p" : "0"}
	for i := range volts {
		volts[i] = execOnHost( "vcgencmd measure_volts "+ i +" | egrep -o '[0-9]*\\.[0-9]*'", resp);
	}

	/*---------------*/

	/*mem_alloc := map[string]string{ "arm" : "0", "gpu" : "0"}
	for i := range mem_alloc {
		mem_alloc[i] = execOnHost( "vcgencmd get_mem "+ i +" | cut -f2 -d \"=\"", resp);
	}

	/*---------------*/

	outc, _ := exeCmd("df -B 1 /")
	dres := strings.Fields(string(strings.Split(outc, "\n")[1]))
	disk := map[string]string{
		"device":     dres[0],
		"size":       dres[1],
		"used":       dres[2],
		"available":  dres[3],
		"percent":    dres[4],
		"mountpoint": dres[5],
	}

	/*---------------*/

	//cpu_usage := exeCmd( "grep 'cpu ' /proc/stat | awk '{usage=(($2+$4)*100/($2+$4+$5))} END {printf int(usage)}'", resp);
	//cpu_usage := exeCmd( "awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf int(($2+$4-u1) * 100 / (t-t1)); }' <(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat)", resp);
	//cpu_usage := exeCmd( "top -bn1 | grep \"Cpu(s)\" | sed \"s/.*, *\\([0-9.]*\\)%* id.*/\\1/\" | awk '{printf (100 - $1)}'", resp);
	//cpu_usage := exeCmd( "top -bn1 | grep \"Cpu(s)\" | sed \"s/.*, *\\\\([0-9.]*\\\\)%* id.*/\\\\1/\" | awk '{print int( 100 - $1)}'", resp);
	cpu_usage, _ := execOnHost(`top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print int( 100 - $1)}'`)

	/*---------------*/

	outc, _ = exeCmd("free | grep Mem")
	mres := strings.Fields(outc)
	mem_usage := map[string]string{
		"total": mres[1],
		"used":  mres[2],
	}

	/*---------------*/

	out := map[string]interface{}{
		"temp": temp,
		// "config"	:	config,
		// "clocks"	:	clocks,
		// "volts"		:	volts,
		// "mem_alloc"	:	mem_alloc,
		"disk":      disk,
		"cpu_usage": cpu_usage,
		"mem_usage": mem_usage,
	}

	outJson, err := json.Marshal(out)
	if err != nil {
		log.Printf("[Err   ] %s", err.Error())
	}

	resp.Write([]byte(outJson))
}

/*-------------------------*/
