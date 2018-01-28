/**
 * Auth related API functions.
 */

const { REACT_APP__API_URL: API_URL } = process.env;

const AUTH_ENDPOINT = `${API_URL}/auth`;

/**
 * Forms a provider callback url to call our API with.
 */
const getCallbackUrl = (provider, code) => `${AUTH_ENDPOINT}/${provider}/callback?code=${code}`;

/**
 * Requests the auth token from our API using a provider code.
 */
export async function getAuthToken(provider, code) {
  const res = await fetch(getCallbackUrl(provider, code));
  const { token } = await res.json();

  return token;
}

/**
 * Refreshes the auth token and gets a new one.
 */
export async function refreshAuthToken(oldAuthToken) {
  const url = `${AUTH_ENDPOINT}/refresh`;
  const body = JSON.stringify({ token: oldAuthToken });
  const headers = new Headers({ 'Content-Type': 'application/json' });

  const res = await fetch(url, { method: 'POST', body, headers });
  const { token } = await res.json();

  return token;
}
