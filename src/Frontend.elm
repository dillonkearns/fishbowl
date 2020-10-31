module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html
import Html.Attributes as Attr
import Html.Events
import Lamdera
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
      , phrases = ( "", "", "" )
      , everyonesPhrases = []
      , mode =
            if url.path == "play" then
                Types.Play

            else
                Types.EnterPhrases
      }
    , Cmd.none
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

        SubmitPhrases ->
            ( model, Lamdera.sendToBackend (SavePhrases model.phrases) )

        PhraseInput inputNumber newValue ->
            let
                ( one, two, three ) =
                    model.phrases

                updatedInput =
                    case inputNumber of
                        Types.One ->
                            ( newValue, two, three )

                        Types.Two ->
                            ( one, newValue, three )

                        Types.Three ->
                            ( one, two, newValue )
            in
            ( { model | phrases = updatedInput }, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        GotUpdatedPhrases phrases ->
            ( { model | everyonesPhrases = phrases }, Cmd.none )


view model =
    let
        ( one, two, three ) =
            model.phrases
    in
    { title = ""
    , body =
        [ Html.div [ Attr.style "text-align" "center", Attr.style "padding-top" "40px" ]
            [ Html.input [ Attr.value one, Html.Events.onInput (PhraseInput Types.One) ] []
            , Html.input [ Attr.value two, Html.Events.onInput (PhraseInput Types.Two) ] []
            , Html.input [ Attr.value three, Html.Events.onInput (PhraseInput Types.Three) ] []
            ]
        , Html.button [ Html.Events.onClick SubmitPhrases ] [ Html.text "Submit" ]
        , Html.pre [] [ Html.text (String.join "\n" model.everyonesPhrases) ]
        ]
    }
