package main

import (
	"fmt"
	"log"
	// "time"
	"net/http"
	// "encoding/json"
	"strings"
	// "strconv"

	routing "github.com/julienschmidt/httprouter"


	i2c "github.com/d2r2/go-i2c"
	logger "github.com/d2r2/go-logger"
	// shell "github.com/d2r2/go-shell"
	si7021 "github.com/d2r2/go-si7021"	
)

func init() {
}

/*-------------------------*/

func AllSensors( resp http.ResponseWriter, req *http.Request, params routing.Params) {
	
	out := `[`;


	/*---------*/

	out += getCPUTemp()	+ ","
	out += getSi7021()	+ ","

	/*---------*/

	out = strings.Trim( string( out), ",")
	out += `]`;

	// log.Printf( out);

	resp.Write([]byte(out ))
}

/*-------------------------*/

func GetSensor( resp http.ResponseWriter, req *http.Request, params routing.Params) {

	sensorName := params.ByName( "sensor_name")
	out := ""

	switch( sensorName){

	case "cpu_temp": 
		out = getCPUTemp()
		break;

	case "si7021":
		out = getSi7021()
		break;
	}

	resp.Write([]byte(out ))
}

/*-------------------------*/

func getCPUTemp() string {
	
	cpu_temp := exeCmd( `echo "$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))"`, false);
	if( cpu_temp != ""){
		return fmt.Sprintf( `{
			"name": "cpu_temp",
			"desc": "CPU temperature",
			"value": %v
		}`, cpu_temp);
	}	
	
	return	""
}


/*-------------------------*/

func getSi7021() string {

	logger.NewPackageLogger( "main",
		// logger.DebugLevel,
		logger.ErrorLevel,
	)

// Create new connection to i2c-bus on 1 line with address 0x40.
	// Use i2cdetect utility to find device address over the i2c-bus
	i2c, err := i2c.NewI2C( 0x40, 1)
	if err != nil {
		log.Printf( "[Err  ] si7021 not found: ", err.Error())
		return ""
	}
	defer i2c.Close()
	
	sensor := si7021.NewSi7021()
	
	rh, t, err := sensor.ReadRelativeHumidityAndTemperature( i2c)
	if err != nil {
		log.Printf( "[Err  ] ", err.Error())
		return ""
	}

	return fmt.Sprintf( `{
		"name": "si7021",
		"desc": "Relative humidity and temperature",
		"value": {
			"humidity": %v,
			"temperature": %v
		}
	}`, rh, t);

}

/*-------------------------*/