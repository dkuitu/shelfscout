import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../config/database';
import { env } from '../config/environment';
import { ValidationError, UnauthorizedError, NotFoundError } from '../utils/errors';
import type { User } from '../models/user.model';

export class AuthService {
  async register(email: string, username: string, password: string) {
    const existing = await db('users')
      .where({ email })
      .orWhere({ username })
      .first();

    if (existing) {
      const field = existing.email === email ? 'Email' : 'Username';
      throw new ValidationError(`${field} already taken`);
    }

    const password_hash = await bcrypt.hash(password, 12);

    const [user] = await db('users')
      .insert({ email, username, password_hash })
      .returning(['id', 'email', 'username', 'trust_score', 'created_at']);

    const token = this.generateToken(user.id);
    return { user, token };
  }

  async login(email: string, password: string) {
    const user = await db('users').where({ email }).first<User>();

    if (!user) {
      throw new UnauthorizedError('Invalid email or password');
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      throw new UnauthorizedError('Invalid email or password');
    }

    const token = this.generateToken(user.id);
    return {
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        trust_score: user.trust_score,
        created_at: user.created_at,
      },
      token,
    };
  }

  async refreshToken(userId: string) {
    const user = await db('users')
      .where({ id: userId })
      .select('id', 'email', 'username', 'trust_score')
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    const token = this.generateToken(user.id);
    return { user, token };
  }

  async getUserById(userId: string) {
    const user = await db('users')
      .where({ id: userId })
      .select('id', 'email', 'username', 'trust_score', 'region_id', 'created_at')
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    return user;
  }

  private generateToken(userId: string): string {
    const options: jwt.SignOptions = {
      expiresIn: env.JWT_EXPIRES_IN as unknown as jwt.SignOptions['expiresIn'],
    };
    return jwt.sign({ userId }, env.JWT_SECRET, options);
  }
}
