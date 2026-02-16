import db from '../config/database';
import { NotFoundError } from '../utils/errors';

export class StoresService {
  async getNearby(lat: number, lng: number, radius: number) {
    const stores = await db('stores')
      .select(
        'stores.id',
        'stores.name',
        'stores.address',
        'stores.chain',
        'stores.region_id',
        db.raw(
          `ST_Distance(location, ST_GeogFromText('SRID=4326;POINT(${lng} ${lat})')) as distance_meters`
        )
      )
      .whereRaw(
        `ST_DWithin(location, ST_GeogFromText('SRID=4326;POINT(${lng} ${lat})'), ?)`,
        [radius]
      )
      .orderBy('distance_meters', 'asc');

    return stores.map((s) => ({
      ...s,
      distance_meters: Math.round(parseFloat(s.distance_meters)),
    }));
  }

  async getById(id: string) {
    const store = await db('stores')
      .where({ id })
      .select('id', 'name', 'address', 'chain', 'region_id')
      .first();

    if (!store) {
      throw new NotFoundError('Store');
    }

    return store;
  }

  async suggest(
    name: string,
    address: string,
    lat: number,
    lng: number,
    chain?: string
  ) {
    // Auto-assign region via ST_Contains
    const region = await db('regions')
      .whereRaw(
        `ST_Contains(boundary::geometry, ST_GeomFromText('POINT(${lng} ${lat})', 4326))`
      )
      .first();

    const [store] = await db('stores')
      .insert({
        name,
        address,
        location: db.raw(`ST_GeogFromText('SRID=4326;POINT(${lng} ${lat})')`),
        region_id: region?.id ?? null,
        chain: chain ?? null,
      })
      .returning(['id', 'name', 'address', 'chain', 'region_id']);

    return store;
  }
}
