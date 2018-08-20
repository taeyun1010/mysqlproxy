-- assert(package.loadlib(os.getenv("EDBDIR").."/obj/libexecute.so",
--                        "lua_cryptdb_init"))()
-- local proto = assert(require("mysql.proto"))

-- --
-- -- Interception points provided by mysqlproxy
-- --


-- function read_auth()
--     -- Use this instead of connect_server(), to get server name
--     dprint("Connected " .. proxy.connection.client.src.name)
--     CryptDB.connect(proxy.connection.client.src.name,
--                     proxy.connection.server.dst.address,
--                     proxy.connection.server.dst.port,
--                     os.getenv("CRYPTDB_USER") or "root",
--                     os.getenv("CRYPTDB_PASS") or "letmein",
--             os.getenv("CRYPTDB_SHADOW") or os.getenv("EDBDIR").."/shadow")
--     -- EDBClient uses its own connection to the SQL server to set up UDFs
--     -- and to manipulate multi-principal state.  (And, in the future, to
--     -- store its schema state for single- and multi-principal operation.)
-- end

-- function disconnect_client()
--     dprint("Disconnected " .. proxy.connection.client.src.name)
--     CryptDB.disconnect(proxy.connection.client.src.name)
-- end

-- package.cpath = "/home/taeyun/Desktop/tensor1_new/tensor2lib.so"

package.cpath = "/home/taeyun/Desktop/tensor1_new/tfhelib.so"

require "mylib"

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

-- see if the file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
  end
  
-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
    if not file_exists(file) then return {} end
    lines = {}
    for line in io.lines(file) do 
        lines[#lines + 1] = line
    end
    return lines
end

-- syntax:
-- id: id of the individual, integerorder: which integer in the fingerprintvector, value: actual value to be encrypted
-- insert into ciphertext values(id int, integerorder int, value int);
-- int will be encrypted and stored into ciphertext_biti tables
function insert_handler(query)
    -- first check if syntax, number of columns, etc are correct

    local array = {}
    for capture in string.gmatch(query, "-?%d+") do
        table.insert(array, capture)
    end

    id = array[1]
    integerorder = array[2]
    value = array[3]

    print("usedid = " .. id)
   
    -- plaintext = string.match(query, "%d+")

    -- print("plaintext = " .. plaintext)
    
    mylib.HOMencrypt(value)
    
    file = '/home/taeyun/Desktop/mysqlproxy/encryptedInteger.txt'
    lines = lines_from(file)

    -- -- print all line numbers and their contents
    -- for k,v in pairs(lines) do
    --     print('line[' .. k .. ']', v)
    -- end

    linenumber = 1

    for i=0,15,1
        do
        modifiedquery = "insert into ciphertext_bit" .. i .. " values("
        -- whose fingerprint vector this is
        modifiedquery = modifiedquery .. id .. ", "

        -- which integer it is in the fingerprint vector
        modifiedquery = modifiedquery .. integerorder .. ", "
        -- TODO: replace 500 with n
        for j = 0,501,1
        do
            if j == 501 then
                modifiedquery = modifiedquery .. lines[linenumber] .. ")"
                linenumber = linenumber + 1
                break
            end
            modifiedquery = modifiedquery .. lines[linenumber] .. ", "
            linenumber = linenumber + 1
            
        end
        -- print("modifiedquery = " .. modifiedquery)
        if i == 15 then
            proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
        else
            proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
        end
        -- proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true});
    end            

    return proxy.PROXY_SEND_QUERY

end

-- -- extractedfpvectors.txt has a format of fpnumber; intva
-- function insertfp_handler(query)
--     fpfile = '/home/taeyun/Desktop/mysqlproxy/extractedfpvectors.txt'
--     fplines = lines_from(fpfile)
--     isfirstloop = 1
--     modifiedquery = ''
--     -- print all line numbers and their contents
--     for k,v in pairs(fplines) do
--         if (isfirstloop == 0) then
--             if v == 'end'then
--                 proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
--                 print("returning proxy_send_query")
--                 -- print("queue length = " .. proxy.queries.len)
--                 return proxy.PROXY_SEND_QUERY
--             else
--                 print('appneding query with id 3')
--                 -- print('modifiedquery = ' .. modifiedquery)
--                 proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
--                 -- return proxy.PROXY_SEND_QUERY
--             end
--         end
--         isfirstloop = 0
--         --TODO: change 17 to some kind of expression
--         remainder = k % 17
--         if remainder == 1 then
--             fpnumber = v 
--         elseif remainder == 0 then 
--             integerorder = 15
--         else
--             integerorder = remainder - 2
--         end
--         if not (remainder == 1) then
--             print('inside if not statement')
--             print('k = ' .. k)
--             mylib.HOMencrypt(v)
        
