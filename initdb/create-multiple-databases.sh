#!/usr/bin/env bash
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE EXTENSION IF NOT EXISTS vector;

  CREATE USER penpot WITH PASSWORD '${PENPOT_DB_PASSWORD}';
  CREATE DATABASE penpot OWNER penpot;

  CREATE USER appflowy WITH PASSWORD '${APPFLOWY_DB_PASSWORD}';
  CREATE DATABASE appflowy OWNER appflowy;
EOSQL
