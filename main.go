package main

import (
	"database/sql"
	"fmt"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

type user struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
}

func main() {
	r := gin.Default()

	r.GET("/userget", GetDB)
	r.GET("/usergettest", GetDBTest)
	r.GET("/usergettest2", GetDBTest2)
	r.GET("/userpost", PostDB)
	r.Run(":8000")
}

func PostDB(ctx *gin.Context) {
	connStr := "host=db port=5432 user=postgres password=123456 dbname=postgres sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	_, err = db.Exec("insert into t_user(name) values (now()::timestamp::varchar)")
	if err != nil {
		panic(err)
	}

	ctx.IndentedJSON(200, gin.H{"status": "ok"})
}

func GetDB(ctx *gin.Context) {
	connStr := "host=db port=5432 user=postgres password=123456 dbname=postgres sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		panic(err)
	}

	rows, err := db.Query("select * from t_user order by 1")
	if err != nil {
		panic(err)
	}
	defer rows.Close()
	users := []user{}

	for rows.Next() {
		u := user{}
		err := rows.Scan(&u.Id, &u.Name)
		if err != nil {
			fmt.Println(err)
			continue
		}
		users = append(users, u)
	}

	ctx.IndentedJSON(200, users)
}

func GetDBTest(ctx *gin.Context) {
	users := []user{
		{Id: 1, Name: "one"},
		{Id: 2, Name: "two"},
		{Id: 3, Name: "three"},
	}

	ctx.IndentedJSON(200, users)
}

func GetDBTest2(ctx *gin.Context) {
	ctx.IndentedJSON(200, gin.H{
		"test": "huest",
	})
}
