package server

type Config struct {
	dbURL string
}

func NewConfig() *Config {
	return &Config{}
}
