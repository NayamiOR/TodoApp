package config

import (
	"fmt"

	"github.com/spf13/viper"
)

type Config struct {
	DatabaseURL string
	ServerPort  int32
	FrontEndURL string
	DbConfig    *DbConfig
}

// DbConfig Reference for DbConfig fields: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PARAMKEYWORDS
type DbConfig struct {
	Host     string
	Port     int32
	DbName   string
	User     string
	Password string
}

func (c *Config) GetDbConfig() (*DbConfig, error) {
	if c.DbConfig != nil {
		return c.DbConfig, nil
	}
	return nil, fmt.Errorf("db config is not set")
}

var globalConfig *Config

func init() {
	err := LoadConfig()
	if err != nil {
		panic(fmt.Errorf("failed to load config: %w", err))
	}
}

func LoadConfig() error {
	viper.AutomaticEnv()
	viper.SetConfigFile(".env")
	err := viper.ReadInConfig()
	if err != nil {
		return fmt.Errorf("error reading config file: %w", err)
	}
	DataBaseURL := viper.GetString("DATABASE_URL")
	ServerPort := viper.GetInt32("SERVER_PORT")
	FrontEndURL := viper.GetString("FRONT_END_URL")

	if DataBaseURL == "" || ServerPort == 0 || FrontEndURL == "" {
		errStr := fmt.Errorf("missing required configuration values")
		if DataBaseURL == "" {
			errStr = fmt.Errorf("%w, DATABASE_URL is missing", errStr)
		}
		if ServerPort == 0 {
			errStr = fmt.Errorf("%w, SERVER_PORT is missing or zero", errStr)
		}
		if FrontEndURL == "" {
			errStr = fmt.Errorf("%w, FRONT_END_URL is missing", errStr)
		}
		return errStr
	}

	dbConfig := DbConfig{
		Host:     viper.GetString("DB_HOST"),
		Port:     viper.GetInt32("DB_PORT"),
		DbName:   viper.GetString("DB_NAME"),
		User:     viper.GetString("DB_USER"),
		Password: viper.GetString("DB_PASSWORD"),
	}

	if dbConfig.Host == "" || dbConfig.Port == 0 || dbConfig.DbName == "" || dbConfig.User == "" || dbConfig.Password == "" {
		errStr := fmt.Errorf("missing required database configuration values")
		if dbConfig.Host == "" {
			errStr = fmt.Errorf("%w, DB_HOST is missing", errStr)
		}
		if dbConfig.Port == 0 {
			errStr = fmt.Errorf("%w, DB_PORT is missing or zero", errStr)
		}
		if dbConfig.DbName == "" {
			errStr = fmt.Errorf("%w, DB_NAME is missing", errStr)
		}
		if dbConfig.User == "" {
			errStr = fmt.Errorf("%w, DB_USER is missing", errStr)
		}
		if dbConfig.Password == "" {
			errStr = fmt.Errorf("%w, DB_PASSWORD is missing", errStr)
		}
		return errStr
	}

	globalConfig = &Config{
		DatabaseURL: DataBaseURL,
		ServerPort:  ServerPort,
		FrontEndURL: FrontEndURL,
		DbConfig:    &dbConfig,
	}
	return nil
}

func GetConfig() *Config {
	return globalConfig
}
