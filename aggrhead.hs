import System.Environment

other :: [(Double, String)] -> (Double, String)
other rows = ((sum (map fst rows)), "Other")

calc_head :: Int -> [(Double,String)] -> [(Double, String)]
calc_head n input = (take n input) ++ [(other (drop n input))]

parse_line :: String -> (Double, String)
parse_line line = (a, b)
    where
        a = read (takeWhile (/=' ') line) :: Double
        b = drop 1 (dropWhile (/=' ') line)

parse_file :: String -> [(Double, String)]
parse_file = (map parse_line) . lines

serialize_line :: (Double, String) -> String
serialize_line (a, b) = (show a) ++ " " ++ (show b)

serialize :: [(Double, String)] -> String
serialize = unlines . (map serialize_line)

parseArg :: IO (Int)
parseArg = do
    (arg:_) <- getArgs
    return (read arg :: Int)

main = do
    n <- parseArg
    interact (serialize . (calc_head n) . parse_file)
