module Marshall.Random where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)
import Effect.Random (random)
--import Data.Array ((..))
-- import Data.Lazy
import Data.List.Lazy.Types as LT -- defines lazy List in terms of Data.Lazy (which memoizes)
import Data.List.Lazy as LL -- extra operatons for Lazy Lists
import Data.Tuple
-- import Data.Foldable (for_, foldl)
import Data.Maybe (Maybe(..))
-- import Graphics.Canvas (strokePath, fillPath, arc, setStrokeStyle,
--                        setFillStyle, getContext2D, getCanvasElementById)
import Data.Number as Number
import Partial.Unsafe (unsafePartial)

import Random.LCG as LCG

-- See notes in my ~/purescript/random.tips
import Random.SplitMix as Split


-- blows stack when run
splitlist rng =
        let (Tuple x g) = Split.nextNumber rng in
            LT.cons x (splitlist g)

splitgen = Split.mk 42
-- blows stack:
-- splitnums = splitlist splitgen

nextstate rngtuple = 
        let (Tuple _ g) = rngtuple in
            Split.nextNumber g

splitTups = LL.iterate nextstate (Tuple (-24.0) splitgen)


-- blows stack when run
lcglist x = 
        let x' = LCG.lcgNext x in
            LT.cons x' (lcglist x')

lcggen = LCG.mkSeed 42
-- blows stack:
-- lcgnums = lcglist lcggen



blah :: Maybe (Tuple Number Split.SMGen) -> Number
blah Nothing = (-1.0)
blah (Just (Tuple x _)) = x



-- randnos = foldl (\x -> lcgNext x) [] [42]

main :: Effect Unit
main = void $ unsafePartial do

  log "Yow.\n"
  logShow $ LL.head splitTups
  log "\n"
  logShow $ LL.take 5 splitTups
  log "\n"

  logShow $ blah $ LL.index splitTups 2



  -- logShow $ LL.map fst (LL.take 5 splitTups)


  -- logShow splitgen
  -- logShow $ Split.nextNumber splitgen

  -- logShow $ LL.take 10 splitnums
  -- logShow $ LL.take 4 lcgnums

