import path from "path";
import express from "express";
import http from "http";
import { Server } from "socket.io";
import fs from "fs";
import createPicoSocketClient from "./client.js";
import crypto from "crypto";

const getServerUrl = (req) => {
    if (process.env.SERVER_URL) {
        return `'${process.env.SERVER_URL}'`;
    }

    let defaultServerUrl = "'http://localhost:5000'";
    console.log(`SERVER_URL was not defined, so using ${defaultServerUrl}, note it will not work over the internet`);

	return defaultServerUrl;
};

const getOrCreateName = (req) => {
    if (req.query.name) {
        return req.query.name;
    }

    let colors = [
		"red", "teal", "orange", "magenta", "blue", "green", "purple", "pink", "black", "brown", "white", "yellow",
		"grey", "olive", "amber", "azure", "beige", "violet", "fuchsia", "gold", "silver"
	];

	let color = colors[Math.floor(Math.random() * colors.length)];
	let number = Math.floor(Math.random() * 10);

	return color + number;
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

    // host the static files
    app.use(express.static(path.join(process.cwd(), assetFilesPath)));
    app.use((req, res) => {
        // by default serve the modified html game file
        return res.send(modifiedTemplate
            .replace('CURRENT_PLAYER_NAME', getOrCreateName(req))
            .replace('SERVER_URL', getServerUrl())
        );
    });

    server.listen(PORT, () =>
        console.log(`Server Running http://localhost:${PORT}`)
    );

    return { app, server, io };
}

export default createPicoSocketServer;