--             file = '/home/taeyun/Desktop/mysqlproxy/encryptedInteger.txt'
--             lines = lines_from(file)

--             -- -- print all line numbers and their contents
--             -- for k,v in pairs(lines) do
--             --     print('line[' .. k .. ']', v)
--             -- end

--             linenumber = 1

--             for i=0,15,1
--                 do
--                 modifiedquery = "insert into ciphertext_bit" .. i .. " values("
--                 -- whose fingerprint vector this is
--                 modifiedquery = modifiedquery .. fpnumber .. ", "

--                 -- which integer it is in the fingerprint vector
--                 modifiedquery = modifiedquery .. integerorder .. ", "
--                 -- TODO: replace 500 with n
--                 for j = 0,501,1
--                 do
--                     if j == 501 then
--                         modifiedquery = modifiedquery .. lines[linenumber] .. ")"
--                         linenumber = linenumber + 1
--                         break
--                     end
--                     modifiedquery = modifiedquery .. lines[linenumber] .. ", "
--                     linenumber = linenumber + 1
                    
--                 end
--                 -- print("modifiedquery = " .. modifiedquery)
--                 -- if i == 15 then
--                 --     proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
--                 -- else
--                 --     proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
--                 -- end
--                 -- proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true});
--                 if not (i==15) then
--                     proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
--                 end
--             end  
--             -- print('line[' .. k .. ']', v)
--         end
--         -- print("modifiedquery = " .. modifiedquery)
--     end

--     -- return proxy.PROXY_SEND_QUERY

-- end

