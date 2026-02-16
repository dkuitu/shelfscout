import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('weekly_cycles', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.integer('week_number').notNullable().unique(); // YYYYWW format
    t.date('start_date').notNullable();
    t.date('end_date').notNullable();
    t.boolean('active').notNullable().defaultTo(false);
    t.timestamps(true, true);
  });

  await knex.schema.createTable('weekly_items', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.uuid('cycle_id').notNullable().references('id').inTable('weekly_cycles').onDelete('CASCADE');
    t.uuid('item_id').notNullable().references('id').inTable('items').onDelete('CASCADE');
    t.unique(['cycle_id', 'item_id']);
    t.timestamps(true, true);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('weekly_items');
  await knex.schema.dropTableIfExists('weekly_cycles');
}
