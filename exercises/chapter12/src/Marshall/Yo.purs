module Marshall.Yo where

import Prelude
import Effect (Effect)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (strokePath, rect, getContext2D, getCanvasElementById)
import Partial.Unsafe (unsafePartial)

main :: Effect Unit
main = void $ unsafePartial do
  Just canvas <- getCanvasElementById "canvas"
  ctx <- getContext2D canvas

  strokePath ctx $ do
     rect ctx {x: 350.0, y: 50.0,  width: 100.0, height: 100.0}
     rect ctx {x: 350.0, y: 175.0, width: 100.0, height: 100.0}

  strokePath ctx $ rect ctx {x: 250.0, y: 300.0, width: 100.0, height: 100.0} *>
                   rect ctx {x: 250.0, y: 425.0, width: 100.0, height: 100.0}

  strokePath ctx $ rect ctx {x: 150.0, y: 50.0,  width: 100.0, height: 100.0} >>=
             \_ -> rect ctx {x: 150.0, y: 175.0, width: 100.0, height: 100.0}
