-- init.sql (UTF-8 encoded)

CREATE DATABASE IF NOT EXISTS todo_app;

\c todo_app;

-- Users Table
CREATE TABLE IF NOT EXISTS users
(
    id            BIGSERIAL PRIMARY KEY,
    username      VARCHAR(50) UNIQUE  NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT                NOT NULL,
    is_active     BOOLEAN             NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ                  DEFAULT NOW(),
    updated_at    TIMESTAMPTZ                  DEFAULT NOW()
);

-- Todos Table
CREATE TABLE IF NOT EXISTS todos
(
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    description TEXT,
    status      VARCHAR(20)  NOT NULL DEFAULT 'pending', -- pending/completed/archived
    user_id     BIGINT       NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    parent_id   BIGINT       REFERENCES todos (id) ON DELETE SET NULL,
    sub_tasks   BIGINT[],                                -- optional: array of subtask IDs
    created_at  TIMESTAMPTZ           DEFAULT NOW(),
    updated_at  TIMESTAMPTZ           DEFAULT NOW()
);

-- Pomos Table
CREATE TABLE IF NOT EXISTS pomos
(
    id               BIGSERIAL PRIMARY KEY,
    user_id          BIGINT      NOT NULL REFERENCES users (id) ON DELETE CASCADE,

    -- Status & Time
    status           VARCHAR(20) NOT NULL DEFAULT 'running', -- running/paused/finished/cancelled
    started_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at         TIMESTAMPTZ,
    duration_seconds INTEGER              DEFAULT 0,
    is_positive      BOOLEAN     NOT NULL DEFAULT false,     -- true = positive timer

    -- Metadata
    topic            VARCHAR(100),
    todo_id          BIGINT      REFERENCES todos (id) ON DELETE SET NULL,
    note             TEXT,

    created_at       TIMESTAMPTZ          DEFAULT NOW(),
    updated_at       TIMESTAMPTZ          DEFAULT NOW()
);
