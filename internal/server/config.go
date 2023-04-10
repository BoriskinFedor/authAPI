package server

type Config struct {
	DBURL            string
	DBReconnectCount int
}

func NewConfig() *Config {
	return &Config{}
}
