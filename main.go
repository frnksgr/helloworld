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
		log.Printf("%s %s %s \n", r.Method, r.URL, r.Proto)
		next.ServeHTTP(w, r)
	})
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "%s %s %s \n", r.Method, r.URL, r.Proto)
	//Iterate over all header fields
	for k, v := range r.Header {
		fmt.Fprintf(w, "Header field %q, Value %q\n", k, v)
	}
}

func defaultHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World!\nFrom: %s\n", getEnv("FROM", "nowhere"))
}

func main() {
	log.Print("Hello world sample started.")

	http.HandleFunc("/", defaultHandler)
	http.HandleFunc("/info", infoHandler)

	address := fmt.Sprintf(":%s", getEnv("PORT", defaultPort))
	log.Printf("Running http server on %s", address)
	log.Fatal(http.ListenAndServe(address, requestLogger(http.DefaultServeMux)))
}
