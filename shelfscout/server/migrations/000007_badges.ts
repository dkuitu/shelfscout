import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('badges', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.string('name').notNullable().unique();
    t.string('description').notNullable();
    t.string('criteria').notNullable();
    t.enu('rarity', ['common', 'uncommon', 'rare', 'epic', 'legendary']).notNullable().defaultTo('common');
    t.string('icon_url').notNullable().defaultTo('');
    t.timestamps(true, true);
  });

  await knex.schema.createTable('user_badges', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    t.uuid('badge_id').notNullable().references('id').inTable('badges').onDelete('CASCADE');
    t.timestamp('earned_at').notNullable().defaultTo(knex.fn.now());
    t.unique(['user_id', 'badge_id']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('user_badges');
  await knex.schema.dropTableIfExists('badges');
}
