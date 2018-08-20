mysql -u root -pletmein -h 127.0.0.1 -P 3307


mysql-proxy --proxy-lua-script=/home/taeyun/Desktop/mysqlproxy/wrapper.lua --proxy-address=127.0.0.1:3307 --proxy-backend-addresses=localhost:3306 --plugins=proxy --event-threads=4  --max-open-files=1024

//building udf so 
gcc -shared -o udf_example.so udf_example.c -L/usr/lib/x86_64-linux-gnu -lmysqlclient -lpthread -lz -lm -lrt -ldl -I/usr/include/mysql -fPIC

//copy to plugin directory
sudo cp tfhe_udf.so /usr/local/mysql/lib/plugin

g++ -shared -o tfhe_udf.so tfhe_udf.cpp -L/usr/lib/x86_64-linux-gnu -lmysqlclient -lpthread -lz -lm -lrt -ldl -I/usr/include/mysql -fPIC -ltfhe-spqlios-fma -std=gnu++11


gcc -shared -o thfe_udf.so tfhe_udf.c -L/usr/lib/x86_64-linux-gnu -lmysqlclient -lpthread -lz -lm -lrt -ldl -I/usr/include/mysql -fPIC -std=gnu99

select * from mysql.func;
drop function comparison;
