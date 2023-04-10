package store

import (
	"authAPI/internal/model"
	"fmt"

	"github.com/lib/pq"
)

type UserRepository struct {
	store *Store
}

func (r *UserRepository) Auth(u *model.User) {
	r.store.db.QueryRow("select api.fn_user_auth(arg_login := $1, arg_password := $2)", u.Login, u.Password).Scan(&u.Token)
}

func (r *UserRepository) LogGet(u *model.User) (*[]model.UserLog, error) {
	rows, err := r.store.db.Query("select * from api.fn_user_log_get(arg_token := $1)", u.Token)
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

func (r *UserRepository) LogClean(u *model.User) error {
	if _, err := r.store.db.Exec("select api.fn_user_log_clean(arg_token := $1)", u.Token); err != nil {
		if err, ok := err.(*pq.Error); ok {
			return fmt.Errorf("%v", err.Message)
		}
		return err
	}
	return nil
}