-- extractedfpvectors.txt has a format of fpnumber; intva
function insertfp_handler(query)
    isfirstloop = 1
    for k=0,1999,1 do
        for i=0,15,1 do
    -- for k=0,0,1 do
    --     for i=0,0,1 do
            for j=0,15,1 do
                if (isfirstloop == 1) then
                    modifiedquery = "insert into ciphertext_bit" .. j .. " values(1, 14, -888443787, 1724818887, -562316106, -1197098946, -606191749, 683063857, -1071292632, -167759160, -1254302148, 111525753, 1654561465, -327211802, -915566950, 1638724789, -1041421839, 79514859, -1992888234, 1040478138, -1549509411, 1663051644, 460054755, 627193244, 963598536, 1026597068, 72140400, 99593061, 757977536, -123994574, 552679453, 417488790, 871406310, -1598498312, 2044427458, 513440284, 1493730507, 788907458, -1139065734, -2012098928, 1607863244, -1524796381, 2013547194, 1155650134, 1907667796, -445812792, -2032939004, 530308599, 1160445755, -1573160703, 2039173247, -116583085, 273307737, -854682254, 789348997, 2112356763, -496301107, 1541885403, 1880052926, -195598748, -885658734, 736670106, 1565612606, -693826701, 2086578131, -1000179467, -1229037869, -1222723351, 346894371, -1291491607, -273090644, 42177734, -1645264138, 1372848815, 2093109767, 1045075964, -1845202573, -1989878100, 675489703, 1805427404, 856332657, 1029413988, 987346923, 1666435361, -291817000, -986766090, -1353354798, -942285694, -1556137085, -2030185306, -878152350, -1092313255, -556384556, 880077369, -492541367, -1548584640, -75174358, 1045122396, 1510410412, -1766301429, -1936382171, -1095488814, -571369965, -310231362, -1947867180, -409720744, 1805911606, -622902186, 285605268, -795922765, -538645296, 930965308, -328661909, -1459866298, 943611141, -539012527, 1460368124, 645014949, -1921245081, 1776822189, -2019982708, 880498194, -1508766491, 1341334047, -30248335, -1756293613, 169834977, -819181528, -2081239152, 1314338612, 619017614, 347535054, -1500647616, 154876707, -282843792, 1016553896, 1897616926, 1253459867, -373617705, -1653317800, 1617806544, 1795110182, -1700442065, -1123417984, -526273617, -591005188, 112569888, -1130312308, -1757473720, 890203497, -1315752302, 1532694053, 56732599, -37180311, -1306399038, 799283513, 1704958186, 123777495, -457726520, 532161113, 124403723, 2050435641, 733727810, 1333893783, 490386325, 65832983, -1363007810, 1532905156, -2044171296, 862184628, -1262653706, -891068573, -1961150545, -1378661821, -577016411, -348262929, 1911593366, 1880853949, -716372697, 458575702, -869432888, 508159896, -1852172961, -612984895, 20625659, 2058295544, 416293235, -546584664, -1014600401, 1431010217, 320116184, 401158935, 855517886, 1795233648, -745776311, -290843341, -1721007319, -1707270659, -2112072160, -133324244, 217874611, -390614131, -1711572897, 313327053, -189730214, -924307066, -1639955956, -1806841382, 1312705430, 47413471, -1077728584, -1921892569, 1477529020, 686497124, 303683943, -134265157, -1102516770, -114831035, -195453079, -932772320, -1514494784, -1672131149, -1206189101, -818140661, -2140112686, 130855753, -622680377, 1847065986, -2049280343, 1416451276, -50490622, -968098262, -1773065301, 721851482, 1513460453, 1729419506, -31137260, -99134522, -1051052537, -1452059342, 351702415, 318521853, 590347368, -1250966859, 1266610462, 1863739735, -405779581, -634206017, 1202179141, 2128627315, 409826116, 465054841, -961559152, 515776155, 644754, -193982579, 1005235676, 1671287449, -456322839, 734021543, -1160828857, -1044313963, -2109150795, -368562049, 1168450833, 166353975, -95153756, -718717590, -1771913327, 962280392, -575885692, 662871033, 1466770595, 374412179, -1558779781, 1434618941, 1987452100, 1436890353, 499261428, 727850948, 413261908, 1496276457, 2145522472, 1659901112, 1128481018, 332341872, -1836414979, 1744694079, 1144076015, -888726357, 2144824302, -2071454619, -1200721609, -974712827, 1985827362, -2086375537, -236040936, 1353758472, -1113328939, 863693209, 1590741567, 2011365047, 1135407182, -522356587, -1334301280, -1771072638, -316562884, 1489266733, 877532017, -1984177168, -1502843411, -2030221884, 1399720697, 1526823896, 1199552262, -643761461, 1937927488, -1277260824, -1097263810, 1473457590, -1260448248, -746837878, -757693780, -1391481863, -250690207, -160754002, -659754581, 2063762199, 442227431, -1020939429, -1888498674, 2039983223, 852982264, 387946868, -1442245201, 1209976814, 1592069761, -1447033158, -918110740, 543291867, -223414289, 1822005568, 1083211250, 668742830, -146878579, 1837825672, 606066044, -1522453735, 1099945765, 859329078, 1292441004, -1360846563, 781309617, -1533174409, -69162140, 606003121, -121717571, 419997936, -170191391, -1868467957, 1917894165, -533868549, 1049410431, -1411497752, -8709828, -1812326496, -889099562, 941752487, 1101485774, 1670177176, 2003286651, 1039133778, 295462193, 1592923180, 70505665, -1407822215, -1540201735, -62653300, 1634676014, 1303223681, 1823532793, 1272091111, -1600417416, 551117360, -136763688, 526677854, 586516385, -1315894033, -576674591, 1456528854, -1682609104, -1259798087, 842035770, -1894421553, 796101385, 1535933104, -1822905777, -1367741506, 1744255872, -529949447, 380107758, -584594589, -1689010602, -1018684856, 1052043142, 522720038, -2123334826, -311930535, -239233656, -477033208, 455087474, 1682628133, 1183932100, -1654943780, 1920727474, -106549097, -611938553, -311802601, 1956484323, -474994615, 485461787, 181724917, -2088870587, 1328728257, -1366405381, -559601546, 1418926791, -2104890267, 553657682, -1560434913, 570546737, -1692444421, -924504768, 2045573774, 236743720, -459564648, -93710157, 1040985671, -2047232414, 1525831737, 1812446501, 351745913, -479029491, 1449395768, 1849840465, 1242189348, -2011213205, 1703055889, 1379907204, 1828784713, 543287028, -1201626447, 537652587, 714004360, -786858700, -578232678, 1646810529, 1868634807, 1620761104, 1163819538, 474454250, -2115833613, 401111114, -1868708559, 1878919675, -981850713, -277632014, -1666913290, -1997101072, 1675119427, -648880667, 1196219628, -1298852878, -1989754236, 238671268, 1998206292, 1743792847, 1006886509, -644958889, -943300010, 842348264, 1905696811, -1831380502, -1990787173, 1852996492, -1311383214, 1901466065, 1748058849, -1976214714, 1905968420, 1397751135, -2003358458, 1858952736, -39068333, -1817168654, -359014135, -2076523291, 1153557843, -949112204, -1039343701, 729809930, 106286877, -1752441199, 5.9536e-10)"
                    
                    isfirstloop = 0
                else
                    -- print("modifiedquery = " .. modifiedquery)
                    proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                    modifiedquery = "insert into ciphertext_bit" .. j .. " values(1, 14, -888443787, 1724818887, -562316106, -1197098946, -606191749, 683063857, -1071292632, -167759160, -1254302148, 111525753, 1654561465, -327211802, -915566950, 1638724789, -1041421839, 79514859, -1992888234, 1040478138, -1549509411, 1663051644, 460054755, 627193244, 963598536, 1026597068, 72140400, 99593061, 757977536, -123994574, 552679453, 417488790, 871406310, -1598498312, 2044427458, 513440284, 1493730507, 788907458, -1139065734, -2012098928, 1607863244, -1524796381, 2013547194, 1155650134, 1907667796, -445812792, -2032939004, 530308599, 1160445755, -1573160703, 2039173247, -116583085, 273307737, -854682254, 789348997, 2112356763, -496301107, 1541885403, 1880052926, -195598748, -885658734, 736670106, 1565612606, -693826701, 2086578131, -1000179467, -1229037869, -1222723351, 346894371, -1291491607, -273090644, 42177734, -1645264138, 1372848815, 2093109767, 1045075964, -1845202573, -1989878100, 675489703, 1805427404, 856332657, 1029413988, 987346923, 1666435361, -291817000, -986766090, -1353354798, -942285694, -1556137085, -2030185306, -878152350, -1092313255, -556384556, 880077369, -492541367, -1548584640, -75174358, 1045122396, 1510410412, -1766301429, -1936382171, -1095488814, -571369965, -310231362, -1947867180, -409720744, 1805911606, -622902186, 285605268, -795922765, -538645296, 930965308, -328661909, -1459866298, 943611141, -539012527, 1460368124, 645014949, -1921245081, 1776822189, -2019982708, 880498194, -1508766491, 1341334047, -30248335, -1756293613, 169834977, -819181528, -2081239152, 1314338612, 619017614, 347535054, -1500647616, 154876707, -282843792, 1016553896, 1897616926, 1253459867, -373617705, -1653317800, 1617806544, 1795110182, -1700442065, -1123417984, -526273617, -591005188, 112569888, -1130312308, -1757473720, 890203497, -1315752302, 1532694053, 56732599, -37180311, -1306399038, 799283513, 1704958186, 123777495, -457726520, 532161113, 124403723, 2050435641, 733727810, 1333893783, 490386325, 65832983, -1363007810, 1532905156, -2044171296, 862184628, -1262653706, -891068573, -1961150545, -1378661821, -577016411, -348262929, 1911593366, 1880853949, -716372697, 458575702, -869432888, 508159896, -1852172961, -612984895, 20625659, 2058295544, 416293235, -546584664, -1014600401, 1431010217, 320116184, 401158935, 855517886, 1795233648, -745776311, -290843341, -1721007319, -1707270659, -2112072160, -133324244, 217874611, -390614131, -1711572897, 313327053, -189730214, -924307066, -1639955956, -1806841382, 1312705430, 47413471, -1077728584, -1921892569, 1477529020, 686497124, 303683943, -134265157, -1102516770, -114831035, -195453079, -932772320, -1514494784, -1672131149, -1206189101, -818140661, -2140112686, 130855753, -622680377, 1847065986, -2049280343, 1416451276, -50490622, -968098262, -1773065301, 721851482, 1513460453, 1729419506, -31137260, -99134522, -1051052537, -1452059342, 351702415, 318521853, 590347368, -1250966859, 1266610462, 1863739735, -405779581, -634206017, 1202179141, 2128627315, 409826116, 465054841, -961559152, 515776155, 644754, -193982579, 1005235676, 1671287449, -456322839, 734021543, -1160828857, -1044313963, -2109150795, -368562049, 1168450833, 166353975, -95153756, -718717590, -1771913327, 962280392, -575885692, 662871033, 1466770595, 374412179, -1558779781, 1434618941, 1987452100, 1436890353, 499261428, 727850948, 413261908, 1496276457, 2145522472, 1659901112, 1128481018, 332341872, -1836414979, 1744694079, 1144076015, -888726357, 2144824302, -2071454619, -1200721609, -974712827, 1985827362, -2086375537, -236040936, 1353758472, -1113328939, 863693209, 1590741567, 2011365047, 1135407182, -522356587, -1334301280, -1771072638, -316562884, 1489266733, 877532017, -1984177168, -1502843411, -2030221884, 1399720697, 1526823896, 1199552262, -643761461, 1937927488, -1277260824, -1097263810, 1473457590, -1260448248, -746837878, -757693780, -1391481863, -250690207, -160754002, -659754581, 2063762199, 442227431, -1020939429, -1888498674, 2039983223, 852982264, 387946868, -1442245201, 1209976814, 1592069761, -1447033158, -918110740, 543291867, -223414289, 1822005568, 1083211250, 668742830, -146878579, 1837825672, 606066044, -1522453735, 1099945765, 859329078, 1292441004, -1360846563, 781309617, -1533174409, -69162140, 606003121, -121717571, 419997936, -170191391, -1868467957, 1917894165, -533868549, 1049410431, -1411497752, -8709828, -1812326496, -889099562, 941752487, 1101485774, 1670177176, 2003286651, 1039133778, 295462193, 1592923180, 70505665, -1407822215, -1540201735, -62653300, 1634676014, 1303223681, 1823532793, 1272091111, -1600417416, 551117360, -136763688, 526677854, 586516385, -1315894033, -576674591, 1456528854, -1682609104, -1259798087, 842035770, -1894421553, 796101385, 1535933104, -1822905777, -1367741506, 1744255872, -529949447, 380107758, -584594589, -1689010602, -1018684856, 1052043142, 522720038, -2123334826, -311930535, -239233656, -477033208, 455087474, 1682628133, 1183932100, -1654943780, 1920727474, -106549097, -611938553, -311802601, 1956484323, -474994615, 485461787, 181724917, -2088870587, 1328728257, -1366405381, -559601546, 1418926791, -2104890267, 553657682, -1560434913, 570546737, -1692444421, -924504768, 2045573774, 236743720, -459564648, -93710157, 1040985671, -2047232414, 1525831737, 1812446501, 351745913, -479029491, 1449395768, 1849840465, 1242189348, -2011213205, 1703055889, 1379907204, 1828784713, 543287028, -1201626447, 537652587, 714004360, -786858700, -578232678, 1646810529, 1868634807, 1620761104, 1163819538, 474454250, -2115833613, 401111114, -1868708559, 1878919675, -981850713, -277632014, -1666913290, -1997101072, 1675119427, -648880667, 1196219628, -1298852878, -1989754236, 238671268, 1998206292, 1743792847, 1006886509, -644958889, -943300010, 842348264, 1905696811, -1831380502, -1990787173, 1852996492, -1311383214, 1901466065, 1748058849, -1976214714, 1905968420, 1397751135, -2003358458, 1858952736, -39068333, -1817168654, -359014135, -2076523291, 1153557843, -949112204, -1039343701, 729809930, 106286877, -1752441199, 5.9536e-10)"
                end
            end        
        end
    end
    proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
    return proxy.PROXY_SEND_QUERY
