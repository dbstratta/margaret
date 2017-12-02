import { createAction } from 'redux-actions';

import * as types from './types';

export const sendSocialLoginCode = createAction(types.SEND_SOCIAL_LOGIN_CODE, (provider, code) => ({
  provider,
  code,
}));
export const receiveAuthToken = createAction(types.RECEIVE_AUTH_TOKEN);

export const setToken = createAction(types.SET_TOKEN);
export const removeToken = createAction(types.REMOVE_TOKEN);
