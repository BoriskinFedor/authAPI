package store

import (
	"authAPI/internal/model"
	"fmt"

	"github.com/lib/pq"
)

type UserRepository struct {
	store *Store
}

func (r *UserRepository) Auth(u *model.User) *model.Session {
	session := &model.Session{}
	r.store.db.QueryRow("select api.fn_user_auth(arg_login := $1, arg_password := $2)", u.Login, u.Password).Scan(&session.Token)

	return session
}

func (r *UserRepository) LogGet(session *model.Session) (*[]model.UserLog, error) {
	rows, err := r.store.db.Query("select * from api.fn_user_log_get(arg_token := $1)", session.Token)
	if err != nil {
		if err, ok := err.(*pq.Error); ok {
			return nil, fmt.Errorf("%v", err.Message)
		}
		return nil, err
	}

	logs := []model.UserLog{}

	defer rows.Close()

	for rows.Next() {
		log := model.UserLog{}

		err := rows.Scan(&log.Time, &log.Action)
		if err != nil {
			return nil, err
		}

		logs = append(logs, log)
	}

	return &logs, nil
}

func (r *UserRepository) LogClean(session *model.Session) error {
	if _, err := r.store.db.Exec("select api.fn_user_log_clean(arg_token := $1)", session.Token); err != nil {
		if err, ok := err.(*pq.Error); ok {
			return fmt.Errorf("%v", err.Message)
		}
		return err
	}
	return nil
}
