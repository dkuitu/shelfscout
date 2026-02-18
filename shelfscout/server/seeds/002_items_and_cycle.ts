import type { Knex } from 'knex';

export async function seed(knex: Knex): Promise<void> {
  await knex('weekly_items').del();
  await knex('weekly_cycles').del();
  await knex('items').del();

  // Look up category IDs by name
  const categories = await knex('categories').select('id', 'name');
  const catMap: Record<string, string> = {};
  for (const cat of categories) {
    catMap[cat.name] = cat.id;
  }

  const items = await knex('items')
    .insert([
      { name: 'Milk (2L)', category_id: catMap['Dairy'], unit: '2L', status: 'active' },
      { name: 'Bread (White)', category_id: catMap['Bakery'], unit: 'loaf', status: 'active' },
      { name: 'Bananas', category_id: catMap['Produce'], unit: 'lb', status: 'active' },
      { name: 'Eggs (12pk)', category_id: catMap['Dairy'], unit: 'dozen', status: 'active' },
      { name: 'Chicken Breast', category_id: catMap['Meat'], unit: 'kg', status: 'active' },
      { name: 'Rice (2kg)', category_id: catMap['Pantry'], unit: '2kg', status: 'active' },
      { name: 'Butter', category_id: catMap['Dairy'], unit: '454g', status: 'active' },
      { name: 'Canned Tomatoes', category_id: catMap['Pantry'], unit: '796ml', status: 'active' },
    ])
    .returning('id');

  // Current week cycle (YYYYWW)
  const now = new Date();
  const onejan = new Date(now.getFullYear(), 0, 1);
  const weekNum = Math.ceil(
    ((now.getTime() - onejan.getTime()) / 86400000 + onejan.getDay() + 1) / 7
  );
  const weekNumber = now.getFullYear() * 100 + weekNum;

  const startOfWeek = new Date(now);
  startOfWeek.setDate(now.getDate() - now.getDay() + 1); // Monday
  const endOfWeek = new Date(startOfWeek);
  endOfWeek.setDate(startOfWeek.getDate() + 6);

  const [cycle] = await knex('weekly_cycles')
    .insert({
      week_number: weekNumber,
      start_date: startOfWeek.toISOString().split('T')[0],
      end_date: endOfWeek.toISOString().split('T')[0],
      active: true,
    })
    .returning('id');

  // First 5 items in the rotation
  await knex('weekly_items').insert(
    items.slice(0, 5).map((item) => ({
      cycle_id: cycle.id,
      item_id: item.id,
    }))
  );
}
