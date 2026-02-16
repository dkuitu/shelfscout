import type { Knex } from 'knex';

export async function seed(knex: Knex): Promise<void> {
  await knex('weekly_items').del();
  await knex('weekly_cycles').del();
  await knex('items').del();

  const items = await knex('items')
    .insert([
      { name: 'Milk (2L)', category: 'Dairy', unit: '2L' },
      { name: 'Bread (White)', category: 'Bakery', unit: 'loaf' },
      { name: 'Bananas', category: 'Produce', unit: 'lb' },
      { name: 'Eggs (12pk)', category: 'Dairy', unit: 'dozen' },
      { name: 'Chicken Breast', category: 'Meat', unit: 'kg' },
      { name: 'Rice (2kg)', category: 'Pantry', unit: '2kg' },
      { name: 'Butter', category: 'Dairy', unit: '454g' },
      { name: 'Canned Tomatoes', category: 'Pantry', unit: '796ml' },
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
