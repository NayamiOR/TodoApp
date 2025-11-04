package db

import (
	"context"
	"fmt"
	"go-backend/src/config"

	"github.com/jackc/pgx/v5"
	_ "github.com/lib/pq"
)

type Manager struct {
	conn    *pgx.Conn
	queries *Queries
}

var manager *Manager

func ConnectDb() error {
	var err error

	if manager == nil {
		manager = &Manager{}
	}

	dbCfg, err := config.GetConfig().GetDbConfig()
	if err != nil {
		return fmt.Errorf("failed to get db config: %w", err)
	}
	// Reference to connString: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING
	host, port, dbName, user, password := dbCfg.Host, dbCfg.Port, dbCfg.DbName, dbCfg.User, dbCfg.Password
	connStr := fmt.Sprintf("host=%s port=%d dbname=%s user=%s password=%s sslmode=disable ", host, port, dbName, user, password)
	ctx := context.Background()
	manager.conn, err = pgx.Connect(ctx, connStr)
	if err != nil {
		//return fmt.Errorf("unable to connect to database: %w", err)
		return err
	}

	manager.queries = New(manager.conn)
	return nil
}
func DisconnectDb() error {
	if manager.conn == nil {
		return nil
	}
	return manager.conn.Close(context.Background())
}

func init() {
	err := ConnectDb()
	if err != nil {
		panic(fmt.Errorf("failed to connect to db: %w", err))
	}
	println("Db manager connected.")
}

// GetQueries Main access point to get the DB operations, all DB operations are methods of the returned Queries struct.
func GetQueries() *Queries {
	if manager == nil {
		panic("DB DbManager is not initialized (which should never happen).")
	}
	if manager.queries == nil {
		panic("DB Queries is not initialized (which should never happen).")
	}
	return manager.queries
}
