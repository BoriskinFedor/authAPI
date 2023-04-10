package store

import (
	"database/sql"
	"log"
	"time"

	_ "github.com/lib/pq"
)

type Store struct {
	dburl            string
	DBReconnectCount int
	db               *sql.DB
	userRepository   *UserRepository
}

func New(dburl string, dbReconnectCount int) *Store {
	return &Store{
		dburl:            dburl,
		DBReconnectCount: dbReconnectCount,
	}
}

func (s *Store) Open() error {
	db, err := sql.Open("postgres", s.dburl)
	if err != nil {
		return err
	}
	s.db = db

	err = s.db.Ping()
	if err != nil {
		if err = s.reconnection(); err != nil {
			return err
		}
	}

	return nil
}

func (s *Store) Close() {
	s.db.Close()
}

func (s *Store) reconnection() (err error) {
	for i := s.DBReconnectCount; i > 0; i-- {

		time.Sleep(5 * time.Second)
		log.Println("Reconnecting to database...")

		err = s.db.Ping()
		if err == nil {
			break
		}
	}
	return
}

func (s *Store) User() *UserRepository {
	if s.userRepository == nil {
		s.userRepository = &UserRepository{
			store: s,
		}
	}

	return s.userRepository
}
