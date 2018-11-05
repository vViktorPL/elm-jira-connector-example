#!/usr/bin/env node

require('dotenv').config();

const express = require('express');
const proxy = require('express-http-proxy');
const opn = require('opn');
const path = require('path');
const process = require('process');

const app = express();

const SERVER_PORT = 3000;


app.use(express.static(path.join(__dirname, 'static')));
app.use('/jira', proxy(process.env.TARGET_JIRA_URL));

app.listen(SERVER_PORT, () => {
  const host = `http://localhost:${SERVER_PORT}`
  console.log(`Server is listening on ${host}`);
  opn(host);
});