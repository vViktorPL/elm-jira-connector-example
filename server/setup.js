#!/usr/bin/env node

const prompt = require('prompt');
const fs = require('fs');
const process = require('process');

const jiraUrlPattern = /^https:\/\/((.*)(\.atlassian\.net))\/?$/;
const ENV_FILE = '.env';

if (fs.existsSync(ENV_FILE)) {
  process.exit(0);
}

prompt.start();
prompt.get({
    properties: {
      jiraUrl: {
        description: 'Enter URL to the target JIRA',
        pattern: jiraUrlPattern,
        message: 'Invalid JIRA Cloud URL',
        required: true,
      },
  }
}, (err, result) => {
  if (err) {
    console.error('No valid JIRA Cloud URL has been entered.');
    process.exit(1);
  }

  const jiraUrl = `https://${jiraUrlPattern.exec(result.jiraUrl)[1]}`;

  fs.writeFile(ENV_FILE, `TARGET_JIRA_URL=${jiraUrl}\n`, (err) => {
    if (err) {
      console.error("Couldn't save env file");
      process.exit(1);
    }
  });
});