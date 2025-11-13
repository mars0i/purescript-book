-- Exploring differences between do and >>=
module Marshall.DoBind1 where

import Prelude
import Effect (Effect)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (strokePath, rect, setFont, fillText, 
                        getContext2D, getCanvasElementById)
import Partial.Unsafe (unsafePartial)

-- The difference between fillText and strokeText is apparent at large
-- font sizes, where the latter draws outlines of the letter, and the former
-- fills in the outline.

  -- two squares on the right: do version
doTwoSquares ctx =
        strokePath ctx $ do
           setFont ctx "20px Existence"
           fillText ctx "Done:" 350.0 40.0
           rect ctx {x: 350.0, y: 50.0,  width: 100.0, height: 100.0}
           rect ctx {x: 350.0, y: 200.0, width: 100.0, height: 100.0}

  -- two squares on the left: same thing, but translated back into bind:
bindTwoSquares ctx =
           setFont ctx "20px Existence" >>=
           \_ -> fillText ctx "Bound:" 150.0 40.0 >>=
           \_ -> strokePath ctx
                   (rect ctx {x: 150.0, y: 50.0,  width: 100.0, height: 100.0} >>=
              \_ -> rect ctx {x: 150.0, y: 200.0, width: 100.0, height: 100.0})

main :: Effect Unit
main = void $ unsafePartial do
  Just canvas <- getCanvasElementById "canvas"
  ctx <- getContext2D canvas
  bindTwoSquares ctx
  doTwoSquares ctx

-- See https://discord.com/channels/864614189094928394/1436973059423731772/1437043613790900386

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

     So the path argument is executed, but doesn't obviously
     modify ctx or get passed to stroke(). var a is returned, but
     it doesn't do anything inside strokePath. And if you look at
     what is passed to strokePath when I call it, it's a
     function--and auto generated one, with no arguments, named
     things like __do2() or __do3().  These run the 'do'ne
     function calls in sequence.  These calls are wrappers to
     Javascript Context2D functions/attributes.

     There's a difference between the generated Javascript for
     doTwoSquares and bindTwoSquares, though. (!)  [See code below.]

     In the latter, where there's a ">>= \_ ->" sequence, the
     return value of the first argument to >>=" actually is bound
     to a fresh Javascript variable, which is then never used.

     Whereas in doTwoSquares, no binding takes place in the
     generated Javascript.  The wrapper functions generated from
     the do block are just called one after another.

     So in fact the do block *is not* translated into the bind version
     before being compiled into Javascript, and the resulting Javascript
     from the do block code is simpler than its semantically equivalent
     bind version.

     I wonder whether the Javascript bytecode compilers or whatever they
     are produce equivalent code in the browser or in Node.

  // output/Marshall.MWE/index.js
  var doTwoSquares = function(ctx) {
    return strokePath(ctx)(function __do2() {
      setFont(ctx)("20px Existence")();
      fillText(ctx)("Done:")(350)(40)();
      rect(ctx)({
        x: 350,
        y: 50,
        width: 100,
        height: 100
      })();
      return rect(ctx)({
        x: 350,
        y: 200,
        width: 100,
        height: 100
      })();
    });
  };
  var bindTwoSquares = function(ctx) {
    return function __do2() {
      var v = setFont(ctx)("20px Existence")();
      var v1 = fillText(ctx)("Bound:")(150)(40)();
      return strokePath(ctx)(function __do3() {
        var v2 = rect(ctx)({
          x: 150,
          y: 50,
          width: 100,
          height: 100
        })();
        return rect(ctx)({
          x: 150,
          y: 200,
          width: 100,
          height: 100
        })();
      })();
    };
  };

-}
