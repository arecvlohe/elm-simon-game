module Main exposing (..)

-- CORE IMPORTS

import Html exposing (Html, program, text, div, button, input, label)
import Html.Attributes exposing (class, id, style, type_, checked, disabled)
import Html.Events exposing (onClick, onCheck)
import Random exposing (generate)
import Time exposing (Time, millisecond)
import List exposing (map, range, foldl, all, length, (::))
import Array exposing (get, fromList, toList)
import Maybe exposing (withDefault)


-- LIBRARY IMPORTS

import Delay exposing (after, sequence, withUnit)


-- LOCAL IMPORTS

import Ports exposing (playsound)
import Helpers exposing (genSeq, colorSeq, checkUserInput)
import Styles exposing (boxContainer, box, wasClicked, group)


-- MODEL


type alias Model =
    { sequence : List String
    , userInput : List String
    , count : Int
    , on : Bool
    , strict : Bool
    , isRunning : Bool
    , clicked : String
    }


initial : Model
initial =
    Model [] [] 0 False False False ""


init : ( Model, Cmd Msg )
init =
    ( initial, Cmd.none )



-- UPDATES


type Msg
    = NewSequence (List Int)
    | SeqRun
    | SeqDone
    | Start
    | Reset
    | UserClick String
    | AnimateColor Int
    | ResetColor
    | StrictMode Bool
    | NoOp


genAnimation : Int -> Cmd Msg
genAnimation count =
    let
        seq =
            foldl
                (\index acc ->
                    if index == 0 then
                        acc ++ [ ( 1000, AnimateColor index ), ( 300, ResetColor ) ]
                    else
                        acc ++ [ ( 600, AnimateColor index ), ( 300, ResetColor ) ]
                )
                []
                (range 0 <| count - 1)
                ++ [ ( 300, SeqDone ) ]
                |> (::) ( 0, SeqRun )
    in
        sequence <| withUnit millisecond seq


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewSequence list ->
            { model | sequence = colorSeq list } ! [ genAnimation model.count ]

        Start ->
            if model.on then
                model ! []
            else
                { model
                    | on = not model.on
                    , count = model.count + 1
                }
                    ! [ generate NewSequence genSeq ]

        Reset ->
            { initial | count = 1, on = True, strict = model.strict }
                ! [ generate NewSequence genSeq ]

        ResetColor ->
            { model | clicked = "" } ! []

        AnimateColor index ->
            let
                color =
                    withDefault "" <| get index <| fromList model.sequence
            in
                { model | clicked = color } ! [ playsound color ]

        UserClick color ->
            let
                nextUserInput =
                    model.userInput ++ [ color ]

                checksPass =
                    checkUserInput nextUserInput model.sequence
            in
                if model.isRunning then
                    model ! []
                else if checksPass && length nextUserInput == model.count then
                    { model
                        | userInput = []
                        , clicked = color
                        , count = model.count + 1
                    }
                        ! [ playsound color
                          , after 300 millisecond ResetColor
                          , genAnimation <| model.count + 1
                          ]
                else if checksPass then
                    { model
                        | userInput = nextUserInput
                        , clicked = color
                    }
                        ! [ playsound color
                          , after 300 millisecond ResetColor
                          ]
                else if not checksPass && model.strict then
                    { initial
                        | count = 1
                        , on = True
                        , sequence = model.sequence
                        , strict = True
                    }
                        ! [ playsound color
                          , genAnimation 1
                          ]
                else
                    { model | clicked = color, userInput = [] }
                        ! [ playsound color
                          , after 300 millisecond ResetColor
                          , genAnimation model.count
                          ]

        StrictMode bool ->
            if bool then
                { model | strict = True } ! []
            else
                { model | strict = False } ! []

        SeqRun ->
            { model | isRunning = True } ! []

        SeqDone ->
            { model | isRunning = False } ! []

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view { count, clicked, strict, isRunning } =
    div [ boxContainer ]
        [ div
            [ group ]
            [ div
                [ wasClicked clicked "red"
                , id "red"
                , class "box"
                , onClick <| UserClick "red"
                ]
                []
            , div
                [ wasClicked clicked "yellow"
                , id "yellow"
                , class "box"
                , onClick <| UserClick "yellow"
                ]
                []
            ]
        , div
            [ group ]
            [ div
                [ wasClicked clicked "green"
                , id "green"
                , class "box"
                , onClick <| UserClick "green"
                ]
                []
            , div
                [ wasClicked clicked "blue"
                , id "blue"
                , class "box"
                , onClick <| UserClick "blue"
                ]
                []
            ]
        , div []
            [ div [] [ text ("Count " ++ (toString count)) ]
            , div []
                [ label [] [ text "Strict" ]
                , input [ type_ "checkbox", checked strict, onCheck StrictMode, disabled isRunning ] []
                ]
            , button [ onClick Start, disabled isRunning ] [ text "Start" ]
            , button [ onClick Reset, disabled isRunning ] [ text "Reset" ]
            ]
        ]



-- PROGRAM


main : Program Never Model Msg
main =
    program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
