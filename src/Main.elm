module Main exposing (..)

import Browser
import Html exposing (Html, form, div, label, text, input, button, h2)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (type_, value)
import Jira.Api exposing (Cred, ApiCallError, Project, Issue, createBasicAuthCred, getAllProjects, getProjectData)
import Jira.Api.Extra exposing (getIssueNames)
import Jira.Pagination exposing (Page, paginationConfig, pageRequest)
import Jira.Jql exposing (forProject)
import Task

main = Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

type Msg
    = UpdateUser String
    | UpdatePassword String
    | FetchProjects
    | ProjectsResponse (Result ApiCallError (List Project))
    | FetchProjectIssues Project
    | ProjectIssuesResponse (Result ApiCallError (Page (String, String)))


type alias Model =
    { url: String
    , user: String
    , password: String
    , projects: List Project
    , issues: List (String, String)
    , error: String
    }

firstPageRequest = pageRequest (paginationConfig 20) 1

init : () -> (Model, Cmd Msg)
init () =
    ( { url = "http://localhost:3000/jira/"
      , user = ""
      , password = ""
      , projects = []
      , issues = []
      , error = ""
      }
    , Cmd.none
    )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UpdateUser user -> ({ model | user = user }, Cmd.none)
        UpdatePassword password -> ({ model | password = password }, Cmd.none)
        FetchProjects ->
            case createCred model of
                Ok cred -> ({ model | error = "" }, Task.attempt ProjectsResponse (getAllProjects cred))
                Err credErrorDetails -> ({ model | error = credErrorDetails }, Cmd.none)

        ProjectsResponse response ->
            case response of
                Ok projects ->
                    ({ model | projects = projects }, Cmd.none)

                Err apiError -> ( { model | error = Jira.Api.apiErrorToString apiError }, Cmd.none )

        FetchProjectIssues project ->
            case createCred model of
                Ok cred -> (model, Task.attempt ProjectIssuesResponse (getIssueNames cred firstPageRequest (Jira.Jql.forProject project)))
                Err credErrorDetails -> ({ model | error = credErrorDetails }, Cmd.none)

        ProjectIssuesResponse response ->
            case response of
                Ok issuesPage -> ( { model | issues = Jira.Pagination.getItems issuesPage }, Cmd.none)
                Err apiError -> ( { model | error = Jira.Api.apiErrorToString apiError }, Cmd.none )

createCred : Model -> Result String Cred
createCred model =
    createBasicAuthCred model.url (model.user, model.password)


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text model.error ]
        , viewCredsForm model
        , button [ onClick FetchProjects ] [ text "Fetch projects" ]
        , div [] <|
            List.map viewProject model.projects
        , div [] <|
            List.map viewIssue model.issues
        ]

viewCredsForm : Model -> Html Msg
viewCredsForm model = div []
    [ h2 [] [text "Enter Basic Auth credentials:"]
    , label [] [text "User:"]
    , input [ onInput UpdateUser, value model.user ] []
    , label [] [text "Password:"]
    , input [ type_ "password", onInput UpdatePassword, value model.password ] []
    ]



viewProject : Project -> Html Msg
viewProject project =
    let
        data = getProjectData project
    in
    div [ onClick (FetchProjectIssues project) ] [ text data.name ]

viewIssue : (String, String) -> Html Msg
viewIssue (issueName, issueId) =
    div [] [ text issueName ]
