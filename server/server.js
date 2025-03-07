import path from "path";
import express from "express";
import session from "express-session";
import createMemoryStore from "memorystore";
import http from "http";
import { Server } from "socket.io";
import sharedsession from "express-socket.io-session"
import fs from "fs";
import createPicoSocketClient from "./client.js";

const maxPlayerNameLength = 8;

const getServerUrl = (port) => {
    let corsOrigins = getCORSOrigins(port);
    let serverUrl = `'${corsOrigins[0]}'`;

    console.log(`Using first cors origin as SERVER_URL: ${serverUrl}. Note local / private addresses do not work over the internet.`);

	return serverUrl;
};

const normalizePlayerName = (name) => {
    return name.substring(0, maxPlayerNameLength);
}

const injectPlayerIntoSession = (req) => {
    if (req.query.name) {
        let name = normalizePlayerName(req.query.name);
        req.session.name = name;
        return name;
    }

    let colors = [
		"red", "teal", "orange", "magenta", "blue", "green", "purple", "pink", "black", "brown", "white", "yellow",
		"grey", "olive", "amber", "azure", "beige", "violet", "fuchsia", "gold", "silver"
	];

	let color = colors[Math.floor(Math.random() * colors.length)];
	let number = Math.floor(Math.random() * 100);

	let name = normalizePlayerName(color + number);
    req.session.name = name;

    return name;
};

const getCORSOrigins = (serverPort) => {
    let corsOrigins = [];

    try {
      corsOrigins = fs.readFileSync('./allowed_origins.cfg', { encoding: 'utf8', flag: 'r' }).toString().split("\n")
        .map( line => { return line.replaceAll('PORT', serverPort); });
    } catch (err) {
      corsOrigins.push(`http://localhost:{serverPort}`);
    }

    return corsOrigins;
};

const createPicoSocketServer = ({
                                    assetFilesPath,
                                    htmlGameFilePath,
                                    workerFilePath,
                                }) => {
    // host on port 5000
    const PORT = process.env.PORT || 5000;

    // required "create the webserver" logic
    const app = express();
    const server = http.createServer(app);
    const io = new Server(server, {
      cors: {
        origin: getCORSOrigins(PORT),
      }
    });

    // read in the html file now, so we can append some script tags for the client side JS
    const htmlFileData = fs.readFileSync(htmlGameFilePath);
    const htmlFileTemplate = htmlFileData.toString();

    // build script tags to inject in the head of the document
    const clientSideCode = `
      <script src="/socket.io/socket.io.js"></script>
      <script defer>
        const createPicoSocketClient = ${createPicoSocketClient.toString()};
        createPicoSocketClient();
      </script>
    </head>
    `;

    // add the client side code
    const modifiedTemplate = htmlFileTemplate.replace("</head>", clientSideCode);

    const workerFileData = fs.readFileSync(workerFilePath);
    const workerFileTemplate = workerFileData.toString();
    let serverUrl = getServerUrl(PORT);
    const MemoryStore = createMemoryStore(session);
    let mysession = session({
        cookie: { maxAge: 86400000 },
        store: new MemoryStore({
            checkPeriod: 86400000
        }),
        secret: 'sid',
        resave: false,
        saveUninitialized: false,
    })

    app.use(mysession);

    io.use(
        sharedsession(mysession, {
            autoSave: true
        })
    );

    // host the static files
    app.use(['/public'], express.static(path.join(process.cwd(), assetFilesPath)));

    app.get("/", (req, res) => {
        let playerName = injectPlayerIntoSession(req);
        // by default serve the modified html game file
        res.send(modifiedTemplate.replace('CURRENT_PLAYER_NAME', playerName));
    });

    app.get(`/${workerFilePath}`, (req, res) => {
        res.setHeader('content-type', 'text/javascript');
        res.send(
            workerFileTemplate.replace('SERVER_URL', serverUrl)
                .replace('CURRENT_PLAYER_NAME', req.session.name)
        );
    });

    server.listen(PORT, () =>
        console.log(`Server Running on ${serverUrl}`)
    );

    return { app, server, io };
}

export default createPicoSocketServer;