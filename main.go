package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

const defaultPort = "8080"

func getEnv(name string, fallback string) string {
	value, ok := os.LookupEnv(name)
	if !ok {
		value = fallback
	}
	return value
}

// middleware doing request logging
func requestLogger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Got request: %s %s %s \n", r.Proto, r.Method, r.URL)
		next.ServeHTTP(w, r)
	})
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "%s %s %s \n", r.Proto, r.Method, r.URL)
	//Iterate over all header fields
	for k, v := range r.Header {
		fmt.Fprintf(w, "Header field %q, Value %q\n", k, v)
	}
}

func defaultHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World!\nFrom: %s\n", getEnv("FROM", "nowhere"))
}

func main() {
	http.HandleFunc("/", defaultHandler)
	http.HandleFunc("/info", infoHandler)

	address := fmt.Sprintf("0.0.0.0:%s", getEnv("PORT", defaultPort))
	fmt.Printf("Running http server on %s\n", address)

	// get it rolling ...
	log.Fatal(http.ListenAndServe(address, requestLogger(http.DefaultServeMux)))
}
