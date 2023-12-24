package cfg

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	ProjectName string
}

func MakeEnvConfig() Config {
	_ = godotenv.Load()

	return Config{
		ProjectName: getenv("PROJECT_NAME"),
	}
}

func getenv(key string) string {
	val := os.Getenv(key)
	if val == "" {
		panic(fmt.Sprintf("environment variable %s is not set", key))
	}
	return val
}
