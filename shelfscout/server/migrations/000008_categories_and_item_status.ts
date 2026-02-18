import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  // Create categories table
  await knex.schema.createTable('categories', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    t.string('name').notNullable().unique();
    t.string('icon').notNullable();
    t.string('color').notNullable();
    t.integer('sort_order').notNullable().defaultTo(0);
    t.boolean('is_default').notNullable().defaultTo(false);
    t.timestamps(true, true);
  });

  // Seed default categories
  const categories = await knex('categories')
    .insert([
      { name: 'Dairy', icon: 'water_drop', color: '#64B5F6', sort_order: 1, is_default: true },
      { name: 'Bakery', icon: 'bakery_dining', color: '#FFB74D', sort_order: 2, is_default: true },
      { name: 'Produce', icon: 'eco', color: '#81C784', sort_order: 3, is_default: true },
      { name: 'Meat', icon: 'restaurant', color: '#E57373', sort_order: 4, is_default: true },
      { name: 'Pantry', icon: 'shopping_basket', color: '#B39DDB', sort_order: 5, is_default: true },
    ])
    .returning(['id', 'name']);

  const categoryMap: Record<string, string> = {};
  for (const cat of categories) {
    categoryMap[cat.name] = cat.id;
  }

  // Add new columns to items
  await knex.schema.alterTable('items', (t) => {
    t.uuid('category_id').references('id').inTable('categories').onDelete('SET NULL');
    t.enu('status', ['pending', 'active', 'rejected']).notNullable().defaultTo('active');
    t.uuid('created_by').references('id').inTable('users').onDelete('SET NULL');
  });

  // Backfill category_id from existing category string
  for (const [name, id] of Object.entries(categoryMap)) {
    await knex('items').where({ category: name }).update({ category_id: id });
  }

  // Drop old category string column
  await knex.schema.alterTable('items', (t) => {
    t.dropColumn('category');
  });
}

export async function down(knex: Knex): Promise<void> {
  // Re-add category string column
  await knex.schema.alterTable('items', (t) => {
    t.string('category').notNullable().defaultTo('');
  });

  // Backfill from category_id
  const categories = await knex('categories').select('id', 'name');
  for (const cat of categories) {
    await knex('items').where({ category_id: cat.id }).update({ category: cat.name });
  }

  // Drop new columns
  await knex.schema.alterTable('items', (t) => {
    t.dropColumn('created_by');
    t.dropColumn('status');
    t.dropColumn('category_id');
  });

  await knex.schema.dropTableIfExists('categories');
}
