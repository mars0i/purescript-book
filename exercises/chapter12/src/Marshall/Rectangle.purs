module Marshall.Rectangle where

import Prelude

import Effect (Effect)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (rect, fillPath, strokePath,
                        setFillStyle, setStrokeStyle, setLineWidth,
                        getContext2D, getCanvasElementById,
                        Rectangle)
import Partial.Unsafe (unsafePartial)

translate :: forall r . Number -> Number -> { x :: Number, y :: Number | r }
                                         -> { x :: Number, y :: Number | r }
translate dx dy shape = shape
  { x = shape.x + dx    -- M: Using row polymorphism here
  , y = shape.y + dy
  }


main :: Effect Unit
main = void $ unsafePartial do
  Just canvas <- getCanvasElementById "canvas"
  ctx <- getContext2D canvas

  setFillStyle ctx "#00F"
  setStrokeStyle ctx "#F0F"
  setLineWidth ctx 10.0
  
  let box = {x: 250.0,
             y: 250.0,
             width: 100.0,
             height: 100.0}

{-
  fillPath ctx $ rect ctx $ do
     translate 100.0 0.0 box
     translate (-100.0) 0.0 box
     -}


  strokePath ctx $ rect ctx
    { x: 250.0
    , y: 250.0
    , width: 100.0
    , height: 100.0
    }
