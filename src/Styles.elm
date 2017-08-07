module Styles exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Color.Manipulate exposing (lighten)
import Color.Convert exposing (colorToHex)
import Color exposing (..)


boxContainer : Attribute a
boxContainer =
    style
        [ ( "display", "flex" )
        , ( "flex-direction", "column" )
        , ( "justify-content", "center" )
        , ( "align-items", "center" )
        ]


box : String -> Attribute a
box color =
    style
        [ ( "background", color )
        , ( "width", "200px" )
        , ( "height", "200px" )
        ]


group : Attribute a
group =
    style
        [ ( "display", "flex" )
        ]


wasClicked : String -> String -> Attribute a
wasClicked clicked color =
    let
        c =
            case color of
                "red" ->
                    Color.red

                "green" ->
                    Color.green

                "yellow" ->
                    Color.yellow

                "blue" ->
                    Color.blue

                _ ->
                    Color.black
    in
        if clicked == color then
            box (colorToHex <| lighten 0.2 c)
        else
            box color
