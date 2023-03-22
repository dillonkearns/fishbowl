module Backend exposing (..)

import Dict exposing (Dict)
import Form
import Form.Handler
import Html
import Lamdera exposing (ClientId, SessionId)
import PhrasesForm exposing (PhrasesForm)
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


formHandler : Form.Handler.Handler String Submission
formHandler =
    Form.Handler.init Phrases PhrasesForm.wordsForm


type Submission
    = Phrases PhrasesForm.PhrasesForm


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

        FormSubmission fields ->
            case Form.Handler.run fields formHandler of
                Form.Valid (Phrases { one, two, three }) ->
                    let
                        updatedPhrases =
                            model.phrases
                                |> Dict.insert clientId [ one, two, three ]
                    in
                    ( { model | phrases = updatedPhrases }, Cmd.none )
                        |> sendRemainingGuesses

                Form.Invalid _ errors ->
                    ( model, Cmd.none )

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
