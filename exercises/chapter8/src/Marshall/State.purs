-- From the "Mutable State" section of chapter 8 in Purescript by Example
module Marshall.State where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)

import Control.Monad.ST.Ref (modify, new, read)
import Control.Monad.ST (ST, for, run)

simulate :: forall r. Number -> Number -> Int -> ST r Number
simulate x0 v0 time = do
  ref <- new { x: x0, v: v0 }
  for 0 (time * 1000) \_ ->
    modify
      ( \o ->
          { v: o.v - 9.81 * 0.001
          , x: o.x + o.v * 0.001
          }
      )
      ref
  final <- read ref
  pure final.x


simulate' :: Number -> Number -> Int -> Number
simulate' x0 v0 time = run (simulate x0 v0 time)


main :: Effect Unit
main = do
        let x = simulate' 100.0 0.0 4
        logShow x
        let y = simulate' 100.0 0.0 2
        logShow y



