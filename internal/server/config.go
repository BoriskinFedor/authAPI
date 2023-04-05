package server

type Config struct {
	DBURL string
}

func NewConfig() *Config {
	return &Config{}
}
