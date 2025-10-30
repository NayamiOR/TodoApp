-- schema.sql

-- ==================== Users Table ====================
CREATE TABLE IF NOT EXISTS users (
                                     id BIGSERIAL PRIMARY KEY,
                                     username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
    );

-- 索引优化
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);


-- ==================== Todos Table ====================
CREATE TABLE IF NOT EXISTS todos (
                                     id BIGSERIAL PRIMARY KEY,
                                     title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending/completed/archived
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id BIGINT REFERENCES todos(id) ON DELETE SET NULL,
    sub_tasks BIGINT[], -- 子任务 ID 数组（PG 特有，也可拆表）
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
    );

-- 索引优化
CREATE INDEX idx_todos_user_status ON todos(user_id, status);
CREATE INDEX idx_todos_parent_id ON todos(parent_id);
CREATE INDEX idx_todos_sub_tasks ON todos USING GIN(sub_tasks gin_trgm_ops); -- 支持快速查询包含某子任务


-- ==================== Pomos Table ====================
CREATE TABLE IF NOT EXISTS pomos (
                                     id BIGSERIAL PRIMARY KEY,
                                     user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- 状态 & 时间相关
    status VARCHAR(20) NOT NULL DEFAULT 'running', -- running/paused/finished/cancelled
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ, -- 完成或取消时记录
    duration_seconds INTEGER DEFAULT 0, -- 实际运行秒数（自动计算或手动更新）
    is_positive BOOLEAN NOT NULL DEFAULT false, -- true=正计时  false=默认倒计时（可选）

-- 关联内容
    topic VARCHAR(100), -- 如 "前端开发"
    todo_id BIGINT REFERENCES todos(id) ON DELETE SET NULL, -- 可选：关联某待办事项
    note TEXT, -- 备注

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
    );

-- 索引优化
CREATE INDEX idx_pomos_user_id_status ON pomos(user_id, status);
CREATE INDEX idx_pomos_started_at ON pomos(started_at DESC);
CREATE INDEX idx_pomos_todo_id ON pomos(todo_id);
