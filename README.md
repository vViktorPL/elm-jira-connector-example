# Elm Jira connector example

This is an example app using 
[Elm JIRA connector package](https://package.elm-lang.org/packages/vViktorPL/elm-jira-connector/latest/).

Beside Elm code of an app, there is also simple server implementation which is used
to proxy JIRA REST API requests so there is no CORS issue 
(unfortunately, JIRA API does not respond with `Access-Control-Allow-Origin: *` header).