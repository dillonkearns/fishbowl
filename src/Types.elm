module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Url exposing (Url)


type Mode
    = EnterPhrases
    | Play


type alias FrontendModel =
    { key : Key
    , phrases : ( String, String, String )
    , everyonesPhrases : List String
    , mode : Mode
    , currentPhrase : String
    , remaining : List String
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
    | PhraseInput InputField String
    | SubmitPhrases
    | GetRandomPhrase
    | GotRandomPhrase String
    | GuessedCorrectly
    | StartNewRoundClicked


type ToBackend
    = NoOpToBackend
    | SavePhrases ( String, String, String )
    | ClientConnected
    | CorrectGuessInRound String
    | StartNewRound


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | GotUpdatedPhrases (List String)
    | LatestRemainingPhrases (List String)
