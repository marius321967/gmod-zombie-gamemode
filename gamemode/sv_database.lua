function db_query(sql)
	if (db_connection_successful == true) then
		local q = db_connection:query(sql)
		function q:onError(err, sql)
			print('Query failed: '..q:error())
		end
		q:start()
	end
end