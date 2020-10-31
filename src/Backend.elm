module Backend exposing (..)

import Dict exposing (Dict)
import Html
import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { phrases = Dict.empty, mainClient = Nothing }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        SavePhrases ( one, two, three ) ->
            let
                updatedPhrases =
                    model.phrases
                        |> Dict.insert clientId [ one, two, three ]
            in
            ( { model | phrases = updatedPhrases }, Lamdera.broadcast (GotUpdatedPhrases (Dict.values updatedPhrases |> List.concat)) )
