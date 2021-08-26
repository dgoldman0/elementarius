const TelegramBot = require("telegraf");
const Extra = require('telegraf/extra');
const Markup = require('telegraf/markup');
const TronWeb = require('tronweb');

/* MYSQL Components */

var mysql = require('mysql');

var con = mysql.createConnection({
  host: "localhost",
  user: "yourusername",
  password: "yourpassword"
});

con.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
});

/* Telegram Bot Components */

const bot = new Telegraf('insert_bot_token_here');

//method for invoking start command

bot.command('start', ctx => {
    console.log(ctx.from);
    bot.telegram.sendMessage(ctx.chat.id, 'Welcome to the Elementarius Telegram Interface', {
    })
});

// Request Trivia
bot.command('trivia', ctx => {

});

// Respond to control request
bot.on('callback_query', function(cbq) {
});
