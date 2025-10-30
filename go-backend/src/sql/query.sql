-- query.sql

-- ==================== USERS ====================

-- name: CreateUser :one
INSERT INTO users (username, email, password_hash)
VALUES ($1, $2, $3)
    RETURNING *;

-- name: GetUserByID :one
SELECT * FROM users WHERE id = $1 LIMIT 1;

-- name: GetUserByUsernameOrEmail :one
SELECT * FROM users WHERE username = $1 OR email = $2 LIMIT 1;

-- name: ListUsers :many
SELECT * FROM users ORDER BY created_at DESC;

-- name: UpdateUser :exec
UPDATE users SET
                 username = $2,
                 email = $3,
                 password_hash = $4,
                 is_active = $5,
                 updated_at = NOW()
WHERE id = $1;

-- name: DeleteUser :exec
DELETE FROM users WHERE id = $1;


-- ==================== TODOS ====================

-- name: CreateTodo :one
INSERT INTO todos (title, description, status, user_id, parent_id, sub_tasks)
VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *;

-- name: GetTodoByIDAndUserID :one
SELECT * FROM todos WHERE id = $1 AND user_id = $2 LIMIT 1;

-- name: ListTodosByUserID :many
SELECT * FROM todos WHERE user_id = $1 ORDER BY created_at DESC;

-- name: ListPendingTodosByUserID :many
SELECT * FROM todos WHERE user_id = $1 AND status = 'pending' ORDER BY created_at DESC;

-- name: UpdateTodoStatus :exec
UPDATE todos SET
                 status = $2,
                 updated_at = NOW()
WHERE id = $1 AND user_id = $2;

-- name: UpdateTodoTitleAndDesc :exec
UPDATE todos SET
                 title = $2,
                 description = $3,
                 updated_at = NOW()
WHERE id = $1 AND user_id = $2;

-- name: AddSubTaskToTodo :exec
UPDATE todos SET
                 sub_tasks = array_append(sub_tasks, $2),
                 updated_at = NOW()
WHERE id = $1 AND user_id = $3;

-- name: RemoveSubTaskFromTodo :exec
UPDATE todos SET
                 sub_tasks = array_remove(sub_tasks, $2),
                 updated_at = NOW()
WHERE id = $1 AND user_id = $3;

-- name: DeleteTodo :exec
DELETE FROM todos WHERE id = $1 AND user_id = $2;


-- ==================== POMOS ====================

-- name: CreatePomo :one
INSERT INTO pomos (user_id, topic, todo_id, is_positive, status, started_at, duration_seconds)
VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *;

-- name: StartPomo :one
INSERT INTO pomos (user_id, topic, todo_id, is_positive, status, started_at, duration_seconds)
VALUES ($1, $2, $3, $4, 'running', NOW(), 0)
    RETURNING *;

-- name: PausePomo :exec
UPDATE pomos SET
                 status = 'paused',
                 duration_seconds = $2,
                 updated_at = NOW()
WHERE id = $1 AND user_id = $2 AND status = 'running';

-- name: ResumePomo :exec
UPDATE pomos SET
                 status = 'running',
                 updated_at = NOW()
WHERE id = $1 AND user_id = $2 AND status = 'paused';

-- name: CompletePomo :exec
UPDATE pomos SET
                 status = 'finished',
                 ended_at = NOW(),
                 duration_seconds = EXTRACT(EPOCH FROM (NOW() - started_at))::INTEGER,
    updated_at = NOW()
WHERE id = $1 AND user_id = $2 AND status = 'running';

-- name: CancelPomo :exec
UPDATE pomos SET
                 status = 'cancelled',
                 stopped_at = NOW(),
                 duration_seconds = EXTRACT(EPOCH FROM (NOW() - started_at))::INTEGER,
    updated_at = NOW()
WHERE id = $1 AND user_id = $2 AND status IN ('running', 'paused');

-- name: GetActivePomoForUser :one
SELECT * FROM pomos
WHERE user_id = $1 AND status IN ('running', 'paused')
ORDER BY started_at DESC LIMIT 1;

-- name: ListPomosByUserID :many
SELECT * FROM pomos
WHERE user_id = $1 AND status != 'cancelled'
ORDER BY started_at DESC;

-- name: ListFinishedPomosByUserID :many
SELECT * FROM pomos
WHERE user_id = $1 AND status = 'finished'
ORDER BY ended_at DESC;

-- name: GetPomoByIDAndUserID :one
SELECT * FROM pomos WHERE id = $1 AND user_id = $2 LIMIT 1;

-- name: DeletePomo :exec
DELETE FROM pomos WHERE id = $1 AND user_id = $2;
