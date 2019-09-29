module NoDefiningColorsOutsideOfUiColorTests exposing (all)

import NoDefiningColorsOutsideOfUiColor exposing (rule)
import Review.Test exposing (LintResult)
import Test exposing (Test, describe, test)


testRule : String -> LintResult
testRule string =
    Review.Test.run rule string


message : String
message =
    "Do not define colors outside of Ui.Color"


details : List String
details =
    [ "At fruits.com, we try to have all the colors in our application defined in the Ui.Color file. This helps us to have a consistent color palette across the application."
    , "You should define this color in the Ui.Color module, and import it to use it at this location. Do check whether the color does not already exist though."
    ]


tests : List Test
tests =
    [ test "should not report normal function calls" <|
        \() ->
            testRule """module A exposing (..)
a = foo n
b = bar.foo n
c = Bar.foo 1
            """
                |> Review.Test.expectNoErrors
    , test "should not report calls to local functions named `hex`" <|
        \() ->
            testRule """module A exposing (..)
hex n = n
a = hex 1"""
                |> Review.Test.expectNoErrors
    , test "should not report calls to qualified functions named `hex` not from the `Css` module" <|
        \() ->
            testRule """module A exposing (..)
import Foo
a = Foo.hex 1"""
                |> Review.Test.expectNoErrors
    , test "should not report calls to qualified functions of the `Css` module not named `hex`" <|
        \() ->
            testRule """module A exposing (..)
import Css
a = Css.fontSize (Css.rem 10)"""
                |> Review.Test.expectNoErrors
    , test "should report calls of `Css.hex`" <|
        \() ->
            testRule """module A exposing (..)
import Css
a = Css.hex "00FF00\""""
                |> Review.Test.expectErrors
                    [ Review.Test.error
                        { message = message
                        , details = details
                        , under = "Css.hex \"00FF00\""
                        }
                    ]
    ]


all : Test
all =
    describe "NoDefiningColorsOutsideOfUiColor" tests
