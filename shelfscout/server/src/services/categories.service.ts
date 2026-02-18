import db from '../config/database';

export class CategoriesService {
  async getAll() {
    return db('categories').orderBy('sort_order', 'asc');
  }
}
