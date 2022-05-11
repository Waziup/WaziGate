#!/bin/bash
#set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    create role chirpstack_ns with login password 'chirpstack_ns';
    create database chirpstack_ns with owner chirpstack_ns;
    create role chirpstack_as with login password 'chirpstack_as';
    create database chirpstack_as with owner chirpstack_as;
    \connect chirpstack_as;
        create extension pg_trgm;
        create extension hstore;
EOSQL
