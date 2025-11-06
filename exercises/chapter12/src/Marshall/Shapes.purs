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


centerrect = {x: 250.0, y: 250.0, width: 100.0, height: 100.0}

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

  -- two squares left center
  strokePath ctx $ do
     setStrokeStyle ctx "#80FFF0"
     rect ctx $ translate (-150.0) 0.0 centerrect
     rect ctx $ translate (-150.0) 110.0 centerrect

  -- translation of similar code into non-do format.
  -- two squares right center
  -- The outer parens are required, or replace by "$".
  {- strokePath ctx (setStrokeStyle ctx "#10D0A0" >>=
                  \_ -> rect ctx (translate 150.0 0.0 centerrect) >>=
                  \_ -> rect ctx (translate 150.0 110.0 centerrect))
                  -}

  -- two squares right center
  let twoboxer = (setStrokeStyle ctx "#8080F0" >>=
                  \_ -> rect ctx (translate 150.0 0.0 centerrect) >>=
                  \_ -> rect ctx (translate 150.0 110.0 centerrect))

  -- Create a dummy value of type Effect Unit:
  let maybeignored = setStrokeStyle ctx "#00FFF0"

  -- displays squares:
  strokePath ctx twoboxer
  -- doesn't display squares:
  strokePath ctx maybeignored
  -- This shows that the second arg to strokepath is not ignored.
  -- I was thinking maybe that all it did was build up the context,
  -- which was the only thing that was responsible for display.

  -- Yet in the definition of twoboxer, the return values of
  -- setStrokeStyle and the first rect, at least, are ignored.
  -- So either the second rect is returning something used by strokePath,
  -- or ... I don't know---something about ctx? 
  -- But twoboxter can only contain the return value of the second rect, right?
  -- It's not like a Lisp-2 e.g. Common Lisp with a separate function value.