end

function insertplaintextfp_handler(query)

    for i=1,2000,1 do
        modifiedquery = "insert into plaintextfps values(" .. i .. ", 54, 51, 50, 51, 50, 58, 53, 65, 62, 77, 79, 85, 99, 70, 61, 81)"
        if (i == 2000) then
            proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                    
        else
            proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                    
        end            
    end

    return proxy.PROXY_SEND_QUERY
end

function size_handler(query)
    -- first check if syntax, number of columns, etc are correct
    
    modifiedquery = "SELECT table_schema as `Database`, table_name AS `Table`, round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` FROM information_schema.TABLES ORDER BY (data_length + index_length) DESC"
    proxy.queries:append(4, string.char(proxy.COM_QUERY) .. modifiedquery);
    return proxy.PROXY_SEND_QUERY
    
end

function drop_handler(query)
    for i=0,15,1
        do
        modifiedquery = "drop table ciphertext_bit" .. i

        -- print("modifiedquery = " .. modifiedquery)
        -- TODO: fix 15
        if i == 15 then
            proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
        else
            proxy.queries:append(2, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
        end
    end            

    return proxy.PROXY_SEND_QUERY
end

-- asssumes the first field given in where clause is id, and the second is integerorder
function select_handler(query)
    local array = {}
    for capture in string.gmatch(query, "%d+") do
        table.insert(array, capture)
    end

    id = array[1]
    print("user id the user input = " .. id)
    integerorder = array[2]

    for i=0,15,1
        do
        modifiedquery = "select * from ciphertext_bit" .. i .. " where fpnumber = " .. id .. " and integerorder = " .. integerorder 

        -- print("modifiedquery = " .. modifiedquery)
        proxy.queries:append((i+5), string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true})
    end    

    -- for i=0,15,1
    --     do
    --     modifiedquery = "drop table ciphertext_bit" .. i

    --     print("modifiedquery = " .. modifiedquery)
    --     proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery);
    -- end            
    -- print("queries length = " .. proxy.queries:len())

    return proxy.PROXY_SEND_QUERY
