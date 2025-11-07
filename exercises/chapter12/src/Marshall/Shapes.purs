module Marshall.Shapes where

import Prelude

import Effect (Effect)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (closePath, lineTo, moveTo, fillPath, strokePath,
                        setFillStyle, setStrokeStyle, setLineWidth, arc, 
                        rect, getContext2D, getCanvasElementById)
import Graphics.Canvas (translate) as GC
import Data.Number as Number
import Partial.Unsafe (unsafePartial)

trans :: forall r . Number -> Number -> { x :: Number, y :: Number | r }
                                         -> { x :: Number, y :: Number | r }
trans dx dy shape = shape
  { x = shape.x + dx    -- M: Using row polymorphism here
  , y = shape.y + dy
  }


main :: Effect Unit
main = void $ unsafePartial do
  Just canvas <- getCanvasElementById "canvas"
  ctx <- getContext2D canvas

  setFillStyle ctx "#00F"

  fillPath ctx $ rect ctx $ trans (-200.0) (-200.0)
    { x: 250.0     -- M: this is a Rectangle by definition
    , y: 250.0
    , width: 100.0
    , height: 100.0
    }

  setFillStyle ctx "#FF0"

  fillPath ctx $ arc ctx $ trans 200.0 200.0
    { x: 300.0
    , y: 300.0
    , radius: 50.0
    , start: 0.0
    , end: Number.tau * 2.0 / 3.0   -- tau, τ =df 2π
    , useCounterClockwise: false    -- Matters when it's not the whole circle: which way from start?
    }

  setFillStyle ctx "#F00"

  -- filled triangle
  fillPath ctx $ do
    moveTo ctx 300.0 160.0
    lineTo ctx 260.0 240.0
    lineTo ctx 340.0 240.0
    closePath ctx

  -- sort of ex 1

  -- triangle border
  setStrokeStyle ctx "#A000FF"
  setLineWidth ctx 5.0
  strokePath ctx $ do
    moveTo ctx 300.0 160.0
    lineTo ctx 260.0 240.0
    lineTo ctx 340.0 240.0
    closePath ctx

  -- Marshall's additions in resp to exercise prompts:

  -- Will be ignored:
  setFillStyle ctx "#80FF80"

  -- ex 2
  -- upper light blue squares
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
     rect ctx $ trans 0.0 35.0 { x: 400.0
                                   , y: 50.0
                                   , width: 100.0
                                   , height: 100.0}

  let centerrect = {x: 250.0, y: 250.0, width: 100.0, height: 100.0}

  -- two squares left center, greenish blue
  strokePath ctx $ do
     setStrokeStyle ctx "#80FFF0"
     rect ctx $ trans (-150.0) 0.0 centerrect
     rect ctx $ trans (-150.0) 110.0 centerrect

  -- Two squares, one above the other, to be drawn later.
  -- (The outer parens are required, or replace by "$".)
  let twoboxer = (setStrokeStyle ctx "#C080F0" >>=
                  \_ -> rect ctx (trans 150.0 0.0 centerrect) >>=
                  \_ -> rect ctx (trans 150.0 110.0 centerrect))

  -- displays squares:
  strokePath ctx twoboxer
  -- This shows that the second arg to strokepath is not ignored.
  -- I was thinking maybe that all it did was build up the context,
  -- which was the only thing that was responsible for display.


  -- No error, but nothing's showing up.
  -- strokePath ctx (GC.translate ctx {translateX: (-100.0), translateY: 0.0})

  -- let tctx = GC.translate ctx {translateX: (-100.0), translateY: 0.0}

  -- strokePath tctx twoboxer


  -- Yet in the definition of twoboxer, the return values of
  -- setStrokeStyle and the first rect, at least, are ignored.
  -- So either the second rect is returning something used by strokePath,
  -- or ... I don't know---something about ctx? 
  -- But twoboxter can only contain the return value of the second rect, right?
  -- It's not like a Lisp-2 e.g. Common Lisp with a separate function value.

{- What's confusing is that in the def of twoboxer, nothing that
is *returned* by the first two calls affects the third call. 
Presumably, nothing it *returns* can have an effect, either. 
Presumably, the effects are passed from one call to the next via
changes to the context--i.e. to what the variable ctx refers to. 
But then what is contained in twoboxer? What was returned as its
value is something that has no effect, it would seem.  All of the
effects are in the context.  Yet with maybeignored, *that*
twoboxer context has no effect, as if ctx doesn't do anything,
and all of the configuration is in the value of twoboxer. -}
