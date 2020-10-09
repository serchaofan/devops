package main

import (
  "github.com/go-redis/redis/v8"
  "fmt"
)
func main() {
  client := redis.NewClient(&redis.Options{
    Addr: "127.0.0.1:6379",
    Password: "xxxxxxxxx",
    DB: 0,
  })
  _, err := client.Ping(client.Context()).Result()
  if err != nil {
    fmt.Println("DEAD")
  }else{
    fmt.Println("PONG")
  }
}