end


function test_handler(query)
   
    modifiedquery = "select * from ciphertext_bit0" 

    -- print("modifiedquery = " .. modifiedquery)
    proxy.queries:append(21, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true})
       

    -- for i=0,15,1
    --     do
    --     modifiedquery = "drop table ciphertext_bit" .. i

    --     print("modifiedquery = " .. modifiedquery)
    --     proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery);
    -- end            
    -- print("queries length = " .. proxy.queries:len())

    return proxy.PROXY_SEND_QUERY
end

function compare_handler(query)
   
    modifiedquery = "select comparison(fpnumber, integerorder, " 

    for i=0,499,1 do
        modifiedquery = modifiedquery .. i .. "th_a, "
    end
    modifiedquery = modifiedquery .. "b_, variance) from ciphertext_bit0"
    print("modifiedquery = " .. modifiedquery)
    -- for i=0,15,1
    --     do
    --     modifiedquery = "drop table ciphertext_bit" .. i

    --     print("modifiedquery = " .. modifiedquery)
    --     proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery);
    -- end            
    -- print("queries length = " .. proxy.queries:len())
    proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery)
    return proxy.PROXY_SEND_QUERY
end

function createudf_handler(query)
   
    modifiedquery = "drop function if exists metaphon" 
    proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true})
    modifiedquery = "drop function if exists avgcost" 
    proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true})
    modifiedquery = "drop function if exists comparison" 
    proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true})
    modifiedquery = "create function metaphon RETURNS STRING SONAME 'udf_example.so'" 
    -- print("modifiedquery = " .. modifiedquery)
    proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true})
    modifiedquery = "create function avgcost RETURNS REAL SONAME 'udf_example.so'" 
    proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true})
    modifiedquery = "create function comparison RETURNS INTEGER SONAME 'tfhe_udf.so'" 
    proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery)

    return proxy.PROXY_SEND_QUERY
