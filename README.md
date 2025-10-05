# MY ZAMA FHE AUCTION: Đấu giá Kín Tuyệt đối

Dự án minh họa một hệ thống Đấu giá kín (Sealed-Bid Auction) hoàn toàn bảo mật, được xây dựng trên Zama FHEVM (Fully Homomorphic Encryption EVM).

## I. Mục tiêu Dự án Mục tiêu chính là tạo ra một môi trường đấu giá công bằng và riêng tư bằng cách:

Cho phép người dùng đặt giá thầu ở trạng thái mã hóa trên chuỗi.

Logic tìm người thắng thầu được xử lý trên blockchain mà không cần giải mã bất kỳ giá thầu nào.

Loại bỏ hoàn toàn nguy cơ MEV (Miner Extractable Value) và front-running, vì dữ liệu thầu không bao giờ ở dạng thô (plaintext).

## II. 🌟 Tính Năng Cốt Lõi

Tính năng Mô tả Bảo mật Tuyệt đối Giá thầu được mã hóa trên client và được xử lý mã hóa hoàn toàn trên chuỗi (homomorphic computation). Chống Lộ thông tin Không ai, kể cả người vận hành chuỗi khối (node operators), có thể biết được giá trị của các thầu chưa thắng. Giải mã Riêng tư Người tham gia chỉ có thể tự giải mã kết quả thắng/thua của chính họ bằng Private Key FHE cá nhân. Tương thích EVM Hợp đồng được viết bằng Solidity, sử dụng các kiểu dữ liệu euint và ebool mở rộng của FHEVM.

Xuất sang Trang tính **III. 🛠️ Công Nghệ Sử Dụng (Tech Stack) Hạng mục Công nghệ Mục đích Blockchain Zama FHEVM Nền tảng thực thi giao dịch mã hóa đồng hình (FHE). Smart Contract Solidity, Hardhat Ngôn ngữ phát triển hợp đồng thông minh và môi trường phát triển (testing, deployment). Thư viện FHE fhevmjs (TS/JS) Frontend: Tạo cặp khóa FHE, mã hóa giá trị thầu thô (plaintext) và giải mã kết quả. Frontend Next.js / React Giao diện người dùng để tương tác với ví (wallet) và hợp đồng FHE.

Xuất sang Trang tính

## III 🤝 Luồng Tương tác Hợp đồng (Interaction Flow)
Quá trình đặt thầu và công bố kết quả được thực hiện hoàn toàn trong môi trường mã hóa:

Mã hóa giá thầu:

Người dùng nhập giá thầu (ví dụ: 0.15).

Thư viện fhevmjs sử dụng Public Key FHE của mạng để mã hóa giá trị này thành một ciphertext (euint) C.

Gửi giao dịch:

Client gửi giao dịch placeBid(C, proof) đến FHEVM.

Xử lý trên FHEVM (Mã hóa):

Hợp đồng Solidity nhận C và so sánh C với highestBid (cũng là euint đã mã hóa) bằng hàm TFHE.gt().

FHEVM cập nhật highestBid và highestBidder (vẫn ở dạng mã hóa) mà không tiết lộ giá trị thầu thực tế.

Yêu cầu Kết quả Riêng tư:

Sau khi phiên đấu giá kết thúc, người dùng yêu cầu hợp đồng mã hóa lại kết quả thắng/thua (ebool) bằng Public Key FHE của chính họ.

Giải mã Kết quả:

Client dùng Private Key FHE cục bộ của mình để giải mã ebool, hiển thị kết quả cuối cùng (thắng/thua).

## IV. 🚀 Hướng dẫn Cài đặt & Khởi chạy

### Prerequisites

- **Node.js**: Version 20 or higher
- **npm or yarn/pnpm**: Package manager


Thực hiện các bước sau để thiết lập và chạy dự án (Các bước sau được giả định thực hiện từ thư mục gốc của dự án):

Thiết lập Repository & Cài đặt Dependencies Mở Terminal và chạy các lệnh sau:

<pre>
     ```
Bash

git clone https://github.com/Quangx199x/MY-ZAMA-FHE-AUCTION.git
   ```
</pre>

Di chuyển vào thư mục dự án

<pre>
   ```
cd MY-ZAMA-FHE-AUCTION
   ```
</pre>


### Installation

1. **Install dependencies**
<pre>
   ```bash
   npm install
   ```
</pre>

2. **Set up environment variables**
<pre>
   ```bash
   npx hardhat vars set MNEMONIC

   # Set your Infura API key for network access
   npx hardhat vars set INFURA_API_KEY

   # Optional: Set Etherscan API key for contract verification
   npx hardhat vars set ETHERSCAN_API_KEY
   ```
</pre>

3. **Compile and test**
<pre>
   ```bash
   npm run compile
   npm run test
   ```
</pre>
4. **Deploy to local network**
<pre>
   ```bash
   # Start a local FHEVM-ready node
   npx hardhat node
   # Deploy to local network
   npx hardhat deploy --network localhost
   ```
</pre>
5. **Deploy to Sepolia Testnet**
<pre>
   ```bash
   # Deploy to Sepolia
   npx hardhat deploy --network sepolia
   # Verify contract on Etherscan
   npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
   ```
</pre>
6. **Test on Sepolia Testnet**
<pre>
   ```bash
   # Once deployed, you can run a simple test on Sepolia.
   npx hardhat test --network sepolia
   ```
</pre>
## 📁 Project Structure

```
fhevm-hardhat-template/
├── contracts/           # Smart contract source files
│   └── FHECounter.sol   # Example FHE counter contract
├── deploy/              # Deployment scripts
├── tasks/               # Hardhat custom tasks
├── test/                # Test files
├── hardhat.config.ts    # Hardhat configuration
└── package.json         # Dependencies and scripts
```

## 📜 Available Scripts

| Script             | Description              |
| ------------------ | ------------------------ |
| `npm run compile`  | Compile all contracts    |
| `npm run test`     | Run all tests            |
| `npm run coverage` | Generate coverage report |
| `npm run lint`     | Run linting checks       |
| `npm run clean`    | Clean build artifacts    |



## 📚 Documentation

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [FHEVM Hardhat Setup Guide](https://docs.zama.ai/protocol/solidity-guides/getting-started/setup)
- [FHEVM Testing Guide](https://docs.zama.ai/protocol/solidity-guides/development-guide/hardhat/write_test)
- [FHEVM Hardhat Plugin](https://docs.zama.ai/protocol/solidity-guides/development-guide/hardhat)

## 📄 License

This project is licensed under the BSD-3-Clause-Clear License. See the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/zama-ai/fhevm/issues)
- **Documentation**: [FHEVM Docs](https://docs.zama.ai)
- **Community**: [Zama Discord](https://discord.gg/zama)

---

**Built with ❤️ by the Zama team**
