# MY ZAMA FHE AUCTION

Dự án minh họa một hệ thống **Đấu giá kín (Sealed-Bid Auction)
** Hoàn toàn bảo mật, được xây dựng trên **Zama FHEVM (Fully Homomorphic Encryption EVM)**.
** Mục tiêu là cho phép người dùng đặt giá thầu được mã hóa, và logic tìm người thắng thầu được xử lý trên blockchain mà không cần giải mã bất kỳ giá thầu nào
** Loại bỏ hoàn toàn nguy cơ MEV (Miner Extractable Value) và front-running.

## 🌟 Tính Năng Nổi Bật

* **Bảo mật Tuyệt đối (End-to-End Confidentiality):** Giá thầu được mã hóa trên client và được xử lý mã hóa hoàn toàn trên chuỗi (homomorphic computation).
* **Chống Lộ thông tin:** Không ai, kể cả người vận hành chuỗi khối (node operators), có thể biết được giá trị của các thầu chưa thắng.
* **Giải mã Riêng tư:** Người tham gia chỉ có thể tự giải mã kết quả thắng/thua của chính họ bằng Private Key FHE của mình.
* **Tương thích EVM:** Hợp đồng được viết bằng Solidity với các kiểu dữ liệu `euint` mở rộng.

## 🛠️ Công Nghệ Sử Dụng (Tech Stack)

| Hạng mục | Công nghệ | Mục đích |
| :--- | :--- | :--- |
| **Blockchain** | **Zama FHEVM** | Nền tảng thực thi giao dịch mã hóa đồng hình. |
| **Smart Contract** | **Solidity**, **Hardhat** | Ngôn ngữ phát triển hợp đồng thông minh và môi trường phát triển (bao gồm testing, deployment). |
| **Thư viện FHE** | **`fhevmjs`** (TypeScript/JavaScript) | Thư viện front-end dùng để tạo cặp khóa FHE, mã hóa giá trị thầu thô (plaintext) và giải mã kết quả cuối cùng. |
| **Frontend** | **Next.js** / **React** | Giao diện người dùng để tương tác với ví (wallet) và hợp đồng FHE. |

## 🚀 Cài Đặt và Vận Hành (Installation & Usage)

Các bước chung để thiết lập và chạy dự án (có thể thay đổi tùy thuộc vào cấu trúc file cụ thể):
1. Thiết lập Repository
'''bash
# Clone repository
'''
git clone [https://github.com/Quangx199x/MY-ZAMA-FHE-AUCTION.git] (https://github.com/Quangx199x/MY-ZAMA-FHE-AUCTION.git)
cd MY-ZAMA-FHE-AUCTION
'''
# Cài đặt dependencies (backend/contract)
'''
npm install
'''
### 2. Chạy FHEVM Local Node (hoặc kết nối Testnet)
Để phát triển, bạn cần chạy một môi trường FHEVM cục bộ hoặc kết nối tới FHEVM Testnet (như Zama Devnet):
'''
Bash

# Chạy node Hardhat cục bộ có hỗ trợ FHEVM
npx hardhat node
'''
### 3. Triển khai Hợp đồng (Deployment)
Triển khai hợp đồng Đấu giá lên mạng lưới FHEVM:
'''
Bash

# Triển khai hợp đồng
npx hardhat run --network local scripts/deploy.ts
'''
(Ghi lại địa chỉ hợp đồng đã triển khai.)

### 4. Chạy Frontend
Sử dụng địa chỉ hợp đồng đã triển khai để tương tác qua giao diện web:

Bash

# Chuyển đến thư mục frontend (nếu có)
'''
cd frontend
npm install
npm run dev
'''
# Mở trình duyệt tại http://localhost:3000 (thường là vậy)

🤝 Tương tác (Contract Interaction Flow)

Client: Người dùng nhập giá thầu (ví dụ: 0.15).

fhevmjs: Mã hóa 0.15 thành euint ciphertext C bằng Public Key FHE của mạng.

Client: Gửi giao dịch placeBid(C, proof) đến FHEVM.

FHEVM: Hợp đồng Solidity nhận C, so sánh C với highestBid (cũng là euint đã mã hóa) bằng TFHE.gt().

FHEVM: Cập nhật highestBid và highestBidder (vẫn ở dạng mã hóa) mà không tiết lộ giá trị thầu.

Client: Sau khi đấu giá kết thúc, người dùng yêu cầu hợp đồng mã hóa lại kết quả thắng/thua (ebool) bằng Public Key FHE của chính họ.

Client: Dùng Private Key FHE cục bộ để giải mã ebool, hiển thị kết quả cuối cùng.

Để hiểu rõ hơn về cách viết Hợp đồng thông minh bảo mật bằng Zama FHEVM, bạn có thể tham khảo video hướng dẫn sau:
Hướng dẫn viết hợp đồng thông minh bảo mật bằng Zama's fhEVM
https://www.youtube.com/watch?v=1FtbyHZwNX4
