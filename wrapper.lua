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

-- extractedfpvectors.txt has a format of fpnumber; intva
function insertfp_handler(query)
    fpfile = '/home/taeyun/Desktop/mysqlproxy/extractedfpvectors.txt'
    fplines = lines_from(fpfile)
    isfirstloop = 1
    modifiedquery = ''
    -- print all line numbers and their contents
    for k,v in pairs(fplines) do
        if (isfirstloop == 0) then
            if v == 'end'then
                proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                print("returning proxy_send_query")
                -- print("queue length = " .. proxy.queries.len)
                return proxy.PROXY_SEND_QUERY
            else
                print('appneding query with id 3')
                -- print('modifiedquery = ' .. modifiedquery)
                proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                -- return proxy.PROXY_SEND_QUERY
            end
        end
        isfirstloop = 0
        --TODO: change 17 to some kind of expression
        remainder = k % 17
        if remainder == 1 then
            fpnumber = v 
        elseif remainder == 0 then 
            integerorder = 15
        else
            integerorder = remainder - 2
        end
        if not (remainder == 1) then
            print('inside if not statement')
            print('k = ' .. k)
            mylib.HOMencrypt(v)
        
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
                modifiedquery = modifiedquery .. fpnumber .. ", "

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
                -- if i == 15 then
                --     proxy.queries:append(-1, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                -- else
                --     proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                -- end
                -- proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery, {resultset_is_needed = true});
                if not (i==15) then
                    proxy.queries:append(3, string.char(proxy.COM_QUERY) .. modifiedquery , {resultset_is_needed = true});
                end
            end  
            -- print('line[' .. k .. ']', v)
        end
        -- print("modifiedquery = " .. modifiedquery)
    end

    -- return proxy.PROXY_SEND_QUERY

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
