while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

if [$name == ""]; then
    echo "Error: --name arg missing"
    exit 9999
fi
echo "
                                                                   
 ###### #    # #####  #####  ######  ####   ####          #  ####  
 #       #  #  #    # #    # #      #      #              # #      
 #####    ##   #    # #    # #####   ####   ####          #  ####  
 #        ##   #####  #####  #           #      #         #      # 
 #       #  #  #      #   #  #      #    # #    #    #    # #    # 
 ###### #    # #      #    # ######  ####   ####      ####   ####  

"

echo "Directory 👉 ${pwd}/${name}"

if [ -d "./${pwd}/${name}" ] 
then
    echo "Directory already exists." 
    exit 9999
else
    echo "Creating Directory ${name}"
fi

mkdir $name

cd ./$name

touch package.json

echo '
{
  "name": "'$name'",
  "version": "1.0.0",
  "description": "",
  "main": "./src/server.js",
  "scripts": {
    "dev" : "nodemon ./src/server.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
' >> package.json

echo "
Installing npm modules 🥳 .....

"

npm i express
npm i cors
npm i axios
npm i dotenv
npm i winston
npm i nodemon
npm i glob

mkdir src && cd ./src

touch server.js && touch .env

echo '/*  --------- Main Source File ------------ */

// Import libraries
const express = require("express");
const dotenv = require("dotenv");
const http = require("http");
dotenv.config();

// Util imports
const logger = require("./utils/logger.js");


const app = express();

// Middleware
// cors use for dev
// app.use(cors());
app.use(express.json());

// Routes Import
const routes = require("./routes/index.js")();

app.use(routes)

// PORT
const PORT = process.env.PORT || 9000;

// create http server
const server = http.createServer(app);

// Listener
server.listen(PORT, () => logger.info(`Listening on port ${PORT}`));
' >> server.js

mkdir routes && cd ./routes && touch index.js

echo '/*  ---------Routes importer ------------*/

// Import libraries
const glob = require("glob");
const Router = require("express").Router;

module.exports = () =>
  glob
    .sync("**/*.js", { cwd: `${__dirname}/` })
    .map((filename) => require(`./${filename}`))
    .filter((router) => Object.getPrototypeOf(router) == Router)
    .reduce((rootRouter, router) => rootRouter.use(router), Router({ mergeParams: true }));
' >> index.js

touch home.js

echo '/*  --------- Home Route ------------*/

// Import libraries
const express = require("express");
const router = express.Router();

// Util Imports
const logger = require("../utils/logger.js");

router.get("/", (req, res) => {
    logger.info("Home Route called");
    return res.status(200).send("Happy Hacking 🚀");
});

module.exports = router;
' >> home.js

cd .. && mkdir utils && mkdir static

cd utils && touch logger.js && mkdir logs

echo '/*  --------- Logger Util ------------*/

// Import Libraries
const winston = require("winston");
const util = require("util");

function transform(info, opts) {
  const args = info[Symbol.for("splat")];
  if (args) {
    info.message = util.format(info.message, ...args);
  }
  return info;
}

function utilFormatter() {
  return { transform };
}

const logger = winston.createLogger({
  level: "info",
  format: winston.format.combine(
    winston.format.timestamp({ format: "YYYY-MM-DD HH:mm:ss.SSS" }),
    utilFormatter(),
    winston.format.colorize(),
    winston.format.printf(({ message, label, timestamp }) => `${timestamp} ${message}`)
  ),
  defaultMeta: { service: "user-service" },
  transports: [
    //
    // - Write all logs with level `error` and below to `error.log`
    // - Write all logs with level `info` and below to `combined.log`
    //
    new winston.transports.File({ filename: "'$(pwd)'/logs/error.log", level: "error" }),
    new winston.transports.File({ filename: "'$(pwd)'/logs/combined.log" }),
  ],
});

if (process.env.NODE_ENV !== "production") {
  logger.add(
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.timestamp({ format: "YYYY-MM-DD HH:mm:ss.SSS" }),
        utilFormatter(),
        winston.format.colorize(),
        winston.format.printf(({ message, label, timestamp }) => `${timestamp} ${message}`)
      ),
    })
  );
}

module.exports = logger;
' >> logger.js

echo "
To start dev server 👇🏻

cd '$name' && npm run dev

"


echo "Happy Hacking 🚀"
