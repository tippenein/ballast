{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Ballast.Client
import           Ballast.Types
import           Control.Monad.IO.Class
import           Data.Aeson
import qualified Data.Text                 as T
import           Network.HTTP.Client
import qualified Network.HTTP.Types.Method as NHTM

import           Test.Hspec

exampleRate :: Rate
exampleRate = Rate exampleRateOptions exampleRateOrder

exampleRateOptions :: RateOptions
exampleRateOptions = RateOptions USD GroupByAll 1 WarehouseAreaUS Nothing

exampleRateOrder :: RateOrder
exampleRateOrder = RateOrder exampleShipTo exampleItems

exampleItems :: Items
exampleItems = [ItemInfo ((SKU "Ballasttest"), 1)]

exampleShipTo :: ShipTo
exampleShipTo =
  ShipTo
    (AddressLine "6501 Railroad Avenue SE")
    (AddressLine "Room 315")
    (AddressLine "")
    (City "Snoqualmie")
    (PostalCode "85283")
    (Region "WA")
    (Country "US")
    Commercial
    NotPoBox

exampleRateResponse :: RateResponse
exampleRateResponse = RateResponse { rateResponseStatus = 200
                                   , rateResponseMessage = "Successful"
                                   , rateResponseWarnings = Nothing
                                   , rateResponseResourceLocation = Nothing
                                   , rateResponseResource = exampleResource
                                   }

exampleResource :: Resource
exampleResource = Resource { resourceGroupBy = GroupByAll
                           , resourceRates = exampleRates
                           }

exampleRates :: Rates
exampleRates = Rates { rateServiceOptions = [ServiceOptions [] Nothing Nothing] }

main :: IO ()
main = hspec $ do
  describe "get rates" $ do
    it "gets the correct rates" $ do
      req <- mkRequest NHTM.methodPost (T.pack "/rate") (Just $ encode exampleRate)
      let decodedReq = eitherDecode $ responseBody req :: Either String (Maybe RateResponse)

      liftIO $ decodedReq `shouldBe` Right (Just exampleRateResponse)
