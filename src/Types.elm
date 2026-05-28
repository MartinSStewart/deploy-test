module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    }


type alias BackendModel =
    { message : String
    }


type alias Range =
    { start : Int, end : Int }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | PressedCopyButton
    | SelectionChange (Result String ( Maybe String, Maybe ( Range, String ) ))


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
