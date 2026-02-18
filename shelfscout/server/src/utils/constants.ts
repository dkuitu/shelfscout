/** Number of validator confirmations needed to verify a submission */
export const VALIDATION_THRESHOLD = 3;

/** Day of week the weekly cycle resets (0 = Sunday, 1 = Monday) */
export const WEEKLY_RESET_DAY = 1;

/** Hour (UTC) the weekly cycle resets */
export const WEEKLY_RESET_HOUR = 0;

/** Radius in meters for "nearby store" GPS auto-detect */
export const STORE_PROXIMITY_RADIUS = 150;

/** Price difference ($) that triggers a "crown contested" alert */
export const CROWN_CONTEST_THRESHOLD = 0.25;

/** Maximum submissions per user per day */
export const DAILY_SUBMISSION_LIMIT = 50;

/** Trusted validator vote multiplier */
export const TRUSTED_VALIDATOR_WEIGHT = 2;

/** Number of accurate validations to earn Trusted Validator badge */
export const TRUSTED_VALIDATOR_THRESHOLD = 50;

/** Number of community approvals required to activate a user-created item */
export const ITEM_APPROVAL_THRESHOLD = 3;

/** Maximum upload file size in bytes (5MB) */
export const MAX_UPLOAD_SIZE_BYTES = 5 * 1024 * 1024;

/** Allowed MIME types for photo uploads */
export const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
