import System.Environment

movingSum :: [Double] -> [Double] -> [Double]
movingSum xs [] = [sum xs]
movingSum (x:xs) (y:ys) = (sum (x:xs)) : movingSum(xs ++ [y]) ys

doublify :: ([Double] -> [Double]) -> (String -> String)
doublify f = unlines . (map show) . f . (map read) . lines

movingAvg :: Int -> [Double] -> [Double]
movingAvg windowSize xs
    | windowSize < 1 = error "Needs a positive window size"
    | windowSize > length xs = []
    | otherwise = map (/ fromIntegral windowSize) movingSums
    where
        movingSums = movingSum (take windowSize xs) (drop windowSize xs)

{-main = do-}
    {-[windowSizeString] <- getArgs-}
    {-windowSize <- read windowSizeString :: Int-}
    {-contents <- getContents-}
    {-putStr ((process 30) contents) where-}
        {-process = \x -> doublify (movingAvg x)-}

main = interact $ doublify (movingAvg 30)