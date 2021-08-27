/* Connector for MySQL Backend */

var mysql = require('mysql');
var con = null;

function createConnection(host, user, pass) {
  con = mysql.createConnection({
    host: host,
    user: user,
    password: pass
  });
}

function connect(err_function) {
  con.connect(err_function);
}

// Will generate a new question if there is none available, or will return existing question if there's still one pending an answer
function requestQuestion(callback, err) {
  connection.query('CALL request_question();', true, (error, results, fields) => {
    if (error) {
      err.call(error);
    } else {
      // Not even close to done
      console.log(results);
    }
  });
}

exports.createConnection = createConnection;
exports.connect = connect;
exports.requestQuestion = requestQuestion;
