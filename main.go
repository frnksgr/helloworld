package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"
)

const defaultPort = 8080
const defaultFrom = "NoWhere"

// logger writing to stdout
var logger = log.New(os.Stdout, "APP ", log.Lshortfile)

// get port from env or use defaultPort
func getPort() int {
	var port = defaultPort
	var err error

	if value, ok := os.LookupEnv("PORT"); ok {
		if port, err = strconv.Atoi(value); err != nil {
			logger.Println("Cannot convert PORT from environment")
			logger.Println("Using defaut port")
		}
	} else {
		logger.Println("No PORT env variable found")
		logger.Printf("Using defaut port: %d\n", defaultPort)
	}
	return port
}

func getFrom() string {
	if value, ok := os.LookupEnv("FROM"); ok {
		return value
	} else {
		return defaultFrom
	}
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	logger.Printf("%s %s %s \n", r.Method, r.URL, r.Proto)
	fmt.Fprintf(w, "%s %s %s \n", r.Method, r.URL, r.Proto)
	//Iterate over all header fields
	for k, v := range r.Header {
		fmt.Fprintf(w, "Header field %q, Value %q\n", k, v)
	}
	fmt.Fprintf(w, "Host = %q\n", r.Host)
	fmt.Fprintf(w, "RemoteAddr= %q\n", r.RemoteAddr)
	//Get value for a specified token
	//fmt.Fprintf(w, "\n\nFinding value of \"Accept\" %q", r.Header["Accept"])
}

func main() {
	var port = getPort()
	var listener, _ = net.Listen("tcp4", ":"+strconv.Itoa(port))
	var from = getFrom()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		logger.Printf("%s %s %s \n", r.Method, r.URL, r.Proto)
		fmt.Fprintf(w, "Hello World!\nFrom: %s\n", from)
	})

	http.HandleFunc("/info", infoHandler)

	logger.Printf("Starting server on port %d ...", port)
	logger.Fatal(http.Serve(listener, nil))
}
