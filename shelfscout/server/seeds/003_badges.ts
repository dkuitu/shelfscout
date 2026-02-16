import type { Knex } from 'knex';

export async function seed(knex: Knex): Promise<void> {
  await knex('user_badges').del();
  await knex('badges').del();

  await knex('badges').insert([
    {
      name: 'First Submission',
      description: 'Submit your first price report',
      criteria: 'submissions_count >= 1',
      rarity: 'common',
      icon_url: '/badges/first-submission.png',
    },
    {
      name: 'Crown Hunter',
      description: 'Earn your first crown by finding the lowest price',
      criteria: 'crowns_earned >= 1',
      rarity: 'uncommon',
      icon_url: '/badges/crown-hunter.png',
    },
    {
      name: 'Trusted Validator',
      description: 'Accurately validate 50 submissions',
      criteria: 'accurate_validations >= 50',
      rarity: 'rare',
      icon_url: '/badges/trusted-validator.png',
    },
    {
      name: 'Crown Defender',
      description: 'Defend a crown against 5 challengers in a single week',
      criteria: 'crown_defenses_weekly >= 5',
      rarity: 'epic',
      icon_url: '/badges/crown-defender.png',
    },
    {
      name: 'Price King',
      description: 'Hold 10 crowns simultaneously',
      criteria: 'active_crowns >= 10',
      rarity: 'legendary',
      icon_url: '/badges/price-king.png',
    },
  ]);
}
