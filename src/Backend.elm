module Backend exposing (..)

import Dict exposing (Dict)
import Html
import Lamdera exposing (ClientId, SessionId)
import Set
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
    ( { phrases = Dict.empty, mainClient = Nothing, guessedPhrases = [] }
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

        ClientConnected ->
            let
                remainingPhrases =
                    filterGuessed model.phrases model.guessedPhrases
            in
            ( model, Cmd.none )
                |> sendRemainingGuesses

        StartNewRound ->
            ( { model | guessedPhrases = [] }, Cmd.none )
                |> sendRemainingGuesses

        SavePhrases ( one, two, three ) ->
            let
                updatedPhrases =
                    model.phrases
                        |> Dict.insert clientId [ one, two, three ]
            in
            ( { model | phrases = updatedPhrases }, Cmd.none )
                |> sendRemainingGuesses

        CorrectGuessInRound guessedPhrase ->
            let
                updatedGuessed =
                    guessedPhrase :: model.guessedPhrases

                remainingPhrases =
                    filterGuessed model.phrases updatedGuessed
            in
            ( { model | guessedPhrases = updatedGuessed }, Cmd.none )
                |> sendRemainingGuesses


sendRemainingGuesses ( model, cmd ) =
    let
        remainingPhrases =
            filterGuessed model.phrases model.guessedPhrases
    in
    ( model, Cmd.batch [ cmd, Lamdera.broadcast (LatestRemainingPhrases remainingPhrases) ] )


filterGuessed everyonesPhrases guessedPhrases =
    let
        guessedSet =
            Set.fromList guessedPhrases
    in
    everyonesPhrases
        |> Dict.values
        |> List.concat
        |> List.filter (\phrase -> not (Set.member phrase guessedSet))
