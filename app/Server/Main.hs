-- Server
module Main where

import           Control.Monad
import           Network.Simple.TCP
import           Text.Read
import           Util



main :: IO ()
main = do
    let host = "127.0.0.1"
        port = 8000
    putStrLn ("Starting server on " ++ host ++ ":" ++ show port)
    serverLoop host port

serverLoop :: HostName -> Int -> IO ()
serverLoop host port
  = serve (Host host) (show port) (\(socket, remoteAddr) -> do
        putStrLn ("Client " ++ show remoteAddr ++ " connected")
        handleClient socket remoteAddr )



handleClient :: Socket -> SockAddr -> IO ()
handleClient socket remoteAddr = do
    input <- waitForInput socket
    case input of
        ConnectionError -> putStrLn "Connection error"
        ClientQuit -> putStrLn "Client quit"
        ValidMessage message -> do
            answerMessage remoteAddr message
            handleClient socket remoteAddr

data MessageResult
    = ConnectionError
    | ClientQuit
    | ValidMessage String

waitForInput :: Socket -> IO MessageResult
waitForInput socket = do
    chunk <- recv socket 1000
    pure (case chunk of
        Just msg -> case deserialize msg of
            "quit\n" -> ClientQuit
            someText -> ValidMessage someText
        _otherwise -> ConnectionError )

answerMessage :: SockAddr -> String -> IO ()
answerMessage clientId message
    | Just number <- readMaybe message = do
        putStrLn (client ++ " sent number " ++ show number)
        when (isPrime number) (putStrLn "Hey, that's prime!")
    | otherwise =
        putStrLn (client ++ " sent message " ++ show message)
  where
    client = "Client " ++ show clientId
