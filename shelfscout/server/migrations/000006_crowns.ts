import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('crowns', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.uuid('item_id').notNullable().references('id').inTable('items').onDelete('CASCADE');
    t.uuid('region_id').notNullable().references('id').inTable('regions').onDelete('CASCADE');
    t.uuid('cycle_id').notNullable().references('id').inTable('weekly_cycles').onDelete('CASCADE');
    t.uuid('holder_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    t.uuid('submission_id').notNullable().references('id').inTable('submissions').onDelete('CASCADE');
    t.decimal('lowest_price', 10, 2).notNullable();
    t.enu('status', ['active', 'contested', 'archived']).notNullable().defaultTo('active');
    t.timestamp('claimed_at').notNullable().defaultTo(knex.fn.now());
    t.unique(['item_id', 'region_id', 'cycle_id']);
    t.timestamps(true, true);
  });

  await knex.schema.createTable('crown_transfers', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.uuid('crown_id').notNullable().references('id').inTable('crowns').onDelete('CASCADE');
    t.uuid('from_user_id').references('id').inTable('users').onDelete('SET NULL');
    t.uuid('to_user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    t.decimal('price', 10, 2).notNullable();
    t.timestamp('transferred_at').notNullable().defaultTo(knex.fn.now());
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('crown_transfers');
  await knex.schema.dropTableIfExists('crowns');
}
