module PhysMem (MemoryChunk(..),
                Memory,
                sameByte,
                writeMemory,
                readMemory,
                flatten) where

import qualified Data.ByteString.Lazy as BL
import           Data.Int             (Int64)
import           Data.List
import           Data.Word            (Word8)
import           FrameAlloc
import           Interval

data MemoryChunk = MemoryChunk
  { interval :: ByteInterval,
    storage  :: BL.ByteString }
  deriving (Show)

type Memory = [MemoryChunk]

sameByte :: Int64 -> Word8 -> BL.ByteString
sameByte = BL.replicate

writeMemory :: Int64 -> BL.ByteString -> Memory -> Memory
writeMemory _ mData mem | BL.length mData == 0 = mem
writeMemory pos mData mem = MemoryChunk (fromSize pos (fromIntegral (BL.length mData))) mData : mem

readMemory :: ByteInterval -> Memory -> BL.ByteString
readMemory bIvl [] = sameByte (size bIvl) 0
readMemory bIvl@(Interval bIvlFrom bIvlTo) (MemoryChunk mIvl@(Interval mIvlFrom _) mData : rest)
  | intersects bIvl mIvl && offset >= 0 =
      readMemory (Interval bIvlFrom mIvlFrom) rest
      <> BL.take (size available) mData
      <> readMemory (Interval availTo bIvlTo) rest
  | intersects bIvl mIvl && offset < 0 =
    BL.take (size available) (BL.drop (- offset) mData)
    <> readMemory (Interval availTo bIvlTo) rest
  | otherwise = readMemory bIvl rest
  where available@(Interval _ availTo) = intersection bIvl mIvl
        offset = mIvlFrom - bIvlFrom

flatten :: Memory -> Memory
flatten m = map readIt (join sortedIvls)
  where getIvl (MemoryChunk ivl _) = ivl
        sortedIvls = sortOn fromIvl (getIvl <$> m)
        join (x:y:xs)
          | joinable x y = join (joinAdjacent x y : xs)
          | otherwise = x : join (y:xs)
        join lst = lst
        readIt ivl = MemoryChunk ivl (readMemory ivl m)
