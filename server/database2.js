const sql = require("mssql");
const config = {
  user: 'sa',
  password: 'Password10',
  server: 'localhost\\SHTETQYTET', // You can use 'localhost\\instance' to connect t
  database: 'Toke_db',
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
}
// const pool =  new  sql.ConnectionPool(config).connect();
/* pool.on('error',err=>{
   console.log|(err);
 })*/
module.exports = {

  getPoints: async function getPoints(username) {
    // JSON.parse(loginData);
    return new Promise(function(resolve,reject){
    sql.connect(config).then(pool => {
      console.log("connected to db");
      // console.dir(result)
      query = "select points from users where username = @username2";

      // Stored procedure
      return pool.request()
                .input('username2',sql.VarChar,username)
                .query(query);
    }).then(result => {
      console.log(result.recordset);
      console.log(result.recordset[0]); 
      sql.close();// first recordset from result.recordsets
      resolve(result.recordset[0]);
     /*  socket.emit("LOGIN/loginData", JSON.stringify({
        'status': 0,
        'data': result.recordset[0]
      })); */

      

    }).catch(err => {
      sql.close();
      reject(err);

      // ... error checks
    })

    sql.on('error', err => {
      // ... error handler
      sql.close();
      reject(err)
      
    })
  });
  }
  

}