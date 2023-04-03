package store

import "authAPI/internal/model"

type UserRepository struct {
	store *Store
}

func (r *UserRepository) Auth(u *model.User) (*model.User, error) {
	r.store.db.QueryRow("select api.fn_user_auth(arg_login := $1, arg_password := $2)", u.Login, u.Password).Scan(&u.Token)

	return u, nil
}
