module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , phrases : ( String, String, String )
    , everyonesPhrases : List String
    }


type alias BackendModel =
    { phrases : Dict ClientId (List String)
    , mainClient : Maybe ClientId
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


type ToBackend
    = NoOpToBackend
    | SavePhrases ( String, String, String )


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | GotUpdatedPhrases (List String)
