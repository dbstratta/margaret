const express = require('express');
const next = require('next');
const helmet = require('helmet');
const winston = require('winston');

const nextConfig = require('./next.config');

const { NODE_ENV, PORT } = process.env;

const app = next({ dir: './src', dev: NODE_ENV !== 'production', conf: nextConfig });

const server = express();

server.use(helmet());
