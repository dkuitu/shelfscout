import type { Knex } from 'knex';
import dotenv from 'dotenv';

dotenv.config();

const config: Record<string, Knex.Config> = {
  development: {
    client: 'pg',
    connection: process.env.DATABASE_URL || {
      host: 'localhost',
      port: 5433,
      user: 'shelfscout',
      password: 'shelfscout_dev',
      database: 'shelfscout',
    },
    migrations: {
      directory: './migrations',
      extension: 'ts',
    },
    seeds: {
      directory: './seeds',
    },
    pool: {
      min: 2,
      max: 10,
    },
  },

  production: {
    client: 'pg',
    connection: process.env.DATABASE_URL,
    migrations: {
      directory: './migrations',
    },
    seeds: {
      directory: './seeds',
    },
    pool: {
      min: 2,
      max: 20,
    },
  },
};

export default config;
