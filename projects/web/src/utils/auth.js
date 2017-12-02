const tokenKey = 'auth_token';

export default tokenKey;

/**
 * Gets the auth token.
 */
export const getToken = () => localStorage.getItem(tokenKey);

/**
 * Sets the auth token.
 */
export const setToken = token => localStorage.setItem(tokenKey, token);

/**
 * Removes the auth token.
 */
export const removeToken = () => localStorage.removeItem(tokenKey);
