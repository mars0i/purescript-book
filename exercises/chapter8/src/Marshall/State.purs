-- From the "Mutable State" section of chapter 8 in Purescript by Example
module Marshall.State where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)

import Control.Monad.ST.Ref (modify, new, read)
import Control.Monad.ST (ST, for, run)

simulate0 :: forall r. Number -> Number -> Int -> ST r Number
simulate0 x0 v0 time = do
  -- new creates an ST with an STRef as 2nd element, but then <- unwraps the ST.
  -- So ref is an STRef.  So it can be passed to modify.
  ref <- new { x: x0, v: v0 }
  for 0 (time * 1000) \_ ->
    modify (\o -> { v: o.v - 9.81 * 0.001,  x: o.x + o.v * 0.001}) ref
  -- it's called 'read', but what it does is creates an ST with, in this case,
  -- a record with v and x.  However, <- unwraps the ST.  Not sure why the
  -- data item and not the memory location is bound to final.
  final <- read ref
  pure final.x  -- .x?  Why isn't this a number rather than an ST?  Oh, because of pure.
  -- What's the type of the do? Well the rhses of both <-'s are STs.

simulate1 :: Number -> Number -> Int -> Number
simulate1 x0 v0 time = run (simulate0 x0 v0 time)
-- wtf is run?  How do we know what it returns?  The docstring is vague.

simulate2 x0 v0 time = do
  ref <- new { x: x0, v: v0 }
  for 0 (time * 1000) \_ ->  
           -- update function for the ref
    modify (\o -> { v: o.v - 9.81 * 0.001,  x: o.x + o.v * 0.001}) ref
  final <- read ref
  pure final.x

main :: Effect Unit
main = do
        let x = simulate1 100.0 0.0 4
        logShow x
        let y = simulate1 100.0 0.0 2
        logShow y



