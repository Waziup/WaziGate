package api

import (
	"bytes"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
)

// This function performs a unit test on the exposed APIs
func TestRouting(t *testing.T) {

	// Test table
	tt := []struct {
		name     string
		api      string
		method   string
		postData string
		needle   string // a substring that should be found in the output content
		status   int
		err      string
	}{
		{
			name:   "API Path: /",
			api:    "/",
			method: "GET",
			status: 200,
		},
		{
			name:   "API Path: /ui/",
			api:    "/ui/",
			method: "GET",
			needle: "<body",
			status: 200,
		},
		{
			name:   "API Path: /ui/*file_path",
			api:    "/ui/index.html",
			method: "GET",
			needle: "<body",
			status: 200,
		},
		{
			name:   "API Path: /ui/:file_path 404",
			api:    "/ui/gholi_not_exist.html",
			method: "GET",
			status: 404,
		},
		{
			name:   "API Path: /docs/",
			api:    "/docs/",
			method: "GET",
			needle: "<body",
			status: 200,
		},
		{
			name:   "API Path: /docs/:file_path 404",
			api:    "/docs/gholi_not_exist.html",
			method: "GET",
			status: 404,
		},
		{
			name:   "API Path: /docker",
			api:    "/docker",
			method: "GET",
			needle: "waziup.wazigate-system",
			status: 200,
		},
		{
			name:   "API Path: /docker/:cId",
			api:    "/docker/gholi_not_exist",
			method: "GET",
			needle: "[]",
			status: 200,
		},
		{
			name:     "API Path: /docker/:cId/:action",
			api:      "/docker/gholi/stop",
			method:   "POST",
			postData: "",
			needle:   "No such container: gholi",
			status:   200,
		},
		{
			name:     "API Path: /docker/:cId/:action",
			api:      "/docker/gholi/stop",
			method:   "PUT",
			postData: "",
			needle:   "No such container: gholi",
			status:   200,
		},
		{
			name:   "API Path: /docker/:cId/logs",
			api:    "/docker/gholi/logs",
			method: "GET",
			status: 200,
		},
		{
			name:   "API Path: /docker/:cId/logs/:tail",
			api:    "/docker/gholi/logs/50",
			method: "GET",
			status: 200,
		},
		{
			name:   "API Path: /time",
			api:    "/time",
			method: "GET",
			needle: "time",
			status: 200,
		},
		{
			name:   "API Path: /timezones",
			api:    "/timezones",
			method: "GET",
			needle: "Tehran",
			status: 200,
		},
		{
			name:   "API Path: /timezone/auto",
			api:    "/timezone/auto",
			method: "GET",
			needle: "\"",
			status: 200,
		},
		{
			name:   "API Path: /timezone",
			api:    "/timezone",
			method: "GET",
			needle: "\"",
			status: 200,
		},
		{
			name:     "API Path: /timezone",
			api:      "/timezone",
			method:   "PUT",
			postData: "",
			status:   400,
		},
		{
			name:     "API Path: /timezone",
			api:      "/timezone",
			method:   "PUT",
			postData: `"Asia/Tehran"`,
			status:   200,
		},
		{
			name:     "API Path: /timezone",
			api:      "/timezone",
			method:   "POST",
			postData: `"Asia/Tehran"`,
			status:   200,
		},
		{
			name:   "API Path: /usage",
			api:    "/usage",
			method: "GET",
			needle: "cpu_usage",
			status: 200,
		},
		{
			name:   "API Path: /blackout",
			api:    "/blackout",
			method: "GET",
			status: 200,
		},
		{
			name:   "API Path: /conf",
			api:    "/conf",
			method: "GET",
			needle: "local_timezone",
			status: 200,
		},
		{
			name:     "API Path: /conf",
			api:      "/conf",
			method:   "POST",
			postData: `{"fan_trigger_temp":61}`,
			status:   200,
		},
		{
			name:     "API Path: /conf",
			api:      "/conf",
			method:   "PUT",
			postData: `{"fan_trigger_temp":61}`,
			status:   200,
		},
		{
			name:   "API Path: /net",
			api:    "/net",
			method: "GET",
			needle: "mac",
			status: 200,
		},
		{
			name:   "API Path: /gwid",
			api:    "/gwid",
			method: "GET",
			status: 200,
		},
		{
			name:   "API Path: /net/wifi",
			api:    "/net/wifi",
			method: "GET",
			needle: "ap_mode",
			status: 200,
		},
		{
			name:     "API Path: /net/wifi",
			api:      "/net/wifi",
			method:   "POST",
			postData: "",
			status:   200,
		},
		{
			name:     "API Path: /net/wifi",
			api:      "/net/wifi",
			method:   "PUT",
			postData: "",
			status:   200,
		},
		{
			name:   "API Path: /internet",
			api:    "/internet",
			method: "GET",
			status: 200,
		},
		{
			name:   "API Path: /net/wifi/scanning",
			api:    "/net/wifi/scanning",
			method: "GET",
			needle: "[",
			status: 200,
		},
		{
			name:   "API Path: /net/wifi/ap",
			api:    "/net/wifi/ap",
			method: "GET",
			needle: "SSID",
			status: 200,
		},
		{
			name:   "API Path: /net/wifi/ap",
			api:    "/net/wifi/ap",
			method: "POST",
			status: 200,
		},
		{
			name:   "API Path: /net/wifi/ap",
			api:    "/net/wifi/ap",
			method: "PUT",
			status: 200,
		},
		{
			name:   "API Path: /net/wifi/mode/ap",
			api:    "/net/wifi/mode/ap",
			method: "POST",
			needle: "Access Point mode Activated",
			status: 200,
		},
		{
			name:   "API Path: /net/wifi/mode/ap",
			api:    "/net/wifi/mode/ap",
			method: "PUT",
			needle: "Access Point mode Activated",
			status: 200,
		},
		{
			name:     "API Path: /oled",
			api:      "/oled",
			method:   "POST",
			postData: "OLED Test Msg",
			status:   200,
		},
		{
			name:     "API Path: /oled",
			api:      "/oled",
			method:   "PUT",
			postData: "", // Cleanup the OLED
			status:   200,
		},
	}

	/*---------------------*/

	if os.Getenv("EXEC_PATH") == "" {
		t.Fatalf("Env variable `EXEC_PATH` is not set!\n It is required for routing test.")
	}

	/*---------------------*/

	router := setupRouter()

	server := httptest.NewServer(router)
	defer server.Close()

	for _, tc := range tt {

		t.Run(tc.name, func(t *testing.T) {

			apiPath := server.URL + tc.api

			req, err := http.NewRequest(tc.method, apiPath, bytes.NewReader([]byte(tc.postData)))
			if err != nil {
				t.Fatalf("Could not sed `%s` request: %v", tc.method, err)
			}

			req.Header.Set("Content-Type", "application/json; charset=UTF-8")

			res, err := http.DefaultClient.Do(req)
			if err != nil {
				t.Fatalf("Could not receive any response: %v", err)
			}
			defer res.Body.Close()

			content, err := ioutil.ReadAll(res.Body)
			if err != nil {
				t.Fatalf("Could not read the content: %v", err)
			}

			if res.StatusCode != tc.status {
				t.Fatalf("Request failed: `%v` ==> %v", apiPath, res.Status)
			}

			if tc.err != "" && tc.err != string(content) {
				t.Errorf("Expected error message %q; got %q", tc.err, string(content))
			}

			if tc.needle != "" && !strings.Contains(string(content), tc.needle) {
				t.Fatalf("Expected to find %q in the content", tc.needle)
			}
		})
	}
}
