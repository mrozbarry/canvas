module Canvas
    exposing
        ( Canvas
        , Error
        , Size
        , DrawOp(..)
        , DrawImageParams(..)
        , initialize
        , toHtml
        , batch
        , loadImage
        , getImageData
        , getSize
        , setSize
        , toDataUrl
        )

{-| The canvas html element is a very simple way to render 2D graphics. Check out these examples, and get an explanation of the canvas element [here](https://github.com/elm-community/canvas). Furthermore, If you havent heard of [Elm-Graphics](http://package.elm-lang.org/packages/evancz/elm-graphics/latest), I recommend checking that out first, because its probably what you need. Elm-Canvas is for when you need unusually direct and low level access to the canvas element.

# Main Types
@docs Canvas, Size, DrawOp, DrawImageParams

# Basics
@docs initialize, toHtml, batch

# Loading Images
@docs loadImage, Error

# Image Data
@docs getImageData, toDataUrl

# Sizing
@docs getSize, setSize

-}

import Html exposing (Html, Attribute)
import Task exposing (Task)
import Color exposing (Color)
import Canvas.Point exposing (Point)
import Native.Canvas


{-| A `Canvas` contains image data, and can be rendered as html with `toHtml`. It is the primary type of this package.
-}
type Canvas
    = Canvas


{-| Sometimes loading a `Canvas` from a url wont work. When it doesnt, youll get an `Error` instead.
-}
type Error
    = Error


{-| A `Size` contains a width and a height, both of which are `Int`. Many functions will take a `Size` to indicate the size of a canvas region. This type alias is identical to the one found in `elm-lang/window`.
-}
type alias Size =
    { width : Int, height : Int }


{-|`DrawOp` are how you can draw onto `Canvas`. To do so, give a `List DrawOp` to `Canvas.batch`, and apply that to a `Canvas`. Each `DrawOp` corresponds almost exactly to a method in the canvas api. [You can look up all the context methods here at the Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D). The biggest exception to the canvas api, is how we handle `ctx.drawImage()`. Since `ctx.drawImage()` can take parameters in three different ways, we made a union type `DrawImageParams` to handle each case. 
-}
type DrawOp
    = Font String
    | Arc Point Float Float Float
    | ArcTo Point Point Float
    | StrokeText String Point
    | FillText String Point
    | GlobalAlpha Float
    | GlobalCompositionOp String
    | LineCap String
    | LineDashOffset Float
    | LineWidth Float
    | MiterLimit Float
    | LineJoin String
    | LineTo Point
    | MoveTo Point
    | ShadowBlur Float
    | ShadowColor Color
    | ShadowOffsetX Float
    | ShadowOffsetY Float
    | Stroke
    | Fill
    | FillRect Point Size
    | Rect Point Size
    | Rotate Float
    | Scale Float Float
    | StrokeRect Point Size
    | StrokeStyle Color
    | TextAlign String
    | TextBaseline String
    | FillStyle Color
    | BeginPath
    | BezierCurveTo Point Point Point
    | QuadraticCurveTo Point Point
    | PutImageData (List Int) Size Point
    | ClearRect Point Size
    | Clip
    | ClosePath
    | DrawImage Canvas DrawImageParams


{-| The `DrawOp` `DrawImage` takes a `Canvas` and a `DrawImageParam`. We made three different `DrawImageParam`, because there are three different sets of parameters you can give the native javascript `ctx.drawImage()`. [See here for more info](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/drawImage.)
-}
type DrawImageParams
    = At Point
    | Scaled Point Size
    | CropScaled Point Size Point Size


{-| `initialize` takes `Size`, and returns a `Canvas` of that size. A freshly initialized `Canvas` is entirely transparent, meaning if you used `getImageData` to get its image data, it would be a `List Int` entirely of 0s. 

    squareCanvas : Int -> Canvas
    squareCanvas length =
        initialize (Size length length)
-}
initialize : Size -> Canvas
initialize =
    Native.Canvas.initialize


{-| To turn a `Canvas` into `Html msg`, run it through `toHtml`. The first parameter of `toHtml` is a list of attributes just like the html nodes in `elm-lang/html`.

    pixelatedRender : Canvas -> Html Msg
    pixelatedRender canvas =
        canvas |> toHtml [ class "pixelated" ]
-}
toHtml : List (Attribute msg) -> Canvas -> Html msg
toHtml =
    Native.Canvas.toHtml

{-| This is our primary way of drawing onto canvases. Give `batch` a list of `DrawOp` and you can apply those `DrawOp` to a canvas. 

    drawLine : Point -> Point -> Canvas -> Canvas
    drawLine p0 p1 =
        Canvas.batch
            [ BeginPath
            , LineWidth 2
            , MoveTo p0
            , LineTo p1
            , Stroke
            ]
-}
batch : List DrawOp -> Canvas -> Canvas
batch =
    Native.Canvas.batch


{-| Load up an image as a `Canvas` from a url.

    loadSteelix : Cmd Msg
    loadSteelix =
        Task.attempt ImageLoaded (loadImage "./steelix.png")

    update : Msg -> Model -> (Model, Cmd Msg)
    update message model =
        case message of
            ImageLoaded -> 
                case Result.toMaybe result of
                    Just canvas ->
                        -- ..
            
                    Nothing ->
                        -- ..
        -- ..
-}
loadImage : String -> Task Error Canvas
loadImage =
    Native.Canvas.loadImage


{-| `Canvas` have data. Its data comes in the form `List Int`, all of which are between 0 and 255. They represent the RGBA values of every pixel in the image, where the first four `Int` are the color values of the first pixel, the next four `Int` the second pixels, etc. The length of the image data is always a multiple of four, since each pixel is represented by four `Int`. 

    -- twoByTwoCanvas =

    --         |
    --   Black | Red
    --         |
    --  ---------------
    --         |
    --   Black | White
    --         |

    getImageData twoBytwoCanvas == fromList
        [ 0, 0, 0, 255,      255, 0, 0, 255
        , 0, 0, 0, 255,      255, 255, 255, 255
        ]
-}
getImageData : Point -> Size -> Canvas -> List Int
getImageData =
    Native.Canvas.getImageData


{-| Get the `Size` of a `Canvas`.
-}
getSize : Canvas -> Size
getSize =
    Native.Canvas.getSize


{-| Set the `Size` of a `Canvas`
-}
setSize : Size -> Canvas -> Canvas
setSize =
    Native.Canvas.setSize


{-| Given a `String` mimetype, a `Float` quality, and a source `Canvas`, return a base64 encoded string of that data.
-}
toDataUrl : String -> Float -> Canvas -> String
toDataUrl =
    Native.Canvas.toDataURL


