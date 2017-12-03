const { REACT_APP__API_URL: API_URL } = process.env;

const AUTH_ENDPOINT = `${API_URL}/auth`;

/**
 * Forms a provider callback url to call our API with.
 */
const getCallbackUrl = (provider, code) => `${AUTH_ENDPOINT}/${provider}/callback?code=${code}`;

/**
 * Requests the auth token from our API using a provider code.
 */
// eslint-disable-next-line import/prefer-default-export
export async function sendSocialLoginCode(provider, code) {
  const res = await fetch(getCallbackUrl(provider, code));
  const data = await res.json();

  if (!res.ok) {
    throw new Error(data);
  }

  return data.token;
}
