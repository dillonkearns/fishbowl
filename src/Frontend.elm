module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Form
import Form.Field as Field
import Form.FieldView as FieldView
import Form.Validation as Validation
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Lamdera
import PhrasesForm
import Random
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , everyonesPhrases = []
      , remaining = []
      , currentPhrase = ""
      , mode =
            if url.path == "/play" then
                Types.Play

            else
                Types.EnterPhrases
      , formState = Form.init
      , submitting = False
      }
    , Lamdera.sendToBackend ClientConnected
    )


getRandomPhrase : List String -> Random.Generator String
getRandomPhrase phrases =
    Random.int 0 (List.length phrases - 1)
        |> Random.map
            (\index ->
                phrases
                    |> List.drop index
                    |> List.head
                    |> Maybe.withDefault ""
            )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Cmd.batch [ Nav.pushUrl model.key (Url.toString url) ]
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        OnSubmit submission ->
            case submission.parsed of
                Form.Valid _ ->
                    ( { model | submitting = True }
                    , Lamdera.sendToBackend (FormSubmission submission.fields)
                    )

                Form.Invalid _ _ ->
                    ( model, Cmd.none )

        FormMsg formMsg ->
            let
                ( updatedFormModel, cmd ) =
                    Form.update formMsg model.formState
            in
            ( { model | formState = updatedFormModel }, cmd )

        GotRandomPhrase phrase ->
            ( { model | currentPhrase = phrase, submitting = False }, Cmd.none )

        GetRandomPhrase ->
            ( model, Random.generate GotRandomPhrase (getRandomPhrase model.remaining) )

        StartNewRoundClicked ->
            ( model, Lamdera.sendToBackend StartNewRound )

        GuessedCorrectly ->
            let
                updatedRemaining =
                    model.remaining
                        |> List.filter (\phrase -> phrase /= model.currentPhrase)
            in
            ( { model | remaining = updatedRemaining }
            , Lamdera.sendToBackend (CorrectGuessInRound model.currentPhrase)
            )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        GotUpdatedPhrases phrases ->
            ( { model | remaining = phrases }, Cmd.none )

        LatestRemainingPhrases phrases ->
            ( { model | remaining = phrases }, Random.generate GotRandomPhrase (getRandomPhrase phrases) )


view model =
    { title = ""
    , body =
        case model.mode of
            Types.Play ->
                playView model

            Types.EnterPhrases ->
                [ PhrasesForm.wordsForm
                    |> Form.withOnSubmit OnSubmit
                    |> Form.renderHtml "form"
                        []
                        -- TODO get rid of errorData argument (completely, or just for vanilla apps)
                        (\_ -> Nothing)
                        { submitting = model.submitting
                        , state = model.formState
                        }
                        ()
                    |> Html.map FormMsg
                ]
    }


playView model =
    [ Html.h2 []
        [ Html.text model.currentPhrase
        ]
    , Html.button [ Html.Events.onClick GuessedCorrectly ] [ Html.text "✅" ]
    , Html.button [ Html.Events.onClick GetRandomPhrase ] [ Html.text "Start/Skip" ]
    , Html.button [ Html.Events.onClick StartNewRoundClicked ] [ Html.text "Round Complete" ]
    , Html.pre [] [ Html.text (String.join "\n" model.remaining) ]
    ]
