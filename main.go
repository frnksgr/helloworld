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

func main() {
	var (
		port     int
		listener net.Listener
		err      error
		logger   *log.Logger
	)

	if value, hasPort := os.LookupEnv("PORT"); hasPort {
		if port, err = strconv.Atoi(value); err != nil {
			log.Println("Cannot read PORT from environment")
			log.Fatal(err)
		}
	} else {
		port = defaultPort
	}

	listener, err = net.Listen("tcp4", ":"+strconv.Itoa(port))
	if err != nil {
		log.Fatal(err)
	}

	logger = log.New(os.Stdout, "APP ", log.Lshortfile)

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello World!\n")
		logger.Println(r.Proto, r.Host, r.Method, r.URL)
	})

	logger.Printf("Starting server on port %d ...", port)
	log.Fatal(http.Serve(listener, nil))
}
