package store

import (
	"database/sql"

	_ "github.com/lib/pq"
)

type Store struct {
	dburl          string
	db             *sql.DB
	userRepository *UserRepository
}

func New(dburl string) *Store {
	return &Store{
		dburl: dburl,
	}
}

func (s *Store) Open() error {
	db, err := sql.Open("postgres", s.dburl)
	if err != nil {
		return err
	}

	if err = db.Ping(); err != nil {
		return err
	}

	s.db = db

	return nil
}

func (s *Store) Close() {
	s.db.Close()
}

func (s *Store) User() *UserRepository {
	if s.userRepository == nil {
		s.userRepository = &UserRepository{
			store: s,
		}
	}

	return s.userRepository
}
