mysql -u root -pletmein -h 127.0.0.1 -P 3307


mysql-proxy --proxy-lua-script=/home/taeyun/Desktop/mysqlproxy/wrapper.lua --proxy-address=127.0.0.1:3307 --proxy-backend-addresses=localhost:3306 --plugins=proxy --event-threads=4  --max-open-files=1024
