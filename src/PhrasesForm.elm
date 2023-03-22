module PhrasesForm exposing (PhrasesForm, errorsView, wordsForm)

import Form
import Form.Field as Field
import Form.FieldView as FieldView
import Form.Validation as Validation
import Html exposing (Html)
import Html.Attributes as Attr


type alias PhrasesForm =
    { one : String, two : String, three : String }


wordsForm : Form.HtmlForm String PhrasesForm input msg
wordsForm =
    (\one two three ->
        { combine =
            Validation.succeed PhrasesForm
                |> Validation.andMap one
                |> Validation.andMap two
                |> Validation.andMap three
        , view =
            \formState ->
                let
                    fieldView label field =
                        Html.div []
                            [ Html.label []
                                [ Html.text (label ++ " ")
                                , FieldView.input [] field
                                , Validation.fieldStatus field |> Validation.fieldStatusToString |> Html.text
                                , errorsView formState field
                                ]
                            ]
                in
                [ fieldView "one" one
                , fieldView "two" two
                , fieldView "three" three
                , if formState.submitting then
                    Html.button
                        [ Attr.disabled True ]
                        [ Html.text "Submitting..." ]

                  else
                    Html.button [] [ Html.text "Submit" ]
                ]
        }
    )
        |> Form.form
        |> Form.field "one"
            (Field.text
                |> Field.required "Required"
            )
        |> Form.field "two"
            (Field.text
                |> Field.required "Required"
            )
        |> Form.field "three"
            (Field.text
                |> Field.required "Required"
            )


errorsView :
    Form.Context String input
    -> Validation.Field String parsed kind
    -> Html msg
errorsView { submitAttempted, errors } field =
    if submitAttempted || Validation.statusAtLeast Validation.Blurred field then
        -- only show validations when a field has been blurred
        -- (it can be annoying to see errors while you type the initial entry for a field, but we want to see the current
        -- errors once we've left the field, even if we are changing it so we know once it's been fixed or whether a new
        -- error is introduced)
        errors
            |> Form.errorsForField field
            |> List.map (\error -> Html.li [ Attr.style "color" "red" ] [ Html.text error ])
            |> Html.ul []

    else
        Html.ul [] []
