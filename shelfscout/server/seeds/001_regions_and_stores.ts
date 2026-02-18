import type { Knex } from 'knex';

export async function seed(knex: Knex): Promise<void> {
  await knex('stores').del();
  await knex('regions').del();

  // Kelowna bounding box polygon
  const kelownaBoundary = `SRID=4326;POLYGON((
    -119.60 49.82,
    -119.35 49.82,
    -119.35 49.95,
    -119.60 49.95,
    -119.60 49.82
  ))`;

  const [region] = await knex('regions')
    .insert({
      name: 'Kelowna',
      country: 'CA',
      boundary: knex.raw(`ST_GeogFromText('${kelownaBoundary}')`),
    })
    .returning('id');

  await knex('stores').insert([
    {
      name: 'Save-On-Foods (Orchard Park)',
      address: '2271 Harvey Ave, Kelowna, BC V1Y 6H2',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-119.4520 49.8625)')"),
      region_id: region.id,
      chain: 'Save-On-Foods',
    },
    {
      name: 'Real Canadian Superstore',
      address: '2155 Harvey Ave, Kelowna, BC V1Y 6G6',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-119.4350 49.8700)')"),
      region_id: region.id,
      chain: 'Real Canadian Superstore',
    },
    {
      name: 'Costco Kelowna',
      address: '1905 Springfield Rd, Kelowna, BC V1Y 5V5',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-119.4270 49.8840)')"),
      region_id: region.id,
      chain: 'Costco',
    },
    {
      name: 'Walmart Supercentre',
      address: '1876 Cooper Rd, Kelowna, BC V1Y 9N6',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-119.4310 49.8780)')"),
      region_id: region.id,
      chain: 'Walmart',
    },
    {
      name: 'No Frills (Rutland)',
      address: '155 Rutland Rd N, Kelowna, BC V1X 3B1',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-119.4080 49.8875)')"),
      region_id: region.id,
      chain: 'No Frills',
    },
    {
      name: 'FreshCo',
      address: '1835 Gordon Dr, Kelowna, BC V1Y 3H5',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-119.4950 49.8920)')"),
      region_id: region.id,
      chain: 'FreshCo',
    },
    {
      name: 'Safeway (Harvey Ave)',
      address: '591 Bernard Ave, Kelowna, BC V1Y 6N9',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-119.4960 49.8870)')"),
      region_id: region.id,
      chain: 'Safeway',
    },
    {
      name: 'Save-On-Foods (Glenmore)',
      address: '2280 Glenmore Rd, Kelowna, BC V1V 2P7',
      location: knex.raw("ST_GeogFromText('SRID=4326;POINT(-119.4840 49.9030)')"),
      region_id: region.id,
      chain: 'Save-On-Foods',
    },
  ]);
}
