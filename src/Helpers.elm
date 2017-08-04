module Helpers exposing (..)

import Random exposing (Generator, list, int)
import List exposing (map)


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
