const TelegramBot = require("telegraf");
const Extra = require('telegraf/extra');
const Markup = require('telegraf/markup');
const TronWeb = require('tronweb');
const params = require('./settings').params;
const con = require('./connector');

/* Database Component */
con.createConnection(params.mysql_host, mysql_username, mysql_pass);

const bot = new TelegramBot(params.bot_key);
// Respond to control request
bot.on('callback_query', function(cbq) {
  console.log(cbq);
});

bot.start(function(ctx) {
  console.log(ctx.from);
  ctx.reply('Welcome to the Elementarius Telegram Interface');
});

con.connect(function(err) {
  if (err) throw err;
  console.log("Connected to Database!");
  bot.launch();
});

/* Telegram Bot Components */



// Request Trivia
bot.command('trivia', ctx => {

});
