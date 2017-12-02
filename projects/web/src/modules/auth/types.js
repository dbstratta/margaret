import { concat } from 'ramda';

const moduleNamespace = 'auth';

const addModuleNamespace = concat(`${moduleNamespace}/`);

export default moduleNamespace;

export const SEND_SOCIAL_LOGIN_CODE = addModuleNamespace('SEND_SOCIAL_LOGIN_CODE');
export const RECEIVE_AUTH_TOKEN = addModuleNamespace('RECEIVE_AUTH_TOKEN');

export const SET_TOKEN = addModuleNamespace('SET_TOKEN');
export const REMOVE_TOKEN = addModuleNamespace('REMOVE_TOKEN');
