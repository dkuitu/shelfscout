import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('stores', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.string('name').notNullable();
    t.string('address').notNullable();
    t.specificType('location', 'GEOGRAPHY(POINT, 4326)').notNullable();
    t.uuid('region_id').references('id').inTable('regions').onDelete('SET NULL');
    t.string('chain');
    t.timestamps(true, true);
  });

  await knex.raw(
    'CREATE INDEX idx_stores_location ON stores USING GIST (location)'
  );

  await knex.schema.createTable('items', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.string('name').notNullable();
    t.string('category').notNullable();
    t.string('unit').notNullable().defaultTo('each');
    t.timestamps(true, true);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('items');
  await knex.schema.dropTableIfExists('stores');
}
