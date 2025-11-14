module Marshall.Random where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)
import Effect.Random (random)
import Data.Array ((..))
import Data.Foldable (for_, foldl)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (strokePath, fillPath, arc, setStrokeStyle,
                        setFillStyle, getContext2D, getCanvasElementById)
import Data.Number as Number
import Partial.Unsafe (unsafePartial)

-- import Random.LCG
import Random.SplitMix as Split



-- randnos = foldl (\x -> lcgNext x) [] [42]

main :: Effect Unit
main = void $ unsafePartial do

  let gen = Split.mk 42
  logShow gen
  logShow $ Split.nextNumber gen
  logShow $ Split.nextNumber gen

