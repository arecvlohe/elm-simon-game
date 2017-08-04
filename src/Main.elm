module Main exposing (..)

import Html exposing (Html, program, text, div, button)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Random exposing (generate)
import Time exposing (Time, millisecond)
import List exposing (map, range, foldl, all, length)
import Array exposing (get, fromList, toList)
import Maybe exposing (withDefault)
import Delay exposing (after, sequence)
import Helpers exposing (genSeq, colorSeq)
import Styles exposing (boxContainer, box, wasClicked)


type alias Model =
    { sequence : List String
    , userInput : List String
    , count : Int
    , on : Bool
    , strict : Bool
    , clicked : String
    }


initial : Model
initial =
    Model [] [] 0 False False ""


init : ( Model, Cmd Msg )
init =
    ( initial, Cmd.none )


type Msg
    = NewSequence (List Int)
    | Start
    | Reset
    | UserClick String
    | AnimateColor Int
    | ResetColor
    | StrictMode
    | NoOp


genAnimation : Int -> Cmd Msg
genAnimation count =
    let
        seq =
            map
                (\index ->
                    ( 1000, millisecond, AnimateColor index )
                )
                (range 0 <| count - 1)
    in
        sequence seq


checkUserInput : List String -> List String -> Bool
checkUserInput userInput sequence =
    let
        userInputArr =
            fromList userInput

        sequenceArr =
            fromList sequence
    in
        foldl
            (\curr acc ->
                acc ++ [ (==) (get curr userInputArr) (get curr sequenceArr) ]
            )
            []
            (range 0 <| length userInput - 1)
            |> all (\truthy -> truthy)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewSequence list ->
            { model | sequence = colorSeq list } ! [ genAnimation model.count ]

        Start ->
            if model.on then
                model ! []
            else
                { model | on = not model.on, count = model.count + 1 }
                    ! [ generate NewSequence genSeq ]

        Reset ->
            { initial | count = 1 } ! [ generate NewSequence genSeq ]

        ResetColor ->
            { model | clicked = "" } ! []

        AnimateColor index ->
            let
                color =
                    withDefault "" <| get index <| fromList model.sequence
            in
                { model | clicked = color } ! [ after 300 millisecond ResetColor ]

        UserClick color ->
            let
                nextUserInput =
                    model.userInput ++ [ color ]

                checksPass =
                    checkUserInput nextUserInput model.sequence
            in
                if checksPass && length nextUserInput == model.count then
                    { model | userInput = nextUserInput, clicked = color, count = model.count + 1, userInput = [] }
                        ! [ after 300 millisecond ResetColor, genAnimation <| model.count + 1 ]
                else if checksPass && length nextUserInput < model.count then
                    { model | userInput = nextUserInput, clicked = color }
                        ! [ after 300 millisecond ResetColor ]
                else
                    { model | clicked = color, userInput = [] }
                        ! [ after 300 millisecond ResetColor, genAnimation model.count ]

        StrictMode ->
            { model | strict = not model.strict } ! []

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view { count, clicked } =
    div [ boxContainer ]
        [ div
            [ wasClicked clicked "red"
            , id "red"
            , class "box"
            , onClick <| UserClick "red"
            ]
            [ text " I am red" ]
        , div
            [ wasClicked clicked "yellow"
            , id "yellow"
            , class "box"
            , onClick <| UserClick "yellow"
            ]
            [ text "I am yellow" ]
        , div
            [ wasClicked clicked "green"
            , id "green"
            , class "box"
            , onClick <| UserClick "green"
            ]
            [ text "I am green" ]
        , div
            [ wasClicked clicked "blue"
            , id "blue"
            , class "box"
            , onClick <| UserClick "blue"
            ]
            [ text "I am blue" ]
        , div []
            [ div [] [ text (toString count) ]
            , button [ onClick Start ] [ text "Start" ]
            , button [ onClick Reset ] [ text "Reset" ]
            ]
        ]


main : Program Never Model Msg
main =
    program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
