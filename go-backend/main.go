package main

import (
	"fmt"
	"go-backend/src/config"
	"go-backend/src/db"
	"go-backend/src/service"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func init() {

}

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	c := config.GetConfig()

	// Ensure DB disconnection on application exit
	defer func() {
		err := db.DisconnectDb()
		if err != nil {
			fmt.Printf("failed to disconnect db: %v", err)
		}
	}()

	routes := service.ApiHandleFunctions{}
	router := service.NewRouter(routes)

	port := fmt.Sprintf(":%d", c.ServerPort)
	err := router.Run(port)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to start server")
	}
}
