CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS raw.raw_patterns (
    raw_id      BIGSERIAL PRIMARY KEY,
    line_number BIGINT,
    line_text   TEXT,
    source_file TEXT,
    batch_id    TEXT,
    loaded_at   TIMESTAMPTZ DEFAULT now()
);
CREATE TABLE IF NOT EXISTS raw.raw_accounts (
    raw_id             BIGSERIAL PRIMARY KEY,
    bank_name_raw      TEXT,
    bank_id_raw        TEXT,
    account_number_raw TEXT,
    entity_id_raw      TEXT,
    entity_name_raw    TEXT,
    source_file        TEXT,
    source_row_number  BIGINT,
    batch_id           TEXT,
    loaded_at          TIMESTAMPTZ DEFAULT now()
);
CREATE TABLE IF NOT EXISTS raw.raw_transactions (
    raw_id                 BIGSERIAL PRIMARY KEY,
    timestamp_raw          TEXT,
    from_bank_raw          TEXT,
    from_account_raw       TEXT,
    to_bank_raw            TEXT,
    to_account_raw         TEXT,
    amount_received_raw    TEXT,
    receiving_currency_raw TEXT,
    amount_paid_raw        TEXT,
    payment_currency_raw   TEXT,
    payment_format_raw     TEXT,
    is_laundering_raw      TEXT,
    source_file            TEXT,
    source_row_number      BIGINT,
    batch_id               TEXT,
    loaded_at              TIMESTAMPTZ DEFAULT now()
);
CREATE TABLE IF NOT EXISTS staging.stg_transactions (
    txn_id            BIGSERIAL PRIMARY KEY,
    txn_hash          TEXT,
    occurrence_no     INT,
    txn_timestamp     TIMESTAMP,
    from_bank_code    TEXT,
    from_bank_id      BIGINT,
    from_account      TEXT,
    to_bank_code      TEXT,
    to_bank_id        BIGINT,
    to_account        TEXT,
    amount_received   DECIMAL(20,2),
    currency_received TEXT,
    amount_paid       DECIMAL(20,2),
    currency_paid     TEXT,
    payment_format    TEXT,
    is_laundering     BOOLEAN,
    raw_id            BIGINT,
    source_file       TEXT,
    source_row_number BIGINT,
    batch_id          TEXT,
    staged_at         TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT uq_stg_transactions_hash_occ UNIQUE (txn_hash, occurrence_no)
);
CREATE TABLE IF NOT EXISTS staging.stg_accounts (
    account_number    TEXT PRIMARY KEY,
    bank_id           BIGINT,
    bank_name         TEXT,
    bank_country      TEXT,
    entity_id         TEXT,
    entity_name       TEXT,
    entity_type       TEXT,
    entity_number     INT,
    raw_id            BIGINT,
    source_file       TEXT,
    source_row_number BIGINT,
    batch_id          TEXT,
    staged_at         TIMESTAMPTZ DEFAULT now()
);
CREATE TABLE IF NOT EXISTS staging.stg_laundering_attempts (
    attempt_id          TEXT,
    pattern_type        TEXT,
    pattern_detail      TEXT,
    position_in_attempt INT,
    txn_hash            TEXT,
    raw_id              BIGINT,
    batch_id            TEXT,
    staged_at           TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT pk_stg_laundering_attempts PRIMARY KEY (attempt_id, position_in_attempt)
);
CREATE TABLE IF NOT EXISTS staging.stg_rejected_rows (
    rejected_id BIGSERIAL PRIMARY KEY,
    source_table TEXT,
    raw_id       BIGINT,
    reason       TEXT,
    raw_payload  TEXT,
    batch_id     TEXT,
    rejected_at  TIMESTAMPTZ DEFAULT now()
);