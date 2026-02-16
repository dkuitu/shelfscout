import type { Knex } from 'knex';

export async function seed(knex: Knex): Promise<void> {
  await knex('stores').del();
  await knex('regions').del();

  // Vancouver Metro bounding box polygon
  const vancouverBoundary = `SRID=4326;POLYGON((
    -123.28 49.18,
    -122.98 49.18,
    -122.98 49.36,
    -123.28 49.36,
    -123.28 49.18
  ))`;

  const [region] = await knex('regions')
    .insert({
      name: 'Vancouver Metro',
      country: 'CA',
      boundary: knex.raw(`ST_GeogFromText('${vancouverBoundary}')`),
    })
    .returning('id');

  await knex('stores').insert([
    {
      name: 'Save-On-Foods',
      address: '1641 Davie St, Vancouver, BC V6G 1W2',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-123.1375 49.2780)')"),
      region_id: region.id,
      chain: 'Save-On-Foods',
    },
    {
      name: 'No Frills',
      address: '3575 Commercial St, Vancouver, BC V5N 4E8',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-123.0695 49.2488)')"),
      region_id: region.id,
      chain: 'No Frills',
    },
    {
      name: 'Whole Foods Market',
      address: '510 W 8th Ave, Vancouver, BC V5Z 1C5',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-123.1140 49.2640)')"),
      region_id: region.id,
      chain: 'Whole Foods',
    },
  ]);
}