end

function read_query(packet)
    -- print("packet = " .. packet)
    if packet:byte() == proxy.COM_QUERY then

    	-- print(mylib.HOMencrypt(1))
        query = packet:sub(2)
        print("we got a normal query: " .. query)

        -- creates a table to store encrypted values
        -- this ciphertext contains 500 integer columns to represent a array
        --  1 int column to represent b 1 double column to represent current_variance
        if query == "create table ciphertext" then
            print("creating a table ciphertext...")



            for i=0,15,1
                do
                modifiedquery = "create table ciphertext_bit" .. i .. " ("
                -- whose fingerprint vector this is
                modifiedquery = modifiedquery .. "fpnumber int, "

                -- which integer it is in the fingerprint vector
                modifiedquery = modifiedquery .. "integerorder int, "
                -- TODO: replace 500 with n
                for j = 0,499,1
                do
                    modifiedquery = modifiedquery .. tostring(j) .. "th_a int, "
                    if j == 499 then
                        modifiedquery = modifiedquery .. "b_ int, " .. "variance double)" 
                    
                    end
                end
                -- print("modifiedquery = " .. modifiedquery)
                -- TODO: fix 15
                if i == 15 then
                    proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                else
                    proxy.queries:append(1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                end
            end            

            return proxy.PROXY_SEND_QUERY
        
        elseif query == "create table plaintextfps" then
            modifiedquery = "create table plaintextfps(fpnumber int, 1thi int, 2thi int, 3thi int, 4thi int, 5thi int, 6thi int, 7thi int, 8thi int, 9thi int, 10thi int, 11thi int, 12thi int, 13thi int, 14thi int, 15thi int, 16thi int)"
            proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
            return proxy.PROXY_SEND_QUERY

        elseif query == "drop table ciphertext" then
            return drop_handler(query)
    

        -- syntax:
        -- insert into ciphertext values(int);
        -- int will be encrypted and stored into ciphertext_biti tables
        elseif string.starts(query, "insert into ciphertext ") then
            return insert_handler(query)    
        
        -- elseif (string.starts(query, "select ") and string.find(query, "from ciphertext"))then
        --     return select_handler(query)    

        elseif string.starts(query, "show tablesizes") then
            return size_handler(query)    

        elseif string.starts(query, "test readqueryresult") then
            return test_handler(query)   
            
        elseif string.starts(query, "insert fingerprints") then
            return insertfp_handler(query)

        elseif string.starts(query, "insert plaintextfps") then
            return insertplaintextfp_handler(query)

        -- compare two encrypted bits using UDF defined on the DBMS server
        elseif string.starts(query, "compare") then
            return compare_handler(query)

        elseif string.starts(query, "create udfs") then
            return createudf_handler(query)

        elseif string.starts(query, "select * from ciphertext where ") then
            return select_handler(query) 
        end
    end
end

function read_query_result(inj)

    -- --
    -- proxy.response.type = proxy.MYSQLD_PACKET_OK
    -- proxy.response.resultset = {
    --     fields = {
    --         { type = proxy.MYSQL_TYPE_INT24, name = "decrypted", },
    --     },
    --     rows = {
    --         { 0 }
    --     }
    -- }
    -- return proxy.PROXY_SEND_RESULT
    -- --


    -- print("read_query_result: " .. inj)
    originalquery = inj.query:sub(2)
    -- print("inj.id = " .. inj.id)
    -- if not string.starts(originalquery, "select * from ciphertext where ") then
    if inj.id <= 4 then
        -- print("inj.id = " .. inj.id)
        -- print("this was not a select query")
        -- print(originalquery)
        
        if inj.id == -1 then
            proxy.response.type = proxy.MYSQLD_PACKET_OK
            print("returning proxy_send_result")
            return proxy.PROXY_SEND_RESULT
        end
        -- proxy.response.type = proxy.MYSQLD_PACKET_OK
        -- return proxy.PROXY_SEND_RESULT
        return proxy.PROXY_IGNORE_RESULT
    end
    -- print("query-time: " .. (inj.query_time / 1000) .. "ms")
    -- print("response-time: " .. (inj.response_time / 1000) .. "ms")
    -- print("original request query = " .. originalquery)
    -- print("id = " .. inj.id)

    -- --delete any existing datatobedecrypted files
    -- --TODO: fix 0 and 15 to some expression that involves numberofbits
    -- for i=0,15,1 do
    --     os.remove("/home/taeyun/Desktop/mysqlproxy/datatobedecrypted" .. i .. ".txt")
    -- end
    file = io.open("/home/taeyun/Desktop/mysqlproxy/datatobedecrypted" .. (inj.id-5) .. ".txt", "w")
    for rows in inj.resultset.rows do
        --TODO: fix 502 to n+2
        for i = 3,504,1 do
            file:write(rows[i] .. "\n")
            -- print("injected query returned: " .. rows[i])
        end
    end
    file:close()
    decrypted = mylib.HOMdecrypt()
    -- for i,val in ipairs(decrypted) do
    --     print(i,val)
    -- end
    if (decrypted == nil) then
        return proxy.PROXY_IGNORE_RESULT
        -- print("decrypted value was nil")
        -- proxy.response.type = proxy.MYSQLD_PACKET_ERR
        -- proxy.response.errmsg = "decrypted value was nil"
    else
        print("decrypted value = " .. decrypted)

        --delete datatobedecrypted files that were created
        --TODO: fix 0 and 15 to some expression that involves numberofbits
        for i=0,15,1 do
            os.remove("/home/taeyun/Desktop/mysqlproxy/datatobedecrypted" .. i .. ".txt")
        end

        proxy.response.resultset = {
            fields = {
                { type = proxy.MYSQL_TYPE_INT24, name = "decrypted", },
            },
            rows = {
                { decrypted }
            }
        }
        proxy.response.type = proxy.MYSQLD_PACKET_OK
        -- return proxy.PROXY_SEND_RESULT
    end
    -- proxy.response.type = proxy.MYSQLD_PACKET_OK
    return proxy.PROXY_SEND_RESULT


end


-- function read_query(packet)
--     local status, err = pcall(read_query_real, packet)
--     if status then
--         return err
--     else
--         print("read_query: " .. err)
--         return proxy.PROXY_SEND_QUERY
--     end
-- end

-- function read_query_result(inj)
--     local status, err = pcall(read_query_result_real, inj)
--     if status then
--         return err
--     else
--         print("read_query_result: " .. err)
--         return proxy.PROXY_SEND_RESULT
--     end
-- end

-- --
-- -- Helper functions
-- --

-- RES_IGNORE   = 1
-- RES_DECRYPT  = 2

-- function dprint(x)
--     if os.getenv("CRYPTDB_PROXY_DEBUG") then
--         print(x)
--     end
-- end

-- function read_query_real(packet)
--     local query = string.sub(packet, 2)
--     print("read_query: " .. query)

--     if string.byte(packet) == proxy.COM_INIT_DB then
--         query = "USE " .. query
--     end

--     if string.byte(packet) == proxy.COM_INIT_DB or
--        string.byte(packet) == proxy.COM_QUERY then
--         status, error_msg, new_queries =
--             CryptDB.rewrite(proxy.connection.client.src.name, query,
--                             proxy.connection.server.thread_id)

--         if false == status then
--             proxy.response.type = proxy.MYSQLD_PACKET_ERR
--             proxy.response.errmsg = error_msg
--             return proxy.PROXY_SEND_RESULT
--         end

--         if table.maxn(new_queries) == 0 then
--             proxy.response.type = proxy.MYSQLD_PACKET_OK
--             return proxy.PROXY_SEND_RESULT
--         end

--         dprint(" ")
--         for i, v in pairs(new_queries) do
--             print("rewritten query[" .. i .. "]: " .. v)
--             local result_key
--             if i == table.maxn(new_queries) then
--                 result_key = RES_DECRYPT
--             else
--                 result_key = RES_IGNORE
--             end
--             proxy.queries:append(result_key,
--                                  string.char(proxy.COM_QUERY) .. v,
--                                  { resultset_is_needed = true })
--         end

--         return proxy.PROXY_SEND_QUERY
--     elseif string.byte(packet) == proxy.COM_QUIT then
--         -- do nothing
--     else
--         print("unexpected packet type " .. string.byte(packet))
--     end
-- end

-- function read_query_result_real(inj)
--     local client = proxy.connection.client.src.name

--     if inj.id == RES_IGNORE then
--         return proxy.PROXY_IGNORE_RESULT
--     elseif inj.id == RES_DECRYPT then
--         local resultset = inj.resultset

--         if resultset.query_status == proxy.MYSQLD_PACKET_ERR then
--             local err = proto.from_err_packet(resultset.raw)
--             proxy.response.type = proxy.MYSQLD_PACKET_ERR
--             proxy.response.errmsg = err.errmsg
--             proxy.response.errcode = err.errcode
--             proxy.response.sqlstate = err.sqlstate
--         else
--             local fields = {}
--             local rows = {}
--             local query = inj.query:sub(2)

--             -- mysqlproxy doesn't return real lua arrays, so re-package
--             local resfields = resultset.fields
--             for i = 1, #resfields do
--                 rfi = resfields[i]
--                 fields[i] = { type = resfields[i].type,
--                               name = resfields[i].name }
--             end

--             local resrows = resultset.rows
--             if resrows then
--                 for row in resrows do
--                     table.insert(rows, row)
--                 end
--             end

--             -- Handle the backend of the query.
--             status, rollbackd, error_msg, dfields, drows =
--                 CryptDB.envoi(client, fields, rows)

--             -- General error
--             if false == status then
--                 proxy.response.type = proxy.MYSQLD_PACKET_ERR
--                 proxy.response.errmsg = error_msg
--             -- Proxy had to force ROLLBACK
--             elseif true == rollbackd then
--                 proxy.response.type = proxy.MYSQLD_PACKET_ERR
--                 proxy.response.errmsg = "Proxy did ROLLBACK"
--                 -- ER_LOCK_DEADLOCK
--                 -- > error    = 1213
--                 -- > sqlstate = 40001
--                 proxy.response.errcode = 1213
--                 proxy.response.sqlstate = 40001
--             -- Results were successfully fetched for client
--             else
--                 proxy.response.type = proxy.MYSQLD_PACKET_OK
--                 proxy.response.affected_rows = resultset.affected_rows
--                 proxy.response.insert_id = resultset.insert_id
--                 if table.maxn(dfields) > 0 then
--                     proxy.response.resultset = { fields = dfields,
--                                                  rows = drows }
--                 end
--             end
--         end

--         return proxy.PROXY_SEND_RESULT
--     else
--         print("unexpected inj.id " .. inj.id)
--     end
-- end
