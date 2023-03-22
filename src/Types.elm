module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Form
import Lamdera exposing (ClientId, SessionId)
import PhrasesForm exposing (PhrasesForm)
import Url exposing (Url)


type Mode
    = EnterPhrases
    | Play


type alias FrontendModel =
    { key : Key
    , everyonesPhrases : List String
    , mode : Mode
    , currentPhrase : String
    , remaining : List String
    , formState : Form.Model
    , submitting : Bool
    }


type alias BackendModel =
    { phrases : Dict ClientId (List String)
    , mainClient : Maybe ClientId
    , guessedPhrases : List String
    }


type InputField
    = One
    | Two
    | Three


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | FormMsg (Form.Msg FrontendMsg)
    | OnSubmit { fields : List ( String, String ), parsed : Form.Validated String PhrasesForm }
    | GetRandomPhrase
    | GotRandomPhrase String
    | GuessedCorrectly
    | StartNewRoundClicked


type ToBackend
    = NoOpToBackend
    | FormSubmission (List ( String, String ))
    | ClientConnected
    | CorrectGuessInRound String
    | StartNewRound


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | GotUpdatedPhrases (List String)
    | LatestRemainingPhrases (List String)
