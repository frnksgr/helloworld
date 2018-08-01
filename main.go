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

func main() {
	var port = getPort()
	var listener, _ = net.Listen("tcp4", ":"+strconv.Itoa(port))
	var from = getFrom()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello World!\nFrom: %s\n", from)
		logger.Println(r.Proto, r.Host, r.Method, r.URL)
	})

	logger.Printf("Starting server on port %d ...", port)
	logger.Fatal(http.Serve(listener, nil))
}
