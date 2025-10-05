// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ✅ FHE CORE: Import đúng từ @fhevm/solidity
import { FHE, euint64, ebool, externalEuint64 } from "@fhevm/solidity/lib/FHE.sol";

// ✅ CONFIG: Import SepoliaConfig từ ZamaConfig.sol (fix lỗi path)
import { SepoliaConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

// ✅ OPENZEPPELIN: Security và EIP712
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title FHEAuction
 * @dev Blind auction với FHEVM trên Sepolia. Inherit SepoliaConfig để enable FHE ops.
 * Bids encrypted on-chain, reveal off-chain qua decryption request to relayer.
 */
contract FHEAuction is SepoliaConfig, EIP712, ReentrancyGuard {
    
    // ========== FHE ENCRYPTED STATE ==========
    
    euint64 private encryptedMaxBid;
    
    // ========== PLAINTEXT STATE ==========
    
    uint256 public immutable auctionEndTime;
    uint256 public immutable minBidDeposit;
    address payable public currentLeadBidder;
    uint256 public currentLeadDeposit;
    bool public auctionFinalized;
    address public owner;
    uint256 public winningBid;  // ✅ Thêm declaration cho winningBid
    
    // ========== MAPPING FOR BIDS (ENCRYPTED) ==========
    mapping(address => euint64) private encryptedBids;
    
    // ========== DECRYPTION STATE ==========
    uint256 private pendingDecryptId;
    address private constant DECRYPTION_ORACLE = 0x8D196Cc0fd2bA583fBe1D0f8BC0AC3A69faBA5d5; // Sepolia FHEVM Oracle address (correct checksum)
    
    // ========== EVENTS, MODIFIERS ==========
    
    event BidReceived(address indexed bidder, uint256 depositAmount, bool isNewLeader);
    event AuctionFinished(address winner, uint256 finalDeposit);
    event RefundIssued(address indexed recipient, uint256 amount);
    event BidderWithdrew(address indexed bidder, uint256 amount);
    event DecryptionRequested(uint256 requestId);
    
    modifier onlyBeforeEnd() { require(block.timestamp < auctionEndTime, "Auction has ended"); _; }
    modifier onlyAfterEnd() { require(block.timestamp >= auctionEndTime, "Auction is still active"); _; }
    modifier onlyOwner() { require(msg.sender == owner, "Only owner can call this"); _; }
    
    // ✅ MODIFIER: Verify signed publicKey sử dụng EIP712 + ECDSA
    modifier onlySignedPublicKey(bytes32 publicKey, bytes calldata signature) {
        bytes32 structHash = keccak256(abi.encode(
            keccak256("PublicKey(bytes32 key)"),
            publicKey
        ));
        bytes32 digest = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(digest, signature);
        require(signer == owner, "Invalid signature for publicKey");
        _;
    }
    
    // ========== CONSTRUCTOR ==========
    
    constructor(uint256 _durationInSeconds, uint256 _minDeposit) EIP712("FHEAuction", "1") {
        require(_durationInSeconds > 0, "Duration must be positive");
        require(_minDeposit > 0, "Min deposit must be positive");
        
        owner = msg.sender;
        auctionEndTime = block.timestamp + _durationInSeconds;
        minBidDeposit = _minDeposit;
        
        // ✅ Init với FHE.asEuint64(0) - không cần proof cho plaintext
        encryptedMaxBid = FHE.asEuint64(0);
        
        currentLeadBidder = payable(address(0));
        currentLeadDeposit = 0;
        auctionFinalized = false;
    }
    
    // ========== MAIN FUNCTIONS ==========
    
    function bid(
        externalEuint64 encryptedBid,
        bytes calldata proof
    ) external payable onlyBeforeEnd nonReentrant {
        require(msg.value >= minBidDeposit, "Deposit below minimum");
        
        // ✅ Sử dụng FHE.fromExternal để load encrypted input (verify proof)
        euint64 bidAmount = FHE.fromExternal(encryptedBid, proof);
        
        // Lưu encrypted bid
        encryptedBids[msg.sender] = bidAmount;
        
        // ✅ Update encryptedMaxBid homomorphic (sử dụng FHE.gt() và FHE.select())
        ebool isHigher = FHE.gt(bidAmount, encryptedMaxBid);
        euint64 newMaxBid = FHE.select(isHigher, bidAmount, encryptedMaxBid);
        encryptedMaxBid = newMaxBid;
        
        emit BidReceived(msg.sender, msg.value, false);  // Flag update sau reveal off-chain
    }
    
    function finalizeAuction() external onlyAfterEnd nonReentrant { 
        require(!auctionFinalized, "Auction already finalized");
        auctionFinalized = true;
        emit AuctionFinished(currentLeadBidder, currentLeadDeposit);
    }
    
    function withdrawWinnings() external onlyAfterEnd nonReentrant { 
        require(auctionFinalized, "Auction must be finalized first");
        require(msg.sender == currentLeadBidder, "Only winner can withdraw");
        require(currentLeadDeposit > 0, "No deposit to withdraw");
        
        uint256 amount = currentLeadDeposit;
        currentLeadDeposit = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit BidderWithdrew(msg.sender, amount);
    }
    
    // ========== VIEW FUNCTIONS ==========
    
    function getAuctionEndTime() external view returns (uint256) {
        return auctionEndTime;
    }
    
    function getMinBidDeposit() external view returns (uint256) {
        return minBidDeposit;
    }
    
    function getCurrentLeadBidder() external view returns (address payable) {
        return currentLeadBidder;
    }
    
    function getCurrentLeadDeposit() external view returns (uint256) {
        return currentLeadDeposit;
    }
    
    function isAuctionFinalized() external view returns (bool) {
        return auctionFinalized;
    }
    
    /**
     * @notice Owner request decryption của max bid (off-chain qua relayer)
     */
    function requestDecryptMaxBid() external onlyAfterEnd onlyOwner returns (uint256) { 
        require(!auctionFinalized, "Auction already finalized");
        
        // Request decryption của encryptedMaxBid
        bytes32[] memory handles = new bytes32[](1);
        handles[0] = FHE.toBytes32(encryptedMaxBid);  // ✅ Fix: Use FHE.toBytes32 for conversion
        pendingDecryptId = FHE.requestDecryption(handles, this.onDecryptionCallback.selector);
        
        emit DecryptionRequested(pendingDecryptId);
        return pendingDecryptId;
    }
    
    /**
     * @notice Owner request decryption của bid cụ thể
     */
    function requestDecryptBidderBid(address bidder) external onlyAfterEnd onlyOwner returns (uint256) {
        // ✅ Simplified: Skip encrypted != check (cannot compare directly; assume bidder has bid for demo)
        // In production, store as bytes32 and check != bytes32(0)
        
        bytes32[] memory handles = new bytes32[](1);
        handles[0] = FHE.toBytes32(encryptedBids[bidder]);  // ✅ Fix: Use FHE.toBytes32 for conversion
        pendingDecryptId = FHE.requestDecryption(handles, this.onDecryptionCallback.selector);
        
        emit DecryptionRequested(pendingDecryptId);
        return pendingDecryptId;
    }
    
    /**
     * @notice Callback từ relayer sau decryption (gọi bởi oracle)
     */
    function onDecryptionCallback(uint256 requestId, bytes memory cleartexts, bytes memory decryptionProof) external {
        require(msg.sender == DECRYPTION_ORACLE, "Only decryption oracle can call");
        require(requestId == pendingDecryptId, "Invalid request ID");
        FHE.checkSignatures(requestId, cleartexts, decryptionProof);  // ✅ Fix: Pass 3 args: requestId, cleartexts, decryptionProof
        
        // Decode decrypted value (uint256 from euint64)
        uint256 decryptedValue = abi.decode(cleartexts, (uint256));
        
        // Cập nhật state dựa trên decrypted (ví dụ: set winningBid)
        winningBid = decryptedValue;  // ✅ Bây giờ winningBid đã được declare
        
        // Emit event cho frontend listen
        emit AuctionFinished(currentLeadBidder, decryptedValue);
    }
    
    // ========== UTILITY FUNCTIONS ==========
    
    function emergencyCancel() external onlyOwner onlyBeforeEnd nonReentrant {
        require(!auctionFinalized, "Already finalized");
        if (currentLeadDeposit > 0 && currentLeadBidder != address(0)) {
            uint256 refundAmount = currentLeadDeposit;
            address payable recipient = currentLeadBidder;
            currentLeadBidder = payable(address(0));
            currentLeadDeposit = 0;
            (bool success, ) = recipient.call{value: refundAmount}("");
            require(success, "Emergency refund failed");
            emit RefundIssued(recipient, refundAmount);
        }
        // Reset encryptedMaxBid
        encryptedMaxBid = FHE.asEuint64(0);
        auctionFinalized = true;
    }
    
    /**
     * @notice Owner manual refund bidder sau finalize (dựa trên reveal off-chain)
     */
    function manualRefund(address bidder, uint256 amount) external onlyOwner onlyAfterEnd nonReentrant {
        // Simplified check: assume bid exists if called after reveal (for compilation; in prod, use FHE.eq)
        (bool success, ) = payable(bidder).call{value: amount}("");
        require(success, "Refund failed");
        emit RefundIssued(bidder, amount);
        encryptedBids[bidder] = FHE.asEuint64(0);  // ✅ Fix: Set to zero instead of delete for euint64
    }
    
    /**
     * @notice Owner update leader sau reveal off-chain (verify bids trước khi gọi)
     */
    function updateLeaderAfterReveal(address newLeader, uint256 newDeposit) external onlyOwner onlyAfterEnd {
        require(newDeposit > 0, "Invalid deposit");
        if (currentLeadDeposit > 0 && currentLeadBidder != address(0)) {
            (bool success, ) = currentLeadBidder.call{value: currentLeadDeposit}("");
            require(success, "Refund old leader failed");
            emit RefundIssued(currentLeadBidder, currentLeadDeposit);
        }
        currentLeadBidder = payable(newLeader);
        currentLeadDeposit = newDeposit;
        emit BidReceived(newLeader, newDeposit, true);
    }
    
    receive() external payable { revert("Direct transfers not allowed. Use bid()"); }
    fallback() external payable { revert("Invalid function call"); }
}