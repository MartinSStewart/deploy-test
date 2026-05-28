port module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html
import Html.Attributes as Attr
import Html.Events
import Json.Decode
import Json.Encode
import Lamdera
import Types exposing (..)
import Url


port supermario_copy_to_clipboard_to_js : String -> Cmd msg


port selection_changed_from_js : (Json.Encode.Value -> msg) -> Sub msg


decodeHtmlIdAndSelection : Json.Decode.Decoder ( Maybe String, Maybe ( Range, String ) )
decodeHtmlIdAndSelection =
    Json.Decode.oneOf
        [ Json.Decode.map4
            (\id start end direction ->
                ( id
                , Just
                    ( { start = start, end = end }
                    , direction
                    )
                )
            )
            (Json.Decode.field "id" (Json.Decode.nullable Json.Decode.string))
            (Json.Decode.field "selectionStart" Json.Decode.int)
            (Json.Decode.field "selectionEnd" Json.Decode.int)
            (Json.Decode.field "selectionDirection" Json.Decode.string)
        , Json.Decode.map
            (\id -> ( id, Nothing ))
            (Json.Decode.field "id" (Json.Decode.nullable Json.Decode.string))
        ]


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions =
            \m ->
                selection_changed_from_js
                    (\json ->
                        Json.Decode.decodeValue decodeHtmlIdAndSelection json
                            |> Result.mapError Json.Decode.errorToString
                            |> SelectionChange
                    )
        , view = view
        }


init : Url.Url -> Nav.Key -> ( FrontendModel, Cmd FrontendMsg )
init url key =
    ( { key = key
      , message = "Welcome to Lamdera! You're looking at the auto-generated base implementation. Check out src/Frontend.elm to start coding!"
      }
    , Cmd.none
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        PressedCopyButton ->
            ( model, supermario_copy_to_clipboard_to_js "Text copied to clipboard!" )

        SelectionChange string ->
            let
                _ =
                    Debug.log "SelectionChange" string
            in
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.div [ Attr.style "text-align" "center", Attr.style "padding-top" "40px" ]
            [ Html.img [ Attr.src "https://lamdera.app/lamdera-logo-black.png", Attr.width 150 ] []
            , Html.div
                [ Attr.style "font-family" "sans-serif"
                , Attr.style "padding-top" "40px"
                ]
                [ Html.text model.message
                , Html.button [ Html.Events.onClick PressedCopyButton ] [ Html.text "Copy to clipboard" ]
                , Html.textarea [] []
                ]
            ]
        ]
    }
