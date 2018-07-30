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

// logger writing to stdout
var logger = log.New(os.Stdout, "APP ", log.Lshortfile)

// get port from env or use defaultPort
func getPort() int {
	var port = defaultPort
	var err error

	if value, hasPort := os.LookupEnv("PORT"); hasPort {
		if port, err = strconv.Atoi(value); err != nil {
			logger.Println("Cannot convert PORT from environment")
			logger.Printf("Using defaut port: %d\n", defaultPort)
		}
	} else {
		logger.Println("No PORT env variable found")
		logger.Printf("Using defaut port: %d\n", defaultPort)
	}
	return port
}

func main() {
	var port = getPort()
	var listener, _ = net.Listen("tcp4", ":"+strconv.Itoa(port))

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello World!\n")
		logger.Println(r.Proto, r.Host, r.Method, r.URL)
	})

	logger.Printf("Starting server on port %d ...", port)
	logger.Fatal(http.Serve(listener, nil))
}
