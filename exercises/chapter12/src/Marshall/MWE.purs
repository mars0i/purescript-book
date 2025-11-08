module Marshall.MWE where

import Prelude
import Effect (Effect)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (strokePath, rect, getContext2D, getCanvasElementById)
import Partial.Unsafe (unsafePartial)

main :: Effect Unit
main = void $ unsafePartial do
  Just canvas <- getCanvasElementById "canvas"
  ctx <- getContext2D canvas

  -- two squares on the right: do version
  strokePath ctx $ do
     rect ctx {x: 350.0, y: 50.0,  width: 100.0, height: 100.0}
     rect ctx {x: 350.0, y: 200.0, width: 100.0, height: 100.0}

  -- two squares on the left: same thing, but translated back into bind:
  strokePath ctx (rect ctx {x: 150.0, y: 50.0,  width: 100.0, height: 100.0} >>=
                  \_ -> rect ctx {x: 150.0, y: 200.0, width: 100.0, height: 100.0})

   {-

      Clearly, rect operates by side-effecting ctx.  The (Effect
      Unit)s that it return can't be doing the work, since the
      return value of each first call to rect is ignored.

      Yet we pass the result of everything within the parentheses
      (or rather, the result of the second rect call) to
      strokePath.  Why?  

      Maybe the returned (Effect Unit) contains operations that modify the
      context that strokePath uses to guide it.  But then what is ctx doing,
      and how does the first square get drawn by strokePath?


      Maybe: The first rect call in each block affects later calls via ctx,
      *but also* rect returns a value that does something.  It's ignored when
      the first call to rect finishes, but that's OK, because the second call
      will pick up the ctx, and return a value that incorporates what was in
      the ctx.

      This seems unnecessarily complex and confusing.  Note that in the Javascript
      example of drawing a house diagram here:
      https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
      it appears that everything is done by modifying the context.  All calls have
      the form `ctx.function(args)`.

      otoh, the roof code is essentially a particular case of what PUrescript's
      `strokePath` does.

      In the generated code in Main.js, strokePath is defined like this:

            var strokePath = function(ctx) {
              return function(path) {
                return function __do2() {
                  beginPath(ctx)();
                  var a = path();
                  stroke(ctx)();
                  return a;
                };
              };
            };

     So the path argument is executed, but doesn't obviously modify ctx or get
     passed to stroke(). var a is returned, but it doesn't do anything inside
     strokePath.

     Though it is relevant that it's *executed*, so maybe it modifies ctx.
     From the Javascript, it looks like that's happening: my rect calls are
     embedded in a function that's passed to strokePath, I think.
   -}
