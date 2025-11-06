module Marshall.Shapes where

import Prelude

import Effect (Effect)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (closePath, lineTo, moveTo, fillPath, strokePath,
                        setFillStyle, setStrokeStyle, setLineWidth, arc, 
                        rect, getContext2D, getCanvasElementById)
import Data.Number as Number
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

  fillPath ctx $ rect ctx $ translate (-200.0) (-200.0)
    { x: 250.0     -- M: this is a Rectangle by definition
    , y: 250.0
    , width: 100.0
    , height: 100.0
    }

  setFillStyle ctx "#FF0"

  fillPath ctx $ arc ctx $ translate 200.0 200.0
    { x: 300.0
    , y: 300.0
    , radius: 50.0
    , start: 0.0
    , end: Number.tau * 2.0 / 3.0   -- tau, τ =df 2π
    , useCounterClockwise: false    -- Matters when it's not the whole circle: which way from start?
    }

  setFillStyle ctx "#F00"

  fillPath ctx $ do
    moveTo ctx 300.0 260.0
    lineTo ctx 260.0 340.0
    lineTo ctx 340.0 340.0
    closePath ctx

  -- Marshall's additions in resp to exercise prompts:

  -- sort of ex 1
  setStrokeStyle ctx "#A000FF"
  setLineWidth ctx 5.0

  strokePath ctx $ do
    moveTo ctx 300.0 260.0
    lineTo ctx 260.0 340.0
    lineTo ctx 340.0 340.0
    closePath ctx

  -- Will be ignored:
  setFillStyle ctx "#80FF80"

  -- ex 2
  -- It appears that the last setFillStyle in the do will apply to all
  -- filled objects made in ti.  I suppose fillPath does this.  Mutatis mutandis
  -- for setStrokeStyle and strokePath.
  strokePath ctx $ do
     setStrokeStyle ctx "#00FF00" -- ignored
     rect ctx { x: 250.0
              , y: 50.0
              , width: 100.0
              , height: 100.0}
     setStrokeStyle ctx "#80d0F0"
     rect ctx $ translate 0.0 35.0 { x: 400.0
                                   , y: 50.0
                                   , width: 100.0
                                   , height: 100.0}
