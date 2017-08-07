module Helpers exposing (..)

import Random exposing (Generator, list, int)
import List exposing (length, map, range, foldl, all)
import Array exposing (fromList, get)


genSeq : Generator (List Int)
genSeq =
    list 20 (int 1 4)


colorSeq : List Int -> List String
colorSeq =
    map
        (\v ->
            case v of
                1 ->
                    "red"

                2 ->
                    "blue"

                3 ->
                    "green"

                4 ->
                    "yellow"

                _ ->
                    "huh?"
        )


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
