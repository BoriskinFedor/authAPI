package server

import (
	"os"

	"gopkg.in/yaml.v2"
)

type Config struct {
	DBURL            string `yaml:"db_url"`
	DBReconnectCount int    `yaml:"db_wait_attempts"`
}

func NewConfig(configPath string) (*Config, error) {
	file, err := os.ReadFile(configPath)
	if err != nil {
		return nil, err
	}

	config := &Config{}

	if err := yaml.Unmarshal(file, config); err != nil {
		return nil, err
	}

	return config, nil
}
