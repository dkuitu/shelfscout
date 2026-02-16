import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('submissions', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    t.uuid('store_id').notNullable().references('id').inTable('stores').onDelete('CASCADE');
    t.uuid('item_id').notNullable().references('id').inTable('items').onDelete('CASCADE');
    t.uuid('cycle_id').notNullable().references('id').inTable('weekly_cycles').onDelete('CASCADE');
    t.decimal('price', 10, 2).notNullable();
    t.string('photo_url').notNullable();
    t.enu('status', ['pending', 'verified', 'rejected']).notNullable().defaultTo('pending');
    t.decimal('gps_lat', 10, 7).notNullable();
    t.decimal('gps_lng', 10, 7).notNullable();
    t.decimal('ocr_extracted_price', 10, 2);
    t.timestamp('submitted_at').notNullable().defaultTo(knex.fn.now());
    t.timestamp('verified_at');
    t.timestamps(true, true);
  });

  await knex.schema.createTable('validations', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.uuid('submission_id').notNullable().references('id').inTable('submissions').onDelete('CASCADE');
    t.uuid('validator_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    t.enu('vote', ['confirm', 'flag']).notNullable();
    t.string('reason');
    t.unique(['submission_id', 'validator_id']);
    t.timestamps(true, true);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('validations');
  await knex.schema.dropTableIfExists('submissions');
}
