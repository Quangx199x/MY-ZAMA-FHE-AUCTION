# <center>MY ZAMA FHE AUCTION: Đấu giá Kín Tuyệt đối</center>
Dự án minh họa một hệ thống Đấu giá kín (Sealed-Bid Auction) hoàn toàn bảo mật, được xây dựng trên Zama FHEVM (Fully Homomorphic Encryption EVM).

##I. Mục tiêu Dự án
Mục tiêu chính là tạo ra một môi trường đấu giá công bằng và riêng tư bằng cách:

Cho phép người dùng đặt giá thầu ở trạng thái mã hóa trên chuỗi.

Logic tìm người thắng thầu được xử lý trên blockchain mà không cần giải mã bất kỳ giá thầu nào.

Loại bỏ hoàn toàn nguy cơ MEV (Miner Extractable Value) và front-running, vì dữ liệu thầu không bao giờ ở dạng thô (plaintext).

## II. 🌟 Tính Năng Cốt Lõi
Tính năng	Mô tả
Bảo mật Tuyệt đối	Giá thầu được mã hóa trên client và được xử lý mã hóa hoàn toàn trên chuỗi (homomorphic computation).
Chống Lộ thông tin	Không ai, kể cả người vận hành chuỗi khối (node operators), có thể biết được giá trị của các thầu chưa thắng.
Giải mã Riêng tư	Người tham gia chỉ có thể tự giải mã kết quả thắng/thua của chính họ bằng Private Key FHE cá nhân.
Tương thích EVM	Hợp đồng được viết bằng Solidity, sử dụng các kiểu dữ liệu euint và ebool mở rộng của FHEVM.

Xuất sang Trang tính
**III. 🛠️ Công Nghệ Sử Dụng (Tech Stack)
Hạng mục	Công nghệ	Mục đích
Blockchain	Zama FHEVM	Nền tảng thực thi giao dịch mã hóa đồng hình (FHE).
Smart Contract	Solidity, Hardhat	Ngôn ngữ phát triển hợp đồng thông minh và môi trường phát triển (testing, deployment).
Thư viện FHE	fhevmjs (TS/JS)	Frontend: Tạo cặp khóa FHE, mã hóa giá trị thầu thô (plaintext) và giải mã kết quả.
Frontend	Next.js / React	Giao diện người dùng để tương tác với ví (wallet) và hợp đồng FHE.

Xuất sang Trang tính
## IV. 🤝 Luồng Tương tác Hợp đồng (Interaction Flow)
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

## V. 🚀 Hướng dẫn Cài đặt & Khởi chạy
Thực hiện các bước sau để thiết lập và chạy dự án (Các bước sau được giả định thực hiện từ thư mục gốc của dự án):

1. Thiết lập Repository & Cài đặt Dependencies
Mở Terminal và chạy các lệnh sau:
<pre>
Bash

git clone https://github.com/Quangx199x/MY-ZAMA-FHE-AUCTION.git
</pre>
### Di chuyển vào thư mục dự án
<pre>
cd MY-ZAMA-FHE-AUCTION
</pre>
### Cài đặt dependencies cho backend (Hardhat/Contract)
<pre>
npm install
</pre>
2. Chạy FHEVM Local Node
Để phát triển và kiểm thử, bạn cần chạy một môi trường FHEVM cục bộ:
<pre>
Bash

### Chạy node Hardhat cục bộ có hỗ trợ FHEVM
npx hardhat node
</pre>
3. Triển khai Hợp đồng (Deployment)
Sau khi node cục bộ đang chạy, mở một Terminal mới và tiến hành triển khai Hợp đồng Đấu giá lên mạng lưới FHEVM:
<pre>
Bash

### Triển khai hợp đồng lên mạng 'local'
npx hardhat run --network local scripts/deploy.ts
(Ghi lại địa chỉ hợp đồng đã triển khai để sử dụng trong Frontend.)
</pre>
4. Khởi chạy Frontend
Sử dụng địa chỉ hợp đồng đã triển khai ở bước 3 để tương tác qua giao diện web:
<pre>
Bash

### Di chuyển đến thư mục frontend
cd frontend
# Cài đặt dependencies cho frontend
npm install
</pre>
### Khởi chạy ứng dụng web
<pre>
npm run dev
</pre>
Sau khi chạy thành công, mở trình duyệt và truy cập vào địa chỉ: http://localhost:3000 để bắt đầu tương tác với sàn đấu giá FHE.

# VI. 🎥 Tài nguyên Bổ sung##
Để hiểu rõ hơn về cách viết Hợp đồng thông minh bảo mật bằng Zama FHEVM, bạn có thể tham khảo video hướng dẫn sau:

Hướng dẫn viết hợp đồng thông minh bảo mật bằng Zama's fhEVM
