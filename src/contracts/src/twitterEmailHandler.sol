// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./base64.sol";
import "./emailVerifier.sol";

contract VerifiedTwitterEmail is ERC721Enumerable, Verifier {
  using Counters for Counters.Counter;

  Counters.Counter private tokenCounter;

  mapping(string => uint256[17]) public verifiedMailserverKeys;
  mapping(uint256 => string) public tokenToName;
  string constant domain = "twitter.com";

  constructor() ERC721("VerifiedEmail", "VerifiedEmail") {
    // Do dig TXT outgoing._domainkey.twitter.com to verify these.
    // This is the base 2^121 representation of that key.
    verifiedMailserverKeys["twitter.com"][0] = 1362844382337595676288966927845048755;
    verifiedMailserverKeys["twitter.com"][1] = 2051232190029042874602123094057641579;
    verifiedMailserverKeys["twitter.com"][2] = 82180903948917831722803326838373315;
    verifiedMailserverKeys["twitter.com"][3] = 2138065713701593539261187725956930213;
    verifiedMailserverKeys["twitter.com"][4] = 2610113944250628639012720369418287474;
    verifiedMailserverKeys["twitter.com"][5] = 947386626577810308124082119170513710;
    verifiedMailserverKeys["twitter.com"][6] = 536038387946359789768371937196825655;
    verifiedMailserverKeys["twitter.com"][7] = 2153576889316081585234167235144487709;
    verifiedMailserverKeys["twitter.com"][8] = 1287226415982257719800023032828811922;
    verifiedMailserverKeys["twitter.com"][9] = 1018106194828336360857712078662978863;
    verifiedMailserverKeys["twitter.com"][10] = 2182121972991273871088583422676257732;
    verifiedMailserverKeys["twitter.com"][11] = 824080356450773094427801032134768781;
    verifiedMailserverKeys["twitter.com"][12] = 2160330005857484633191775197216017274;
    verifiedMailserverKeys["twitter.com"][13] = 2447512561136956201144186872280764330;
    verifiedMailserverKeys["twitter.com"][14] = 3006152463941257314249890518041106;
    verifiedMailserverKeys["twitter.com"][15] = 820607402446306410974305086636012205;
    verifiedMailserverKeys["twitter.com"][16] = 343542034344264361438243465247009;
  }

  // function getDesc(
  //     address origin,
  //     address sink,
  //     uint256 degree
  // ) private view returns (string memory) {
  //     // convert address to string
  //     string memory originStr = toString(origin);
  //     string memory sinkStr = toString(sink);
  //     // concatenate strings
  //     string memory result = string(
  //         abi.encodePacked(
  //             sinkStr,
  //             "is ",
  //             toString(degree),
  //             "th degree friends with ",
  //             originStr
  //         )
  //     );

  //     return result;
  // }

  // function tokenDesc(uint256 tokenId) public view returns (string memory) {
  //     address origin = originAddress[tokenId];
  //     address sink = sinkAddress[tokenId];
  //     uint256 degree = degree[tokenId];
  //     return getDesc(origin, sink, degree);
  // }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    string[3] memory parts;
    parts[
      0
    ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

    // parts[1] = tokenDesc(tokenId);

    parts[2] = "</text></svg>";

    string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2]));

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"domain": "',
            domain,
            '", "tokenId": ',
            toString(tokenId),
            "}",
            '", "description": "VerifiedEmails are ZK verified proofs of email ownership on Ethereum. They only reveal your email domain, nothing about your identity. We can construct both goods like Glassdoor and Blind, and terrible tragedy of the commons scenarios where instituition reputation is slowly spent by its members. VerifiedEmail uses ZK SNARKs to insinuate this social dynamic.", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(output)),
            '"}'
          )
        )
      )
    );
    output = string(abi.encodePacked("data:application/json;base64,", json));

    return output;
  }

  function toString(address account) public pure returns (string memory) {
    return toString(abi.encodePacked(account));
  }

  function toString(uint256 value) public pure returns (string memory) {
    return toString(abi.encodePacked(value));
  }

  function toString(bytes32 value) public pure returns (string memory) {
    return toString(abi.encodePacked(value));
  }

  function toString(bytes memory data) public pure returns (string memory) {
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(2 + data.length * 2);
    str[0] = "0";
    str[1] = "x";
    for (uint256 i = 0; i < data.length; i++) {
      str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
      str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
    }
    return string(str);
  }

  uint16 public constant msg_len = 163;
  uint256 public constant header_len = 50; // FIX CONSTANT

  // Unpacks uint256s into bytes and then extracts the non-zero characters
  // Only extracts contiguous non-zero characters and ensures theres only 1 such state
  function convert7PackedBytesToBytes(uint256[] memory packedBytes, uint256 packedLen) public pure returns (string memory extractedString) {
    uint8 state = 0;
    // bytes: 0 0 0 0 y u s h _ g 0 0 0
    // state: 0 0 0 0 1 1 1 1 1 1 2 2 2
    bytes memory nonzeroBytesArray = new bytes(packedBytes.length * 7);
    uint256 nonzeroBytesArrayIndex = 0;
    for (uint16 i = 0; i < msg_len - 17; i++) {
      uint256 packedByte = packedBytes[i];
      uint8[7] memory unpackedBytes = [
        uint8(packedByte >> 48),
        uint8(packedByte >> 40),
        uint8(packedByte >> 32),
        uint8(packedByte >> 24),
        uint8(packedByte >> 16),
        uint8(packedByte >> 8),
        uint8(packedByte)
      ];
      for (uint256 j = 0; j < 7; j++) {
        uint8 unpackedByte = unpackedBytes[j];
        if (unpackedByte != 0) {
          nonzeroBytesArray[nonzeroBytesArrayIndex] = bytes1(unpackedByte);
          nonzeroBytesArrayIndex++;
          if (state % 2 == 0) {
            state += 1;
          }
        } else {
          if (state % 2 == 1) {
            state += 1;
          }
        }
        packedByte = packedByte >> 8;
      }
    }
    string memory returnValue = toString(nonzeroBytesArray);
    require(state == 2, "Invalid states in packed bytes in email");
    return returnValue;
    // Have to end at the end of the email -- state cannot be 1 since there should be an email footer
  }

  function mint(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[msg_len] memory signals
  ) public {
    // require(signals[0] == 1337, "invalid signals"); // TODO no invalid signal check yet, which is fine since the zk proof does it
    require(signals[0] == 0, "Invalid starting message character");
    // msg_len-17 public signals are the masked message bytes, 17 are the modulus.
    uint256[] memory headerSignals = new uint256[](header_len);
    // TODO set consistent body len with circuit
    uint256 body_len = msg_len - header_len;
    uint256[] memory bodySignals = new uint256[](body_len);
    for (uint256 i = 0; i < header_len; i++) {
      headerSignals[i] = signals[i];
    }
    for (uint256 i = header_len; i < msg_len; i++) {
      bodySignals[i] = signals[i];
    }
    string memory messageBytes = convert7PackedBytesToBytes(headerSignals, header_len);
    string memory senderBytes = convert7PackedBytesToBytes(bodySignals, body_len);
    string memory domainString = "verify@twitter.com";
    require(keccak256(abi.encodePacked(senderBytes)) == keccak256(abi.encodePacked(domainString)), "Invalid domain");

    for (uint32 i = msg_len - 17; i < msg_len; i++) {
      require(signals[i] == verifiedMailserverKeys[domain][i], "Invalid modulus not matched");
    }
    require(verifyProof(a, b, c, signals), "Invalid Proof"); // checks effects iteractions, this should come first

    uint256 tokenId = tokenCounter.current() + 1;
    tokenToName[tokenId] = messageBytes;
    _mint(msg.sender, tokenId);
    tokenCounter.increment();
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override {
    require(from == address(0), "Cannot transfer - VerifiedEmail is soulbound");
  }
}
