import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('regions', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.string('name').notNullable();
    t.string('country').notNullable().defaultTo('CA');
    t.specificType('boundary', 'GEOGRAPHY(POLYGON, 4326)');
    t.timestamps(true, true);
  });

  await knex.raw(
    'CREATE INDEX idx_regions_boundary ON regions USING GIST (boundary)'
  );

  await knex.schema.createTable('users', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.string('email').notNullable().unique();
    t.string('username').notNullable().unique();
    t.string('password_hash').notNullable();
    t.decimal('trust_score', 5, 2).notNullable().defaultTo(1.0);
    t.uuid('region_id').references('id').inTable('regions').onDelete('SET NULL');
    t.timestamps(true, true);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('users');
  await knex.schema.dropTableIfExists('regions');
}
